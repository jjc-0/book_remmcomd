<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import request from '@/utils/request.js'

const route = useRoute()
const router = useRouter()

// 响应式数据
const typeId = ref('')
const keyword = ref(route.query.keyword || '')
const goods = ref([])
const pageNum = ref(1)
const pageSize = ref(12)
const total = ref(0)
const sortBy = ref('all')
// 方法
const load = () => {
  request.get("/book/front/page", {
    params: {
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      keyword: keyword.value,
      categoryId: typeId.value,
      sortBy: sortBy.value
    }
  }).then(res => {
    if (res.code === '200') {
      goods.value = res.data.records || []
      total.value = res.data?.total || 0
    }
  })
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

// 生命周期
onMounted(() => {
  load()
  loadType()
})

const types = ref([])
const loadType = () => {
  request.get('/book/category').then(res => {
    types.value = res.data
  })
}

// 分类切换方法
const handleTypeChange = (id) => {
  typeId.value = id
  pageNum.value = 1 // 重置到第一页
  load()
}

</script>

<template>
  <div class="home-container">
    <!-- 分类筛选区域 -->
    <div class="category-filter-section">
      <div class="filter-title">图书分类：</div>
      <div class="category-buttons">
        <el-button
            :type="typeId === '' ? 'primary' : 'default'"
            size="small"
            @click="handleTypeChange('')">
          全部
        </el-button>
        <el-button
            v-for="type in types"
            :key="type.id"
            :type="typeId === type.id ? 'primary' : 'default'"
            size="small"
            @click="handleTypeChange(type.id)">
          {{ type.name }}
        </el-button>
      </div>

    </div>

    <div class="filters">
      <div class="sort-options">
        <button :class="{ active: sortBy === 'all' }" @click="updateSort('all')">综合</button>
        <button :class="{ active: sortBy === 'new' }" @click="updateSort('new')">新品</button>
        <button :class="{ active: sortBy === 'sales' }" @click="updateSort('sales')">销量</button>
      </div>
    </div>

    <div style="margin-top: 20px;">
      <h2>搜索图书: {{keyword || '无'}}</h2>
    </div>

    <el-divider></el-divider>

    <div class="good-grid">
      <div v-for="good in goods" :key="good.id" class="good-card"
           @click="router.push('/front/goodsDetail?id=' + good.id)">
        <img :src="good.img" class="good-image">
        <h3>{{ good.name }}</h3>
        <div class="good-info">
          <span class="price">{{ good.price }}元/{{ good.unit }}</span>
        </div>
        <div class="tags">
          <span class="tag installment">库存{{ good.inventory }}</span>
          <span class="tag coupon">销量{{ good.sales }}</span>
        </div>
      </div>
    </div>

    <div style="padding: 10px 0;text-align: center;margin-top: 10px;">
      <el-pagination
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          :current-page="pageNum"
          :page-sizes="[4, 8, 12, 16]"
          :page-size="pageSize"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total">
      </el-pagination>
    </div>

  </div>
</template>



<style lang="scss" scoped>
.home-container {
  width: 80%;
  margin: 0 auto;
  padding: 24px 20px;
  background: transparent;
  min-height: 100vh;
}

.filters {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  margin-top: 20px;
}

.category-filter {
  font-size: 14px;
}

.active-filter {
  color: #4084d9;
}

.sort-options button {
  background: none;
  border: none;
  cursor: pointer;
  margin-right: 15px;
  font-size: 14px;
  color: #909399;
  transition: color 0.25s ease;
}

.sort-options button.active {
  color: #4084d9;
  font-weight: 600;
}

.additional-filters {
  display: flex;
  align-items: center;
  margin-top: 10px;
}

.additional-filters > * {
  margin-left: 15px;
}

.good-grid {
  cursor: pointer;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

.good-card {
  background: #ffffff;
  border: 1px solid #ebeef5;
  border-radius: 10px;
  padding: 15px;
  text-align: center;
  transition: all 0.3s ease;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
  overflow: hidden;
}

.good-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
  border-color: rgba(64, 132, 217, 0.3);
}

.good-image {
  width: auto;
  height: 300px;
  margin-bottom: 10px;
  transition: transform 0.3s ease;
}

.good-card:hover .good-image {
  transform: scale(1.03);
}

.good-card h3 {
  font-size: 14px;
  margin-bottom: 10px;
  color: #2c3e50;
}

.price {
  color: #e74c3c;
  font-weight: 700;
  font-size: 18px;
}

.tags {
  display: flex;
  justify-content: center;
}

.tag {
  padding: 2px 5px;
  font-size: 12px;
  margin: 0 2px;
  border-radius: 4px;
}

.installment {
  background: rgba(46, 125, 50, 0.08);
  color: #2e7d32;
}

.coupon {
  background: rgba(230, 81, 0, 0.08);
  color: #e65100;
}

.category-filter-section {
  margin-top: 20px;
  margin-bottom: 20px;
  padding: 18px;
  background: #ffffff;
  border-radius: 10px;
  border: 1px solid #ebeef5;
  box-shadow: 0 1px 8px rgba(0, 0, 0, 0.04);
}

.filter-title {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
  margin-bottom: 10px;
}

.category-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.category-buttons .el-button {
  border-radius: 8px;
  padding: 6px 16px;
  font-size: 13px;
  transition: all 0.25s ease;
}

.category-buttons .el-button--default {
  background: #f5f7fa;
  border-color: #dcdfe6;
  color: #606266;
}

.category-buttons .el-button--default:hover {
  background: rgba(64, 132, 217, 0.15);
  border-color: rgba(64, 132, 217, 0.3);
  color: #4084d9;
}

.category-buttons .el-button--primary {
  background: linear-gradient(135deg, #4084d9 0%, #1a4f94 100%);
  border-color: #4084d9;
}
</style>