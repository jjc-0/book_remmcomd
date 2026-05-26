<script setup>
import {ref, reactive} from 'vue'
import {useRouter} from 'vue-router'
import {projectName} from '../../config/config.default'
import {User, Lock, Key, Reading, Collection, Notebook} from '@element-plus/icons-vue'
import {ElMessage} from 'element-plus'
import request from "@/utils/request.js";

// 路由实例
const router = useRouter()
const userFormInst = ref(null)

// 角色选项
const roleOptions = [
  { label: '普通用户', value: 'ROLE_USER' },
  { label: '管理员', value: 'ROLE_ADMIN' },
]

// 登录表单
const account = reactive({
  username: '',
  password: '',
  role: 'ROLE_USER' // 默认选择普通用户
})

// 是否同意
const isAllow = ref(true)

// 表单验证规则
const rules = {
  username: [
    {required: true, message: '请输入用户名', trigger: 'blur'},
    {min: 3, max: 10, message: '长度在 3 到 10 个字符', trigger: 'blur'}
  ],
  password: [
    {required: true, message: '请输入密码', trigger: 'blur'},
    {min: 1, max: 20, message: '长度在 1 到 20 个字符', trigger: 'blur'}
  ],
  role: [
    {required: true, message: '请选择角色', trigger: 'change'}
  ]
}

// 登录方法
const login = () => {
  // 表单校验合法
  userFormInst.value.validate((valid) => {
    // 如果合法
    if (valid) {
      request.post('/web/login', account).then((res) => {
        if (res.code === '200') {
          localStorage.setItem('account', JSON.stringify(res.data))
          if (res.data.role === 'ROLE_ADMIN' || res.data.role === 'ROLE_UNIT') {
            router.push('/back/home')
          } else {
            router.push('/front/home')
          }
          ElMessage.success('登录成功')
        } else {
          ElMessage.error(res.msg || '出错啦')
        }
      })
    }
  })
}

</script>

<template>
  <div class="login-container">
    <div class="background-shapes">
      <div class="shape shape-1"></div>
      <div class="shape shape-2"></div>
      <div class="shape shape-3"></div>
      <div class="shape shape-4"></div>
    </div>

    <div class="login-content">
      <div class="login-left">
        <div class="brand-logo">
          <div class="logo-circle">
            <img src="../../config/logo.svg" alt="Logo" class="logo-image" />
            <Key class="logo-icon" />
          </div>
          <h2 class="brand-name">{{ projectName }}</h2>
        </div>
        <div class="login-features">
          <div class="feature-item">
            <div class="feature-icon">
              <el-icon><Reading /></el-icon>
            </div>
            <div class="feature-text">
              <h3>智能推荐</h3>
              <p>基于知识图谱的个性化图书推荐</p>
            </div>
          </div>
          <div class="feature-item">
            <div class="feature-icon">
              <el-icon><Collection /></el-icon>
            </div>
            <div class="feature-text">
              <h3>知识关联</h3>
              <p>深度挖掘图书间的语义关联关系</p>
            </div>
          </div>
          <div class="feature-item">
            <div class="feature-icon">
              <el-icon><Notebook /></el-icon>
            </div>
            <div class="feature-text">
              <h3>海量图书</h3>
              <p>丰富的图书资源库随心探索阅读</p>
            </div>
          </div>
        </div>
        <div class="login-footer">
          <p>© {{ new Date().getFullYear() }} {{ projectName }}. 保留所有权利</p>
        </div>
      </div>

      <div class="login-right">
        <div class="login-form-container">
          <h1 class="login-title">欢迎回来</h1>
          <p class="login-subtitle">请登录您的账号继续访问</p>

          <el-form :model="account" :rules="rules" ref="userFormInst" class="login-form" @keydown.enter="login">
            <el-form-item prop="username">
              <el-input
                  placeholder="请输入用户名"
                  size="large"
                  :prefix-icon="User"
                  v-model="account.username">
              </el-input>
            </el-form-item>

            <el-form-item prop="password">
              <el-input
                  size="large"
                  :prefix-icon="Lock"
                  show-password
                  placeholder="请输入密码"
                  v-model="account.password">
              </el-input>
            </el-form-item>

            <el-form-item prop="role">
              <el-select
                  v-model="account.role"
                  placeholder="请选择角色"
                  size="large"
                  style="width: 100%">
                <el-option
                    v-for="item in roleOptions"
                    :key="item.value"
                    :label="item.label"
                    :value="item.value">
                </el-option>
              </el-select>
            </el-form-item>

            <el-form-item>
              <el-checkbox v-model="isAllow" class="allow-warp">
                我已阅读并同意 <a href="#" class="link">《隐私政策》</a>和<a href="#" class="link">《服务条款》</a>
              </el-checkbox>
            </el-form-item>

            <el-form-item>
              <el-button
                  class="login-button"
                  type="primary"
                  size="large"
                  :disabled="!isAllow"
                  @click="login">
                登录
              </el-button>
            </el-form-item>

            <div class="register-link">
              还没有账号？<a @click="router.push('/register')" class="link">立即注册</a>
            </div>
          </el-form>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.login-container {
  width: 100%;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background: linear-gradient(180deg, #e8f0fe 0%, #dce8fc 40%, #f0f2f5 70%, #f5f7fa 100%);
  position: relative;
  overflow: hidden;
}

.background-shapes {
  position: absolute;
  width: 100%;
  height: 100%;
  z-index: 0;

  .shape {
    position: absolute;
    border-radius: 50%;

    &-1 {
      width: 400px;
      height: 400px;
      background: radial-gradient(circle, rgba(64, 132, 217, 0.12) 0%, transparent 70%);
      top: -150px;
      left: -100px;
    }

    &-2 {
      width: 300px;
      height: 300px;
      background: radial-gradient(circle, rgba(64, 132, 217, 0.08) 0%, transparent 70%);
      bottom: -80px;
      right: 5%;
    }

    &-3 {
      width: 200px;
      height: 200px;
      background: radial-gradient(circle, rgba(212, 175, 55, 0.08) 0%, transparent 70%);
      top: 15%;
      right: -60px;
    }

    &-4 {
      width: 350px;
      height: 350px;
      background: radial-gradient(circle, rgba(64, 132, 217, 0.06) 0%, transparent 70%);
      bottom: 5%;
      left: 8%;
    }
  }
}

.login-content {
  width: 960px;
  height: 560px;
  display: flex;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 8px 40px rgba(0, 0, 0, 0.08);
  position: relative;
  z-index: 1;
  background: #ffffff;
  border: 1px solid #e4e7ed;
}

.login-left {
  width: 40%;
  background: linear-gradient(135deg, #4084d9 0%, #1a4f94 100%);
  color: white;
  padding: 40px;
  display: flex;
  flex-direction: column;
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: radial-gradient(circle, rgba(255, 255, 255, 0.05) 0%, transparent 50%);
  }
}

.brand-logo {
  display: flex;
  align-items: center;
  margin-bottom: 60px;
  position: relative;
  z-index: 1;

  .logo-circle {
    width: 40px;
    height: 40px;
    border-radius: 12px;
    background-color: rgba(255, 255, 255, 0.2);
    display: flex;
    justify-content: center;
    align-items: center;
    margin-right: 12px;

    .logo-image {
      width: 28px;
      height: 28px;
      object-fit: contain;
      filter: brightness(0) invert(1);
    }
  }

  .brand-name {
    font-size: 20px;
    font-weight: 600;
    letter-spacing: 0.5px;
  }
}

.login-features {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  position: relative;
  z-index: 1;

  .feature-item {
    display: flex;
    align-items: center;
    margin-bottom: 28px;

    .feature-icon {
      width: 44px;
      height: 44px;
      border-radius: 12px;
      background-color: rgba(255, 255, 255, 0.15);
      display: flex;
      justify-content: center;
      align-items: center;
      margin-right: 16px;

      .el-icon {
        font-size: 22px;
      }
    }

    .feature-text {
      h3 {
        font-size: 15px;
        margin: 0 0 4px 0;
        font-weight: 600;
      }

      p {
        font-size: 13px;
        margin: 0;
        opacity: 0.75;
      }
    }
  }
}

.login-footer {
  font-size: 12px;
  opacity: 0.6;
  text-align: center;
  position: relative;
  z-index: 1;
}

.login-right {
  width: 60%;
  background-color: transparent;
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
}

.login-form-container {
  width: 340px;
  position: relative;
  z-index: 1;
}

.login-title {
  font-size: 26px;
  font-weight: 700;
  color: #303133;
  margin: 0 0 6px 0;
}

.login-subtitle {
  font-size: 15px;
  color: #909399;
  margin: 0 0 36px 0;
}

.login-form {
  .allow-warp {
    font-size: 13px;
    color: #909399;
  }

  .login-button {
    width: 100%;
    height: 46px;
    font-size: 15px;
    font-weight: 600;
    margin-top: 10px;
    background: linear-gradient(135deg, #4084d9 0%, #1a4f94 100%);
    border: none;
    border-radius: 10px;
    letter-spacing: 1px;
    transition: all 0.3s ease;

    &:hover {
      transform: translateY(-1px);
      box-shadow: 0 6px 20px rgba(64, 132, 217, 0.35);
    }

    &:disabled {
      background: linear-gradient(135deg, #a0c3f0 0%, #8eadd3 100%);
      transform: none;
      box-shadow: none;
    }
  }
}

.register-link {
  text-align: center;
  margin-top: 20px;
  font-size: 14px;
  color: #909399;
}

.link {
  color: #4084d9;
  text-decoration: none;
  cursor: pointer;
  font-weight: 500;

  &:hover {
    text-decoration: underline;
  }
}
</style>
