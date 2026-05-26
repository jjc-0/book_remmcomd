<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { projectName } from '../../config/config.default'
import {User, Lock, SwitchButton, Search, Connection} from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

// 路由实例
const router = useRouter()
const route = useRoute()

// 用户信息
const account = ref(
    localStorage.getItem('account') ? JSON.parse(localStorage.getItem('account')) : {}
)

// 当前激活的菜单项
const activeMenu = computed(() => route.path)

// 退出登录
const logout = () => {
  localStorage.removeItem('account')
  ElMessage.success('退出成功')
  router.push('/login')
}

const handleUpdateAccount = (updatedAccount) => {
  // 更新父组件中的用户信息
  account.value = updatedAccount
}

const keyword = ref('')

const search = () => {
  location.href = '/front/search?keyword=' + keyword.value
}

const clearSearch = () => {
  location.href = '/front/search?keyword=' + ''
}

</script>

<template>
  <div class="front-container">
    <!-- 顶部导航栏 -->
    <header class="header-nav">
      <div class="header-left-warp" @click="$router.push('/front/home')">
        <div class="logo-warp">
          <div class="logo">
            <img src="../../config/logo.svg" alt="Logo" />
          </div>
          <div class="logo-text">{{ projectName }}</div>
        </div>
      </div>

      <div class="search-bar">
        <el-input size="medium" style="width: 240px" v-model="keyword" @clear="clearSearch" clearable
                  placeholder="搜索图书"></el-input>
        <el-button size="medium" @click="search" class="search-btn">
          <el-icon><Search /></el-icon></el-button>
      </div>

      <div class="kg-nav-btn" @click="$router.push('/front/kgGraph')">
        <el-icon><Connection /></el-icon>
        <span>知识图谱</span>
      </div>

      <div class="user-warp">
        <!-- 未登录状态显示登录注册按钮 -->
        <template v-if="!account.id">
          <div class="btn-login">
            <el-button @click="router.push('/login')">登录</el-button>
          </div>
          <div class="btn-login" style="margin-left: 10px">
            <el-button @click="router.push('/register')">注册</el-button>
          </div>
        </template>

        <!-- 已登录状态显示用户头像和下拉菜单 -->
        <el-dropdown v-else class="custom-dropdown">
          <div class="user-avatar">
            <img :src="account.avatarUrl" />
          </div>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item>{{ account.nickname }}</el-dropdown-item>
              <el-dropdown-item>
                <router-link to="/front/person" class="dropdown-link">
                  <el-icon><User /></el-icon>
                  <span>个人信息</span>
                </router-link>
              </el-dropdown-item>
              <el-dropdown-item>
                <router-link to="/front/password" class="dropdown-link">
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

    <!-- 主内容区域 -->
    <div class="main-content">
      <router-view @update-account="handleUpdateAccount"></router-view>
    </div>

    <!-- 页脚 -->
    <footer class="front-footer">
      <p>{{ projectName }}</p>
    </footer>
  </div>
</template>

<style lang="scss" scoped>

$front-accent: #4084d9;
$front-bg: #f0f2f5;

.front-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: $front-bg;
}

.header-nav {
  z-index: 1800;
  position: sticky;
  top: 0;
  height: 64px;
  background: #ffffff;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 40px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
  overflow: visible;

  .header-left-warp {
    display: flex;
    align-items: center;
    height: 100%;
    cursor: pointer;

    .logo-warp {
      display: flex;
      align-items: center;
      margin-left: 20px;

      .logo {
        width: 32px;
        height: 32px;
        margin-right: 10px;

        img {
          width: 100%;
          height: 100%;
          object-fit: cover;
        }
      }

      .logo-text {
        font-size: 20px;
        font-weight: 600;
        color: #303133;
        letter-spacing: 0.5px;
      }

    }

    .header-navs{
      margin-left: 80px;
      height: 100%;

      .el-menu {
        background-color: transparent !important;
        border: none !important;
        height: 64px !important;
      }

      .el-menu-item {
        height: 64px !important;
        line-height: 64px !important;
        border: none !important;
        font-weight: 500;
      }

      .el-menu-item:hover {
        color: $front-accent !important;
        background-color: transparent !important;
      }

      .el-menu-item.is-active {
        color: $front-accent !important;
        background-color: transparent !important;
        border: none !important;
      }

    }

  }

  .search-bar {
    display: flex;
    align-items: center;

    :deep(.el-input__wrapper) {
      border-radius: 20px;
      background: #f5f7fa;
      box-shadow: 0 0 0 1px #dcdfe6 inset;
      transition: all 0.3s;

      &:hover {
        box-shadow: 0 0 0 1px $front-accent inset;
      }

      &.is-focus {
        box-shadow: 0 0 0 1px $front-accent inset;
      }
    }

    :deep(.el-input__inner) {
      color: #303133;

      &::placeholder {
        color: #c0c4cc;
      }
    }

    .search-btn {
      margin-left: 5px;
      background: linear-gradient(135deg, #4084d9 0%, #2c5fa1 100%);
      color: #fff;
      border: none;
      border-radius: 50%;
      width: 36px;
      height: 36px;
      padding: 0;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: all 0.3s ease;

      &:hover {
        background: linear-gradient(135deg, #5a9ae6 0%, #4084d9 100%);
        box-shadow: 0 2px 12px rgba(64, 132, 217, 0.35);
        transform: translateY(-1px);
      }
    }
  }

  .kg-nav-btn {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 6px 16px;
    border-radius: 8px;
    border: 1px solid #dcdfe6;
    color: #606266;
    font-size: 14px;
    cursor: pointer;
    transition: all 0.25s ease;
    background: #f5f7fa;

    &:hover {
      color: $front-accent;
      border-color: rgba(64, 132, 217, 0.4);
      background: rgba(64, 132, 217, 0.08);
    }

    .el-icon {
      font-size: 18px;
    }
  }

  .user-warp {
    display: flex;
    align-items: center;
    margin-right: 20px;
    height: 100%;
    gap: 12px;

    .btn-login {
      margin-top: 0;

      .el-button {
        border-radius: 20px;
        font-weight: 500;
        background: #f5f7fa;
        border-color: #dcdfe6;
        color: #606266;
      }
    }

    .user-avatar {
      width: 38px;
      height: 38px;
      border-radius: 50%;
      overflow: hidden;
      border: 2px solid rgba(255, 255, 255, 0.3);
      padding: 2px;
      cursor: pointer;
      outline: none !important;
      transition: transform 0.2s ease;

      &:hover {
        transform: scale(1.05);
      }

      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        border-radius: 50%;
      }

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

  }
}

.main-content {
  flex: 1;
  background: $front-bg;
}

.front-footer {
  padding: 20px 24px;
  text-align: center;
  background: #ffffff;
  color: #909399;
  font-size: 12px;
  border-top: 1px solid #ebeef5;
}

</style>
