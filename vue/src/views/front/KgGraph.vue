<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import * as echarts from 'echarts'
import request from '../../utils/request'

const chartInstance = ref(null)
const chartContainer = ref(null)
const bookId = ref(0)
const loading = ref(false)
const stats = ref({ nodes: {}, relations: {} })

const categoryNames = ['图书', '作者', '分类', '主题', '出版社', '时代']
const categoryColors = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de', '#3ba272']

const nodeTypeIcons = {
  Book: '📖',
  Author: '✍️',
  Category: '📂',
  Theme: '🏷️',
  Publisher: '🏢',
  Era: '📅'
}

const loadStats = () => {
  request.get('/kg/stats').then(res => {
    stats.value = res.data
  }).catch(() => {})
}

const loadGraph = () => {
  loading.value = true
  request.get('/kg/graph', { params: { bookId: bookId.value } }).then(res => {
    renderGraph(res.data)
    loading.value = false
  }).catch(() => {
    loading.value = false
  })
}

const renderGraph = (data) => {
  if (!chartInstance.value) return

  const nodes = (data.nodes || []).map(node => ({
    name: node.name,
    category: node.category,
    symbolSize: node.symbolSize || 30,
    itemStyle: {
      color: categoryColors[node.category] || '#5470c6'
    },
    label: {
      show: true,
      fontSize: 11,
      color: '#000'
    }
  }))

  const links = (data.links || []).map(link => ({
    source: link.source,
    target: link.target,
    value: link.value || '',
    lineStyle: {
      curveness: 0.2,
      color: '#333',
      width: 1.5
    },
    label: {
      show: true,
      fontSize: 9,
      color: '#333',
      formatter: params => params.value || ''
    }
  }))

  const categories = categoryNames.map((name, idx) => ({
    name,
    itemStyle: { color: categoryColors[idx] }
  }))

  const option = {
    title: {
      text: bookId.value ? '图书知识图谱' : '全局知识图谱',
      subtext: bookId.value ? '' : '基于Neo4j的图书实体关系网络',
      left: 'center',
      top: 10,
      textStyle: { color: '#222', fontSize: 18 },
      subtextStyle: { color: '#555', fontSize: 12 }
    },
    tooltip: {
      trigger: 'item',
      formatter: params => {
        if (params.dataType === 'node') {
          return `${categoryNames[params.data.category] || '未知'}: ${params.name}`
        }
        if (params.dataType === 'edge') {
          return `${params.data.source} → ${params.data.target}<br/>关系: ${params.data.value || ''}`
        }
        return ''
      }
    },
    legend: {
      data: categoryNames,
      bottom: 10,
      textStyle: { color: '#444' }
    },
    animationDuration: 1500,
    animationEasingUpdate: 'quinticInOut',
    series: [{
      type: 'graph',
      layout: 'force',
      data: nodes,
      links: links,
      categories: categories,
      roam: true,
      draggable: true,
      force: {
        repulsion: 300,
        edgeLength: [100, 200],
        gravity: 0.1
      },
      emphasis: {
        focus: 'adjacency',
        lineStyle: { width: 4 }
      },
      edgeSymbol: ['none', 'arrow'],
      edgeSymbolSize: [0, 12],
      label: {
        show: true,
        position: 'right',
        formatter: '{b}'
      }
    }]
  }

  chartInstance.value.setOption(option, true)
}

const handleResize = () => {
  chartInstance.value && chartInstance.value.resize()
}

onMounted(() => {
  chartInstance.value = echarts.init(chartContainer.value)
  loadStats()
  loadGraph()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  chartInstance.value && chartInstance.value.dispose()
})
</script>

<template>
  <div class="kg-graph-container">
    <div class="kg-stats-row" v-if="Object.keys(stats.nodes).length">
      <div class="kg-stat-card" v-for="(count, type) in stats.nodes" :key="type">
        <span class="kg-stat-icon">{{ nodeTypeIcons[type] || '🔷' }}</span>
        <div class="kg-stat-body">
          <span class="kg-stat-count">{{ count }}</span>
          <span class="kg-stat-label">{{ type }}</span>
        </div>
      </div>
    </div>

    <div class="kg-toolbar">
      <el-input-number v-model="bookId" :min="0" :step="1" placeholder="图书ID" style="width: 160px" />
      <el-button type="primary" @click="loadGraph" :loading="loading">查询图谱</el-button>
      <el-button @click="bookId = 0; loadGraph()">查看全局</el-button>
    </div>

    <div class="kg-info-bar" v-if="Object.keys(stats.relations).length">
      <span class="kg-info-label">关联关系:</span>
      <el-tag v-for="(count, type) in stats.relations" :key="type" size="small" effect="dark" style="margin-right: 6px">
        {{ type }} ({{ count }})
      </el-tag>
    </div>

    <div ref="chartContainer" class="kg-chart"></div>
  </div>
</template>

<style lang="scss" scoped>
.kg-graph-container {
  padding: 20px;
  min-height: calc(100vh - 64px);
  display: flex;
  flex-direction: column;
}

.kg-stats-row {
  display: flex;
  gap: 10px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}

.kg-stat-card {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 14px;
  background: #ffffff;
  border-radius: 8px;
  border: 1px solid #ebeef5;
  min-width: 100px;
}

.kg-stat-icon {
  font-size: 20px;
}

.kg-stat-body {
  display: flex;
  flex-direction: column;
}

.kg-stat-count {
  font-size: 18px;
  font-weight: 700;
  color: #303133;
  line-height: 1.2;
}

.kg-stat-label {
  font-size: 11px;
  color: #909399;
}

.kg-toolbar {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.kg-info-bar {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 6px 0;
  margin-bottom: 8px;
  flex-wrap: wrap;
}

.kg-info-label {
  font-size: 12px;
  color: #909399;
  margin-right: 6px;
}

.kg-chart {
  flex: 1;
  min-height: 500px;
  background: #ffffff;
  border-radius: 8px;
  border: 1px solid #333;
}
</style>
