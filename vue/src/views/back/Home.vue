<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import {
  Document, Collection, Connection, User, Tickets, DataAnalysis,
  Reading, Notebook, TrendCharts, Management
} from '@element-plus/icons-vue'
import request from '../../utils/request'

const router = useRouter()

const stats = ref({
  bookCount: 0,
  categoryCount: 0,
  entityCount: 0,
  relationCount: 0,
  userCount: 0,
  orderCount: 0,
  behaviorCount: 0
})

const loading = ref(true)

const loadDashboard = () => {
  loading.value = true
  request.get('/echarts/dashboard').then(res => {
    if (res.data) {
      stats.value = res.data
    }
  }).finally(() => {
    loading.value = false
  })
}

const statCards = [
  { key: 'bookCount', label: '图书总数', icon: Reading, gradient: 'linear-gradient(135deg, #667eea55, #764ba255)' },
  { key: 'categoryCount', label: '分类数量', icon: Collection, gradient: 'linear-gradient(135deg, #43e97b55, #38f9d755)' },
  { key: 'entityCount', label: '知识实体', icon: Connection, gradient: 'linear-gradient(135deg, #fa709a55, #fee14055)' },
  { key: 'relationCount', label: '实体关系', icon: TrendCharts, gradient: 'linear-gradient(135deg, #a18cd155, #fbc2eb55)' },
  { key: 'userCount', label: '用户数量', icon: User, gradient: 'linear-gradient(135deg, #667eea55, #764ba255)' },
  { key: 'orderCount', label: '订单总数', icon: Tickets, gradient: 'linear-gradient(135deg, #43e97b55, #38f9d755)' },
  { key: 'behaviorCount', label: '用户行为', icon: DataAnalysis, gradient: 'linear-gradient(135deg, #fa709a55, #fee14055)' }
]

const quickLinks = [
  { path: '/back/echarts', label: '数据统计', icon: DataAnalysis, desc: '图书分类与知识图谱统计图表' },
  { path: '/back/recommendAnalyze', label: '算法分析', icon: Connection, desc: 'CF+KG推荐算法对比与可视化' },
  { path: '/back/type', label: '分类管理', icon: Management, desc: '管理图书分类层级体系' },
  { path: '/back/orders', label: '订单管理', icon: Document, desc: '查看与处理用户订单' }
]

onMounted(() => {
  loadDashboard()
})
</script>

<template>
  <div class="dashboard">
    <div class="welcome-section">
      <div class="welcome-glow"></div>
      <div class="welcome-text">
        <h1>基于知识图谱的图书推荐系统</h1>
        <p>融合 Neo4j 知识图谱与协同过滤，实现精准个性化图书推荐</p>
      </div>
    </div>

    <div class="section-title">数据概览</div>
    <div class="stats-grid" v-loading="loading">
      <div
        v-for="card in statCards"
        :key="card.key"
        class="stat-card"
      >
        <div class="stat-icon" :style="{ background: card.gradient }">
          <el-icon :size="24"><component :is="card.icon" /></el-icon>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats[card.key] }}</span>
          <span class="stat-label">{{ card.label }}</span>
        </div>
      </div>
    </div>

    <div class="section-title">快捷操作</div>
    <div class="quick-grid">
      <div
        v-for="link in quickLinks"
        :key="link.path"
        class="quick-card"
        @click="router.push(link.path)"
      >
        <div class="quick-icon">
          <el-icon :size="22"><component :is="link.icon" /></el-icon>
        </div>
        <div class="quick-info">
          <span class="quick-label">{{ link.label }}</span>
          <span class="quick-desc">{{ link.desc }}</span>
        </div>
        <div class="quick-arrow">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
        </div>
      </div>
    </div>

    <div class="info-section">
      <div class="info-icon">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
      </div>
      <p>本系统基于 Neo4j 知识图谱构建图书·作者·分类·出版社之间的语义关系网络，结合协同过滤与用户行为分析，通过 α 加权融合实现 Top-N 个性化图书推荐。</p>
    </div>
  </div>
</template>

<style scoped>
.dashboard {
  padding: 24px;
  max-width: 1320px;
  margin: 0 auto;
}

.section-title {
  font-size: 13px;
  font-weight: 600;
  color: #909399;
  text-transform: uppercase;
  letter-spacing: 2px;
  margin-bottom: 14px;
  padding-left: 4px;
}

/* ====== 欢迎区 ====== */
.welcome-section {
  position: relative;
  background: linear-gradient(135deg, rgba(64,132,217,0.06) 0%, rgba(118,75,162,0.06) 50%, rgba(64,132,217,0.04) 100%);
  border: 1px solid #e4e7ed;
  border-radius: 16px;
  padding: 40px 44px;
  margin-bottom: 32px;
  overflow: hidden;
}

.welcome-glow {
  position: absolute;
  top: -60px;
  right: -60px;
  width: 200px;
  height: 200px;
  background: radial-gradient(circle, rgba(64,132,217,0.06), transparent 70%);
  border-radius: 50%;
  pointer-events: none;
}

.welcome-text h1 {
  margin: 0 0 10px 0;
  font-size: 26px;
  font-weight: 700;
  color: #2c3e50;
  letter-spacing: 1px;
  position: relative;
  z-index: 1;
}

.welcome-text p {
  margin: 0;
  font-size: 14px;
  color: #909399;
  position: relative;
  z-index: 1;
}

/* ====== 统计卡片 ====== */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
  margin-bottom: 32px;
}

.stat-card {
  background: #ffffff;
  border: 1px solid #ebeef5;
  border-radius: 14px;
  padding: 22px 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  transition: all 0.3s ease;
  cursor: default;
}

.stat-card:hover {
  background: #f5f7fa;
  border-color: #c6e2ff;
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0,0,0,0.06);
}

.stat-icon {
  width: 52px;
  height: 52px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  color: #606266;
  border: 1px solid #ebeef5;
}

.stat-info {
  display: flex;
  flex-direction: column;
}

.stat-value {
  font-size: 30px;
  font-weight: 700;
  color: #303133;
  line-height: 1.1;
  font-variant-numeric: tabular-nums;
}

.stat-label {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

/* ====== 快捷操作 ====== */
.quick-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-bottom: 28px;
}

.quick-card {
  background: #ffffff;
  border: 1px solid #ebeef5;
  border-radius: 14px;
  padding: 20px 18px;
  display: flex;
  align-items: center;
  gap: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.quick-card:hover {
  background: #ecf5ff;
  border-color: rgba(64,132,217,0.3);
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(64,132,217,0.08);
}

.quick-card:hover .quick-arrow {
  opacity: 1;
  transform: translateX(0);
}

.quick-icon {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  background: #f5f7fa;
  border: 1px solid #ebeef5;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #909399;
  flex-shrink: 0;
  transition: all 0.3s ease;
}

.quick-card:hover .quick-icon {
  color: #4084d9;
  background: rgba(64,132,217,0.1);
  border-color: rgba(64,132,217,0.2);
}

.quick-info {
  display: flex;
  flex-direction: column;
  flex: 1;
  min-width: 0;
}

.quick-label {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.quick-desc {
  font-size: 11px;
  color: #909399;
  margin-top: 3px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.quick-arrow {
  color: #dcdfe6;
  flex-shrink: 0;
  opacity: 0;
  transform: translateX(-4px);
  transition: all 0.3s ease;
}

/* ====== 底部说明 ====== */
.info-section {
  background: #fafafa;
  border: 1px solid #ebeef5;
  border-radius: 14px;
  padding: 18px 22px;
  display: flex;
  align-items: flex-start;
  gap: 14px;
}

.info-icon {
  color: #c0c4cc;
  flex-shrink: 0;
  margin-top: 1px;
}

.info-section p {
  margin: 0;
  font-size: 13px;
  line-height: 1.8;
  color: #909399;
}

@media (max-width: 1200px) {
  .stats-grid {
    grid-template-columns: repeat(3, 1fr);
  }
  .quick-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .quick-grid {
    grid-template-columns: 1fr;
  }
  .welcome-section {
    padding: 28px 24px;
  }
  .welcome-text h1 {
    font-size: 20px;
  }
}
</style>
