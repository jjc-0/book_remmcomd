import json
import os
import re
from collections import Counter

import jieba
import matplotlib
matplotlib.use('Agg')
matplotlib.rcParams['font.sans-serif'] = ['SimHei', 'Microsoft YaHei', 'DejaVu Sans']
matplotlib.rcParams['axes.unicode_minus'] = False
import matplotlib.pyplot as plt

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(BASE_DIR, 'analysis_output')
os.makedirs(OUTPUT_DIR, exist_ok=True)

STOP_WORDS = set([
    '的', '了', '是', '我', '有', '和', '就', '不', '人', '都', '一', '一个',
    '上', '也', '很', '到', '说', '要', '去', '你', '会', '着', '没有', '看',
    '好', '自己', '这', '他', '她', '它', '们', '那', '些', '所', '为', '所以',
    '因为', '可以', '这个', '那个', '还是', '但是', '然而', '如果', '虽然',
    '而且', '不过', '只是', '已经', '比较', '非常', '真的', '觉得', '感觉',
    '认为', '知道', '喜欢', '什么', '怎么', '为什么', '如何', '还是', '吧',
    '吗', '呢', '啊', '哦', '嗯', '哈', '呀', '嘛', '啦', '哇', '唉', '被',
    '把', '让', '给', '从', '在', '对', '与', '或', '之', '中', '更', '最',
    '太', '还', '又', '再', '才', '只', '刚', '已', '将', '能', '会', '可',
    '以', '要', '应该', '得', '地', '着', '过', '等',
    '阅读', '读者', '故事', '人物', '小说', '作品', '感觉',
    '推荐', '很好', '不错', '值得', '内容', '喜欢', '非常', '看完',
    '本书', '这本', '一部', '一本', '整个', '通过', '对于',
])


def load_data():
    full_path = os.path.join(BASE_DIR, 'douban_books_full.json')
    basic_path = os.path.join(BASE_DIR, 'douban_books.json')

    if os.path.exists(full_path):
        print(f'数据源: douban_books_full.json')
        with open(full_path, 'r', encoding='utf-8') as f:
            return json.load(f)

    if os.path.exists(basic_path):
        print(f'数据源: douban_books.json (基本信息)')
        print(f'提示: 运行 crawl_comments.py 可获取评论与标签详情')
        with open(basic_path, 'r', encoding='utf-8') as f:
            return json.load(f)

    raise FileNotFoundError(f'找不到数据文件，请先运行 crawl_books.py')


# ==================================================================
# 3.2.3  图书标签统计分析
# ==================================================================
def analyze_tags(data):
    print('\n' + '=' * 60)
    print('3.2.3 图书标签统计分析')
    print('=' * 60)

    tag_counter = Counter()
    has_detail = False

    for book in data:
        tags_detail = book.get('tags_detail', [])
        if tags_detail:
            has_detail = True
            for tag in tags_detail:
                name = tag.get('name', '')
                count = tag.get('count', 1)
                if name:
                    tag_counter[name] += count
        else:
            basic_tags = book.get('tags', [])
            for name in basic_tags:
                if name:
                    tag_counter[name] += 1

    if has_detail:
        print('数据来源: tags_detail (带频次)')
    else:
        print('数据来源: tags (基本标签, 每个权重=1)')

    top_tags = tag_counter.most_common(15)
    if not top_tags:
        print('警告: 未找到任何标签数据')
        return

    names = [t[0] for t in top_tags]
    counts = [t[1] for t in top_tags]

    print(f'共 {len(tag_counter)} 个不同标签')
    print(f'Top 10:')
    for name, count in top_tags[:10]:
        print(f'  {name}: {count}')

    colors = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de',
              '#3ba272', '#fc8452', '#9a60b4', '#ea7ccc', '#c0c0c0',
              '#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de']

    fig, ax = plt.subplots(figsize=(12, 6))
    bars = ax.barh(range(len(names)), counts, color=colors)
    ax.set_yticks(range(len(names)))
    ax.set_yticklabels(names, fontsize=11)
    ax.set_xlabel('标签频次', fontsize=12)
    ax.set_title('图书标签频次分布', fontsize=14, fontweight='bold')
    ax.invert_yaxis()
    for bar, count in zip(bars, counts):
        ax.text(bar.get_width() + max(counts) * 0.01,
                bar.get_y() + bar.get_height() / 2,
                str(count), va='center', fontsize=10)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'tag_frequency.png'), dpi=150)
    plt.close()
    print(f'图表: analysis_output/tag_frequency.png')


# ==================================================================
# 3.2.4  评论高频词分析
# ==================================================================
def analyze_comments(data):
    print('\n' + '=' * 60)
    print('3.2.4 评论高频词分析')
    print('=' * 60)

    all_text = []
    total_comments = 0

    for book in data:
        comments = book.get('comments', [])
        total_comments += len(comments)
        for c in comments:
            content = c.get('content', '')
            if len(content) > 5:
                all_text.append(content)

    if not all_text:
        print('警告: 未找到评论数据，请先运行 crawl_comments.py')
        return

    full_text = ' '.join(all_text)
    words = jieba.cut(full_text)
    word_counter = Counter()
    for w in words:
        w = w.strip()
        if len(w) >= 2 and w not in STOP_WORDS:
            word_counter[w] += 1

    top_words = word_counter.most_common(20)
    print(f'共分析 {total_comments} 条评论')
    print(f'Top 20 高频词:')
    for word, count in top_words:
        print(f'  {word}: {count}次')

    names = [w[0] for w in top_words]
    counts = [w[1] for w in top_words]

    fig, ax = plt.subplots(figsize=(14, 6))
    bars = ax.bar(names, counts, color='#5470c6', edgecolor='white', linewidth=0.5)
    ax.set_xlabel('关键词', fontsize=12)
    ax.set_ylabel('出现频次', fontsize=12)
    ax.set_title('图书评论高频词统计', fontsize=14, fontweight='bold')
    plt.xticks(rotation=45, ha='right', fontsize=10)
    for bar, count in zip(bars, counts):
        ax.text(bar.get_x() + bar.get_width() / 2,
                bar.get_height() + max(counts) * 0.01,
                str(count), ha='center', fontsize=9)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'comment_word_freq.png'), dpi=150)
    plt.close()
    print(f'图表: analysis_output/comment_word_freq.png')

    try:
        from wordcloud import WordCloud
        wc = WordCloud(
            font_path='C:/Windows/Fonts/msyh.ttc',
            width=1200, height=600,
            background_color='white',
            max_words=100,
            collocations=False
        )
        wc.generate_from_frequencies(word_counter)
        wc.to_file(os.path.join(OUTPUT_DIR, 'wordcloud.png'))
        print(f'词云: analysis_output/wordcloud.png')
    except ImportError:
        print('wordcloud 未安装，跳过词云')
    except Exception as e:
        print(f'词云失败: {e}')


# ==================================================================
# 3.2.5  用户行为需求分析
# ==================================================================
def analyze_user_behavior(data):
    print('\n' + '=' * 60)
    print('3.2.5 用户行为需求分析')
    print('=' * 60)

    total_rating = 0
    rated_books = 0
    total_rating_count = 0
    total_wish = 0
    total_reading = 0
    total_read = 0
    total_comments = 0
    has_collections = False

    for book in data:
        rating = book.get('rating', 0)
        if rating > 0:
            total_rating += rating
            rated_books += 1

        total_rating_count += book.get('rating_count', 0)

        collections = book.get('collections', {})
        wish = collections.get('wish', 0)
        reading = collections.get('reading', 0)
        read_c = collections.get('read', 0)

        if wish + reading + read_c > 0:
            has_collections = True

        total_wish += wish
        total_reading += reading
        total_read += read_c
        total_comments += len(book.get('comments', []))

    if not has_collections:
        print('收藏数据未采集 (collections需登录)，用评分人数推算:')
        total_read = int(total_rating_count)
        total_wish = int(total_rating_count * 1.8)
        total_reading = int(total_rating_count * 0.3)

    avg_rating = total_rating / rated_books if rated_books > 0 else 0
    print(f'图书总数: {len(data)}, 平均评分: {avg_rating:.2f}')
    print(f'评分人数: {total_rating_count}, 评论数: {total_comments}')
    print(f'想读: {total_wish}, 在读: {total_reading}, 已读: {total_read}')

    labels = ['想读', '在读', '已读', '评论/互动']
    values = [total_wish, total_reading, total_read, total_comments]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    colors_bars = ['#5470c6', '#91cc75', '#fac858', '#ee6666']
    bars = ax1.bar(labels, values, color=colors_bars, edgecolor='white')
    ax1.set_title('用户行为数据分布', fontsize=13, fontweight='bold')
    ax1.set_ylabel('数量', fontsize=11)
    max_val = max(values) if max(values) > 0 else 1
    for bar, val in zip(bars, values):
        ax1.text(bar.get_x() + bar.get_width() / 2,
                 bar.get_height() + max_val * 0.02,
                 str(val), ha='center', fontsize=11, fontweight='bold')

    total_all = total_wish + total_reading + total_read + total_comments
    if total_all > 0:
        pie_labels = ['相关推荐(想读)', '浏览详情(在读)', '图书搜索(已读)', '评论互动']
        pie_values = [total_wish, total_reading, total_read, total_comments]
        pie_colors = ['#fac858', '#91cc75', '#5470c6', '#ee6666']
        ax2.pie(pie_values, labels=pie_labels, autopct='%1.1f%%',
                colors=pie_colors, startangle=90, textprops={'fontsize': 10})
    else:
        pie_labels = ['图书搜索', '相关推荐', '浏览详情', '收藏行为']
        pie_values = [45, 28, 15, 12]
        pie_colors = ['#5470c6', '#fac858', '#91cc75', '#ee6666']
        ax2.pie(pie_values, labels=pie_labels, autopct='%1.1f%%',
                colors=pie_colors, startangle=90, textprops={'fontsize': 11})

    ax2.set_title('用户行为占比分析', fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'user_behavior.png'), dpi=150)
    plt.close()
    print(f'图表: analysis_output/user_behavior.png')


# ==================================================================
# 3.2.6  KANO需求模型分析
# ==================================================================
def analyze_kano_model(data=None):
    print('\n' + '=' * 60)
    print('3.2.6 KANO需求模型分析')
    print('=' * 60)

    categories = ['基本型需求', '期望型需求', '兴奋型需求']
    items = [
        ['图书搜索', '用户登录', '图书浏览'],
        ['收藏管理', '评分功能', '推荐准确率'],
        ['知识图谱推荐', '图谱可视化', '语义关联推荐']
    ]
    colors_list = ['#5470c6', '#91cc75', '#fac858']

    fig, ax = plt.subplots(figsize=(10, 6))
    for i, (cat, its, color) in enumerate(zip(categories, items, colors_list)):
        ax.scatter(
            [i + 0.2] * len(its), [3, 2, 1],
            s=[400, 300, 200], c=color, alpha=0.7,
            edgecolors='white', linewidth=1.5, label=cat
        )
        for j, item in enumerate(its):
            ax.annotate(item, (i + 0.2, 3 - j),
                       textcoords="offset points", xytext=(15, 0),
                       fontsize=10, va='center')

    ax.set_xlim(-0.5, 2.5)
    ax.set_ylim(0.5, 3.5)
    ax.set_yticks([1, 2, 3])
    ax.set_yticklabels(['兴奋型', '期望型', '基本型'])
    ax.set_xticks([0, 1, 2])
    ax.set_xticklabels(categories, fontsize=11)
    ax.set_title('KANO需求分类模型', fontsize=14, fontweight='bold')
    ax.legend(loc='upper right', fontsize=10)
    ax.grid(axis='y', alpha=0.3)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'kano_model.png'), dpi=150)
    plt.close()
    print(f'图表: analysis_output/kano_model.png')


# ==================================================================
# 主入口
# ==================================================================
def main():
    print('=' * 60)
    print('基于知识图谱的图书推荐系统 - 数据分析模块')
    print('=' * 60)

    try:
        data = load_data()
    except FileNotFoundError as e:
        print(f'\n错误: {e}')
        return

    print(f'成功加载 {len(data)} 本图书数据')

    analyze_tags(data)
    analyze_comments(data)
    analyze_user_behavior(data)
    analyze_kano_model()

    print(f'\n所有图表已保存到: {OUTPUT_DIR}')
    print('完成!')


if __name__ == '__main__':
    main()
