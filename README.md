# 📚 图书推荐系统

基于 **Spring Boot 3 + Vue 3** 的智能图书推荐平台，集成**协同过滤**与**知识图谱**混合推荐算法，为用户提供个性化图书推荐服务。

## ✨ 核心功能

### 用户端

- 🔐 **注册/登录** — JWT 身份认证，支持用户和管理员双角色
- 🏠 **首页浏览** — 轮播图 Banner、推荐分类、热门图书展示
- 📖 **图书检索** — 分类筛选、关键词搜索、图书详情查看
- 🛒 **购物车** — 添加/删除图书、批量结算
- ❤️ **收藏夹** — 图书收藏管理
- 📦 **订单管理** — 下单、查看订单状态
- 👤 **个人中心** — 个人信息修改、密码修改、收货地址管理
- 🧠 **知识图谱可视化** — 图书知识图谱关系图展示

### 管理后台

- 📊 **数据仪表盘** — ECharts 可视化统计图表
- 📚 **图书管理** — 图书 CRUD、上架/下架
- 📂 **分类管理** — 图书分类增删改查
- 🏷️ **标签管理** — 图书标签维护
- 🖼️ **轮播图管理** — 首页 Banner 配置
- 📢 **公告管理** — 系统公告发布
- 👥 **用户管理** — 用户信息管理
- 🛒 **订单管理** — 订单查看与处理
- 🧠 **知识图谱后台** — 知识图谱数据管理

### 推荐引擎

- 🤝 **协同过滤推荐** — 基于用户的协同过滤算法（UserCF）
- 🕸️ **知识图谱推荐** — 基于 Neo4j 的知识图谱语义推荐
- 🔀 **混合推荐** — KNN + 协同过滤融合策略

## 🛠️ 技术栈

| 层级 | 技术 |
|------|------|
| 后端框架 | Spring Boot 3.5、MyBatis-Plus |
| 数据库 | MySQL |
| 图数据库 | Neo4j |
| 认证鉴权 | JWT (Auth0) |
| 前端框架 | Vue 3 + Vite |
| UI 组件库 | Element Plus |
| 可视化 | ECharts 5 |
| HTTP 客户端 | Axios |
| 路由 | Vue Router 4 |
| 富文本编辑器 | WangEditor 5 |

## 📁 项目结构

```
book_remmcomd/
├── src/main/java/com/example/springboot/
│   ├── common/              # 公共类（常量、统一响应）
│   ├── config/              # 配置（CORS、拦截器、MyBatis-Plus）
│   ├── controller/          # REST 控制器
│   ├── entity/              # 数据库实体
│   ├── exception/           # 全局异常处理
│   ├── mapper/              # MyBatis Mapper 接口
│   ├── neo4j/               # Neo4j 节点定义与仓库
│   │   ├── node/            # 图节点实体
│   │   └── repository/      # Neo4j 查询仓库
│   ├── service/             # 业务逻辑层
│   │   └── impl/            # 服务实现
│   └── utils/               # 工具类（协同过滤、知识图谱推荐）
├── src/main/resources/
│   └── application.yaml     # 应用配置
├── scripts/
│   └── douban_books.json    # 豆瓣图书种子数据
└── vue/                     # Vue 3 前端项目
    └── src/
        ├── views/           # 页面组件
        │   ├── front/       # 用户端页面
        │   └── back/        # 管理后台页面
        ├── components/      # 通用组件
        ├── router/          # 路由配置
        ├── utils/           # 工具（Axios 封装）
        └── style/           # 全局样式
```

## 🚀 快速开始

### 环境要求

- **JDK** 21+
- **Maven** 3.6+
- **Node.js** 18+
- **MySQL** 8.0+
- **Neo4j** 4.x / 5.x

### 1. 数据库准备

创建 MySQL 数据库：

```sql
CREATE DATABASE book_recommend DEFAULT CHARACTER SET utf8mb4;
```

配置 Neo4j 连接（`application.yaml`）：

```yaml
spring:
  neo4j:
    uri: bolt://localhost:7687
    authentication:
      username: neo4j
      password: your_password
```

### 2. 后端启动

```bash
cd book_remmcomd
mvn spring-boot:run
```

后端默认运行在 `http://localhost:9090`

### 3. 前端启动

```bash
cd book_remmcomd/vue
npm install
npm run dev
```

前端默认运行在 `http://localhost:5173`

### 4. 访问系统

- 用户端：`http://localhost:5173`
- 管理后台：登录后访问后台管理页面

## ⚙️ 配置文件

主要配置项在 `src/main/resources/application.yaml`：

```yaml
server:
  port: 9090

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/book_recommend
    username: root
    password: your_password

  neo4j:
    uri: bolt://localhost:7687
    authentication:
      username: neo4j
      password: your_password

recommend:
  similar-user-count: 20    # 相似用户数量
  alpha: 0.3                # 混合推荐权重
```

## 📊 推荐算法说明

### 协同过滤（UserCF）

基于用户行为数据（浏览、收藏、购买），计算用户间相似度，为用户推荐相似用户喜欢的图书。

### 知识图谱推荐

构建图书知识图谱（图书-作者-分类-出版社-时代-主题），利用 Neo4j 图数据库进行语义关联推荐，挖掘图书间深层关系。

### 混合推荐策略

融合协同过滤与知识图谱两种推荐结果，通过权重参数 `alpha` 调节两者的影响比例，兼顾用户行为偏好与内容语义关联。

## 📄 License

本项目仅用于学习交流目的。
