<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import * as echarts from 'echarts'
import request from '../../utils/request'

const pieChartInstance = ref(null)
const pieChartContainer = ref(null)
const entityPieInstance = ref(null)
const entityPieContainer = ref(null)
const barChartInstance = ref(null)
const barChartContainer = ref(null)
const kgPieInstance = ref(null)
const kgPieContainer = ref(null)

const loadCategoryDistribution = () => {
  request.get('/echarts/categoryDistribution').then(res => {
    renderCategoryPie(res.data)
  })
}

const loadEntityDistribution = () => {
  request.get('/echarts/entityDistribution').then(res => {
    renderEntityPie(res.data)
  })
}

const loadAuthorBookCount = () => {
  request.get('/echarts/authorBookCount').then(res => {
    renderAuthorBar(res.data)
  })
}

const loadKgDistribution = () => {
  request.get('/echarts/kgDistribution').then(res => {
    renderKgPie(res.data)
  })
}

const renderCategoryPie = (data) => {
  if (!pieChartContainer.value) return

  if (pieChartInstance.value) {
    pieChartInstance.value.dispose()
  }

  pieChartInstance.value = echarts.init(pieChartContainer.value)

  const option = {
    title: {
      text: '图书分类分布',
      left: 'center',
      textStyle: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#222'
      }
    },
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c} 本 ({d}%)',
      backgroundColor: 'rgba(21, 26, 58, 0.9)',
      borderColor: 'rgba(255, 255, 255, 0.1)',
      textStyle: { color: 'rgba(255, 255, 255, 0.85)' }
    },
    legend: {
      orient: 'vertical',
      left: 'left',
      top: '15%',
      textStyle: { color: '#555' }
    },
    series: [
      {
        name: '图书数量',
        type: 'pie',
        radius: ['40%', '70%'],
        center: ['50%', '48%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: '#ebeef5',
          borderWidth: 2
        },
        label: {
          show: false
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 18,
            fontWeight: 'bold'
          }
        },
        labelLine: {
          show: false
        },
        data: data
      }
    ]
  }

  pieChartInstance.value.setOption(option)
}

const renderEntityPie = (data) => {
  if (!entityPieContainer.value) return

  if (entityPieInstance.value) {
    entityPieInstance.value.dispose()
  }

  entityPieInstance.value = echarts.init(entityPieContainer.value)

  const typeNameMap = {
    'author': '作者',
    'category': '分类',
    'publisher': '出版社',
    'book': '图书',
    'genre': '流派'
  }

  const mappedData = data.map(item => ({
    ...item,
    name: typeNameMap[item.name] || item.name
  }))

  const option = {
    title: {
      text: '知识图谱实体类型分布',
      left: 'center',
      textStyle: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#222'
      }
    },
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c} 个 ({d}%)',
      backgroundColor: 'rgba(21, 26, 58, 0.9)',
      borderColor: 'rgba(255, 255, 255, 0.1)',
      textStyle: { color: 'rgba(255, 255, 255, 0.85)' }
    },
    legend: {
      orient: 'vertical',
      left: 'left',
      top: '15%',
      textStyle: { color: '#555' }
    },
    series: [
      {
        name: '实体数量',
        type: 'pie',
        radius: ['40%', '70%'],
        center: ['50%', '48%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: '#ebeef5',
          borderWidth: 2
        },
        label: {
          show: false
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 18,
            fontWeight: 'bold'
          }
        },
        labelLine: {
          show: false
        },
        data: mappedData
      }
    ]
  }

  entityPieInstance.value.setOption(option)
}

const renderAuthorBar = (data) => {
  if (!barChartContainer.value) return

  if (barChartInstance.value) {
    barChartInstance.value.dispose()
  }

  barChartInstance.value = echarts.init(barChartContainer.value)

  const names = data.map(item => item.name)
  const values = data.map(item => item.value)

  const option = {
    title: {
      text: '作者图书数量 TOP10',
      left: 'center',
      textStyle: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#222'
      }
    },
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'shadow' },
      formatter: function (params) {
        const d = params[0]
        return `${d.axisValue}<br/>图书数量: ${d.value} 本`
      },
      backgroundColor: 'rgba(21, 26, 58, 0.9)',
      borderColor: 'rgba(255, 255, 255, 0.1)',
      textStyle: { color: 'rgba(255, 255, 255, 0.85)' }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      top: '20%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: names,
      axisLabel: {
        rotate: 30,
        interval: 0,
        color: '#555',
        fontSize: 12
      },
      axisLine: { lineStyle: { color: '#ccc' } }
    },
    yAxis: {
      type: 'value',
      name: '图书数量(本)',
      nameTextStyle: { color: '#555' },
      axisLabel: {
        color: '#555'
      },
      splitLine: { lineStyle: { color: '#eee' } },
      axisLine: { lineStyle: { color: '#ccc' } }
    },
    series: [
      {
        name: '图书数量',
        type: 'bar',
        data: values,
        itemStyle: {
          color: {
            type: 'linear',
            x: 0, y: 0, x2: 0, y2: 1,
            colorStops: [
              { offset: 0, color: '#83bff6' },
              { offset: 0.5, color: '#188df0' },
              { offset: 1, color: '#188df0' }
            ]
          }
        },
        emphasis: {
          itemStyle: {
            color: {
              type: 'linear',
              x: 0, y: 0, x2: 0, y2: 1,
              colorStops: [
                { offset: 0, color: '#2378f7' },
                { offset: 0.7, color: '#2378f7' },
                { offset: 1, color: '#83bff6' }
              ]
            }
          }
        },
        barWidth: '60%',
        label: {
          show: true,
          position: 'top',
          color: '#555',
          fontSize: 12
        }
      }
    ]
  }

  barChartInstance.value.setOption(option)
}

const renderKgPie = (data) => {
  if (!kgPieContainer.value) return

  if (kgPieInstance.value) {
    kgPieInstance.value.dispose()
  }

  kgPieInstance.value = echarts.init(kgPieContainer.value)

  const option = {
    title: {
      text: '知识图谱关系类型分布 (Neo4j)',
      left: 'center',
      textStyle: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#222'
      }
    },
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c} 条 ({d}%)',
      backgroundColor: 'rgba(21, 26, 58, 0.9)',
      borderColor: 'rgba(255, 255, 255, 0.1)',
      textStyle: { color: 'rgba(255, 255, 255, 0.85)' }
    },
    legend: {
      bottom: 0,
      textStyle: { color: '#555', fontSize: 11 }
    },
    series: [{
      name: '关系数量',
      type: 'pie',
      radius: ['40%', '65%'],
      center: ['50%', '48%'],
      avoidLabelOverlap: false,
      itemStyle: {
        borderRadius: 8,
        borderColor: '#ebeef5',
        borderWidth: 2
      },
      label: { show: false },
      emphasis: {
        label: { show: true, fontSize: 16, fontWeight: 'bold' }
      },
      labelLine: { show: false },
      color: ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de', '#3ba272', '#fc8452', '#9a60b4'],
      data: data
    }]
  }

  kgPieInstance.value.setOption(option)
}

const handleResize = () => {
  if (pieChartInstance.value) pieChartInstance.value.resize()
  if (entityPieInstance.value) entityPieInstance.value.resize()
  if (barChartInstance.value) barChartInstance.value.resize()
  if (kgPieInstance.value) kgPieInstance.value.resize()
}

onMounted(() => {
  loadCategoryDistribution()
  loadEntityDistribution()
  loadAuthorBookCount()
  loadKgDistribution()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  if (pieChartInstance.value) pieChartInstance.value.dispose()
  if (entityPieInstance.value) entityPieInstance.value.dispose()
  if (barChartInstance.value) barChartInstance.value.dispose()
  if (kgPieInstance.value) kgPieInstance.value.dispose()
  window.removeEventListener('resize', handleResize)
})
</script>

<template>
  <div class="echarts-container">
    <div class="top-section">
      <div class="chart-row">
        <div ref="pieChartContainer" class="chart-half"></div>
        <div ref="entityPieContainer" class="chart-half"></div>
      </div>
    </div>

    <div class="bottom-section">
      <div class="chart-row">
        <div ref="barChartContainer" class="chart-half"></div>
        <div ref="kgPieContainer" class="chart-half"></div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.echarts-container {
  padding: 20px;
  background: #ffffff;
  border-radius: 8px;
  box-shadow: 0 1px 8px rgba(0, 0, 0, 0.04);
}

.top-section {
  margin-bottom: 20px;
}

.chart-row {
  display: flex;
  gap: 20px;
}

.chart-half {
  flex: 1;
  height: 380px;
  background: #fafafa;
  border-radius: 8px;
}

.chart-full {
  width: 100%;
  height: 400px;
  background: #fafafa;
  border-radius: 8px;
  padding: 10px;
}

.bottom-section {
  background: #fafafa;
  border-radius: 8px;
  padding: 10px;
}
</style>