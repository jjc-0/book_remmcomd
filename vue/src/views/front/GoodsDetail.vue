<script setup>
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from "vue-router";
import request from "@/utils/request.js";
import { Shop, Place, ShoppingBag, Calendar, StarFilled, Star, Guide } from "@element-plus/icons-vue";
import { ElMessage } from "element-plus";

const route = useRoute();
const router = useRouter();

const account = ref(localStorage.getItem('account') ? JSON.parse(localStorage.getItem('account')) : {});
const id = route.query.id;
const goods = ref({});
const unit = ref({});
const comments = ref([]);
const users = ref([]);
const addressId = ref('');
const addresses = ref([]);
const buyNum = ref(1);
const relatedBooks = ref([]);

const loadUser = () => {
  request.get('/user').then(res => {
    users.value = res.data;
  });
};

const loadGoods = () => {
  request.get('/book/' + id).then(res => {
    goods.value = res.data
    request.get('/orders/goodComment/' + goods.value.id).then(res => {
      comments.value = res.data
    }).catch(() => {
      comments.value = []
    })
    loadRelatedBooks()
    checkCollected()
  })
}

const checkCollected = () => {
  if (account.value.id) {
    request.get('/collect/check/' + id).then(res => {
      goods.value.isCollected = res.data || false
    }).catch(() => {
      goods.value.isCollected = false
    })
  }
};

const loadRelatedBooks = () => {
  request.get('/kg/related/' + id).then(res => {
    relatedBooks.value = res.data || [];
  }).catch(() => {
    relatedBooks.value = [];
  });
};

const loadAddress = () => {
  request.get('/address').then(res => {
    addresses.value = res.data;
  });
};

const changeImg = (img) => {
  goods.value.img = img;
};

const getImageList = (imgString) => {
  if (!imgString) return [];
  return imgString.split(',');
};

const getAuthorIntro = (author) => {
  const intros = {
    '鲁迅': '鲁迅（1881-1936），原名周树人，浙江绍兴人。中国现代文学的奠基人，伟大的文学家、思想家、革命家。代表作有《呐喊》《彷徨》《朝花夕拾》等，其作品深刻揭示了社会矛盾，对中国现代文学产生了深远影响。',
    '金庸': '金庸（1924-2018），原名查良镛，浙江海宁人。当代武侠小说大师，与古龙、梁羽生合称为"中国武侠小说三剑客"。代表作"飞雪连天射白鹿，笑书神侠倚碧鸳"，其作品将武侠小说提升至文学经典的高度。',
    '余华': '余华（1960-），浙江杭州人，当代著名作家。代表作《活着》《许三观卖血记》等，以简洁冷峻的笔触描绘普通人在历史洪流中的命运，作品被翻译成多种语言在全球出版。',
    '沈从文': '沈从文（1902-1988），湖南凤凰人，中国现代作家、历史文物研究者。代表作《边城》以湘西风土人情为背景，被誉为中国现代文学史上最纯净的小说之一。',
    '老舍': '老舍（1899-1966），原名舒庆春，北京人。中国现代小说家、剧作家，语言大师。代表作《骆驼祥子》《四世同堂》《茶馆》等，以地道的北京方言和深刻的社会洞察著称。',
    '巴金': '巴金（1904-2005），原名李尧棠，四川成都人。中国现代作家、翻译家，代表作"激流三部曲"《家》《春》《秋》，以真挚的情感和对封建制度的批判影响了几代读者。',
    '曹禺': '曹禺（1910-1996），原名万家宝，湖北潜江人。中国现代剧作家，被誉为"中国的莎士比亚"。代表作《雷雨》《日出》《原野》是中国话剧史上的经典。',
    '张爱玲': '张爱玲（1920-1995），上海人，中国现代女作家。代表作《倾城之恋》《金锁记》《红玫瑰与白玫瑰》等，以细腻的心理描写和独特的文学风格在华语文坛独树一帜。',
    '朱自清': '朱自清（1898-1948），江苏扬州人，中国现代散文家、诗人。代表作《背影》《荷塘月色》《匆匆》等，其散文以真挚的情感和优美的文字打动无数读者。',
    '史铁生': '史铁生（1951-2010），北京人，中国当代作家、散文家。代表作《我与地坛》《务虚笔记》等，在轮椅上以深邃的哲思探讨生命的意义，感动了无数读者。',
    '余秋雨': '余秋雨（1946-），浙江余姚人，中国当代文化学者、散文家。代表作《文化苦旅》《山居笔记》等，以宏大的文化视野和优美的文笔探寻中华文明脉络。',
    '龙应台': '龙应台（1952-），台湾作家、文学评论家。代表作《目送》《亲爱的安德烈》《大江大海一九四九》等，以深情细腻的笔触书写亲情与社会关怀。',
    '梁实秋': '梁实秋（1903-1987），浙江杭州人，中国现代散文家、翻译家。代表作《雅舍小品》以幽默雅致的笔调描绘生活百态，是中国现代散文的经典之作。',
    '徐志摩': '徐志摩（1897-1931），浙江海宁人，中国现代诗人、散文家，新月派代表诗人。代表作《再别康桥》《翡冷翠的一夜》等，其诗歌以浪漫的情怀和优美的韵律著称。',
    '海子': '海子（1964-1989），原名查海生，安徽怀宁人，中国当代诗人。代表作《面朝大海，春暖花开》《以梦为马》等，以纯粹的诗意和炽热的情感成为中国当代诗歌的标志性人物。',
    '艾青': '艾青（1910-1996），浙江金华人，中国现代诗人。代表作《大堰河——我的保姆》《我爱这土地》等，以深沉的情感和强烈的时代感成为中国现代诗歌的杰出代表。',
    '霍金': '斯蒂芬·霍金（1942-2018），英国理论物理学家、宇宙学家。代表作《时间简史》以通俗易懂的语言向大众解释宇宙的奥秘，全球销量超过2500万册。',
    '冯友兰': '冯友兰（1895-1990），河南唐河人，中国哲学家、哲学史家。代表作《中国哲学简史》以简洁明了的语言梳理中国哲学发展脉络，是了解中国哲学的最佳入门读物。',
    '老子': '老子（约公元前571年-约公元前471年），姓李名耳，中国古代哲学家、思想家，道家学派创始人。代表作《道德经》以五千言阐述"道法自然"的哲学思想，影响深远。',
    '钱穆': '钱穆（1895-1990），江苏无锡人，中国现代历史学家、国学大师。代表作《国史大纲》以独特的视角和深厚的学养梳理中国历史，是了解中国通史的经典之作。',
    '当年明月': '当年明月（1979-），本名石悦，湖北武汉人，中国当代作家。代表作《明朝那些事儿》以幽默风趣的笔调讲述明朝三百年历史，开创了通俗历史写作的新风潮。',
    '黄仁宇': '黄仁宇（1918-2000），美籍华裔历史学家。代表作《万历十五年》以"大历史观"的独特视角剖析明朝历史，被誉为历史写作的经典范本。'
  };
  return intros[author] || `${author}，知名作家，其作品深受读者喜爱，在文学领域具有重要影响力。`;
};

const addOrder = () => {
  if (account.value.id == null) {
    ElMessage.warning("请登录");
    return;
  }
  if (addressId.value === '') {
    ElMessage.error('请选择您的收货地址');
    return;
  }
  request.post('/orders', {
    bookId: id,
    num: buyNum.value,
    addressId: addressId.value
  }).then(res => {
    if (res.code === '200') {
      ElMessage.success('已下单，请及时支付！');
      router.push('/front/orders');
    } else {
      ElMessage.error(res.msg);
    }
  });
};

const addCart = () => {
  if (account.value.id == null) {
    ElMessage.warning("请登录");
    return;
  }
  const data = { bookId: id, num: buyNum.value };
  request.post('/cart', data).then(res => {
    if (res.code === '200') {
      ElMessage.success('加入购物车成功');
    } else {
      ElMessage.error(res.msg);
    }
  });
};

const collect = (bookId) => {
  if (account.value.id == null) {
    ElMessage.warning("请登录");
    return;
  }
  let data = {
    bookId: bookId,
    userId: account.value.id
  };
  request.post("/collect", data).then(res => {
    if (res.code === '200') {
      goods.value.isCollected = true;
      ElMessage.success("收藏成功");
    } else {
      goods.value.isCollected = false;
      ElMessage.error(res.msg);
    }
  });
};

onMounted(() => {
  loadUser();
  loadGoods();
  loadAddress();
});
</script>

<template>
  <div class="page-container">

    <div class="product-layout">
      <div class="image-thumbnails">
        <div v-for="(img, index) in getImageList(goods.imgList)"
             :key="index"
             class="thumbnail-item"
             @click="changeImg(img)">
          <img :src="img" width="100" height="100">
        </div>
      </div>

      <div class="main-image">
        <img :src="goods.img" class="product-main-image" />
      </div>

      <div class="product-details">
        <h2 class="product-title">{{ goods.name }}</h2>
        <div class="product-description">{{ goods.description }}</div>

        <div class="price-section">
          <span class="currency">¥</span>
          <span class="price">{{ goods.price }}</span>
          <span class="unit-text">/本</span>
        </div>

        <div class="book-info-section">
          <div class="info-item">
            <span class="info-label">作者：</span>
            <span class="info-value">{{ goods.author }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">出版社：</span>
            <span class="info-value">{{ goods.publisher }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">出版日期：</span>
            <span class="info-value">{{ goods.publishDate }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">ISBN：</span>
            <span class="info-value">{{ goods.isbn }}</span>
          </div>
        </div>

        <div class="stats-section">
          <div class="stat-item">
            <el-icon class="stat-icon"><ShoppingBag /></el-icon>
            <span>已售 {{ goods.sales }}</span>
          </div>
          <div class="stat-item">
            <el-icon class="stat-icon"><ShoppingBag /></el-icon>
            <span>库存 {{ goods.inventory }}</span>
          </div>
          <div class="stat-item">
            <el-icon class="stat-icon"><StarFilled /></el-icon>
            <span>评分 {{ goods.rating }}</span>
          </div>
        </div>

        <div class="delivery-section">
          <el-icon class="delivery-icon"><Place /></el-icon>
          <span class="delivery-text">配送至</span>
          <el-select v-model="addressId" placeholder="请选择地址" class="address-select">
            <el-option
                v-for="address in addresses"
                :key="address.id"
                :label="`${address.name} - ${address.address} - ${address.phone}`"
                :value="address.id">
            </el-option>
          </el-select>
        </div>

        <div class="shipping-section">
          <el-icon class="shipping-icon"><Guide /></el-icon>
          <span>快递: 免运费</span>
          <span class="promotion-text">正版保证 假一赔十 平台承诺24小时内发货</span>
        </div>

        <div class="quantity-section">
          <span>数量: </span>
          <el-input-number class="quantity-input" v-model="buyNum" :min="1" :max="3"
                           label="数量"></el-input-number>
        </div>

        <div class="action-buttons">
          <button class="buy-button" @click="addOrder">直接购买</button>
          <button class="cart-button" @click="addCart">加入购物车</button>
          <button class="collect-button" @click="collect(goods.id)">
            <el-icon>
              <StarFilled v-if="goods.isCollected" />
              <Star v-else />
            </el-icon>
            收藏
          </button>
        </div>
      </div>
    </div>

    <el-tabs class="product-tabs">
      <el-tab-pane label="图书详情">
        <div class="detail-section">
          <div class="detail-block">
            <h3 class="detail-title">
              <span class="detail-title-icon">📖</span> 内容简介
            </h3>
            <div class="detail-content" v-html="goods.content"></div>
          </div>

          <div class="detail-block">
            <h3 class="detail-title">
              <span class="detail-title-icon">✍️</span> 作者简介
            </h3>
            <p class="detail-text">{{ getAuthorIntro(goods.author) }}</p>
          </div>

          <div class="detail-block">
            <h3 class="detail-title">
              <span class="detail-title-icon">📋</span> 图书信息
            </h3>
            <div class="book-specs">
              <div class="spec-row">
                <span class="spec-label">书  名</span>
                <span class="spec-value">{{ goods.name }}</span>
              </div>
              <div class="spec-row">
                <span class="spec-label">作  者</span>
                <span class="spec-value">{{ goods.author }}</span>
              </div>
              <div class="spec-row">
                <span class="spec-label">出 版 社</span>
                <span class="spec-value">{{ goods.publisher }}</span>
              </div>
              <div class="spec-row">
                <span class="spec-label">出版日期</span>
                <span class="spec-value">{{ goods.publishDate }}</span>
              </div>
              <div class="spec-row">
                <span class="spec-label">I S B N</span>
                <span class="spec-value">{{ goods.isbn }}</span>
              </div>
              <div class="spec-row">
                <span class="spec-label">定  价</span>
                <span class="spec-value spec-price">¥{{ goods.price }}</span>
              </div>
              <div class="spec-row">
                <span class="spec-label">销  量</span>
                <span class="spec-value">{{ goods.sales }} 本</span>
              </div>
              <div class="spec-row">
                <span class="spec-label">评  分</span>
                <span class="spec-value">{{ goods.rating }} / 5.0</span>
              </div>
            </div>
          </div>
        </div>
      </el-tab-pane>

      <el-tab-pane label="历史评价">
        <div class="comments-container">
          <div v-if="comments.length === 0" class="sample-comments">
            <div class="comment-item">
              <div class="comment-header">
                <div class="user-info">
                  <el-avatar :size="40" style="background: rgba(64,132,217,0.2); color: #4084d9; font-weight: 600;">书</el-avatar>
                  <div class="user-details">
                    <span class="username">书友_文学爱好者</span>
                    <span class="comment-time">2025-12-15</span>
                  </div>
                </div>
                <div class="product-info">
                  <span class="product-name">{{ goods.name }}</span>
                </div>
              </div>
              <div class="comment-content">
                <div class="rating-section">
                  <span class="rating-label">评分：</span>
                  <el-rate :model-value="5" disabled />
                </div>
                <div class="comment-text">
                  <div class="comment-label">评价内容：</div>
                  <div class="comment-body">非常满意的一次购书体验！书籍印刷精美，纸张质感很好，装帧设计也很用心。内容更是不用多说，经典之作值得反复阅读。</div>
                </div>
              </div>
            </div>
            <div class="comment-item">
              <div class="comment-header">
                <div class="user-info">
                  <el-avatar :size="40" style="background: rgba(64,132,217,0.2); color: #4084d9; font-weight: 600;">读</el-avatar>
                  <div class="user-details">
                    <span class="username">读者_知行合一</span>
                    <span class="comment-time">2025-11-28</span>
                  </div>
                </div>
                <div class="product-info">
                  <span class="product-name">{{ goods.name }}</span>
                </div>
              </div>
              <div class="comment-content">
                <div class="rating-section">
                  <span class="rating-label">评分：</span>
                  <el-rate :model-value="4" disabled />
                </div>
                <div class="comment-text">
                  <div class="comment-label">评价内容：</div>
                  <div class="comment-body">书的内容很好，是正版无疑。快递速度还可以，总体来说值得购买，推荐给喜欢阅读的朋友们。</div>
                </div>
              </div>
            </div>
          </div>
          <div v-else>
            <div v-for="comment in comments" :key="comment.id" class="comment-item">
              <div class="comment-header">
                <div class="user-info">
                  <el-avatar :src="users.find(item => item.id === comment.userId)?.avatarUrl" :size="40"/>
                  <div class="user-details">
                    <span class="username">{{ users.find(item => item.id === comment.userId)?.nickname }}</span>
                    <span class="comment-time">{{ comment.time }}</span>
                  </div>
                </div>
                <div class="product-info">
                  <span class="product-name">{{ comment.name }}</span>
                </div>
              </div>

              <div class="comment-content">
                <div class="rating-section">
                  <span class="rating-label">评分：</span>
                  <el-rate v-model="comment.rate" disabled></el-rate>
                </div>

                <div class="comment-text">
                  <div class="comment-label">评价内容：</div>
                  <div class="comment-body" v-html="comment.comment"></div>
                </div>

                <div v-if="comment.reply" class="reply-section">
                  <div class="reply-label">商家回复：</div>
                  <div class="reply-content">{{ comment.reply }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </el-tab-pane>
    </el-tabs>

    <div class="recommend-section" v-if="relatedBooks.length > 0">
      <h3 class="recommend-title">📚 知识图谱关联推荐</h3>
      <div class="recommend-grid">
        <div v-for="book in relatedBooks" :key="book.id" class="recommend-card" @click="router.push('/front/goodsDetail?id=' + book.id)">
          <img :src="book.img" class="recommend-img" />
          <div class="recommend-info">
            <div class="recommend-name">{{ book.name }}</div>
            <div class="recommend-price">¥{{ book.price }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page-container {
  width: 70%;
  margin: 0 auto;
  padding: 24px 20px;
  background: transparent;
  min-height: 100vh;
}

.product-layout {
  display: flex;
  gap: 24px;
  background: #ffffff;
  border-radius: 10px;
  padding: 20px;
  box-shadow: 0 1px 8px rgba(0, 0, 0, 0.04);
  border: 1px solid #ebeef5;
}

.image-thumbnails {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.thumbnail-item {
  margin-bottom: 10px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 8px;
  height: 100px;
  width: 100px;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  transition: all 0.25s ease;
  overflow: hidden;
}

.thumbnail-item:hover {
  border-color: #4084d9;
  box-shadow: 0 2px 8px rgba(64, 132, 217, 0.15);
}

.main-image {
  flex: 3;
  display: flex;
  justify-content: center;
  align-items: center;
}

.product-main-image {
  width: 500px;
  height: 500px;
  object-fit: cover;
  border-radius: 10px;
}

.product-details {
  flex: 4;
  padding: 0 20px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif;
  color: #303133;
  background: transparent;
  border-radius: 0;
  box-shadow: none;
}

.product-title {
  font-size: 22px;
  font-weight: 700;
  margin-bottom: 12px;
  color: #303133;
  letter-spacing: 0.5px;
}

.product-description {
  font-size: 14px;
  line-height: 1.7;
  color: #606266;
  margin-bottom: 20px;
}

.price-section {
  margin-bottom: 20px;
  padding: 16px 20px;
  background: rgba(64, 132, 217, 0.06);
  border-radius: 10px;
  border: 1px solid rgba(64, 132, 217, 0.08);
}

.currency {
  font-size: 16px;
  color: #6ba3e0;
  font-weight: 600;
}

.price {
  font-size: 30px;
  font-weight: 700;
  color: #6ba3e0;
}

.unit-text {
  font-size: 13px;
  color: #909399;
}

.book-info-section {
  margin-bottom: 20px;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 10px;
}

.info-item {
  display: flex;
  margin-bottom: 8px;
  font-size: 13px;
}

.info-item:last-child {
  margin-bottom: 0;
}

.info-label {
  min-width: 80px;
  color: #909399;
  font-weight: 500;
}

.info-value {
  color: #303133;
  flex: 1;
}

.stats-section {
  margin-bottom: 16px;
  display: flex;
  gap: 24px;
}

.stat-item {
  display: flex;
  align-items: center;
  font-size: 13px;
  color: #606266;
}

.stat-icon {
  margin-right: 6px;
  font-size: 18px;
  color: #4084d9;
}

.delivery-section {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
  font-size: 13px;
  color: #606266 !important;
}

.delivery-icon {
  margin-right: 6px;
  font-size: 18px;
  color: #4084d9;
}

.delivery-text {
  margin-right: 8px;
}

.address-select {
  width: 400px;
}

.shipping-section {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
  font-size: 13px;
  color: #909399;
}

.shipping-icon {
  margin-right: 6px;
  font-size: 18px;
  color: #4084d9;
}

.promotion-text {
  margin-left: 10px;
  color: #6ba3e0;
  font-weight: 500;
  font-size: 12px;
}

.quantity-section {
  display: flex;
  align-items: center;
  margin-bottom: 16px;
  font-size: 13px;
  color: #606266;
}

.quantity-input {
  margin-left: 10px;
}

.action-buttons {
  margin-top: 16px;
  margin-bottom: 16px;
  display: flex;
  gap: 10px;
}

.buy-button {
  padding: 10px 28px;
  background: linear-gradient(135deg, #4084d9 0%, #1a4f94 100%);
  color: #fff;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 600;
  transition: all 0.3s ease;
  letter-spacing: 0.5px;
}

.buy-button:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 16px rgba(64, 132, 217, 0.35);
}

.cart-button {
  padding: 10px 28px;
  border: 1px solid #4084d9;
  background: rgba(64, 132, 217, 0.08);
  color: #4084d9;
  cursor: pointer;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  transition: all 0.3s ease;
  letter-spacing: 0.5px;
}

.cart-button:hover {
  background: rgba(64, 132, 217, 0.15);
  border-color: #4084d9;
  transform: translateY(-1px);
  box-shadow: 0 4px 16px rgba(64, 132, 217, 0.2);
}

.collect-button {
  padding: 10px 20px;
  border: 1px solid #dcdfe6;
  background: #f5f7fa;
  cursor: pointer;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 14px;
  color: #606266;
  transition: all 0.25s ease;
}

.collect-button:hover {
  border-color: #4084d9;
  color: #4084d9;
}

.product-tabs {
  margin-top: 24px;
  background: #ffffff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
  border: 1px solid #ebeef5;
  overflow: hidden;
}

.product-tabs :deep(.el-tabs__content) {
  overflow: hidden;
}

.detail-section {
  padding: 8px 0;
  overflow: hidden;
}

.detail-block {
  margin-bottom: 32px;
  overflow: hidden;
}

.detail-block:last-child {
  margin-bottom: 0;
}

.detail-title {
  font-size: 16px;
  font-weight: 700;
  color: #303133;
  margin: 0 0 16px;
  padding-bottom: 10px;
  border-bottom: 1px solid #ebeef5;
  display: flex;
  align-items: center;
  gap: 8px;
}

.detail-title-icon {
  font-size: 18px;
}

.detail-content {
  color: #606266;
  line-height: 1.9;
  font-size: 14px;
  word-break: break-all;
  overflow-wrap: break-word;
  overflow: hidden;
  max-width: 100%;
}

.detail-content :deep(*) {
  max-width: 100%;
  box-sizing: border-box;
  word-break: break-all;
  overflow-wrap: break-word;
}

.detail-content :deep(img) {
  max-width: 100%;
  height: auto;
}

.detail-content :deep(table) {
  max-width: 100%;
  display: block;
  overflow-x: auto;
}

.detail-content :deep(pre) {
  white-space: pre-wrap;
  word-break: break-all;
}

.detail-text {
  color: #606266;
  line-height: 1.9;
  font-size: 14px;
  margin: 0;
}

.book-specs {
  background: #f5f7fa;
  border: 1px solid #ebeef5;
  border-radius: 10px;
  overflow: hidden;
}

.spec-row {
  display: flex;
  padding: 12px 18px;
  border-bottom: 1px solid #ebeef5;
  font-size: 13px;
}

.spec-row:last-child {
  border-bottom: none;
}

.spec-label {
  width: 100px;
  flex-shrink: 0;
  color: #909399;
  font-weight: 500;
}

.spec-value {
  color: #303133;
  flex: 1;
}

.spec-price {
  color: #6ba3e0;
  font-weight: 600;
}

.comments-container {
  padding: 16px 0;
}

.sample-comments {
  padding: 8px 0;
}

.comment-item {
  background: #f5f7fa;
  border: 1px solid #ebeef5;
  border-radius: 10px;
  padding: 20px;
  margin-bottom: 14px;
}

.comment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 14px;
  padding-bottom: 10px;
  border-bottom: 1px solid #ebeef5;
}

.user-info {
  display: flex;
  align-items: center;
}

.user-details {
  margin-left: 12px;
  display: flex;
  flex-direction: column;
}

.username {
  font-weight: 500;
  color: #303133;
  font-size: 14px;
}

.comment-time {
  color: #909399;
  font-size: 12px;
  margin-top: 2px;
}

.product-info {
  text-align: right;
}

.product-name {
  color: #909399;
  font-size: 13px;
  font-weight: 500;
}

.comment-content {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.rating-section {
  display: flex;
  align-items: center;
}

.rating-label {
  color: #606266;
  font-size: 13px;
  margin-right: 8px;
  min-width: 60px;
}

.comment-text {
  display: flex;
  flex-direction: column;
}

.comment-label {
  color: #606266;
  font-size: 13px;
  margin-bottom: 6px;
  font-weight: 500;
}

.comment-body {
  background: #ffffff;
  padding: 12px;
  border-radius: 8px;
  color: #606266;
  line-height: 1.6;
  font-size: 14px;
}

.reply-section {
  background: rgba(64, 132, 217, 0.08);
  padding: 12px;
  border-radius: 8px;
  border-left: 3px solid #4084d9;
}

.reply-label {
  color: #4084d9;
  font-size: 12px;
  font-weight: 600;
  margin-bottom: 4px;
}

.reply-content {
  color: #606266;
  font-size: 13px;
  line-height: 1.5;
}

.recommend-section {
  margin-top: 24px;
  background: #ffffff;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
  border: 1px solid #ebeef5;
}

.recommend-title {
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 16px;
  color: #303133;
}

.recommend-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 16px;
}

.recommend-card {
  background: #f5f7fa;
  border-radius: 8px;
  padding: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid #ebeef5;
}

.recommend-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 16px rgba(64, 132, 217, 0.2);
  border-color: rgba(64, 132, 217, 0.3);
}

.recommend-img {
  width: 100%;
  height: 160px;
  object-fit: cover;
  border-radius: 6px;
  margin-bottom: 8px;
}

.recommend-info {
  text-align: center;
}

.recommend-name {
  font-size: 13px;
  color: #2c3e50;
  margin-bottom: 4px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.recommend-price {
  font-size: 15px;
  color: #f56c6c;
  font-weight: 600;
}
</style>