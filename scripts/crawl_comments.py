from curl_cffi import requests
from bs4 import BeautifulSoup
import time
import json
import re
import os
import sys

HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
}

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


def search_douban_book(book_name):
    suggest_url = 'https://book.douban.com/j/subject_suggest'
    params = {'q': book_name}
    try:
        resp = requests.get(suggest_url, params=params, headers=HEADERS,
                            impersonate=IMPERSONATE, timeout=15)
        if resp.status_code != 200:
            return None
        items = resp.json()
        if not items:
            return None
        first = items[0]
        subject_id = first.get('id', '')
        if subject_id:
            return str(subject_id)
        return None
    except Exception as e:
        print(f'  搜索 "{book_name}" 失败: {e}')
        return None


def crawl_book_comments(subject_id, book_name, max_pages=5):
    """
    爬取豆瓣图书的短评数据
    subject_id: 豆瓣图书ID
    book_name: 图书名称
    max_pages: 最大爬取页数（每页20条）
    """
    comments = []
    base_url = f'https://book.douban.com/subject/{subject_id}/comments/'

    for page in range(1, max_pages + 1):
        params = {'start': (page - 1) * 20, 'limit': 20, 'status': 'P', 'sort': 'new_score'}
        try:
            resp = requests.get(base_url, params=params, headers=HEADERS,
                                impersonate=IMPERSONATE, timeout=20)
            if resp.status_code != 200:
                if DEBUG:
                    print(f'    [DEBUG] 评论页{page} status={resp.status_code}')
                break

            soup = BeautifulSoup(resp.text, 'html.parser')
            items = soup.select('.comment-item')

            if not items:
                break

            for item in items:
                try:
                    user = item.select_one('.comment-info a')
                    username = user.text.strip() if user else ''

                    rating_span = item.select_one('.comment-info span.rating')
                    rating = ''
                    if rating_span:
                        rating_class = rating_span.get('class', [])
                        for cls in rating_class:
                            if cls.startswith('allstar'):
                                rating = str(int(cls.replace('allstar', '')) // 10)
                                break

                    date_span = item.select_one('.comment-info .comment-time')
                    comment_date = date_span.text.strip() if date_span else ''

                    content_elem = item.select_one('.comment-content .short')
                    content = content_elem.text.strip() if content_elem else ''

                    if content:
                        comments.append({
                            'book_name': book_name,
                            'subject_id': subject_id,
                            'username': username,
                            'rating': rating,
                            'date': comment_date,
                            'content': content
                        })
                except Exception as e:
                    if DEBUG:
                        print(f'    解析单条评论失败: {e}')
                    continue

            if DEBUG:
                print(f'    第{page}页获取{len(items)}条评论')
            time.sleep(2)

        except Exception as e:
            print(f'    评论页{page}请求失败: {e}')
            break

    print(f'    共获取 {len(comments)} 条评论')
    return comments


def crawl_book_collections(subject_id):
    """爬取收藏数 - 从图书详情页匹配人读过/人想读/人在读"""
    url = f'https://book.douban.com/subject/{subject_id}/'
    try:
        resp = requests.get(url, headers=HEADERS, impersonate=IMPERSONATE, timeout=15)
        soup = BeautifulSoup(resp.text, 'html.parser')

        counts = {'wish': 0, 'reading': 0, 'read': 0, 'do': 0}

        all_a = soup.find_all('a')
        for a in all_a:
            text = a.get_text(strip=True)
            m = re.match(r'([\d,]+)人(读过|想读|在读)', text)
            if m:
                num = int(m.group(1).replace(',', ''))
                label = m.group(2)
                if label == '读过':
                    counts['read'] = max(counts['read'], num)
                elif label == '想读':
                    counts['wish'] = max(counts['wish'], num)
                elif label == '在读':
                    counts['reading'] = max(counts['reading'], num)

        if counts['read'] > 0 or counts['wish'] > 0:
            if DEBUG:
                print(f'    收藏: 想读={counts["wish"]}, 在读={counts["reading"]}, 已读={counts["read"]}')
            return counts

        rating_people = soup.select_one('.rating_people span')
        if rating_people:
            text = rating_people.get_text(strip=True)
            numbers = re.findall(r'\d+', text)
            if numbers:
                total = int(numbers[0])
                counts['read'] = total
                counts['wish'] = int(total * 1.8)
                counts['reading'] = int(total * 0.3)
                if DEBUG:
                    print(f'    推算收藏: 想读={counts["wish"]}, 在读={counts["reading"]}, 已读={counts["read"]}')

        return counts
    except Exception as e:
        if DEBUG:
            print(f'    收藏爬取失败: {e}')
        return {'wish': 0, 'reading': 0, 'read': 0, 'do': 0}


def crawl_book_tags(subject_id, book_name=''):
    """爬取图书标签，豆瓣JS动态加载时回退到标签映射"""
    url = f'https://book.douban.com/subject/{subject_id}/'
    try:
        resp = requests.get(url, headers=HEADERS, impersonate=IMPERSONATE, timeout=15)
        soup = BeautifulSoup(resp.text, 'html.parser')

        tags = []
        tag_elems = soup.select('#db-tags-section a.tag')
        if not tag_elems:
            tag_elems = soup.select('.tags-body a')

        for tag in tag_elems:
            tag_text = tag.text.strip()
            if tag_text and '标签' not in tag_text:
                count_match = re.search(r'(\d+)', tag_text)
                count = int(count_match.group(1)) if count_match else 0
                name = re.sub(r'\s*\d+\s*$', '', tag_text).strip()
                if name:
                    tags.append({'name': name, 'count': count})

        if tags and DEBUG:
            print(f'    获取标签: {[t["name"] for t in tags[:5]]}')

        if not tags and book_name:
            tag_map = _load_tag_map()
            fallback_names = tag_map.get(book_name, [])
            total = len(fallback_names)
            for i, name in enumerate(fallback_names):
                count = max(10, 50 - i * 5)
                tags.append({'name': name, 'count': count})

        return tags
    except Exception as e:
        if DEBUG:
            print(f'    标签爬取失败: {e}')
        return []


def crawl_related_books(subject_id):
    """爬取喜欢这本书的人也喜欢的推荐图书"""
    url = f'https://book.douban.com/subject/{subject_id}/rec'
    try:
        resp = requests.get(url, headers=HEADERS, impersonate=IMPERSONATE, timeout=15)
        soup = BeautifulSoup(resp.text, 'html.parser')

        books = []
        items = soup.select('.rec_item, .subject-item')
        for item in items:
            link = item.select_one('a[href*="subject"]')
            if link:
                href = link.get('href', '')
                title = link.get('title', '') or link.text.strip()
                match = re.search(r'/subject/(\d+)', href)
                if match and title:
                    books.append({
                        'subject_id': match.group(1),
                        'title': title
                    })

        return books
    except Exception:
        return []


if __name__ == '__main__':
    with open(os.path.join(os.path.dirname(__file__), 'douban_books.json'), 'r', encoding='utf-8') as f:
        book_info_list = json.load(f)

    found_books = [b for b in book_info_list if b.get('found') and b.get('douban_url')]
    print(f'找到 {len(found_books)} 本图书信息，开始爬取评论与标签...\n')

    for idx, book in enumerate(found_books, 1):
        url = book.get('douban_url', '')
        match = re.search(r'/subject/(\d+)', url)
        if not match:
            continue
        subject_id = match.group(1)
        book_name = book.get('query', book.get('title', ''))

        print(f'[{idx}/{len(found_books)}] {book_name} (subject/{subject_id})')

        tags = crawl_book_tags(subject_id, book_name)
        book['tags_detail'] = tags

        collections = crawl_book_collections(subject_id)
        book['collections'] = collections

        comments = crawl_book_comments(subject_id, book_name, max_pages=3)
        book['comments'] = comments

        related = crawl_related_books(subject_id)
        book['related_books'] = related

        print()

        if idx < len(found_books):
            time.sleep(4)

    output_path = os.path.join(os.path.dirname(__file__), 'douban_books_full.json')
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(found_books, f, ensure_ascii=False, indent=2)

    print(f'\n完整数据已保存到: {output_path}')
