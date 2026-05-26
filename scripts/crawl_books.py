from curl_cffi import requests
from bs4 import BeautifulSoup
import time
import json
import re
import os
import sys

HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
}

BOOKS = [
    '呐喊', '彷徨', '射雕英雄传', '神雕侠侣', '活着',
    '许三观卖血记', '深度学习', '机器学习', '人类简史', '未来简史',
    '围城', '边城', '骆驼祥子', '家', '雷雨',
    '倾城之恋', '朝花夕拾', '背影', '我与地坛', '文化苦旅',
    '目送', '雅舍小品', '唐诗三百首', '宋词三百首', '飞鸟集',
    '新月诗选', '海子诗全集', '艾青诗选', '时间简史', '上帝掷骰子吗',
    '从一到无穷大', '自私的基因', '万物简史', '枪炮、病菌与钢铁',
    '算法导论', '计算机程序设计艺术', '深入理解计算机系统', '编译原理',
    '计算机网络', '数据库系统概念', '苏菲的世界', '中国哲学简史',
    '理想国', '存在与时间', '沉思录', '道德经', '模式识别与机器学习',
    '强化学习', '自然语言处理', '计算机视觉', '万历十五年', '全球通史',
    '国史大纲', '明朝那些事儿',
]

IMPERSONATE = 'chrome120'
DEBUG = '--debug' in sys.argv

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
TAG_MAP_PATH = os.path.join(SCRIPT_DIR, 'book_tags_map.json')
_tag_map_cache = None


def _load_tag_map():
    global _tag_map_cache
    if _tag_map_cache is None:
        try:
            with open(TAG_MAP_PATH, 'r', encoding='utf-8') as f:
                _tag_map_cache = json.load(f)
        except Exception:
            _tag_map_cache = {}
    return _tag_map_cache


def _get_fallback_tags(book_name):
    tag_map = _load_tag_map()
    return tag_map.get(book_name, [])


def search_douban_book(book_name):
    """先用 JSON suggest API 快速搜到豆瓣 subject ID，再返回详情页 URL"""
    suggest_url = 'https://book.douban.com/j/subject_suggest'
    params = {'q': book_name}

    try:
        resp = requests.get(suggest_url, params=params, headers=HEADERS,
                            impersonate=IMPERSONATE, timeout=15)
        if resp.status_code != 200:
            if DEBUG:
                print(f'  [DEBUG] suggest API status={resp.status_code}')
            return None

        items = resp.json()
        if not items:
            if DEBUG:
                print(f'  [DEBUG] suggest API returned empty list')
            return None

        first = items[0]
        subject_url = first.get('url', '')
        if subject_url:
            return subject_url

        subject_id = first.get('id', '')
        if subject_id:
            return f'https://book.douban.com/subject/{subject_id}/'

        return None

    except Exception as e:
        print(f'  搜索 "{book_name}" 失败: {e}')
        if DEBUG:
            import traceback
            traceback.print_exc()
        return None


def parse_douban_detail(url):
    """解析豆瓣图书详情页"""
    try:
        resp = requests.get(url, headers=HEADERS, impersonate=IMPERSONATE, timeout=20)
        resp.encoding = 'utf-8'

        if resp.status_code != 200:
            if DEBUG:
                print(f'  [DEBUG] 详情页 status={resp.status_code}')
            return {}

        soup = BeautifulSoup(resp.text, 'html.parser')
        wrapper = soup.select_one('#wrapper')
        if not wrapper:
            if DEBUG:
                print(f'  [DEBUG] wrapper not found, html length={len(resp.text)}')
            return {}

        info = {}

        title_elem = (wrapper.select_one('h1 span[property="v:itemreviewed"]')
                      or soup.select_one('h1 span[property="v:itemreviewed"]'))
        info['title'] = title_elem.text.strip() if title_elem else ''

        rating_elem = (wrapper.select_one('strong.rating_num')
                       or soup.select_one('strong.rating_num'))
        info['rating'] = float(rating_elem.text.strip()) if rating_elem else 0.0

        rating_count = (wrapper.select_one('span[property="v:votes"]')
                        or soup.select_one('span[property="v:votes"]')
                        or wrapper.select_one('a.rating_people span'))
        if rating_count:
            count_text = rating_count.text.strip()
            info['rating_count'] = int(re.sub(r'\D', '', count_text)) if count_text else 0
        else:
            info['rating_count'] = 0

        cover = (wrapper.select_one('#mainpic a.nbg img')
                 or wrapper.select_one('#mainpic img')
                 or soup.select_one('a.nbg img'))
        info['cover_url'] = cover.get('src', '') if cover else ''

        info_text = wrapper.select_one('#info') or soup.select_one('#info')
        if info_text:
            text = info_text.get_text('\n', strip=True)
            for label, field in [('作者', 'author'), ('出版社', 'publisher'),
                                 ('出版年', 'pub_date'), ('定价', 'price'),
                                 ('ISBN', 'isbn')]:
                match = re.search(rf'{label}[:\s]*\n?(.+)', text)
                info[field] = match.group(1).strip() if match else ''

        intro_selectors = ['#link-report .intro', 'div.intro',
                           '.related_info .intro', '[property="v:description"]']
        intro = None
        for sel in intro_selectors:
            intro = wrapper.select_one(sel)
            if intro:
                break
        if not intro:
            intro = soup.select_one('.intro')
        info['intro'] = intro.get_text(strip=True)[:500] if intro else ''

        tag_selectors = ['.indent .tag-info-wrapper a.tag',
                         '.gaia .tag a', 'a.tag']
        tags = []
        for sel in tag_selectors:
            tags = [t.text.strip() for t in wrapper.select(sel)]
            if tags:
                break
        info['tags'] = tags[:8]

        return info

    except Exception as e:
        print(f'  解析详情页失败: {e}')
        if DEBUG:
            import traceback
            traceback.print_exc()
        return {}


def crawl_all_books():
    results = []
    total = len(BOOKS)

    print(f'开始爬取 {total} 本书的豆瓣数据...')
    print(f'调试模式: {"开启" if DEBUG else "关闭"} (加 --debug 开启)')
    print(f'TLS 模拟: {IMPERSONATE}\n')

    for idx, book_name in enumerate(BOOKS, 1):
        print(f'[{idx}/{total}] {book_name}')

        detail_url = search_douban_book(book_name)

        if not detail_url:
            print(f'  [FAIL] 未找到')
            results.append({'query': book_name, 'found': False})
            continue

        print(f'  -> {detail_url}')
        info = parse_douban_detail(detail_url)

        if info:
            info['query'] = book_name
            info['douban_url'] = detail_url
            info['found'] = True
            if not info.get('tags'):
                info['tags'] = _get_fallback_tags(book_name)
            results.append(info)
            print(f'  [OK] {info.get("title","")} | 评分: {info.get("rating","N/A")} | {info.get("author","")}')
        else:
            print(f'  [FAIL] 解析失败')
            results.append({'query': book_name, 'found': False, 'douban_url': detail_url})

        if idx < total:
            time.sleep(3)

    return results


def save_results(results):
    output_dir = os.path.dirname(os.path.abspath(__file__))
    json_path = os.path.join(output_dir, 'douban_books.json')
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=2)

    csv_path = os.path.join(output_dir, 'douban_books.csv')
    with open(csv_path, 'w', encoding='utf-8-sig') as f:
        f.write('查询书名,豆瓣标题,作者,出版社,出版日期,定价,ISBN,评分,评分人数,标签,封面URL,豆瓣URL\n')
        for r in results:
            if r.get('found'):
                tags_str = '/'.join(r.get('tags', []))
                f.write(f'"{r.get("query","")}","{r.get("title","")}","{r.get("author","")}",'
                        f'"{r.get("publisher","")}","{r.get("pub_date","")}","{r.get("price","")}",'
                        f'"{r.get("isbn","")}",{r.get("rating",0)},{r.get("rating_count",0)},'
                        f'"{tags_str}","{r.get("cover_url","")}","{r.get("douban_url","")}"\n')
            else:
                f.write(f'"{r.get("query","")}",未找到,,,,,,,,\n')

    found_count = sum(1 for r in results if r.get('found'))
    print(f'\n{"=" * 50}')
    print(f'完成! 共找到 {found_count}/{len(results)} 本书')
    print(f'JSON: {json_path}')
    print(f'CSV:  {csv_path}')


if __name__ == '__main__':
    results = crawl_all_books()
    save_results(results)
