/*
 基于知识图谱的图书推荐系统 - 数据库脚本
 Source Schema         : pro_mall
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for address
-- ----------------------------
DROP TABLE IF EXISTS `address`;
CREATE TABLE `address` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '联系人',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '具体地址',
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '电话',
  `user_id` int DEFAULT NULL COMMENT '用户id',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='地址管理';

-- ----------------------------
-- Records of address
-- ----------------------------
BEGIN;
INSERT INTO `address` (`id`, `name`, `address`, `phone`, `user_id`) VALUES (2, '王兰花', 'xxxx地址', '18888888888', 1);
INSERT INTO `address` (`id`, `name`, `address`, `phone`, `user_id`) VALUES (3, '陈寻', '天津市滨海新区第二大街62号伊势丹百货(滨海店)B2', '17688888888', 2);
INSERT INTO `address` (`id`, `name`, `address`, `phone`, `user_id`) VALUES (4, '牛仔蓝', '邢台市清河县葛仙庄镇长城大街西头与外环路交叉口新奥加油站北邻', '16577778888', 2);
INSERT INTO `address` (`id`, `name`, `address`, `phone`, `user_id`) VALUES (5, '小溪', 'xxxxxxxxx', '1679998778', 3);
COMMIT;

-- ----------------------------
-- Table structure for banner
-- ----------------------------
DROP TABLE IF EXISTS `banner`;
CREATE TABLE `banner` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '标题',
  `info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '说明',
  `img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '封面',
  `book_id` int DEFAULT NULL COMMENT '图书id',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='轮播图管理';

-- ----------------------------
-- Records of banner
-- ----------------------------
BEGIN;
INSERT INTO `banner` (`id`, `name`, `info`, `img`, `book_id`) VALUES (1, '探索知识，启迪智慧', '基于知识图谱的智能图书推荐，发现你的下一本好书', 'http://127.0.0.1:9090/web/download/1.png', 1);
INSERT INTO `banner` (`id`, `name`, `info`, `img`, `book_id`) VALUES (2, '好书推荐，开启智慧之旅', '知识图谱关联分析，精准匹配你的阅读偏好', 'http://127.0.0.1:9090/web/download/2.png', 5);
COMMIT;

-- ----------------------------
-- Table structure for book
-- ----------------------------
DROP TABLE IF EXISTS `book`;
CREATE TABLE `book` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '图书ID',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '书名',
  `author` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '作者',
  `publisher` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '出版社',
  `publish_date` date DEFAULT NULL COMMENT '出版日期',
  `isbn` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'ISBN编号',
  `price` decimal(10,2) DEFAULT NULL COMMENT '价格',
  `category_id` int DEFAULT NULL COMMENT '分类ID',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '图书简介',
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '图书详情',
  `img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '封面图片',
  `img_list` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '更多图片',
  `inventory` int DEFAULT NULL COMMENT '库存',
  `sales` int DEFAULT 0 COMMENT '销量',
  `rating` decimal(3,2) DEFAULT 0.00 COMMENT '评分',
  `status` tinyint DEFAULT 1 COMMENT '上架状态',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category_id`),
  KEY `idx_author` (`author`),
  KEY `idx_isbn` (`isbn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='图书表';

-- ----------------------------
-- Records of book
-- ----------------------------
BEGIN;
INSERT INTO `book` (`id`, `name`, `author`, `publisher`, `publish_date`, `isbn`, `price`, `category_id`, `description`, `content`, `img`, `img_list`, `inventory`, `sales`, `rating`, `status`) VALUES
(1, '呐喊', '鲁迅', '人民文学出版社', '1923-08-01', '9787020002200', 25.00, 2, '鲁迅小说集，包含《狂人日记》、《孔乙己》等经典作品', '<p>《呐喊》是鲁迅的第一本短篇小说集，收入了《狂人日记》、《孔乙己》、《药》、《明天》、《一件小事》、《头发的故事》等14篇作品。</p>', 'http://127.0.0.1:9090/web/download/nahan.jpg', 'http://127.0.0.1:9090/web/download/nahan.jpg', 3, 150, 4.80, 1),
(2, '彷徨', '鲁迅', '人民文学出版社', '1926-10-01', '9787020002217', 28.00, 2, '鲁迅小说集，包含《祝福》、《在酒楼上》等作品', '<p>《彷徨》是鲁迅的第二部小说集，收入了《祝福》、《在酒楼上》、《幸福的家庭》、《肥皂》等11篇作品。</p>', 'http://127.0.0.1:9090/web/download/panghuang.jpg', 'http://127.0.0.1:9090/web/download/panghuang.jpg', 2, 120, 4.70, 1),
(3, '射雕英雄传', '金庸', '三联书店', '1957-01-01', '9787108000001', 45.00, 2, '金庸武侠小说代表作，讲述郭靖的成长故事', '<p>《射雕英雄传》是金庸创作的长篇武侠小说，讲述了憨厚老实郭靖与聪明伶俐黄蓉的爱情故事，以及郭靖从草原少年成长为一代大侠的历程。</p>', 'http://127.0.0.1:9090/web/download/shediao.jpg', 'http://127.0.0.1:9090/web/download/shediao.jpg', 3, 300, 4.90, 1),
(4, '神雕侠侣', '金庸', '三联书店', '1959-01-01', '9787108000002', 48.00, 2, '金庸武侠小说，杨过与小龙女的爱情故事', '<p>《神雕侠侣》是金庸创作的长篇武侠小说，是"射雕三部曲"系列的第二部，讲述了杨过和小龙女之间的凄美爱情故事。</p>', 'http://127.0.0.1:9090/web/download/shendiao.jpg', 'http://127.0.0.1:9090/web/download/shendiao.jpg', 2, 280, 4.80, 1),
(5, '活着', '余华', '作家出版社', '1993-01-01', '9787506330001', 35.00, 2, '余华代表作，讲述福贵一生的苦难故事', '<p>《活着》讲述了一个人一生的故事，这是一个历尽世间沧桑和磨难老人的人生感言，是一幕演绎人生苦难经历的戏剧。</p>', 'http://127.0.0.1:9090/web/download/huozhe.jpg', 'http://127.0.0.1:9090/web/download/huozhe.jpg', 3, 400, 4.90, 1),
(6, '许三观卖血记', '余华', '作家出版社', '1995-01-01', '9787506330002', 32.00, 2, '余华作品，讲述许三观卖血养家的故事', '<p>《许三观卖血记》以博大的温情描绘了磨难中的人生，以激烈的故事形式表达了人在面对厄运时求生的欲望。</p>', 'http://127.0.0.1:9090/web/download/xusanguan.jpg', 'http://127.0.0.1:9090/web/download/xusanguan.jpg', 2, 250, 4.70, 1),
(7, '深度学习', 'Ian Goodfellow', '人民邮电出版社', '2017-06-01', '9787115461476', 128.00, 7, '深度学习领域的经典教材', '<p>《深度学习》由三位全球知名的专家撰写，是深度学习领域奠基性的经典教材。</p>', 'http://127.0.0.1:9090/web/download/deeplearning.jpg', 'http://127.0.0.1:9090/web/download/deeplearning.jpg', 2, 80, 4.60, 1),
(8, '机器学习', '周志华', '清华大学出版社', '2016-01-01', '9787302423287', 88.00, 7, '机器学习领域的经典教材', '<p>《机器学习》是机器学习领域的经典教材，全面介绍了机器学习的基本理论和方法。</p>', 'http://127.0.0.1:9090/web/download/machinelearning.jpg', 'http://127.0.0.1:9090/web/download/machinelearning.jpg', 3, 100, 4.80, 1),
(9, '人类简史', '尤瓦尔·赫拉利', '中信出版社', '2014-11-01', '9787508647357', 68.00, 8, '从认知革命到科学革命的人类发展史', '<p>《人类简史》从十万年前有生命迹象开始到21世纪资本、科技交织的人类发展史，将科学和历史编织在一起。</p>', 'http://127.0.0.1:9090/web/download/sapiens.jpg', 'http://127.0.0.1:9090/web/download/sapiens.jpg', 2, 200, 4.70, 1),
(10, '未来简史', '尤瓦尔·赫拉利', '中信出版社', '2017-01-01', '9787508672069', 68.00, 8, '对人类未来发展的预测和思考', '<p>《未来简史》以宏大视角审视人类未来的终极命运，探讨了科技发展对人类社会的影响。</p>', 'http://127.0.0.1:9090/web/download/weilaijianshi.jpg', 'http://127.0.0.1:9090/web/download/weilaijianshi.jpg', 3, 180, 4.60, 1),
(11, '围城', '钱钟书', '人民文学出版社', '1947-05-01', '9787020002221', 36.00, 1, '钱钟书代表作，中国现代文学经典讽刺小说', '<p>《围城》是钱钟书所著的长篇小说，被誉为"新儒林外史"，以幽默讽刺的笔触描绘了抗战初期知识分子的群像。</p>', 'http://127.0.0.1:9090/web/download/weicheng.jpg', 'http://127.0.0.1:9090/web/download/weicheng.jpg', 3, 350, 4.80, 1),
(12, '边城', '沈从文', '人民文学出版社', '1934-04-01', '9787020002214', 28.00, 1, '沈从文中篇小说代表作，湘西风情画卷', '<p>《边城》是沈从文的代表作，以20世纪30年代川湘交界的边城小镇茶峒为背景，描绘了湘西地区特有的风土人情。</p>', 'http://127.0.0.1:9090/web/download/biancheng.jpg', 'http://127.0.0.1:9090/web/download/biancheng.jpg', 3, 280, 4.70, 1),
(13, '骆驼祥子', '老舍', '人民文学出版社', '1936-09-01', '9787020002221', 32.00, 1, '老舍代表作，旧社会底层人民的命运悲歌', '<p>《骆驼祥子》是老舍的代表作，以北平一个人力车夫祥子的行踪为线索，深刻揭露了旧中国的黑暗。</p>', 'http://127.0.0.1:9090/web/download/luotuoxiangzi.jpg', 'http://127.0.0.1:9090/web/download/luotuoxiangzi.jpg', 3, 350, 4.80, 1),
(14, '家', '巴金', '人民文学出版社', '1933-05-01', '9787020002238', 35.00, 1, '巴金激流三部曲第一部，封建家庭的崩溃', '<p>《家》是巴金的代表作，描写了20世纪20年代初期四川成都一个封建大家庭的罪恶和腐朽。</p>', 'http://127.0.0.1:9090/web/download/jia.jpg', 'http://127.0.0.1:9090/web/download/jia.jpg', 3, 300, 4.70, 1),
(15, '雷雨', '曹禺', '人民文学出版社', '1934-07-01', '9787020002245', 26.00, 1, '中国话剧史上的经典名作', '<p>《雷雨》是曹禺的话剧代表作，以1925年前后的中国社会为背景，描写了一个封建资产阶级家庭的悲剧。</p>', 'http://127.0.0.1:9090/web/download/leiyu.jpg', 'http://127.0.0.1:9090/web/download/leiyu.jpg', 3, 260, 4.60, 1),
(16, '倾城之恋', '张爱玲', '北京十月文艺出版社', '1943-09-01', '9787530200001', 30.00, 1, '张爱玲中短篇小说集，乱世中的爱情传奇', '<p>《倾城之恋》是张爱玲最脍炙人口的短篇小说之一，讲述了白流苏和范柳原在战争年代的爱情故事。</p>', 'http://127.0.0.1:9090/web/download/qingchengzhilian.jpg', 'http://127.0.0.1:9090/web/download/qingchengzhilian.jpg', 3, 240, 4.70, 1),
(17, '朝花夕拾', '鲁迅', '人民文学出版社', '1928-09-01', '9787020002252', 22.00, 3, '鲁迅唯一一部回忆性散文集', '<p>《朝花夕拾》是鲁迅的回忆性散文集，原名《旧事重提》，收录了鲁迅于1926年创作的10篇回忆性散文。</p>', 'http://127.0.0.1:9090/web/download/zhaohuaxishi.jpg', 'http://127.0.0.1:9090/web/download/zhaohuaxishi.jpg', 3, 200, 4.60, 1),
(18, '背影', '朱自清', '人民文学出版社', '1928-10-01', '9787020002269', 24.00, 3, '朱自清散文代表作，感人至深的父爱', '<p>《背影》是朱自清的散文集，收录了《背影》、《荷塘月色》等经典散文名篇。</p>', 'http://127.0.0.1:9090/web/download/beiying.jpg', 'http://127.0.0.1:9090/web/download/beiying.jpg', 3, 220, 4.50, 1),
(19, '我与地坛', '史铁生', '人民文学出版社', '1991-01-01', '9787020002276', 28.00, 3, '史铁生散文代表作，对生命的深刻思考', '<p>《我与地坛》是史铁生的散文代表作，以地坛为背景，抒写了作者对生命、命运和母亲的深沉思考。</p>', 'http://127.0.0.1:9090/web/download/woyuditan.jpg', 'http://127.0.0.1:9090/web/download/woyuditan.jpg', 3, 260, 4.80, 1),
(20, '文化苦旅', '余秋雨', '长江文艺出版社', '1992-03-01', '9787535400001', 38.00, 3, '余秋雨文化散文集，探寻中华文化脉络', '<p>《文化苦旅》是余秋雨的文化散文集，通过山水风物探求文化灵魂和人生真谛。</p>', 'http://127.0.0.1:9090/web/download/wenhuakulv.jpg', 'http://127.0.0.1:9090/web/download/wenhuakulv.jpg', 3, 300, 4.70, 1),
(21, '目送', '龙应台', '广西师范大学出版社', '2008-07-01', '9787563378000', 32.00, 3, '龙应台散文集，关于亲情与生命的感悟', '<p>《目送》是龙应台的散文集，由七十三篇散文组成，写父亲的逝、母亲的老、儿子的离。</p>', 'http://127.0.0.1:9090/web/download/musong.jpg', 'http://127.0.0.1:9090/web/download/musong.jpg', 3, 280, 4.60, 1),
(22, '雅舍小品', '梁实秋', '人民文学出版社', '1949-01-01', '9787020002283', 26.00, 3, '梁实秋散文经典，雅致幽默的生活小品', '<p>《雅舍小品》是梁实秋的散文集，以幽默风趣的笔触描绘了生活中的点滴趣事。</p>', 'http://127.0.0.1:9090/web/download/yashexiaopin.jpg', 'http://127.0.0.1:9090/web/download/yashexiaopin.jpg', 3, 190, 4.50, 1),
(23, '唐诗三百首', '蘅塘退士', '中华书局', '1764-01-01', '9787101000001', 42.00, 4, '中国古典诗歌精华，流传最广的唐诗选本', '<p>《唐诗三百首》是清代蘅塘退士编选的唐诗选集，收录了77位诗人的311首诗作。</p>', 'http://127.0.0.1:9090/web/download/tangshisanbaishou.jpg', 'http://127.0.0.1:9090/web/download/tangshisanbaishou.jpg', 3, 400, 4.90, 1),
(24, '宋词三百首', '朱祖谋', '中华书局', '1924-01-01', '9787101000002', 42.00, 4, '宋词精华荟萃，古典文学的璀璨明珠', '<p>《宋词三百首》是朱祖谋编选的宋词选集，收录了宋代81位词人的283首词作。</p>', 'http://127.0.0.1:9090/web/download/songcisanbaishou.jpg', 'http://127.0.0.1:9090/web/download/songcisanbaishou.jpg', 3, 350, 4.80, 1),
(25, '飞鸟集', '泰戈尔', '人民文学出版社', '1916-01-01', '9787020002290', 22.00, 4, '泰戈尔诗集，充满哲思的短诗经典', '<p>《飞鸟集》是印度诗人泰戈尔的诗集，包括325首无题诗，短小精悍，蕴含深刻哲理。</p>', 'http://127.0.0.1:9090/web/download/feiniaoji.jpg', 'http://127.0.0.1:9090/web/download/feiniaoji.jpg', 3, 300, 4.70, 1),
(26, '新月诗选', '徐志摩', '人民文学出版社', '1931-01-01', '9787020002306', 28.00, 4, '新月派诗歌精选，中国现代诗歌的里程碑', '<p>《新月诗选》收录了徐志摩、闻一多等新月派诗人的代表作，展现了中国现代诗歌的艺术成就。</p>', 'http://127.0.0.1:9090/web/download/xinyueshixuan.jpg', 'http://127.0.0.1:9090/web/download/xinyueshixuan.jpg', 3, 180, 4.50, 1),
(27, '海子诗全集', '海子', '作家出版社', '2009-03-01', '9787506300001', 48.00, 4, '海子全部诗歌作品，面朝大海春暖花开', '<p>《海子诗全集》收录了海子一生所有诗歌作品，包括《面朝大海，春暖花开》等经典名篇。</p>', 'http://127.0.0.1:9090/web/download/haizishiquanji.jpg', 'http://127.0.0.1:9090/web/download/haizishiquanji.jpg', 3, 220, 4.80, 1),
(28, '艾青诗选', '艾青', '人民文学出版社', '1979-01-01', '9787020002313', 30.00, 4, '艾青诗歌精选，中国现代诗歌的杰出代表', '<p>《艾青诗选》收录了艾青各个时期的代表作，如《大堰河——我的保姆》、《我爱这土地》等。</p>', 'http://127.0.0.1:9090/web/download/aiqingshixuan.jpg', 'http://127.0.0.1:9090/web/download/aiqingshixuan.jpg', 3, 200, 4.60, 1),
(29, '时间简史', '霍金', '湖南科学技术出版社', '1988-04-01', '9787535700001', 45.00, 5, '霍金科普经典，探索宇宙的奥秘', '<p>《时间简史》是霍金的科普著作，讲述了宇宙的起源、黑洞、时间旅行等前沿物理概念。</p>', 'http://127.0.0.1:9090/web/download/shijianjianshi.jpg', 'http://127.0.0.1:9090/web/download/shijianjianshi.jpg', 3, 500, 4.90, 1),
(30, '上帝掷骰子吗', '曹天元', '北京联合出版公司', '2006-01-01', '9787550200001', 42.00, 5, '量子力学史话，通俗易懂的物理科普', '<p>《上帝掷骰子吗》以生动的语言讲述了量子力学的发展历程，被誉为中文世界最好的量子力学科普书。</p>', 'http://127.0.0.1:9090/web/download/shangdizhitouzi.jpg', 'http://127.0.0.1:9090/web/download/shangdizhitouzi.jpg', 3, 350, 4.80, 1),
(31, '从一到无穷大', '伽莫夫', '科学出版社', '1947-01-01', '9787030000001', 38.00, 5, '科学经典，从数学到宇宙的奇妙之旅', '<p>《从一到无穷大》是伽莫夫的科普经典，以幽默的语言介绍了数学、物理、生物等科学知识。</p>', 'http://127.0.0.1:9090/web/download/congyidaowuqiongda.jpg', 'http://127.0.0.1:9090/web/download/congyidaowuqiongda.jpg', 3, 280, 4.70, 1),
(32, '自私的基因', '理查德·道金斯', '中信出版社', '1976-01-01', '9787508600001', 48.00, 5, '进化生物学经典，基因视角下的生命演化', '<p>《自私的基因》是道金斯的经典著作，提出了以基因为中心的进化论观点。</p>', 'http://127.0.0.1:9090/web/download/zisidejiyin.jpg', 'http://127.0.0.1:9090/web/download/zisidejiyin.jpg', 3, 300, 4.70, 1),
(33, '万物简史', '比尔·布莱森', '接力出版社', '2003-01-01', '9787544800001', 45.00, 5, '科学史通俗读物，讲述万物的奇妙故事', '<p>《万物简史》以幽默风趣的笔触讲述了科学发展的历史，从宇宙大爆炸到人类文明。</p>', 'http://127.0.0.1:9090/web/download/wanwujianshi.jpg', 'http://127.0.0.1:9090/web/download/wanwujianshi.jpg', 3, 320, 4.60, 1),
(34, '枪炮、病菌与钢铁', '贾雷德·戴蒙德', '中信出版社', '1997-03-01', '9787508600002', 55.00, 5, '人类社会发展史，普利策奖获奖作品', '<p>《枪炮、病菌与钢铁》探讨了为什么不同大陆的人类社会发展速度存在巨大差异。</p>', 'http://127.0.0.1:9090/web/download/qiangpaobingjun.jpg', 'http://127.0.0.1:9090/web/download/qiangpaobingjun.jpg', 3, 380, 4.80, 1),
(35, '算法导论', 'Thomas Cormen', '机械工业出版社', '1990-01-01', '9787111000001', 128.00, 6, '计算机算法领域的圣经级教材', '<p>《算法导论》全面介绍了计算机算法的设计与分析方法，是算法领域的权威教材。</p>', 'http://127.0.0.1:9090/web/download/suanfadaolun.jpg', 'http://127.0.0.1:9090/web/download/suanfadaolun.jpg', 2, 150, 4.80, 1),
(36, '计算机程序设计艺术', 'Donald Knuth', '人民邮电出版社', '1968-01-01', '9787115000001', 198.00, 6, '计算机科学领域的史诗级巨著', '<p>《计算机程序设计艺术》是高德纳的经典著作，被誉为计算机科学领域的圣经。</p>', 'http://127.0.0.1:9090/web/download/jisuanjichengxu.jpg', 'http://127.0.0.1:9090/web/download/jisuanjichengxu.jpg', 2, 80, 4.90, 1),
(37, '深入理解计算机系统', 'Randal Bryant', '机械工业出版社', '2003-01-01', '9787111000002', 99.00, 6, '从程序员视角深入理解计算机系统', '<p>《深入理解计算机系统》从程序员的角度介绍了计算机系统的核心概念。</p>', 'http://127.0.0.1:9090/web/download/shenrulijie.jpg', 'http://127.0.0.1:9090/web/download/shenrulijie.jpg', 2, 120, 4.70, 1),
(38, '编译原理', 'Alfred Aho', '机械工业出版社', '1986-01-01', '9787111000003', 89.00, 6, '编译技术经典教材，龙书', '<p>《编译原理》是编译技术领域的经典教材，全面介绍了编译器的设计与实现。</p>', 'http://127.0.0.1:9090/web/download/bianyyuanli.jpg', 'http://127.0.0.1:9090/web/download/bianyyuanli.jpg', 2, 100, 4.60, 1),
(39, '计算机网络', 'James Kurose', '机械工业出版社', '2000-01-01', '9787111000004', 79.00, 6, '计算机网络经典教材，自顶向下方法', '<p>《计算机网络》采用自顶向下的方法介绍计算机网络，是网络领域的经典教材。</p>', 'http://127.0.0.1:9090/web/download/jisuanjiwangluo.jpg', 'http://127.0.0.1:9090/web/download/jisuanjiwangluo.jpg', 2, 130, 4.60, 1),
(40, '数据库系统概念', 'Abraham Silberschatz', '机械工业出版社', '1986-01-01', '9787111000005', 85.00, 6, '数据库领域经典教材', '<p>《数据库系统概念》全面介绍了数据库系统的基本概念、设计和实现。</p>', 'http://127.0.0.1:9090/web/download/shujukuxitong.jpg', 'http://127.0.0.1:9090/web/download/shujukuxitong.jpg', 2, 110, 4.50, 1),
(41, '苏菲的世界', '乔斯坦·贾德', '作家出版社', '1991-12-01', '9787506300002', 38.00, 9, '哲学入门经典，以小说形式讲述西方哲学史', '<p>《苏菲的世界》以小说的形式，通过一名哲学导师向一个叫苏菲的女孩传授哲学知识。</p>', 'http://127.0.0.1:9090/web/download/sufeideshijie.jpg', 'http://127.0.0.1:9090/web/download/sufeideshijie.jpg', 3, 400, 4.80, 1),
(42, '中国哲学简史', '冯友兰', '北京大学出版社', '1948-01-01', '9787301000001', 42.00, 9, '冯友兰经典，中国哲学入门必读', '<p>《中国哲学简史》是冯友兰的经典著作，系统介绍了中国哲学的发展历程和主要流派。</p>', 'http://127.0.0.1:9090/web/download/zhongguozhexue.jpg', 'http://127.0.0.1:9090/web/download/zhongguozhexue.jpg', 3, 300, 4.70, 1),
(43, '理想国', '柏拉图', '商务印书馆', '1901-01-01', '9787100000001', 48.00, 9, '西方哲学经典，柏拉图代表作', '<p>《理想国》是柏拉图的代表作，探讨了正义、理想城邦和哲学王等核心哲学问题。</p>', 'http://127.0.0.1:9090/web/download/lixiangguo.jpg', 'http://127.0.0.1:9090/web/download/lixiangguo.jpg', 3, 350, 4.80, 1),
(44, '存在与时间', '海德格尔', '商务印书馆', '1927-01-01', '9787100000002', 58.00, 9, '海德格尔代表作，20世纪最重要的哲学著作', '<p>《存在与时间》是海德格尔的代表作，探讨了存在的意义这一根本哲学问题。</p>', 'http://127.0.0.1:9090/web/download/cunzaiyushijian.jpg', 'http://127.0.0.1:9090/web/download/cunzaiyushijian.jpg', 2, 180, 4.60, 1),
(45, '沉思录', '马可·奥勒留', '商务印书馆', '1901-01-01', '9787100000003', 32.00, 9, '古罗马皇帝的人生哲学思考', '<p>《沉思录》是古罗马皇帝马可·奥勒留的哲学思考录，探讨了人生、道德和宇宙的本质。</p>', 'http://127.0.0.1:9090/web/download/chensilu.jpg', 'http://127.0.0.1:9090/web/download/chensilu.jpg', 3, 280, 4.60, 1),
(46, '道德经', '老子', '中华书局', '1901-01-01', '9787101000003', 28.00, 9, '道家经典，中国哲学的重要源头', '<p>《道德经》是老子所著的道家经典，以"道"为核心阐述了宇宙、人生和政治的哲学思想。</p>', 'http://127.0.0.1:9090/web/download/daodejing.jpg', 'http://127.0.0.1:9090/web/download/daodejing.jpg', 3, 450, 4.90, 1),
(47, '模式识别与机器学习', 'Christopher Bishop', '机械工业出版社', '2006-01-01', '9787111000006', 98.00, 7, '机器学习经典教材，贝叶斯方法', '<p>《模式识别与机器学习》是机器学习领域的经典教材，以贝叶斯视角系统介绍了机器学习方法。</p>', 'http://127.0.0.1:9090/web/download/moshishibie.jpg', 'http://127.0.0.1:9090/web/download/moshishibie.jpg', 2, 90, 4.70, 1),
(48, '强化学习', 'Richard Sutton', '人民邮电出版社', '1998-01-01', '9787115000002', 108.00, 7, '强化学习领域经典教材', '<p>《强化学习》是强化学习领域的奠基性教材，全面介绍了强化学习的理论与算法。</p>', 'http://127.0.0.1:9090/web/download/qianghuaxuexi.jpg', 'http://127.0.0.1:9090/web/download/qianghuaxuexi.jpg', 2, 85, 4.60, 1),
(49, '自然语言处理', 'Daniel Jurafsky', '机械工业出版社', '2000-01-01', '9787111000007', 118.00, 7, 'NLP领域经典教材', '<p>《自然语言处理》是自然语言处理领域的经典教材，涵盖了NLP的核心技术和方法。</p>', 'http://127.0.0.1:9090/web/download/ziranyuyan.jpg', 'http://127.0.0.1:9090/web/download/ziranyuyan.jpg', 2, 75, 4.50, 1),
(50, '计算机视觉', 'Richard Szeliski', '机械工业出版社', '2010-01-01', '9787111000008', 98.00, 7, '计算机视觉领域经典教材', '<p>《计算机视觉》全面介绍了计算机视觉的算法与应用，是CV领域的权威教材。</p>', 'http://127.0.0.1:9090/web/download/jisuanjishijue.jpg', 'http://127.0.0.1:9090/web/download/jisuanjishijue.jpg', 2, 80, 4.50, 1),
(51, '万历十五年', '黄仁宇', '中华书局', '1981-01-01', '9787101000004', 36.00, 8, '大历史观经典，以1587年看明朝兴衰', '<p>《万历十五年》以1587年为切入点，运用大历史观分析了明朝由盛转衰的深层原因。</p>', 'http://127.0.0.1:9090/web/download/wanlishiwunian.jpg', 'http://127.0.0.1:9090/web/download/wanlishiwunian.jpg', 3, 380, 4.80, 1),
(52, '全球通史', '斯塔夫里阿诺斯', '北京大学出版社', '1970-01-01', '9787301000002', 68.00, 8, '全球史观经典，从史前到21世纪', '<p>《全球通史》以全球史观讲述了从史前到21世纪的人类历史，是历史学经典著作。</p>', 'http://127.0.0.1:9090/web/download/quanqiutongshi.jpg', 'http://127.0.0.1:9090/web/download/quanqiutongshi.jpg', 3, 320, 4.70, 1),
(53, '国史大纲', '钱穆', '商务印书馆', '1940-01-01', '9787100000004', 58.00, 8, '钱穆史学经典，中国通史纲要', '<p>《国史大纲》是钱穆的代表作，以独特的视角系统梳理了中国历史的发展脉络。</p>', 'http://127.0.0.1:9090/web/download/guoshidagang.jpg', 'http://127.0.0.1:9090/web/download/guoshidagang.jpg', 3, 250, 4.70, 1),
(54, '明朝那些事儿', '当年明月', '浙江人民出版社', '2006-01-01', '9787213000001', 35.00, 8, '通俗历史读物，幽默讲述明朝三百年', '<p>《明朝那些事儿》以幽默风趣的语言讲述了明朝三百年的历史故事。</p>', 'http://127.0.0.1:9090/web/download/mingchaonaxieshier.jpg', 'http://127.0.0.1:9090/web/download/mingchaonaxieshier.jpg', 3, 500, 4.80, 1);
COMMIT;

-- ----------------------------
-- Table structure for book_category
-- ----------------------------
DROP TABLE IF EXISTS `book_category`;
CREATE TABLE `book_category` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '分类名称',
  `parent_id` int DEFAULT 0 COMMENT '父分类ID',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '分类描述',
  `img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '分类图片',
  `status` tinyint DEFAULT 1 COMMENT '状态',
  PRIMARY KEY (`id`),
  KEY `idx_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='图书分类表';

-- ----------------------------
-- Records of book_category
-- ----------------------------
BEGIN;
INSERT INTO `book_category` (`id`, `name`, `parent_id`, `description`, `img`, `status`) VALUES
(1, '文学', 0, '文学类图书', 'http://127.0.0.1:9090/web/download/literature.png', 1),
(2, '小说', 1, '小说类图书', 'http://127.0.0.1:9090/web/download/fiction.png', 1),
(3, '散文', 1, '散文类图书', 'http://127.0.0.1:9090/web/download/prose.png', 1),
(4, '诗歌', 1, '诗歌类图书', 'http://127.0.0.1:9090/web/download/poetry.png', 1),
(5, '科技', 0, '科技类图书', 'http://127.0.0.1:9090/web/download/tech.png', 1),
(6, '计算机', 5, '计算机类图书', 'http://127.0.0.1:9090/web/download/computer.png', 1),
(7, '人工智能', 6, '人工智能类图书', 'http://127.0.0.1:9090/web/download/ai.png', 1),
(8, '历史', 0, '历史类图书', 'http://127.0.0.1:9090/web/download/history.png', 1),
(9, '哲学', 0, '哲学类图书', 'http://127.0.0.1:9090/web/download/philosophy.png', 1);
COMMIT;

-- ----------------------------
-- Table structure for cart
-- ----------------------------
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `book_id` int DEFAULT NULL COMMENT '图书id',
  `num` int DEFAULT NULL COMMENT '数量',
  `user_id` int DEFAULT NULL COMMENT '用户id',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='购物车管理';

-- ----------------------------
-- Records of cart
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for collect
-- ----------------------------
DROP TABLE IF EXISTS `collect`;
CREATE TABLE `collect` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `user_id` int DEFAULT NULL COMMENT '用户id',
  `book_id` int DEFAULT NULL COMMENT '图书id',
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`,`book_id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏管理';

-- ----------------------------
-- Records of collect
-- ----------------------------
BEGIN;
INSERT INTO `collect` (`id`, `user_id`, `book_id`) VALUES (27, 1, 5);
COMMIT;

-- ----------------------------
-- Table structure for kg_entity
-- ----------------------------
DROP TABLE IF EXISTS `kg_entity`;
CREATE TABLE `kg_entity` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '实体ID',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '实体名称',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '实体类型',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '实体描述',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name_type` (`name`, `type`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识图谱实体表';

-- ----------------------------
-- Records of kg_entity
-- ----------------------------
BEGIN;
INSERT INTO `kg_entity` (`id`, `name`, `type`, `description`) VALUES
(1, '鲁迅', 'author', '中国现代文学的奠基人'),
(2, '金庸', 'author', '武侠小说大师'),
(3, '余华', 'author', '当代著名作家'),
(4, 'Ian Goodfellow', 'author', '深度学习领域的专家'),
(5, '周志华', 'author', '机器学习领域的专家'),
(6, '尤瓦尔·赫拉利', 'author', '历史学家、哲学家'),
(7, '武侠小说', 'genre', '中国传统武侠文学'),
(8, '现代文学', 'genre', '20世纪中国文学'),
(9, '科幻小说', 'genre', '科学幻想文学'),
(10, '人工智能', 'theme', '计算机科学的重要分支'),
(11, '机器学习', 'theme', '人工智能的核心技术'),
(12, '历史', 'theme', '对过去事件的研究'),
(13, '哲学', 'theme', '对存在和知识的思考'),
(14, '人民文学出版社', 'publisher', '中国著名出版社'),
(15, '三联书店', 'publisher', '中国知名出版社'),
(16, '作家出版社', 'publisher', '中国文学出版社'),
(17, '人民邮电出版社', 'publisher', '科技类出版社'),
(18, '清华大学出版社', 'publisher', '教育类出版社'),
(19, '中信出版社', 'publisher', '综合性出版社'),
(20, '民国时期', 'era', '1912-1949年'),
(21, '当代', 'era', '1949年至今'),
(22, '钱钟书', 'author', '中国现代作家、文学研究家'),
(23, '沈从文', 'author', '中国现代作家，湘西文学代表'),
(24, '老舍', 'author', '中国现代小说家、剧作家'),
(25, '巴金', 'author', '中国现代作家、翻译家'),
(26, '曹禺', 'author', '中国现代剧作家'),
(27, '张爱玲', 'author', '中国现代女作家'),
(28, '朱自清', 'author', '中国现代散文家、诗人'),
(29, '史铁生', 'author', '中国当代作家、散文家'),
(30, '余秋雨', 'author', '中国当代文化学者、散文家'),
(31, '龙应台', 'author', '中国台湾作家、文学评论家'),
(32, '梁实秋', 'author', '中国现代散文家、翻译家'),
(33, '蘅塘退士', 'author', '清代学者，唐诗三百首编选者'),
(34, '朱祖谋', 'author', '清末民初词人，宋词三百首编选者'),
(35, '泰戈尔', 'author', '印度诗人、文学家'),
(36, '徐志摩', 'author', '中国现代诗人、散文家'),
(37, '海子', 'author', '中国当代诗人'),
(38, '艾青', 'author', '中国现代诗人'),
(39, '霍金', 'author', '英国理论物理学家、宇宙学家'),
(40, '曹天元', 'author', '中国科普作家'),
(41, '伽莫夫', 'author', '俄裔美籍物理学家、科普作家'),
(42, '理查德·道金斯', 'author', '英国演化生物学家'),
(43, '比尔·布莱森', 'author', '美国作家、科普作家'),
(44, '贾雷德·戴蒙德', 'author', '美国生物地理学家、作家'),
(45, 'Thomas Cormen', 'author', '美国计算机科学家，算法导论作者'),
(46, 'Donald Knuth', 'author', '美国计算机科学家，算法分析之父'),
(47, 'Randal Bryant', 'author', '美国计算机科学家'),
(48, 'Alfred Aho', 'author', '加拿大计算机科学家，编译原理作者'),
(49, 'James Kurose', 'author', '美国计算机科学家，网络领域专家'),
(50, 'Abraham Silberschatz', 'author', '计算机科学家，数据库领域专家'),
(51, '乔斯坦·贾德', 'author', '挪威作家，苏菲的世界作者'),
(52, '冯友兰', 'author', '中国哲学家、哲学史家'),
(53, '柏拉图', 'author', '古希腊哲学家'),
(54, '海德格尔', 'author', '德国哲学家，存在主义代表人物'),
(55, '马可·奥勒留', 'author', '古罗马皇帝、哲学家'),
(56, '老子', 'author', '中国古代哲学家，道家创始人'),
(57, 'Christopher Bishop', 'author', '英国计算机科学家，机器学习专家'),
(58, 'Richard Sutton', 'author', '加拿大计算机科学家，强化学习之父'),
(59, 'Daniel Jurafsky', 'author', '美国计算机科学家，NLP领域专家'),
(60, 'Richard Szeliski', 'author', '美国计算机科学家，计算机视觉专家'),
(61, '黄仁宇', 'author', '美籍华裔历史学家'),
(62, '斯塔夫里阿诺斯', 'author', '美国历史学家，全球史观倡导者'),
(63, '钱穆', 'author', '中国现代历史学家、国学大师'),
(64, '当年明月', 'author', '中国当代作家，明朝那些事儿作者'),
(65, '古典文学', 'genre', '中国古代文学作品'),
(66, '戏剧', 'genre', '话剧、戏曲等舞台表演文学'),
(67, '散文', 'genre', '以抒情、叙事为主的文学体裁'),
(68, '诗歌', 'genre', '以韵律和意象为特征的文学体裁'),
(69, '科普', 'theme', '科学普及与传播'),
(70, '计算机科学', 'theme', '研究计算机与计算的学科'),
(71, '西方哲学', 'theme', '西方哲学思想与流派'),
(72, '中国哲学', 'theme', '中国哲学思想与流派'),
(73, '世界历史', 'theme', '全球范围的历史研究'),
(74, '中国历史', 'theme', '中国历史研究'),
(75, '北京十月文艺出版社', 'publisher', '中国文艺类出版社'),
(76, '长江文艺出版社', 'publisher', '中国文艺类出版社'),
(77, '广西师范大学出版社', 'publisher', '中国综合性出版社'),
(78, '中华书局', 'publisher', '中国古籍与学术出版社'),
(79, '湖南科学技术出版社', 'publisher', '中国科技类出版社'),
(80, '北京联合出版公司', 'publisher', '中国综合性出版社'),
(81, '科学出版社', 'publisher', '中国科学类出版社'),
(82, '接力出版社', 'publisher', '中国少儿与科普出版社'),
(83, '机械工业出版社', 'publisher', '中国工业与计算机类出版社'),
(84, '北京大学出版社', 'publisher', '中国学术与教育类出版社'),
(85, '商务印书馆', 'publisher', '中国学术与工具书出版社'),
(86, '浙江人民出版社', 'publisher', '中国综合性出版社'),
(87, '古代', 'era', '1840年以前'),
(88, '近现代', 'era', '1840-1949年'),
(89, '80年代', 'era', '1980-1989年'),
(90, '90年代', 'era', '1990-1999年'),
(91, '21世纪', 'era', '2000年至今');
COMMIT;

-- ----------------------------
-- Table structure for kg_relation
-- ----------------------------
DROP TABLE IF EXISTS `kg_relation`;
CREATE TABLE `kg_relation` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '关系ID',
  `source_id` int DEFAULT NULL COMMENT '源实体ID',
  `target_id` int DEFAULT NULL COMMENT '目标实体ID',
  `relation_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '关系类型',
  `weight` decimal(5,2) DEFAULT 1.00 COMMENT '关系权重',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_source` (`source_id`),
  KEY `idx_target` (`target_id`),
  KEY `idx_relation_type` (`relation_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识图谱关系表';

-- ----------------------------
-- Records of kg_relation
-- ----------------------------
BEGIN;
INSERT INTO `kg_relation` (`source_id`, `target_id`, `relation_type`, `weight`) VALUES
(1, 2, 'similar_to', 0.80),
(1, 3, 'similar_to', 0.70),
(2, 3, 'similar_to', 0.90),
(4, 5, 'similar_to', 0.85),
(6, 6, 'similar_to', 0.90),
(7, 8, 'related_to', 0.90),
(10, 11, 'related_to', 0.95),
(12, 13, 'related_to', 0.70),
(14, 15, 'similar_to', 0.60),
(14, 16, 'similar_to', 0.70),
(15, 16, 'similar_to', 0.65),
(17, 18, 'similar_to', 0.60),
(18, 19, 'similar_to', 0.50),
(20, 21, 'time_sequence', 1.00),
(1, 24, 'similar_to', 0.85),
(1, 25, 'similar_to', 0.80),
(1, 23, 'similar_to', 0.75),
(1, 22, 'similar_to', 0.70),
(22, 23, 'similar_to', 0.80),
(22, 24, 'similar_to', 0.75),
(22, 27, 'similar_to', 0.70),
(23, 24, 'similar_to', 0.80),
(23, 25, 'similar_to', 0.75),
(24, 25, 'similar_to', 0.85),
(24, 26, 'similar_to', 0.80),
(25, 26, 'similar_to', 0.75),
(26, 27, 'similar_to', 0.70),
(28, 32, 'similar_to', 0.85),
(29, 30, 'similar_to', 0.80),
(36, 38, 'similar_to', 0.85),
(36, 37, 'similar_to', 0.70),
(37, 38, 'similar_to', 0.75),
(39, 41, 'similar_to', 0.80),
(42, 44, 'similar_to', 0.75),
(45, 46, 'similar_to', 0.90),
(45, 48, 'similar_to', 0.85),
(46, 48, 'similar_to', 0.80),
(47, 49, 'similar_to', 0.80),
(47, 50, 'similar_to', 0.75),
(57, 58, 'similar_to', 0.85),
(57, 59, 'similar_to', 0.80),
(57, 60, 'similar_to', 0.80),
(58, 59, 'similar_to', 0.75),
(53, 54, 'similar_to', 0.80),
(53, 55, 'similar_to', 0.75),
(52, 56, 'similar_to', 0.85),
(61, 63, 'similar_to', 0.80),
(61, 62, 'similar_to', 0.70),
(63, 64, 'similar_to', 0.65),
(8, 65, 'related_to', 0.80),
(8, 66, 'related_to', 0.75),
(8, 67, 'related_to', 0.85),
(8, 68, 'related_to', 0.80),
(65, 68, 'related_to', 0.90),
(67, 68, 'related_to', 0.75),
(10, 70, 'related_to', 0.95),
(11, 8, 'related_to', 0.90),
(69, 12, 'related_to', 0.60),
(69, 13, 'related_to', 0.55),
(71, 72, 'related_to', 0.70),
(73, 74, 'related_to', 0.85),
(14, 75, 'similar_to', 0.70),
(14, 76, 'similar_to', 0.65),
(16, 75, 'similar_to', 0.60),
(78, 85, 'similar_to', 0.80),
(78, 84, 'similar_to', 0.75),
(83, 17, 'similar_to', 0.70),
(83, 18, 'similar_to', 0.65),
(19, 80, 'similar_to', 0.60),
(81, 79, 'similar_to', 0.70),
(87, 88, 'time_sequence', 1.00),
(88, 20, 'time_sequence', 1.00),
(20, 21, 'time_sequence', 1.00),
(21, 89, 'time_sequence', 1.00),
(89, 90, 'time_sequence', 1.00),
(90, 91, 'time_sequence', 1.00);
COMMIT;

-- ----------------------------
-- Table structure for book_entity
-- ----------------------------
DROP TABLE IF EXISTS `book_entity`;
CREATE TABLE `book_entity` (
  `id` int NOT NULL AUTO_INCREMENT,
  `book_id` int DEFAULT NULL COMMENT '图书ID',
  `entity_id` int DEFAULT NULL COMMENT '实体ID',
  `relation_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '关系类型',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_book` (`book_id`),
  KEY `idx_entity` (`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='图书实体关联表';

-- ----------------------------
-- Records of book_entity
-- ----------------------------
BEGIN;
INSERT INTO `book_entity` (`book_id`, `entity_id`, `relation_type`) VALUES
(1, 1, 'written_by'),
(1, 7, 'belongs_to'),
(1, 8, 'belongs_to'),
(1, 14, 'published_by'),
(1, 20, 'written_in'),
(2, 1, 'written_by'),
(2, 7, 'belongs_to'),
(2, 8, 'belongs_to'),
(2, 14, 'published_by'),
(2, 20, 'written_in'),
(3, 2, 'written_by'),
(3, 7, 'belongs_to'),
(3, 15, 'published_by'),
(3, 21, 'written_in'),
(4, 2, 'written_by'),
(4, 7, 'belongs_to'),
(4, 15, 'published_by'),
(4, 21, 'written_in'),
(5, 3, 'written_by'),
(5, 7, 'belongs_to'),
(5, 16, 'published_by'),
(5, 21, 'written_in'),
(6, 3, 'written_by'),
(6, 7, 'belongs_to'),
(6, 16, 'published_by'),
(6, 21, 'written_in'),
(7, 4, 'written_by'),
(7, 10, 'about'),
(7, 11, 'about'),
(7, 17, 'published_by'),
(7, 21, 'written_in'),
(8, 5, 'written_by'),
(8, 10, 'about'),
(8, 11, 'about'),
(8, 18, 'published_by'),
(8, 21, 'written_in'),
(9, 6, 'written_by'),
(9, 12, 'about'),
(9, 13, 'about'),
(9, 19, 'published_by'),
(9, 21, 'written_in'),
(10, 6, 'written_by'),
(10, 12, 'about'),
(10, 13, 'about'),
(10, 19, 'published_by'),
(10, 21, 'written_in'),
(11, 22, 'written_by'),
(11, 8, 'belongs_to'),
(11, 14, 'published_by'),
(11, 20, 'written_in'),
(12, 23, 'written_by'),
(12, 8, 'belongs_to'),
(12, 14, 'published_by'),
(12, 20, 'written_in'),
(13, 24, 'written_by'),
(13, 8, 'belongs_to'),
(13, 14, 'published_by'),
(13, 20, 'written_in'),
(14, 25, 'written_by'),
(14, 8, 'belongs_to'),
(14, 14, 'published_by'),
(14, 20, 'written_in'),
(15, 26, 'written_by'),
(15, 66, 'belongs_to'),
(15, 8, 'belongs_to'),
(15, 14, 'published_by'),
(15, 20, 'written_in'),
(16, 27, 'written_by'),
(16, 8, 'belongs_to'),
(16, 75, 'published_by'),
(16, 20, 'written_in'),
(17, 1, 'written_by'),
(17, 67, 'belongs_to'),
(17, 8, 'belongs_to'),
(17, 14, 'published_by'),
(17, 20, 'written_in'),
(18, 28, 'written_by'),
(18, 67, 'belongs_to'),
(18, 8, 'belongs_to'),
(18, 14, 'published_by'),
(18, 20, 'written_in'),
(19, 29, 'written_by'),
(19, 67, 'belongs_to'),
(19, 8, 'belongs_to'),
(19, 14, 'published_by'),
(19, 90, 'written_in'),
(20, 30, 'written_by'),
(20, 67, 'belongs_to'),
(20, 8, 'belongs_to'),
(20, 76, 'published_by'),
(20, 90, 'written_in'),
(21, 31, 'written_by'),
(21, 67, 'belongs_to'),
(21, 8, 'belongs_to'),
(21, 77, 'published_by'),
(21, 91, 'written_in'),
(22, 32, 'written_by'),
(22, 67, 'belongs_to'),
(22, 8, 'belongs_to'),
(22, 14, 'published_by'),
(22, 20, 'written_in'),
(23, 33, 'written_by'),
(23, 68, 'belongs_to'),
(23, 65, 'belongs_to'),
(23, 78, 'published_by'),
(23, 87, 'written_in'),
(24, 34, 'written_by'),
(24, 68, 'belongs_to'),
(24, 65, 'belongs_to'),
(24, 78, 'published_by'),
(24, 88, 'written_in'),
(25, 35, 'written_by'),
(25, 68, 'belongs_to'),
(25, 14, 'published_by'),
(25, 88, 'written_in'),
(26, 36, 'written_by'),
(26, 68, 'belongs_to'),
(26, 8, 'belongs_to'),
(26, 14, 'published_by'),
(26, 20, 'written_in'),
(27, 37, 'written_by'),
(27, 68, 'belongs_to'),
(27, 8, 'belongs_to'),
(27, 16, 'published_by'),
(27, 91, 'written_in'),
(28, 38, 'written_by'),
(28, 68, 'belongs_to'),
(28, 8, 'belongs_to'),
(28, 14, 'published_by'),
(28, 21, 'written_in'),
(29, 39, 'written_by'),
(29, 69, 'about'),
(29, 79, 'published_by'),
(29, 89, 'written_in'),
(30, 40, 'written_by'),
(30, 69, 'about'),
(30, 80, 'published_by'),
(30, 91, 'written_in'),
(31, 41, 'written_by'),
(31, 69, 'about'),
(31, 81, 'published_by'),
(31, 20, 'written_in'),
(32, 42, 'written_by'),
(32, 69, 'about'),
(32, 19, 'published_by'),
(32, 21, 'written_in'),
(33, 43, 'written_by'),
(33, 69, 'about'),
(33, 82, 'published_by'),
(33, 91, 'written_in'),
(34, 44, 'written_by'),
(34, 69, 'about'),
(34, 12, 'about'),
(34, 19, 'published_by'),
(34, 90, 'written_in'),
(35, 45, 'written_by'),
(35, 70, 'about'),
(35, 83, 'published_by'),
(35, 90, 'written_in'),
(36, 46, 'written_by'),
(36, 70, 'about'),
(36, 17, 'published_by'),
(36, 21, 'written_in'),
(37, 47, 'written_by'),
(37, 70, 'about'),
(37, 83, 'published_by'),
(37, 91, 'written_in'),
(38, 48, 'written_by'),
(38, 70, 'about'),
(38, 83, 'published_by'),
(38, 89, 'written_in'),
(39, 49, 'written_by'),
(39, 70, 'about'),
(39, 83, 'published_by'),
(39, 91, 'written_in'),
(40, 50, 'written_by'),
(40, 70, 'about'),
(40, 83, 'published_by'),
(40, 89, 'written_in'),
(41, 51, 'written_by'),
(41, 71, 'about'),
(41, 16, 'published_by'),
(41, 90, 'written_in'),
(42, 52, 'written_by'),
(42, 72, 'about'),
(42, 84, 'published_by'),
(42, 20, 'written_in'),
(43, 53, 'written_by'),
(43, 71, 'about'),
(43, 85, 'published_by'),
(43, 87, 'written_in'),
(44, 54, 'written_by'),
(44, 71, 'about'),
(44, 85, 'published_by'),
(44, 20, 'written_in'),
(45, 55, 'written_by'),
(45, 71, 'about'),
(45, 85, 'published_by'),
(45, 87, 'written_in'),
(46, 56, 'written_by'),
(46, 72, 'about'),
(46, 78, 'published_by'),
(46, 87, 'written_in'),
(47, 57, 'written_by'),
(47, 10, 'about'),
(47, 11, 'about'),
(47, 83, 'published_by'),
(47, 91, 'written_in'),
(48, 58, 'written_by'),
(48, 10, 'about'),
(48, 11, 'about'),
(48, 17, 'published_by'),
(48, 90, 'written_in'),
(49, 59, 'written_by'),
(49, 10, 'about'),
(49, 83, 'published_by'),
(49, 91, 'written_in'),
(50, 60, 'written_by'),
(50, 10, 'about'),
(50, 83, 'published_by'),
(50, 91, 'written_in'),
(51, 61, 'written_by'),
(51, 74, 'about'),
(51, 78, 'published_by'),
(51, 89, 'written_in'),
(52, 62, 'written_by'),
(52, 73, 'about'),
(52, 84, 'published_by'),
(52, 21, 'written_in'),
(53, 63, 'written_by'),
(53, 74, 'about'),
(53, 85, 'published_by'),
(53, 20, 'written_in'),
(54, 64, 'written_by'),
(54, 74, 'about'),
(54, 86, 'published_by'),
(54, 91, 'written_in');
COMMIT;

-- ----------------------------
-- Table structure for user_behavior
-- ----------------------------
DROP TABLE IF EXISTS `user_behavior`;
CREATE TABLE `user_behavior` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL COMMENT '用户ID',
  `book_id` int DEFAULT NULL COMMENT '图书ID',
  `behavior_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '行为类型',
  `behavior_value` int DEFAULT 1 COMMENT '行为值',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '行为时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_book` (`user_id`, `book_id`),
  KEY `idx_behavior_type` (`behavior_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户行为表';

-- ----------------------------
-- Records of user_behavior
-- ----------------------------
BEGIN;
INSERT INTO `user_behavior` (`user_id`, `book_id`, `behavior_type`, `behavior_value`) VALUES
(1, 1, 'view', 1),
(1, 1, 'collect', 2),
(1, 2, 'view', 1),
(1, 3, 'view', 1),
(1, 3, 'order', 5),
(1, 5, 'view', 1),
(1, 5, 'collect', 2),
(1, 5, 'order', 5),
(1, 6, 'view', 1),
(2, 3, 'view', 1),
(2, 3, 'collect', 2),
(2, 4, 'view', 1),
(2, 4, 'order', 5),
(2, 5, 'view', 1),
(2, 5, 'collect', 2),
(3, 1, 'view', 1),
(3, 2, 'view', 1),
(3, 2, 'order', 5),
(3, 6, 'view', 1),
(3, 6, 'collect', 2),
(4, 7, 'view', 1),
(4, 7, 'collect', 2),
(4, 8, 'view', 1),
(4, 8, 'order', 5),
(4, 9, 'view', 1),
(4, 10, 'view', 1),
(4, 10, 'collect', 2);
COMMIT;

-- ----------------------------
-- Table structure for notice
-- ----------------------------
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '标题',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='公告管理';

-- ----------------------------
-- Records of notice
-- ----------------------------
BEGIN;
INSERT INTO `notice` (`id`, `name`) VALUES (1, '本系统基于知识图谱技术，构建图书、作者、分类、出版社等实体之间的语义关系网络，实现精准个性化图书推荐');
INSERT INTO `notice` (`id`, `name`) VALUES (2, '新功能上线：知识图谱可视化展示图书关联关系，帮助您发现更多感兴趣的图书');
COMMIT;

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '订单号',
  `time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '下单时间',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '图书名称',
  `img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '图书封面',
  `book_id` int DEFAULT NULL COMMENT '图书id',
  `user_id` int DEFAULT NULL COMMENT '用户id',
  `num` int DEFAULT NULL COMMENT '购买数量',
  `price` decimal(10,2) DEFAULT NULL COMMENT '订单总价',
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '下单用户名',
  `user_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '下单地址',
  `user_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '下单电话',
  `rate` int DEFAULT NULL COMMENT '评分',
  `comment` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '评价',
  `reply` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '回复',
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '状态',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单管理';

-- ----------------------------
-- Records of orders
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for sys_admin
-- ----------------------------
DROP TABLE IF EXISTS `sys_admin`;
CREATE TABLE `sys_admin` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '密码',
  `nickname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '昵称',
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '头像',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机号',
  `role` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '角色',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='管理员';

-- ----------------------------
-- Records of sys_admin
-- ----------------------------
BEGIN;
INSERT INTO `sys_admin` (`id`, `username`, `password`, `nickname`, `role`) VALUES (1, 'jjc', '1221jjc0', '管理员', 'ROLE_ADMIN');
COMMIT;

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '密码',
  `nickname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '昵称',
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '头像',
  `role` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '角色',
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机号',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户';

-- ----------------------------
-- Records of sys_user
-- ----------------------------
BEGIN;
INSERT INTO `sys_user` (`id`, `username`, `password`, `nickname`, `role`, `phone`, `email`) VALUES (1, '111', '111', 'jack', 'ROLE_USER', '13800000001', 'user1@example.com');
INSERT INTO `sys_user` (`id`, `username`, `password`, `nickname`, `role`, `phone`, `email`) VALUES (2, '222', '222', 'Tom', 'ROLE_USER', '13800000002', 'user2@example.com');
INSERT INTO `sys_user` (`id`, `username`, `password`, `nickname`, `role`, `phone`, `email`) VALUES (3, '333', '333', 'jjc', 'ROLE_USER', '13800000003', 'user3@example.com');
COMMIT;

-- ----------------------------
-- Table structure for tag
-- ----------------------------
DROP TABLE IF EXISTS `tag`;
CREATE TABLE `tag` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '标签名称',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='标签';

-- ----------------------------
-- Records of tag
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for type
-- ----------------------------
DROP TABLE IF EXISTS `type`;
CREATE TABLE `type` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '分类名称',
  `img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '分类图片',
  `status` tinyint DEFAULT 1 COMMENT '状态',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品分类';

-- ----------------------------
-- Records of type
-- ----------------------------
BEGIN;
INSERT INTO `type` (`id`, `name`, `img`, `status`) VALUES
(1, '文学', 'http://127.0.0.1:9090/web/download/literature.png', 1),
(2, '小说', 'http://127.0.0.1:9090/web/download/fiction.png', 1),
(3, '散文', 'http://127.0.0.1:9090/web/download/prose.png', 1),
(4, '诗歌', 'http://127.0.0.1:9090/web/download/poetry.png', 1),
(5, '科技', 'http://127.0.0.1:9090/web/download/tech.png', 1),
(6, '计算机', 'http://127.0.0.1:9090/web/download/computer.png', 1),
(7, '人工智能', 'http://127.0.0.1:9090/web/download/ai.png', 1),
(8, '历史', 'http://127.0.0.1:9090/web/download/history.png', 1),
(9, '哲学', 'http://127.0.0.1:9090/web/download/philosophy.png', 1);
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
