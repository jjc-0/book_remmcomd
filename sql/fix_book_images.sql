-- ============================================
-- 修复图书图片路径（运行中数据库直接执行）
-- ============================================

UPDATE `book` SET `img` = 'http://127.0.0.1:9090/web/download/shangdizhitouzi.jpg', `img_list` = 'http://127.0.0.1:9090/web/download/shangdizhitouzi.jpg' WHERE `id` = 30;
UPDATE `book` SET `img` = 'http://127.0.0.1:9090/web/download/qiangpaobingjun.jpg', `img_list` = 'http://127.0.0.1:9090/web/download/qiangpaobingjun.jpg' WHERE `id` = 34;
UPDATE `book` SET `img` = 'http://127.0.0.1:9090/web/download/jisuanjichengxu.jpg', `img_list` = 'http://127.0.0.1:9090/web/download/jisuanjichengxu.jpg' WHERE `id` = 36;
UPDATE `book` SET `img` = 'http://127.0.0.1:9090/web/download/shenrulijie.jpg', `img_list` = 'http://127.0.0.1:9090/web/download/shenrulijie.jpg' WHERE `id` = 37;
UPDATE `book` SET `img` = 'http://127.0.0.1:9090/web/download/bianyyuanli.jpg', `img_list` = 'http://127.0.0.1:9090/web/download/bianyyuanli.jpg' WHERE `id` = 38;
UPDATE `book` SET `img` = 'http://127.0.0.1:9090/web/download/shujukuxitong.jpg', `img_list` = 'http://127.0.0.1:9090/web/download/shujukuxitong.jpg' WHERE `id` = 40;
UPDATE `book` SET `img` = 'http://127.0.0.1:9090/web/download/zhongguozhexue.jpg', `img_list` = 'http://127.0.0.1:9090/web/download/zhongguozhexue.jpg' WHERE `id` = 42;
UPDATE `book` SET `img` = 'http://127.0.0.1:9090/web/download/moshishibie.jpg', `img_list` = 'http://127.0.0.1:9090/web/download/moshishibie.jpg' WHERE `id` = 47;
UPDATE `book` SET `img` = 'http://127.0.0.1:9090/web/download/ziranyuyan.jpg', `img_list` = 'http://127.0.0.1:9090/web/download/ziranyuyan.jpg' WHERE `id` = 49;