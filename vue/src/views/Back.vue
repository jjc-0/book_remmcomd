<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {User, Lock, SwitchButton, House, UserFilled,Notification,Picture,Star,Location,Document,Goods,Setting,PieChart,Connection,DataAnalysis} from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { projectName } from '../../config/config.default'

// 路由实例
const router = useRouter()
const route = useRoute()

// 用户信息
const account = ref(
    localStorage.getItem('account') ? JSON.parse(localStorage.getItem('account')) : {}
)

// 侧边栏状态
const isCollapse = ref(false)
const sideWidth = computed(() => isCollapse.value ? 64 : 200)
const logoTextShow = computed(() => !isCollapse.value)

// 当前激活的菜单项
const activeMenu = computed(() => route.path)

// 主题设置
const themeStatus = ref(parseInt(localStorage.getItem('theme') || '0'))
const themes = ref(['theme1', 'theme2', 'theme3', 'theme4', 'theme5', 'theme6', 'theme7', 'theme8'])

// 抽屉状态
const drawer = ref(false)

// 打开主题设置抽屉
const openThemeDrawer = () => {
  drawer.value = true
}

// 切换主题
const changeTheme = (index) => {
  localStorage.setItem('theme', index.toString())
  themeStatus.value = index
}

// 退出登录
const logout = () => {
  localStorage.removeItem('account')
  ElMessage.success('退出成功')
  router.push('/login')
}

// 刷新用户信息
const handleUpdateAccount = (updatedAccount) => {
  // 更新父组件中的用户信息
  account.value = updatedAccount
}



</script>

<template>
  <div class="admin-layout" :class="themes[themeStatus]">
    <!-- 顶部区域 -->
    <header class="admin-header">
      <div class="header-left">
        <div class="logo-container" :style="{ width: sideWidth + 'px' }" @click="openThemeDrawer">
          <img src="../../config/logo.svg" alt="Logo" class="logo-image" />
          <h1 class="logo-text" v-show="logoTextShow">{{ projectName }}</h1>
        </div>
      </div>

      <div class="header-right">
        <el-dropdown>
          <div class="user-info">
            <div class="user-avatar">
              <img :src="account.avatarUrl" />
            </div>
            <span class="user-name">{{ account.nickname}}</span>
          </div>
          <template #dropdown>
            <el-dropdown-menu>
              <!--个人信息页面-->
              <el-dropdown-item v-if="account.role==='ROLE_ADMIN'">
                <router-link to="/back/adminPerson" class="dropdown-link">
                  <el-icon><User /></el-icon>
                  <span>个人信息</span>
                </router-link>
              </el-dropdown-item>
              <!--个人信息页面-->
              <el-dropdown-item>
                <router-link to="/back/password" class="dropdown-link">
                  <el-icon><Lock /></el-icon>
                  <span>修改密码</span>
                </router-link>
              </el-dropdown-item>
              <el-dropdown-item>
                <div @click="logout" class="dropdown-link">
                  <el-icon><SwitchButton /></el-icon>
                  <span>退出登录</span>
                </div>
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </header>

    <!--内容区域-->
    <div class="admin-container">
      <!-- 左侧菜单区域 -->
      <aside class="admin-sidebar" :style="{ width: sideWidth + 'px'}">
        <el-menu
            :default-active="activeMenu"
            :collapse="isCollapse"
            router
            :collapse-transition="false"
        >

          <!--后台菜单-->

          <el-menu-item index="/back/home">
            <el-icon><House /></el-icon>
            <template #title>后台首页</template>
          </el-menu-item>

          <el-menu-item index="/back/echarts">
            <el-icon><PieChart /></el-icon>
            <template #title>数据统计</template>
          </el-menu-item>

          <el-menu-item index="/back/recommendAnalyze">
            <el-icon><DataAnalysis /></el-icon>
            <template #title>推荐算法分析</template>
          </el-menu-item>

          <el-menu-item index="/back/notice" v-if="account.role==='ROLE_ADMIN'">
            <el-icon><Notification /></el-icon>
            <template #title>公告管理</template>
          </el-menu-item>

          <el-menu-item index="/back/banner" v-if="account.role==='ROLE_ADMIN'">
            <el-icon><Picture /></el-icon>
            <template #title>轮播图管理</template>
          </el-menu-item>

          <el-menu-item index="/back/type" v-if="account.role==='ROLE_ADMIN'">
            <el-icon><Setting /></el-icon>
            <template #title>分类管理</template>
          </el-menu-item>

          <el-menu-item index="/back/orders">
            <el-icon><Document /></el-icon>
            <template #title>订单管理</template>
          </el-menu-item>

          <el-menu-item index="/back/address" v-if="account.role==='ROLE_ADMIN'">
            <el-icon><Location /></el-icon>
            <template #title>地址管理</template>
          </el-menu-item>

          <el-menu-item index="/back/collect" v-if="account.role==='ROLE_ADMIN'">
            <el-icon><Star /></el-icon>
            <template #title>收藏管理</template>
          </el-menu-item>

          <el-sub-menu index="" v-if="account.role==='ROLE_ADMIN'">
            <template #title>
              <el-icon><UserFilled /></el-icon>
              <span>系统角色管理</span>
            </template>

            <!--系统角色菜单-->

            <el-menu-item index="/back/admin">
              <el-icon><User /></el-icon>
              <template #title>管理员管理</template>
            </el-menu-item>

            <el-menu-item index="/back/user">
              <el-icon><User /></el-icon>
              <template #title>用户管理</template>
            </el-menu-item>

            <!--系统角色菜单-->

          </el-sub-menu>


          <!--后台菜单-->

        </el-menu>
      </aside>

      <!-- 主要内容区域 -->
      <main class="admin-content">
        <router-view @update-account="handleUpdateAccount"></router-view>
      </main>
    </div>

    <!-- 主题设置抽屉 -->
    <el-drawer v-model="drawer" title="系统设置" direction="rtl" size="300px">
      <div class="drawer-content">
        <div class="drawer-section">
          <h3>侧边栏设置</h3>
          <div class="drawer-option">
            <span>折叠侧边栏</span>
            <el-switch v-model="isCollapse" active-color="var(--font-color-primary)" inactive-color="#dcdfe6" />
          </div>
        </div>

        <el-divider />

        <div class="drawer-section">
          <h3>主题设置</h3>
          <div class="theme-options">
            <div
                v-for="(theme, index) in themes"
                :key="index"
                class="theme-option"
                :class="[theme, { active: themeStatus === index }]"
                @click="changeTheme(index)"
            >
              <div class="theme-color"></div>
              <div class="theme-check" v-if="themeStatus === index">✓</div>
            </div>
          </div>
        </div>


      </div>
    </el-drawer>

  </div>
</template>

<style lang="scss" scoped>
.admin-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.admin-header {
  height: 60px;
  background-color: var(--font-color-primary);
  color: #fff;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
  z-index: 1000;

  .header-left {
    display: flex;
    align-items: center;
    padding: 0 10px;

    .logo-container {
      height: 60px;
      display: flex;
      align-items: center;
      justify-content: center;

      .logo-image {
        width: 30px;
        height: 30px;
        margin-right: 10px;
      }

      .logo-text {
        font-size: 18px;
        font-weight: 600;
        color: #fff;
        margin: 0;
        white-space: nowrap;
      }
    }
  }

  .header-right {
    display: flex;
    align-items: center;
    margin-right: 20px;

    .user-info {
      display: flex;
      align-items: center;
      cursor: pointer;
      padding: 5px 10px;
      border-radius: 4px;

      &:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      .user-avatar {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        overflow: hidden;
        margin-right: 8px;
        background-color: rgba(255, 255, 255, 0.1);

        img {
          width: 100%;
          height: 100%;
          object-fit: cover;
          outline: none !important;
        }
      }

      .user-name {
        font-size: 14px;
        color: #fff;
      }
    }
  }
}

.admin-container {
  display: flex;
  flex: 1;
  gap: 10px;
  padding: 10px;
  background-color: #f0f2f5;
}

.admin-sidebar {
  min-height: calc(100vh - 80px);
  background-color: #ffffff;
  box-shadow: 2px 0 8px 0 rgba(0, 0, 0, 0.06);
}

.admin-content {
  flex: 1;
  overflow-y: auto;
  background-color: #ffffff;
  border-radius: 5px;
}

.dropdown-link {
  display: flex;
  align-items: center;
  color: inherit;
  text-decoration: none;

  .el-icon {
    margin-right: 8px;
  }
}

.drawer-content {
  padding: 20px;

  .drawer-section {
    margin-bottom: 20px;

    h3 {
      margin-top: 0;
      margin-bottom: 20px;
      font-size: 16px;
      color: #303133;
    }

    .drawer-option {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 15px;

      span {
        font-size: 14px;
        color: #606266;
      }
    }
  }

  .theme-options {
    display: flex;
    flex-wrap: wrap;
    gap: 15px;

    .theme-option {
      position: relative;
      width: 60px;
      height: 60px;
      border-radius: 4px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      border: 2px solid transparent;

      &.active {
        border-color: rgba(0, 0, 0, 0.3);
      }

      .theme-color {
        width: 40px;
        height: 40px;
        border-radius: 4px;
        background-color: var(--font-color-primary);
      }

      .theme-check {
        position: absolute;
        bottom: 5px;
        right: 5px;
        width: 16px;
        height: 16px;
        background-color: rgba(0, 0, 0, 0.08);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 12px;
        color: var(--font-color-primary);
        font-weight: bold;
      }
    }
  }
}
</style>

<style scoped>

/*/
  menu菜单 整体样式
 */
.el-menu {
  background-color: #ffffff !important;
  border: none !important;
}

/*/
  menu菜单 鼠标指针放到具体的某一项上时候的样式
 */
.el-menu-item:hover {
  color: var(--font-color-primary) !important;
  background-color: var(--back-color-primary) !important;
}

/*/
  menu菜单 当前被选择项的样式
 */
.el-menu-item.is-active {
  background-color: var(--back-color-primary) !important;
  color: var(--font-color-primary) !important;
  border-right-style: solid !important;
  border-right-width: 3px !important;
  border-right-color: var(--font-color-primary) !important;
}

/* 使用Vue 3的深度选择器语法 */

/*/
  menu菜单 标题 展开时候的样式
 */
:deep(.el-sub-menu .el-sub-menu__title) {
  background-color: #ffffff !important;
}

/*/
  menu菜单 标题 鼠标放到展开时候的样式
 */
:deep(.el-sub-menu .el-sub-menu__title:hover) {
  color: var(--font-color-primary) !important;
  background-color: var(--back-color-primary) !important;
}

/*/
  menu菜单 标题 被展开时候，这个展开标题的样式
 */
:deep(.el-sub-menu.is-opened .el-sub-menu__title) {
  color: var(--font-color-primary) !important;
}

/*/
  去除下拉框的鼠标悬浮边框效果
 */
:deep(.el-dropdown *) {
  outline: none !important;
}

</style>

<style>
.admin-content {
  --glass-bg: #ffffff;
  --glass-border: #e4e7ed;
  --glass-hover-bg: #f5f7fa;
  --glass-radius: 10px;
}

.admin-content .el-card,
.admin-content .el-table,
.admin-content .el-pagination,
.admin-content .el-dialog,
.admin-content .el-alert,
.admin-content .el-empty {
  background: #ffffff !important;
  border: 1px solid #ebeef5 !important;
  border-radius: 10px !important;
}

.admin-content .el-card__header {
  background: #fafafa !important;
  border-bottom: 1px solid #ebeef5 !important;
  border-radius: 10px 10px 0 0 !important;
}

.admin-content .el-card__body {
  background: transparent !important;
}

.admin-content .el-table__header-wrapper {
  background: transparent !important;
  border-radius: 10px 10px 0 0 !important;
}

.admin-content .el-table__header th {
  background: #f5f7fa !important;
  border-bottom: 1px solid #ebeef5 !important;
  border-right: 1px solid #ebeef5 !important;
  color: #303133 !important;
  font-weight: 600 !important;
  font-size: 13px !important;
}

.admin-content .el-table__body tr {
  background: transparent !important;
}

.admin-content .el-table__body tr:hover > td {
  background: #f5f7fa !important;
}

.admin-content .el-table__body td {
  border-bottom: 1px solid #ebeef5 !important;
  border-right: 1px solid #f5f7fa !important;
  color: #606266 !important;
  background: transparent !important;
  font-size: 13px !important;
}

.admin-content .el-table--border::after,
.admin-content .el-table--group::after,
.admin-content .el-table::before {
  background-color: #ebeef5 !important;
}

.admin-content .el-table--border .el-table__inner-wrapper::after {
  background-color: #ebeef5 !important;
}

.admin-content .el-table .cell {
  color: #606266 !important;
}

.admin-content .el-table__empty-block {
  background: transparent !important;
}

.admin-content .el-table__empty-text {
  color: #909399 !important;
}

.admin-content .el-input__wrapper {
  background: #ffffff !important;
  border: 1px solid #dcdfe6 !important;
  border-radius: 8px !important;
  box-shadow: none !important;
  transition: all 0.25s ease !important;
}

.admin-content .el-input__wrapper:hover {
  border-color: #c0c4cc !important;
  background: #ffffff !important;
}

.admin-content .el-input__wrapper.is-focus {
  border-color: #4084d9 !important;
  box-shadow: 0 0 0 1px rgba(64,132,217,0.15) !important;
}

.admin-content .el-input__inner {
  color: #303133 !important;
  background: transparent !important;
}

.admin-content .el-input__inner::placeholder {
  color: #c0c4cc !important;
}

.admin-content .el-select .el-input__wrapper {
  background: #ffffff !important;
}

.admin-content .el-select-dropdown {
  background: #ffffff !important;
  border: 1px solid #e4e7ed !important;
  border-radius: 8px !important;
}

.admin-content .el-select-dropdown__item {
  color: #606266 !important;
}

.admin-content .el-select-dropdown__item.hover,
.admin-content .el-select-dropdown__item:hover {
  background: #f5f7fa !important;
  color: #303133 !important;
}

.admin-content .el-select-dropdown__item.selected {
  color: #4084d9 !important;
  font-weight: 600 !important;
}

.admin-content .el-pagination {
  background: transparent !important;
  padding: 12px 0 !important;
}

.admin-content .el-pagination button {
  background: #ffffff !important;
  border: 1px solid #dcdfe6 !important;
  border-radius: 6px !important;
  color: #606266 !important;
}

.admin-content .el-pagination button:hover {
  color: #4084d9 !important;
  background: #ecf5ff !important;
}

.admin-content .el-pagination button:disabled {
  background: #f5f7fa !important;
  color: #c0c4cc !important;
  border-color: #e4e7ed !important;
}

.admin-content .el-pager li {
  background: #ffffff !important;
  border: 1px solid #dcdfe6 !important;
  border-radius: 6px !important;
  color: #606266 !important;
  font-weight: 500 !important;
  margin: 0 2px !important;
}

.admin-content .el-pager li:hover {
  color: #4084d9 !important;
  background: #ecf5ff !important;
}

.admin-content .el-pager li.is-active {
  background: #4084d9 !important;
  border-color: #4084d9 !important;
  color: #fff !important;
  font-weight: 700 !important;
}

.admin-content .el-pagination__total,
.admin-content .el-pagination__sizes,
.admin-content .el-pagination__jump {
  color: #909399 !important;
}

.admin-content .el-dialog {
  background: #ffffff !important;
  border-radius: 14px !important;
}

.admin-content .el-dialog__header {
  border-bottom: 1px solid #ebeef5 !important;
}

.admin-content .el-dialog__title {
  color: #303133 !important;
}

.admin-content .el-dialog__body {
  color: #606266 !important;
}

.admin-content .el-form-item__label {
  color: #606266 !important;
}

.admin-content .el-button--default {
  background: #ffffff !important;
  border: 1px solid #dcdfe6 !important;
  color: #606266 !important;
}

.admin-content .el-button--default:hover {
  background: #ecf5ff !important;
  border-color: #c6e2ff !important;
  color: #4084d9 !important;
}

.admin-content .el-button--primary {
  background: linear-gradient(135deg, #5470c6, #3b5fc0) !important;
  border: 1px solid rgba(84,112,198,0.3) !important;
  font-weight: 500 !important;
}

.admin-content .el-button--primary:hover {
  background: linear-gradient(135deg, #6581d7, #4c70d1) !important;
  box-shadow: 0 4px 14px rgba(84,112,198,0.25) !important;
}

.admin-content .el-button--danger {
  background: rgba(245,108,108,0.1) !important;
  border: 1px solid rgba(245,108,108,0.2) !important;
  color: #f56c6c !important;
}

.admin-content .el-button--danger:hover {
  background: rgba(245,108,108,0.2) !important;
  border-color: rgba(245,108,108,0.35) !important;
}

.admin-content .el-button--success {
  background: rgba(103,194,58,0.1) !important;
  border: 1px solid rgba(103,194,58,0.2) !important;
  color: #67c23a !important;
}

.admin-content .el-button--warning {
  background: rgba(230,162,60,0.1) !important;
  border: 1px solid rgba(230,162,60,0.2) !important;
  color: #e6a23c !important;
}

.admin-content .el-tag {
  background: #f5f7fa !important;
  border: 1px solid #e4e7ed !important;
  color: #606266 !important;
}

.admin-content .el-tag--success {
  background: rgba(103,194,58,0.1) !important;
  border-color: rgba(103,194,58,0.18) !important;
  color: #67c23a !important;
}

.admin-content .el-tag--warning {
  background: rgba(230,162,60,0.1) !important;
  border-color: rgba(230,162,60,0.18) !important;
  color: #e6a23c !important;
}

.admin-content .el-tag--danger {
  background: rgba(245,108,108,0.1) !important;
  border-color: rgba(245,108,108,0.18) !important;
  color: #f56c6c !important;
}

.admin-content .el-alert--info {
  background: #f4f4f5 !important;
}

.admin-content .el-alert__title {
  color: #303133 !important;
}

.admin-content .el-alert__description {
  color: #606266 !important;
}

.admin-content .el-empty__description p {
  color: #909399 !important;
}

.admin-content .el-descriptions {
  background: #ffffff !important;
  border: 1px solid #ebeef5 !important;
  border-radius: 10px !important;
}

.admin-content .el-descriptions__label {
  background: #fafafa !important;
  color: #909399 !important;
}

.admin-content .el-descriptions__content {
  color: #606266 !important;
}

.admin-content .el-tabs__header {
  border-bottom: 1px solid #e4e7ed !important;
}

.admin-content .el-tabs__item {
  color: #909399 !important;
}

.admin-content .el-tabs__item.is-active {
  color: #4084d9 !important;
}

.admin-content .el-tabs__active-bar {
  background: #4084d9 !important;
}

.admin-content .el-tabs__nav-wrap::after {
  background-color: #e4e7ed !important;
}

.admin-content .el-radio__label,
.admin-content .el-checkbox__label {
  color: #606266 !important;
}

.admin-content .el-divider__text {
  background: #ffffff !important;
  color: #909399 !important;
}

.admin-content .el-message-box {
  background: #ffffff !important;
  border: 1px solid #e4e7ed !important;
  border-radius: 14px !important;
}

.admin-content .el-message-box__title {
  color: #303133 !important;
}

.admin-content .el-message-box__message {
  color: #606266 !important;
}

.admin-content .el-popper.is-dark {
  background: #ffffff !important;
  border: 1px solid #e4e7ed !important;
}

.admin-content .el-switch__label {
  color: #606266 !important;
}

.admin-content .el-switch__label.is-active {
  color: #4084d9 !important;
}

.admin-content .el-upload-dragger {
  background: #fafafa !important;
  border: 2px dashed #dcdfe6 !important;
  border-radius: 10px !important;
}

.admin-content .el-upload-dragger:hover {
  border-color: #4084d9 !important;
}

.admin-content .el-upload__text {
  color: #909399 !important;
}

.admin-content .el-image-viewer__wrapper {
  background: rgba(0,0,0,0.85) !important;
}

.admin-content .el-tooltip__trigger {
  outline: none !important;
}
</style>