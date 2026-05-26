<script setup>
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
import * as echarts from 'echarts'
import request from '../../utils/request'
import { ElMessage } from 'element-plus'

const heatmapInstance = ref(null)
const heatmapContainer = ref(null)
const barInstance = ref(null)
const barContainer = ref(null)
const pieInstance = ref(null)
const pieContainer = ref(null)
const gaugeInstance = ref(null)
const gaugeContainer = ref(null)

const selectedUserId = ref(1)
const userList = ref([])
const loading = ref(false)
const alphaValue = ref(0.3)
const scoreData = ref(null)
const behaviorData = ref(null)

const darkBg = 'rgba(21, 26, 58, 0.9)'
const darkBorder = 'rgba(255, 255, 255, 0.1)'
const darkText = '#fff'
const darkSubText = '#555'
const darkSplit = '#e8e8e8'
const darkAxis = '#bbb'
const chartTitle = '#222'

const loadUsers = () => {
  return request.get('/kg/analyze/users').then(res => {
    userList.value = res.data || []
    const exists = userList.value.some(u => u.userId === selectedUserId.value)
    if (!exists && userList.value.length > 0) {
      selectedUserId.value = userList.value[0].userId
    }
    console.log('用户列表加载成功:', userList.value.length, '选中用户:', selectedUserId.value)
  }).catch((err) => {
    console.error('用户列表加载失败:', err)
    userList.value = []
  })
}

const loadAll = () => {
  loading.value = true
  loadUsers().then(() => {
    return Promise.all([
      request.get('/kg/analyze/similarity'),
      request.get('/kg/analyze/scores', { params: { userId: selectedUserId.value, alpha: alphaValue.value } }),
      request.get('/kg/analyze/behavior', { params: { userId: selectedUserId.value } })
    ])
  }).then(([simRes, scoreRes, behaviorRes]) => {
    scoreData.value = scoreRes.data
    behaviorData.value = behaviorRes.data
    alphaValue.value = scoreRes.data.cfWeight || 0.3
    try { renderHeatmap(simRes.data) } catch (e) { console.error('热力图渲染失败:', e) }
    try { renderBarChart() } catch (e) { console.error('柱状图渲染失败:', e) }
    try { renderPieChart() } catch (e) { console.error('饼图渲染失败:', e) }
    try { renderGauge() } catch (e) { console.error('仪表盘渲染失败:', e) }
    loading.value = false
  }).catch((err) => {
    console.error('API请求失败:', err)
    ElMessage.warning('部分数据加载失败，请确认有用户行为数据')
    loading.value = false
  })
}

const setAlpha = (val) => {
  const newAlpha = Math.round(val * 100) / 100
  alphaValue.value = newAlpha
  renderGauge()
  request.get('/kg/analyze/scores', { params: { userId: selectedUserId.value, alpha: newAlpha } }).then(res => {
    scoreData.value = res.data
    renderBarChart()
  }).catch(() => {
    ElMessage.warning('更新评分失败')
  })
}

const renderHeatmap = (data) => {
  if (!heatmapContainer.value || !data) return
  if (heatmapInstance.value) {
    try { heatmapInstance.value.dispose() } catch (e) { /* ignore */ }
    heatmapInstance.value = null
  }

  const users = data.users || []
  const matrix = data.matrix || []

  if (users.length === 0 || matrix.length === 0) {
    return
  }

  const heatData = []
  for (let i = 0; i < matrix.length; i++) {
    const row = matrix[i] || []
    for (let j = 0; j < row.length; j++) {
      const v = row[j]
      if (v != null && !isNaN(v)) {
        heatData.push([j, i, Number(v)])
      }
    }
  }

  if (heatData.length === 0) return

  try {
    heatmapInstance.value = echarts.init(heatmapContainer.value)
  } catch (e) {
    console.warn('Heatmap init failed:', e)
    return
  }

  const option = {
    title: { text: '用户相似度矩阵 (余弦相似度)', left: 'center', top: 6, textStyle: { fontSize: 14, color: chartTitle } },
    tooltip: { backgroundColor: darkBg, borderColor: darkBorder, textStyle: { color: darkText },
      formatter: p => users[p.value[0]] + ' ↔ ' + users[p.value[1]] + '<br/>相似度: ' + (p.value[2] * 100).toFixed(1) + '%' },
    grid: { left: 100, right: 20, top: 50, bottom: 40 },
    xAxis: { type: 'category', data: users, axisLabel: { fontSize: 10, color: darkSubText },
      axisLine: { lineStyle: { color: darkAxis } } },
    yAxis: { type: 'category', data: [...users], axisLabel: { fontSize: 10, color: darkSubText },
      axisLine: { lineStyle: { color: darkAxis } } },
    visualMap: { min: 0, max: 1, show: false,
      inRange: { color: ['#0d1b3e', '#1a3a6b', '#2a5aaa', '#5470c6', '#a0c4ff'] } },
    series: [{ type: 'heatmap', data: heatData, label: { show: true, fontSize: 9, color: darkText,
      formatter: p => (p.value[2] * 100).toFixed(0) + '%' }, emphasis: { itemStyle: { shadowBlur: 10, shadowColor: 'rgba(0,0,0,0.5)' } } }]
  }
  heatmapInstance.value.setOption(option)
}

const renderBarChart = () => {
  const data = scoreData.value
  if (!barContainer.value || !data) return
  if (barInstance.value) {
    try { barInstance.value.dispose() } catch (e) { /* ignore */ }
    barInstance.value = null
  }

  const displayItems = (data.items || []).slice(0, 10)
  if (displayItems.length === 0) return

  try {
    barInstance.value = echarts.init(barContainer.value)
  } catch (e) {
    console.warn('Bar chart init failed:', e)
    return
  }

  const truncate = (name, maxLen) => name && name.length > maxLen ? name.substring(0, maxLen) + '…' : name
  const bookLabels = displayItems.map(it => truncate(it.bookName, 8) || ('书' + it.bookId))
  const cfScores = displayItems.map(it => it.cfScore)
  const kgScores = displayItems.map(it => it.kgScore)
  const fusedScores = displayItems.map(it => it.fusedScore)

  const option = {
    title: { text: 'CF vs KG 评分对比 (TOP10)', left: 'center', top: 6, textStyle: { fontSize: 14, color: chartTitle } },
    tooltip: { trigger: 'axis', backgroundColor: darkBg, borderColor: darkBorder, textStyle: { color: darkText },
      formatter: params => {
        const idx = params[0].dataIndex
        const source = displayItems[idx].source || ''
        return params.map(p => p.marker + ' ' + p.seriesName + ': ' + p.value).join('<br/>') + '<br/>来源: ' + source + '<br/>图书: ' + displayItems[idx].bookName
      }
    },
    legend: { data: ['协同过滤CF', '知识图谱KG', '融合得分'], top: 30, textStyle: { fontSize: 10, color: darkSubText } },
    grid: { left: 90, right: 20, top: 60, bottom: 20, containLabel: true },
    xAxis: { type: 'value', name: '归一化得分(0-1)', max: 1, nameTextStyle: { fontSize: 10, color: darkSubText },
      axisLabel: { color: darkSubText }, splitLine: { lineStyle: { color: darkSplit } }, axisLine: { lineStyle: { color: darkAxis } } },
    yAxis: { type: 'category', data: bookLabels, inverse: true, axisLabel: { fontSize: 11, color: darkSubText, width: 80, overflow: 'truncate' }, axisLine: { lineStyle: { color: darkAxis } } },
    series: [
      { name: '协同过滤CF', type: 'bar', data: cfScores, itemStyle: { color: '#5470c6' }, barGap: '10%', barWidth: '30%' },
      { name: '知识图谱KG', type: 'bar', data: kgScores, itemStyle: { color: '#91cc75' }, barWidth: '30%' },
      { name: '融合得分', type: 'line', data: fusedScores, z: 10, itemStyle: { color: '#fc8452' }, symbol: 'circle', symbolSize: 10, lineStyle: { width: 3, color: '#fc8452' }, label: { show: true, position: 'right', fontSize: 9, color: '#fc8452', formatter: p => p.value.toFixed(2) } }
    ]
  }
  barInstance.value.setOption(option)
}

const renderPieChart = () => {
  const data = behaviorData.value
  if (!pieContainer.value || !data) return
  if (pieInstance.value) {
    try { pieInstance.value.dispose() } catch (e) { /* ignore */ }
    pieInstance.value = null
  }

  const distribution = data.distribution || []

  try {
    pieInstance.value = echarts.init(pieContainer.value)
  } catch (e) {
    console.warn('Pie chart init failed:', e)
    return
  }
  const colors = { '浏览': '#91cc75', '收藏': '#fac858', '购买': '#ee6666' }
  const pieData = distribution.map(d => ({ ...d, itemStyle: { color: colors[d.name] || '#999', borderColor: '#ebeef5', borderWidth: 2 } }))

  const option = {
    title: { text: (data.nickname || ('用户' + data.userId)) + ' 行为类型分布', left: 'center', top: 6, textStyle: { fontSize: 14, color: chartTitle } },
    tooltip: { trigger: 'item', formatter: '{b}: {c} 次 ({d}%)', backgroundColor: darkBg, borderColor: darkBorder, textStyle: { color: darkText } },
    legend: { bottom: 0, textStyle: { fontSize: 10, color: darkSubText } },
    series: [{
      type: 'pie', radius: ['40%', '70%'], center: ['50%', '50%'], data: pieData,
      label: { formatter: '{b}\n{c}次', color: darkSubText },
      emphasis: { itemStyle: { shadowBlur: 10, shadowColor: 'rgba(0,0,0,0.5)' } }
    }]
  }
  pieInstance.value.setOption(option)
}

const renderGauge = () => {
  if (!gaugeContainer.value) return
  if (gaugeInstance.value) {
    try { gaugeInstance.value.dispose() } catch (e) { /* ignore */ }
    gaugeInstance.value = null
  }

  try {
    gaugeInstance.value = echarts.init(gaugeContainer.value)
  } catch (e) {
    console.warn('Gauge init failed:', e)
    return
  }

  const cfPercent = (alphaValue.value * 100).toFixed(0)
  const kgPercent = (100 - parseFloat(cfPercent)).toFixed(0)

  const option = {
    title: { text: '融合权重比例 α 参数', left: 'center', top: 6, textStyle: { fontSize: 14, color: chartTitle } },
    series: [{
      type: 'gauge', startAngle: 210, endAngle: -30, center: ['50%', '60%'], radius: '85%',
      min: 0, max: 100, splitNumber: 10,
      axisLine: { show: true, lineStyle: { width: 20, color: [[0.5, '#91cc75'], [1, '#5470c6']] } },
      pointer: { length: '60%', width: 6, itemStyle: { color: 'auto' } },
      axisTick: { distance: -20, length: 6, lineStyle: { width: 1, color: darkSubText } },
      splitLine: { distance: -25, length: 14, lineStyle: { width: 1, color: darkSubText } },
      axisLabel: { distance: 15, fontSize: 10, formatter: v => v + '%', color: darkSubText },
      detail: { valueAnimation: true, formatter: 'CF {value}% : KG ' + kgPercent + '%', fontSize: 13,
        color: chartTitle, offsetCenter: [0, '75%'] },
      data: [{ value: parseFloat(cfPercent), name: '协同过滤占比' }],
      title: { color: darkSubText, fontSize: 12 }
    }]
  }
  gaugeInstance.value.setOption(option)
}

const handleResize = () => {
  heatmapInstance.value?.resize()
  barInstance.value?.resize()
  pieInstance.value?.resize()
  gaugeInstance.value?.resize()
}

onMounted(() => {
  loadAll()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  heatmapInstance.value?.dispose()
  barInstance.value?.dispose()
  pieInstance.value?.dispose()
  gaugeInstance.value?.dispose()
})
</script>

<template>
  <div class="analyze-container">
    <div class="toolbar">
      <span class="toolbar-label">选择用户：</span>
      <el-select v-model="selectedUserId" placeholder="请选择用户" @change="loadAll" style="width: 200px">
        <el-option v-for="u in userList" :key="u.userId" :label="u.name + ' (' + u.behaviorCount + '条行为)'" :value="u.userId" />
      </el-select>
      <el-button type="primary" @click="loadAll" :loading="loading">刷新数据</el-button>
      <div class="alpha-divider"></div>
      <span class="toolbar-label">α 权重调节：</span>
      <div class="alpha-controls">
        <button class="alpha-btn alpha-step" @click="setAlpha(Math.max(0, alphaValue - 0.1))" :disabled="alphaValue <= 0">－</button>
        <button class="alpha-btn alpha-preset" :class="{ active: alphaValue === 0.1 }" @click="setAlpha(0.1)">0.1</button>
        <button class="alpha-btn alpha-preset" :class="{ active: alphaValue === 0.3 }" @click="setAlpha(0.3)">0.3</button>
        <button class="alpha-btn alpha-preset" :class="{ active: alphaValue === 0.5 }" @click="setAlpha(0.5)">0.5</button>
        <button class="alpha-btn alpha-preset" :class="{ active: alphaValue === 0.7 }" @click="setAlpha(0.7)">0.7</button>
        <button class="alpha-btn alpha-preset" :class="{ active: alphaValue === 0.9 }" @click="setAlpha(0.9)">0.9</button>
        <button class="alpha-btn alpha-step" @click="setAlpha(Math.min(1, alphaValue + 0.1))" :disabled="alphaValue >= 1">＋</button>
        <span class="alpha-display">当前 α = <strong>{{ alphaValue.toFixed(1) }}</strong></span>
      </div>
    </div>

    <div class="chart-grid">
      <div class="chart-cell" ref="heatmapContainer" style="grid-column: span 2"></div>
      <div class="chart-cell" ref="gaugeContainer"></div>
      <div class="chart-cell" ref="barContainer" style="grid-column: span 2"></div>
      <div class="chart-cell" ref="pieContainer"></div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.analyze-container {
  padding: 20px;
  min-height: calc(100vh - 120px);
}

.toolbar {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
  padding: 12px 16px;
  background: #ffffff;
  border: 1px solid #ebeef5;
  border-radius: 10px;
  flex-wrap: wrap;
}

.toolbar-label {
  font-size: 14px;
  color: #606266;
  font-weight: 500;
  white-space: nowrap;
}

.alpha-divider {
  width: 1px;
  height: 24px;
  background: #dcdfe6;
  margin: 0 4px;
}

.alpha-controls {
  display: flex;
  align-items: center;
  gap: 6px;
}

.alpha-btn {
  border: 1px solid #dcdfe6;
  background: #f5f7fa;
  color: #606266;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
  font-weight: 500;
  transition: all 0.2s;
  outline: none;
  font-family: inherit;
}

.alpha-btn:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.1);
  border-color: #dcdfe6;
  color: #303133;
}

.alpha-btn:disabled {
  opacity: 0.3;
  cursor: not-allowed;
}

.alpha-step {
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
}

.alpha-preset {
  padding: 5px 10px;
  min-width: 38px;
  text-align: center;
}

.alpha-preset.active {
  background: linear-gradient(135deg, #5470c6, #3b5fc0);
  border-color: #5470c6;
  color: #fff;
  font-weight: 700;
}

.alpha-display {
  font-size: 13px;
  color: #909399;
  margin-left: 8px;
}

.alpha-display strong {
  color: #303133;
}

.chart-grid {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 16px;
  margin-bottom: 20px;
}

.chart-cell {
  background: #ffffff;
  border-radius: 8px;
  border: 1px solid #ebeef5;
  height: 320px;
}
</style>

