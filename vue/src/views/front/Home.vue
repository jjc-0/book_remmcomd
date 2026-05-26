<script setup>
import { ref, computed, onMounted } from 'vue'
import { ArrowRight, ShoppingCart, StarFilled, Bell, Location } from '@element-plus/icons-vue'
import request from '../../utils/request'
import BookGallery from './components/BookGallery.vue'
import { useRouter } from "vue-router"

const router = useRouter()

const types = ref([])
const category = ref([])
const banners = ref([])
const recommend = ref([])
const account = ref(localStorage.getItem('account') ? JSON.parse(localStorage.getItem('account')) : {})
const isGuest = computed(() => !account.value.id)

const load = () => {
  request.get("/book/recommend").then(res => {
    recommend.value = res.data
  })
}

const loadType = () => {
  request.get("/book/category").then(res => {
    types.value = res.data
  })
}

const loadCategory = () => {
  request.get("/book/category").then(res => {
    category.value = res.data || []
  })
}

const loadBanner = () => {
  request.get("/banner").then(res => {
    banners.value = res.data
  })
}

onMounted(() => {
  load()
  loadType()
  loadBanner()
  loadCategory()
})
</script>

<template>
  <div class="home-wrapper">
    <div class="home">
      <!-- 公告栏 - 极简 -->
      <div class="notice-bar">
        <el-icon class="notice-dot"><Bell /></el-icon>
        <el-carousel height="28px" direction="vertical" :autoplay="true" :interval="4000" indicator-position="none" class="notice-scroll">
          <el-carousel-item>
            <span class="notice-txt">本系统基于知识图谱构建图书关联关系网络，精准挖掘用户阅读偏好，实现个性化智能图书推荐</span>
          </el-carousel-item>
          <el-carousel-item>
            <span class="notice-txt">依托图书知识图谱多维关联分析，智能匹配阅读喜好，高效推送优质书单</span>
          </el-carousel-item>
        </el-carousel>
      </div>

      <!-- 3D图书旋转画廊 -->
      <BookGallery />

      <!-- 分类标签 - 横向简约 -->
      <div class="cat-tags">
        <span
          v-for="type in types"
          :key="type.id"
          class="cat-tag"
          @click="router.push('/front/goods?typeId=' + type.id)"
        >{{ type.name }}</span>
      </div>

      <!-- 主视觉区：轮播 + 用户 -->
      <div class="hero-section">
        <div class="hero-carousel">
          <el-carousel height="420px" class="main-carousel" :interval="5000" arrow="hover">
            <el-carousel-item v-for="banner in banners" :key="banner.id">
              <div class="banner-cell">
                <img :src="banner.img" class="banner-img">
                <div class="banner-text">
                  <p class="banner-label">{{ banner.name }}</p>
                  <p class="banner-hint">{{ banner.info }}</p>
                </div>
              </div>
            </el-carousel-item>
          </el-carousel>
        </div>

        <div class="hero-user">
          <div class="user-panel">
            <div class="user-head">
              <img v-if="!isGuest" :src="account.avatarUrl" class="avatar" />
              <img v-else src="../../assets/用户头像.svg" class="avatar" />
              <div class="user-meta">
                <span class="user-name">{{ isGuest ? '游客' : account.nickname }}</span>
                <span class="user-role">{{ isGuest ? '探索知识海洋' : '欢迎回来' }}</span>
              </div>
            </div>
            <p class="user-tip">{{ isGuest ? '登录后享受个性化图书推荐' : '基于您的偏好，发现更多好书' }}</p>
            <el-button class="user-btn" @click="isGuest ? router.push('/login') : router.push('/front/orders')">
              {{ isGuest ? '立即登录' : '我的订单' }}
            </el-button>
          </div>
          <div class="user-actions">
            <div class="act-item" @click="router.push('/front/cart')">
              <el-icon class="act-icon"><ShoppingCart /></el-icon>
              <span>购物车</span>
            </div>
            <div class="act-item" @click="router.push('/front/collect')">
              <el-icon class="act-icon"><StarFilled /></el-icon>
              <span>收藏夹</span>
            </div>
            <div class="act-item" @click="router.push('/front/address')">
              <el-icon class="act-icon"><Location /></el-icon>
              <span>地址</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 精选推荐 -->
      <div class="recommend-section">
        <div class="sec-head">
          <div class="sec-title-group">
            <h2 class="sec-title">精选推荐</h2>
            <span class="sec-sub">为你发现好书</span>
          </div>
        </div>
        <div class="rec-grid">
          <div v-for="product in recommend" :key="product.id" class="rec-card"
               @click="router.push('/front/goodsDetail?id=' + product.id)">
            <div class="rec-cover">
              <img :src="product.img" class="rec-img" />
            </div>
            <div class="rec-info">
              <h4 class="rec-name">{{ product.name }}</h4>
              <span class="rec-author">{{ product.author }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 分类图书 -->
      <div class="category-section" v-for="item in category" :key="item.id">
        <div class="sec-head">
          <div class="sec-title-group">
            <h2 class="sec-title">{{ item.name }}</h2>
            <span class="sec-sub">浏览更多</span>
          </div>
          <span class="sec-more" @click="router.push('/front/goods?typeId=' + item.id)">
            查看全部 <el-icon><ArrowRight /></el-icon>
          </span>
        </div>
        <div class="cat-grid">
          <div v-for="book in item.bookList" :key="book.id" class="cat-card"
               @click="router.push('/front/goodsDetail?id=' + book.id)">
            <div class="cat-cover">
              <img :src="book.img" class="cat-img" />
            </div>
            <div class="cat-info">
              <span class="cat-name">{{ book.name }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.home-wrapper {
  width: 100%;
  min-height: 100vh;
  background: #ffffff;
}

.home {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'PingFang SC', 'Microsoft YaHei', sans-serif;
  width: 1320px;
  max-width: 100%;
  margin: 0 auto;
  padding: 20px 24px 60px;
}

/* ====== 公告栏 ====== */
.notice-bar {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
  padding: 0 4px;
  height: 36px;
}

.notice-dot {
  color: #4084d9;
  font-size: 15px;
  flex-shrink: 0;
}

.notice-scroll {
  flex: 1;
  height: 28px;
}

.notice-txt {
  color: #606266;
  font-size: 13px;
  letter-spacing: 0.3px;
}

/* ====== 分类标签 ====== */
.cat-tags {
  display: flex;
  justify-content: center;
  gap: 8px;
  margin-bottom: 28px;
  flex-wrap: wrap;
}

.cat-tag {
  padding: 7px 20px;
  border-radius: 20px;
  font-size: 13px;
  color: #606266;
  background: #f5f7fa;
  border: 1px solid #e4e7ed;
  cursor: pointer;
  transition: all 0.3s ease;
  letter-spacing: 0.5px;
}

.cat-tag:hover {
  color: #fff;
  background: rgba(64, 132, 217, 0.65);
  border-color: rgba(64, 132, 217, 0.5);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(64, 132, 217, 0.15);
}

/* ====== 主视觉区 ====== */
.hero-section {
  display: flex;
  gap: 20px;
  margin-bottom: 36px;
}

.hero-carousel {
  flex: 1;
  border-radius: 14px;
  overflow: hidden;
  min-width: 0;
}

.main-carousel {
  border-radius: 14px;
}

.banner-cell {
  position: relative;
  height: 100%;
  overflow: hidden;
  border-radius: 14px;
}

.banner-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.6s ease;
}

.banner-cell:hover .banner-img {
  transform: scale(1.04);
}

.banner-text {
  position: absolute;
  bottom: 32px;
  left: 36px;
  right: 36px;
}

.banner-label {
  font-size: 24px;
  font-weight: 700;
  color: #fff;
  margin: 0 0 6px;
  letter-spacing: 1px;
}

.banner-hint {
  font-size: 13px;
  color: #fff;
  margin: 0;
  max-width: 480px;
}

/* ====== 用户面板 ====== */
.hero-user {
  width: 280px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.user-panel {
  background: #ffffff;
  border: 1px solid #ebeef5;
  border-radius: 14px;
  padding: 24px;
}

.user-head {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 16px;
}

.avatar {
  width: 52px;
  height: 52px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #e4e7ed;
}

.user-meta {
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.user-name {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.user-role {
  font-size: 12px;
  color: #909399;
}

.user-tip {
  font-size: 12px;
  color: #909399;
  text-align: center;
  margin: 0 0 14px;
  line-height: 1.6;
}

.user-btn {
  width: 100%;
  height: 38px;
  border-radius: 10px;
  font-size: 13px;
  font-weight: 600;
  letter-spacing: 0.5px;
  background: rgba(64, 132, 217, 0.2) !important;
  border: 1px solid rgba(64, 132, 217, 0.3) !important;
  color: #4084d9 !important;
  transition: all 0.3s ease;
}

.user-btn:hover {
  background: rgba(64, 132, 217, 0.35) !important;
  border-color: rgba(64, 132, 217, 0.5) !important;
  transform: translateY(-1px);
  box-shadow: 0 4px 16px rgba(64, 132, 217, 0.2);
}

.user-actions {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
}

.act-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
  padding: 12px 4px;
  border-radius: 12px;
  background: #f5f7fa;
  border: 1px solid #ebeef5;
  cursor: pointer;
  transition: all 0.28s ease;
}

.act-item:hover {
  background: rgba(64, 132, 217, 0.1);
  border-color: rgba(64, 132, 217, 0.2);
  transform: translateY(-2px);
}

.act-icon {
  font-size: 18px;
  color: #909399;
  transition: color 0.28s ease;
}

.act-item:hover .act-icon {
  color: #4084d9;
}

.act-item span {
  font-size: 11px;
  color: #909399;
}

/* ====== 精选推荐 ====== */
.recommend-section {
  margin-bottom: 36px;
  padding: 32px;
  background: #ffffff;
  border: 1px solid #ebeef5;
  border-radius: 16px;
}

.sec-head {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  margin-bottom: 24px;
}

.sec-title-group {
  display: flex;
  align-items: baseline;
  gap: 12px;
}

.sec-title {
  font-size: 22px;
  font-weight: 700;
  color: #303133;
  margin: 0;
  letter-spacing: 0.5px;
}

.sec-sub {
  font-size: 13px;
  color: #909399;
}

.sec-more {
  font-size: 13px;
  color: #909399;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 4px;
  transition: all 0.28s ease;
}

.sec-more:hover {
  color: #4084d9;
  gap: 8px;
}

.rec-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 16px;
}

.rec-card {
  border-radius: 12px;
  overflow: hidden;
  cursor: pointer;
  background: #ffffff;
  border: 1px solid #ebeef5;
  transition: all 0.35s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}

.rec-card:hover {
  transform: translateY(-6px);
  border-color: rgba(64, 132, 217, 0.25);
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.08);
}

.rec-cover {
  aspect-ratio: 3/4;
  overflow: hidden;
  background: #f5f7fa;
}

.rec-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.5s ease;
}

.rec-card:hover .rec-img {
  transform: scale(1.05);
}

.rec-info {
  padding: 14px 16px;
}

.rec-name {
  font-size: 14px;
  font-weight: 600;
  color: #2c3e50;  /* rec-name */
  margin: 0 0 6px;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
  line-height: 1.5;
}

.rec-author {
  font-size: 12px;
  color: #909399;
}

/* ====== 分类图书 ====== */
.category-section {
  margin-bottom: 36px;
  padding: 32px;
  background: #ffffff;
  border: 1px solid #ebeef5;
  border-radius: 16px;
}

.category-section:last-child {
  margin-bottom: 0;
}

.cat-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 16px;
}

.cat-card {
  border-radius: 12px;
  overflow: hidden;
  cursor: pointer;
  background: #ffffff;
  border: 1px solid #ebeef5;
  transition: all 0.35s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}

.cat-card:hover {
  transform: translateY(-4px);
  border-color: rgba(64, 132, 217, 0.2);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
}

.cat-cover {
  aspect-ratio: 3/4;
  overflow: hidden;
  background: #f5f7fa;
}

.cat-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.5s ease;
}

.cat-card:hover .cat-img {
  transform: scale(1.05);
}

.cat-info {
  padding: 12px 14px;
}

.cat-name {
  font-size: 13px;
  font-weight: 600;
  color: #2c3e50;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  display: block;
}

/* ====== 响应式 ====== */
@media (max-width: 1400px) {
  .home {
    width: 100%;
    padding: 16px 20px 48px;
  }
  .hero-user {
    width: 260px;
  }
  .rec-grid {
    grid-template-columns: repeat(4, 1fr);
  }
  .cat-grid {
    grid-template-columns: repeat(5, 1fr);
  }
}

@media (max-width: 1100px) {
  .hero-section {
    flex-direction: column;
  }
  .hero-user {
    width: 100%;
    flex-direction: row;
  }
  .user-panel {
    flex: 1;
  }
  .user-actions {
    width: 240px;
    flex-shrink: 0;
  }
  .rec-grid {
    grid-template-columns: repeat(3, 1fr);
  }
  .cat-grid {
    grid-template-columns: repeat(4, 1fr);
  }
}

@media (max-width: 768px) {
  .home {
    padding: 12px 14px 40px;
  }
  .hero-user {
    flex-direction: column;
  }
  .user-actions {
    width: 100%;
  }
  .rec-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
  }
  .cat-grid {
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
  }
  .recommend-section,
  .category-section {
    padding: 20px;
  }
  .sec-title {
    font-size: 18px;
  }
  .banner-label {
    font-size: 18px;
  }
}

@media (max-width: 480px) {
  .cat-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
