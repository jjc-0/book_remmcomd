<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import request from '@/utils/request.js'

const router = useRouter()

// 响应式数据
const selectAll = ref(false)
const cartItems = ref([])
const totalLength = ref(0)
const address = ref([])
const addressId = ref('')

// 计算属性
const selectedCartItems = computed(() => {
  return cartItems.value.filter(item => item.selected).map(item => ({
    bookName: item.bookName,
    num: item.num,
    totalPrice: (item.bookPrice * item.num).toFixed(2)
  }))
})

const selectedItemsCount = computed(() => {
  return cartItems.value.filter(item => item.selected).length
})

const finalTotal = computed(() => {
  return selectedCartItems.value.reduce((sum, item) => sum + parseFloat(item.totalPrice), 0).toFixed(2)
})

// 方法
const toggleSelectAll = () => {
  cartItems.value.forEach(item => {
    item.selected = selectAll.value
  })
}

const select = () => {
  const selectedCount = cartItems.value.filter(item => item.selected).length
  selectAll.value = selectedCount === cartItems.value.length
}

const load = () => {
  request.get("/cart").then(res => {
    cartItems.value = res.data.map(item => ({
      ...item,
      selected: false
    }))
    totalLength.value = cartItems.value.length
  })
}

const updateQuantity = (item) => {
  let cart = JSON.parse(JSON.stringify(item))
  request.post("/cart/num", cart).then(res => {
    if (res.code === '200') {
      // 更新成功
    }
  })
}

const delBatch = () => {
  const selectedItems = cartItems.value.filter(item => item.selected)
  if (!selectedItems.length) {
    ElMessage.error("请选择需要删除的图书数据")
    return
  }

  const ids = selectedItems.map(item => item.id)

  request.post("/cart/del/batch", ids).then(res => {
    if (res.code === '200') {
      ElMessage.success("批量删除成功")
      load()
    } else {
      ElMessage.error("批量删除失败")
    }
  })
}

const del = (id) => {
  request.delete("/cart/" + id).then(res => {
    if (res.code === '200') {
      ElMessage.success("删除成功")
      load()
    } else {
      ElMessage.error("删除失败")
    }
  })
}

const sum = () => {
  const selectedItems = cartItems.value.filter(item => item.selected)

  if (!selectedItems.length) {
    ElMessage.warning("下单失败，未选择图书")
    return
  }

  if (addressId.value === '') {
    ElMessage.error('请选择您的地址')
    return
  }

  const carts = selectedItems.map(item => ({
    bookId: item.bookId,
    num: item.num,
    id: item.id
  }))

  request.post("/orders/fromCart/" + addressId.value, carts).then(res => {
    if (res.code === '200') {
      ElMessage.success('已下单，请及时支付！')
      router.push('/front/orders')
    } else {
      ElMessage.error(res.msg)
    }
  }).catch(error => {
    console.error('下单请求失败:', error)
    ElMessage.error('下单失败，请稍后重试。')
  })
}

// 生命周期
onMounted(() => {
  load()

  request.get('/address').then(res => {
    address.value = res.data
  })
})
</script>

<template>
  <div class="shopping-cart">
    <div class="cart-header">
      <h2>全部图书 ({{ totalLength }})</h2>
    </div>

    <div class="cart-actions">
      <el-checkbox v-model="selectAll" @change="toggleSelectAll">全选</el-checkbox>
      <el-popconfirm
          class="ml-5"
          confirm-button-text='确定'
          cancel-button-text='取消'
          icon="el-icon-info"
          icon-color="red"
          title="您确定批量删除这些图书吗？"
          @confirm="delBatch"
      >
        <template #reference>
          <el-button type="danger" style="margin-left: 10px" plain>批量删除</el-button>
        </template>
      </el-popconfirm>
    </div>

    <div class="cart-content">
      <div class="cart-items">
        <el-alert
            title="一键结算，享受便捷购物体验！"
            type="success"
            :closable="false"
            show-icon>
        </el-alert>
        <div v-for="item in cartItems" :key="item.id" class="cart-item">
          <el-checkbox v-model="item.selected" style="margin-right: 10px" @change="select"></el-checkbox>
          <div class="item-image">
            <img :src="item.bookImg" alt="图书图片">
          </div>
          <div class="item-details">
            <h3>{{ item.bookName }}</h3>
            <p>{{ item.bookInfo }}</p>
            <div class="item-price">¥{{ item.bookPrice }}</div>
          </div>
          <div class="item-quantity">
            <el-input-number
                v-model="item.num"
                :min="1"
                :max="3"
                @change="updateQuantity(item)">
            </el-input-number>
          </div>
          <div class="item-actions">
            <el-popconfirm
                class="ml-5"
                confirm-button-text='确定'
                cancel-button-text='取消'
                icon="el-icon-info"
                icon-color="red"
                title="您确定删除这条数据吗？"
                @confirm="del(item.id)"
            >
              <template #reference>
                <span style="color: #d54941;cursor: pointer">删除</span>
              </template>
            </el-popconfirm>
          </div>
        </div>
      </div>

      <div class="cart-summary">
        <div style="padding: 10px 20px; background-color: #f5f7fa; margin: 10px 0; border-radius: 10px">
          <div style="margin-bottom: 10px">
            <span>收货地址</span>
            <el-button style="margin-left: 50px" type="primary" link @click="router.push('/front/address')">
              前往新建地址
            </el-button>
          </div>

          <el-select v-model="addressId" placeholder="请选择" style="width: 300px;">
            <el-option
                v-for="addressItem in address"
                :key="addressItem.id"
                :label="`${addressItem.name} - ${addressItem.address} - ${addressItem.phone}`"
                :value="addressItem.id">
            </el-option>
          </el-select>
        </div>

        <div style="font-size: 20px;margin-bottom: 20px">
          <span>结算明细</span>
        </div>

        <el-table :data="selectedCartItems" style="width: 100%">
          <el-table-column prop="bookName" label="图书名称"></el-table-column>
          <el-table-column prop="num" label="数量"></el-table-column>
          <el-table-column prop="totalPrice" label="价格"></el-table-column>
        </el-table>

        <div class="summary-row total">
          <span>合计:</span>
          <span>¥{{ finalTotal }}</span>
        </div>
        <el-button type="primary" size="large" @click="sum">
          结算 ({{ selectedItemsCount }} 件)
        </el-button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.shopping-cart {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif;
  width: 70%;
  margin: 0 auto;
  padding: 24px 20px;
  background: transparent;
  min-height: 100vh;
}

.cart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding: 18px 24px;
  background: #ffffff;
  border-radius: 10px;
  box-shadow: 0 1px 8px rgba(0, 0, 0, 0.04);
  border: 1px solid #ebeef5;
}

.cart-header h2 {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin: 0;
}

.cart-actions {
  margin-bottom: 20px;
  padding: 14px 24px;
  background: #ffffff;
  border-radius: 10px;
  box-shadow: 0 1px 8px rgba(0, 0, 0, 0.04);
  border: 1px solid #ebeef5;
  display: flex;
  align-items: center;
}

.cart-content {
  display: flex;
  gap: 20px;
}

.cart-items {
  flex: 1;
}

.cart-item {
  display: flex;
  align-items: center;
  padding: 18px 20px;
  background: #ffffff;
  border-radius: 10px;
  box-shadow: 0 1px 8px rgba(0, 0, 0, 0.04);
  border: 1px solid #ebeef5;
  margin-bottom: 12px;
  transition: all 0.25s ease;
}

.cart-item:hover {
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  border-color: rgba(64, 132, 217, 0.3);
}

.item-image {
  border-radius: 8px;
  overflow: hidden;
  flex-shrink: 0;
}

.item-image img {
  width: 90px;
  height: 90px;
  object-fit: cover;
  margin-right: 0;
  transition: transform 0.3s ease;
}

.cart-item:hover .item-image img {
  transform: scale(1.05);
}

.item-details {
  flex-grow: 1;
  margin-left: 16px;
}

.item-details h3 {
  font-size: 15px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 6px;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 1;
  overflow: hidden;
}

.item-details p {
  font-size: 12px;
  color: #909399;
  margin: 0 0 8px;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 1;
  overflow: hidden;
}

.item-price {
  color: #e74c3c;
  font-weight: 700;
  font-size: 16px;
  margin-top: 0;
}

.item-quantity {
  margin: 0 20px;
  flex-shrink: 0;
}

.item-actions {
  flex-shrink: 0;
}

.item-actions span {
  color: #e74c3c;
  cursor: pointer;
  font-size: 13px;
  transition: all 0.2s ease;
  padding: 4px 10px;
  border-radius: 6px;
}

.item-actions span:hover {
  background: rgba(231, 76, 60, 0.15);
}

.cart-summary {
  background: #ffffff;
  padding: 24px;
  border-radius: 10px;
  box-shadow: 0 1px 8px rgba(0, 0, 0, 0.04);
  border: 1px solid #ebeef5;
  width: 30%;
  position: sticky;
  top: 80px;
  height: fit-content;
}

.summary-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
}

.total {
  font-weight: 700;
  font-size: 18px;
  margin-top: 10px;
  color: #303133;
}

.total span:last-child {
  color: #e74c3c;
}
</style>