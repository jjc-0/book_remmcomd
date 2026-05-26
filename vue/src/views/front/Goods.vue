<script setup>
import {ref, onMounted, reactive} from 'vue'
import { useRoute, useRouter } from 'vue-router'
import request from '../../utils/request'
const router = useRouter()
const route = useRoute()

const category = ref({})
const types = ref([])
const typeId = ref(route.query.typeId || '')
const pageNum = ref(1)
const pageSize = ref(12)
const total = ref(0)
// 搜索条件
const searchForm = reactive({
  keyword: '',
})
// 用户信息
const account = ref(localStorage.getItem('account') ? JSON.parse(localStorage.getItem('account')) : {})

const goods = ref([])
const sortBy = ref('all')

const load = () => {
  request.get("/book/front/page", {
    params: {
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      keyword: searchForm.keyword,
      categoryId: typeId.value,
      sortBy: sortBy.value
    }
  }).then(res => {
    if (res.data) {
      goods.value = res.data.records || []
      total.value = res.data?.total || 0
    }
  })
}

const loadCategory =  () => {
  if (typeId.value) {
    request.get("/book/category/" + typeId.value).then(res=>{
      category.value = res.data || {}
    })
  }
}

const loadType =  () => {
  request.get("/book/category").then(res=>{
    types.value = res.data || []
  })
}

const changeType = (id) => {
  typeId.value = id
  load()
  loadCategory()
}

const updateSort = (sortCriterion) => {
  sortBy.value = sortCriterion
  load()
}

const handleSizeChange = (newPageSize) => {
  pageSize.value = newPageSize
  load()
}

const handleCurrentChange = (newPageNum) => {
  pageNum.value = newPageNum
  load()
}

const reset = () => {
  name.value = ''
  typeId.value = ''
  load()
}

const cleanType = () => {
  location.href = '/front/goods?typeId=' + ''
}

const goHome = () => {
  router.push('/front/home')
}

const goToDetail = (id) => {
  router.push('/front/goodsDetail?id=' + id)
}


onMounted(() => {
  load()
  loadCategory()
  loadType()
})
</script>

<template>
  <div class="goods-wrapper">
    <div class="goods-container">
      <!-- 面包屑导航 -->
      <div class="breadcrumb">
      <span class="breadcrumb-item" @click="goHome">首页</span>
      <span class="breadcrumb-separator">/</span>
      <span class="breadcrumb-item" @click="cleanType">全部分类</span>
      <span v-if="typeId !== ''" class="breadcrumb-separator">/</span>
      <span v-if="typeId !== ''" class="breadcrumb-current">{{ category.name }}</span>
    </div>

    <!-- 分类筛选 -->
    <div v-if="typeId === ''" class="category-filter">
      <div class="filter-header">
        <span class="filter-label">图书分类</span>
      </div>
      <div class="category-list">
        <span
            v-for="item in types"
            :key="item.id"
            :class="{ active: typeId === item.id }"
            @click="changeType(item.id)"
            class="category-item">
          {{ item.name }}
        </span>
      </div>
    </div>

    <!-- 排序选项 -->
    <div class="sort-filter">
      <div class="sort-label">排序方式</div>
      <div class="sort-options">
        <button :class="{ active: sortBy === 'all' }" @click="updateSort('all')">
          <span class="sort-text">综合排序</span>
        </button>
        <button :class="{ active: sortBy === 'new' }" @click="updateSort('new')">
          <span class="sort-text">新品优先</span>
        </button>
        <button :class="{ active: sortBy === 'sales' }" @click="updateSort('sales')">
          <span class="sort-text">销量最高</span>
        </button>
      </div>
      <div class="result-count">
        共 <span class="count-number">{{ total }}</span> 本图书
      </div>
    </div>

    <!-- 图书网格 -->
    <div class="goods-grid">
      <div v-for="good in goods" :key="good.id" class="goods-card" @click="goToDetail(good.id)">
        <div class="goods-image-wrapper">
          <img :src="good.img" class="goods-image">
          <div class="goods-overlay">
            <div class="view-btn">查看详情</div>
          </div>
        </div>
        <div class="goods-info">
          <h3 class="goods-name">{{ good.name }}</h3>
          <div class="goods-author">{{ good.author }}</div>
          <div class="goods-meta">
            <div class="goods-price">
              <span class="price-symbol">¥</span>
              <span class="price-value">{{ good.price }}</span>
            </div>
            <div class="goods-tags">
              <span class="tag inventory">库存 {{ good.inventory }}</span>
              <span class="tag sales">销量 {{ good.sales }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 分页 -->
    <div class="pagination-container">
      <el-pagination
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          :current-page="pageNum"
          :page-sizes="[12, 24, 36, 48]"
          :page-size="pageSize"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total">
      </el-pagination>
    </div>
    </div>
  </div>
</template>

<style scoped>
.goods-wrapper {
  width: 100%;
  min-height: 100vh;
  background: transparent;
}

.goods-container {
  width: 1400px;
  margin: 0 auto;
  padding: 24px 20px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif;
}

.breadcrumb {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
  padding: 14px 20px;
  background: #ffffff;
  border-radius: 10px;
  box-shadow: 0 1px 8px rgba(0, 0, 0, 0.04);
  border: 1px solid #ebeef5;
}

.breadcrumb-item {
  color: #909399;
  font-size: 14px;
  cursor: pointer;
  transition: color 0.25s ease;
}

.breadcrumb-item:hover {
  color: #4084d9;
}

.breadcrumb-separator {
  margin: 0 8px;
  color: #fff;
  font-size: 12px;
}

.breadcrumb-current {
  color: #303133;
  font-size: 14px;
  font-weight: 500;
}

.category-filter {
  background: #ffffff;
  border-radius: 10px;
  padding: 20px;
  margin-bottom: 20px;
  box-shadow: 0 1px 8px rgba(0, 0, 0, 0.04);
  border: 1px solid #ebeef5;
}

.filter-header {
  margin-bottom: 14px;
}

.sort-label {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.category-list {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.category-item {
  padding: 7px 18px;
  border-radius: 8px;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.6);
  cursor: pointer;
  transition: all 0.25s ease;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid transparent;
}

.category-item:hover {
  background: rgba(64, 132, 217, 0.1);
  color: #4084d9;
  border-color: rgba(64, 132, 217, 0.3);
  transform: translateY(-1px);
}

.category-item.active {
  background: linear-gradient(135deg, #4084d9 0%, #1a4f94 100%);
  color: #fff;
  border-color: #4084d9;
}

.sort-filter {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #ffffff;
  border-radius: 10px;
  padding: 16px 20px;
  margin-bottom: 24px;
  box-shadow: 0 1px 8px rgba(0, 0, 0, 0.04);
  border: 1px solid #ebeef5;
}

.sort-label {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.sort-options {
  display: flex;
  gap: 8px;
}

.sort-options button {
  padding: 7px 18px;
  border-radius: 8px;
  background: #f5f7fa;
  border: 1px solid transparent;
  cursor: pointer;
  transition: all 0.25s ease;
  font-size: 13px;
  color: #606266;
  outline: none;
}

.sort-options button:hover {
  background: rgba(64, 132, 217, 0.1);
  color: #4084d9;
  border-color: rgba(64, 132, 217, 0.3);
}

.sort-options button.active {
  background: linear-gradient(135deg, #4084d9 0%, #1a4f94 100%);
  color: #fff;
  border-color: #4084d9;
}

.result-count {
  font-size: 13px;
  color: #909399;
}

.count-number {
  color: #4084d9;
  font-weight: 600;
  font-size: 15px;
}

.goods-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 16px;
  margin-bottom: 32px;
}

.goods-card {
  background: #ffffff;
  border-radius: 10px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
  border: 1px solid #ebeef5;
}

.goods-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
  border-color: rgba(64, 132, 217, 0.3);
}

.goods-image-wrapper {
  position: relative;
  overflow: hidden;
  aspect-ratio: 3/4;
  background: #f5f7fa;
}

.goods-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.4s ease;
}

.goods-card:hover .goods-image {
  transform: scale(1.06);
}

.goods-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(26, 79, 148, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.goods-card:hover .goods-overlay {
  opacity: 1;
}

.view-btn {
  padding: 8px 20px;
  background: rgba(64, 132, 217, 0.8);
  color: #fff;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 500;
  border: 1px solid rgba(255, 255, 255, 0.3);
  transform: translateY(20px);
  transition: transform 0.3s ease;
}

.goods-card:hover .view-btn {
  transform: translateY(0);
}

.goods-info {
  padding: 16px;
}

.goods-name {
  margin: 0 0 6px;
  font-size: 15px;
  color: #2c3e50;
  font-weight: 600;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
  line-height: 1.4;
}

.goods-author {
  font-size: 12px;
  color: #909399;
  margin-bottom: 10px;
}

.goods-meta {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.goods-price {
  display: flex;
  align-items: baseline;
  gap: 2px;
}

.price-symbol {
  font-size: 13px;
  color: #e74c3c;
  font-weight: 600;
}

.price-value {
  font-size: 18px;
  color: #e74c3c;
  font-weight: 700;
}

.goods-tags {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.tag {
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 500;
}

.tag.inventory {
  background: rgba(46, 125, 50, 0.08);
  color: #2e7d32;
}

.tag.sales {
  background: rgba(230, 81, 0, 0.08);
  color: #e65100;
}

.pagination-container {
  display: flex;
  justify-content: center;
  padding: 24px 0;
  background: #ffffff;
  border-radius: 10px;
}

@media (max-width: 1400px) {
  .goods-container {
    width: 100%;
    padding: 20px 16px;
  }
  
  .goods-grid {
    grid-template-columns: repeat(3, 1fr);
    gap: 16px;
  }
}

@media (max-width: 1200px) {
  .goods-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .sort-filter {
    flex-direction: column;
    gap: 14px;
    align-items: flex-start;
  }
  
  .sort-options {
    width: 100%;
    flex-wrap: wrap;
  }
}

@media (max-width: 768px) {
  .goods-container {
    padding: 16px 12px;
  }
  
  .breadcrumb,
  .category-filter,
  .sort-filter {
    padding: 14px;
  }
  
  .goods-grid {
    grid-template-columns: 1fr;
    gap: 14px;
  }
  
  .category-list {
    gap: 8px;
  }
  
  .category-item {
    padding: 6px 14px;
    font-size: 12px;
  }
  
  .goods-info {
    padding: 14px;
  }
  
  .goods-name {
    font-size: 14px;
  }
  
  .price-value {
    font-size: 16px;
  }
}
</style>