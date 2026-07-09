# 校园二手交易互助平台

一个基于 ASP.NET Web Forms 的校园二手交易与互助综合服务平台，为高校学生提供二手物品交易、失物招领、社区交流、避雷曝光、校园求助等功能。

## 技术栈

| 层级 | 技术 |
|------|------|
| 前端 | ASP.NET Web Forms, HTML5, CSS3, JavaScript, AJAX, ECharts |
| 后端 | C# (.NET Framework 4.7.2) |
| 数据库 | SQL Server (数据库名: `CampusMarket`) |
| IDE | Visual Studio + IIS Express |

## 功能模块

### 用户认证
- 注册（学号+真实姓名，需通过预存学生信息库实名验证）
- 登录（区分学生/管理员角色，被封禁账号拒绝登录）
- 密码重置（学号+姓名验证身份后重置）

### 二手交易
- 商品浏览：首页展示所有在售商品，支持分类筛选和关键词搜索
- 商品发布：标题、价格、描述、分类、多图上传
- 商品详情：图片轮播、卖家信息、信誉风险预警、评论区
- 快捷购买：一键生成订单，自动下架商品
- 信誉风控：购买前校验卖家信誉分，低于 60 分禁止交易

### 社区广场
- 帖子类型：求购、避雷曝光、求助帮忙
- 点赞功能（一人一赞，再次点击取消）
- 帖子置顶优先显示
- 分类筛选与搜索

### 失物招领
- 发布寻物/招领信息，可设置答谢金额
- 物归原主后结帖归档

### 管理员后台
- 帖子管理：置顶/取消置顶、强制下架
- 避雷审核：判定属实/不实，自动扣分
- 用户管理：封禁/解封、删除用户
- 活跃度统计：ECharts 饼图 + 排行榜

### 信誉系统
- 初始信誉分 100，违规扣分
- 低于 80 分黄色预警，低于 60 分红标禁止交易
- 信誉分快照记录（UserReputation 表）

## 项目结构

```
├── AdminCenter.aspx          # 管理员后台
├── Community.aspx            # 社区广场
├── Default.aspx              # 首页/二手市场
├── LostFound.aspx            # 失物招领
├── MyAccount.aspx            # 个人中心
├── PostProduct.aspx          # 发帖页
├── ProductDetail.aspx        # 商品/帖子详情
├── Login.aspx                # 登录
├── Register.aspx             # 注册
├── ResetPassword.aspx        # 密码重置
├── App_Code/
│   └── DBHelper.cs           # 数据库访问封装
├── Models/                   # 数据模型
├── images/                   # 图片资源
├── Uploads/                  # 用户上传文件
└── Web.config                # 配置文件
```

## 数据库表

| 表名 | 说明 |
|------|------|
| Users | 用户表（学号、姓名、密码、角色、信誉分、状态） |
| Products | 帖子商品表（标题、价格、描述、分类、类型、状态、置顶） |
| Categories | 分类表 |
| Orders | 订单表 |
| Comments | 评论表 |
| ChatMessages | 私聊消息表 |
| Reports | 举报记录表 |
| ProductLikes | 点赞记录表 |
| Students | 预存学生信息表（实名验证用） |
| UserReputation | 信誉快照表 |

## 快速开始

### 环境要求

- Visual Studio 2017+
- SQL Server (LocalDB 或 Express)
- .NET Framework 4.7.2

### 运行步骤

1. 克隆仓库到本地

2. 使用 Visual Studio 打开 `0506-1.sln`

3. 在 SQL Server 中创建数据库 `CampusMarket`，执行项目提供的建表脚本

4. 修改 `Web.config` 中的数据库连接字符串（默认使用 Windows 集成认证连接本地 SQL Server）

```xml
<connectionStrings>
  <add name="ConnStr"
       connectionString="Data Source=.;Initial Catalog=CampusMarket;Integrated Security=True"
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

5. 在 `Students` 表中预存学生信息（学号+姓名），用于注册实名验证

6. 按 F5 或 Ctrl+F5 启动项目，访问 `http://localhost:62470/`

### 默认管理员

在 `Users` 表中手动插入一条管理员记录（Role = "Admin"），即可通过管理员后台入口进行管理操作。

## 页面导航

```
Login.aspx ──→ Default.aspx（学生）/ AdminCenter.aspx（管理员）
Default.aspx ──→ ProductDetail.aspx（查看详情）
            ──→ PostProduct.aspx（发帖）
            ──→ Community.aspx（社区）
            ──→ LostFound.aspx（失物招领）
            ──→ MyAccount.aspx（个人中心）
```

## 作者

**Ccioroll** — 单人独立开发
