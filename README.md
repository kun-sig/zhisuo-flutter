# ZhiSuo Flutter

知索智能学习/题库客户端（Flutter 多端）。当前版本定位为业务原型与工程基座，已具备完整页面流转、主题体系、国际化、日志体系与网络层封装，业务数据以本地 Mock 为主。

## 1. 项目定位

- 目标场景：职业考试/题库练习/学习提升
- 产品形态：移动端主导（Android、iOS），含 OpenHarmony 工程目录
- 工程目标：提供可扩展的企业级 Flutter 脚手架，支持后续快速接入真实业务

## 2. 功能清单（已实现）

### 2.1 登录与启动链路

- 启动页（`Splash`）带渐显动效，启动时初始化科目数据（拉取远端并写入本地）
- 初始化成功后跳转登录页，失败则停留在启动页并支持重试
- 登录页支持两种模式切换：
  - 手机号 + 验证码登录（含 60 秒倒计时发送逻辑）
  - 手机号 + 密码登录
- 登录流程已接入加载态和模拟成功跳转

### 2.2 考试选择

- 独立考试选择页（`Subject`）
- 左侧分类菜单 + 右侧自适应网格（2~4 列）
- 分类切换、考试项选中状态可响应更新

### 2.3 首页主框架

- 底部导航 4 Tab（首页/题库/学习中心/我的）
- `IndexedStack` 保留 Tab 状态，切换不丢页面上下文

### 2.4 各 Tab 业务原型

- 首页（`TabHome`）：
  - Banner 轮播（自动滚动）
  - 资讯列表展示
- 题库（`TabQuestionBank`）：
  - 每日一练打卡卡片
  - 测试练习宫格入口
  - 专项练习列表
- 学习中心（`TabStudyCenter`）：
  - 今日练习数据概览
  - 模块化练习入口
  - 专项突破列表
- 我的（`TabMine`）：
  - 用户信息卡片
  - 常用设置菜单
  - 退出登录确认

### 2.5 工程能力

- 路由管理：GetX 命名路由 + Binding 注入
- 状态管理：GetX 响应式状态（`Rx`）
- 主题系统：统一色板、圆角、按钮、输入框、NavigationBar 样式
- 国际化：中文/英文文案资源
- 日志系统：
  - 控制台 + 本地文件双通道输出
  - 日志按天与文件大小轮转（10MB）
  - 默认保留最近 3 天日志
  - 捕获 Flutter 与 Dart 层异常
- 网络封装：基于 Dio 的 `GET/POST/PUT/DELETE` 统一入口与拦截器

## 3. 技术栈

- Flutter（Dart SDK 约束：`^3.6.2`）
- 状态管理/路由/依赖注入：`get`
- 网络：`dio`
- 日志：`logger`
- 本地目录：`path_provider`
- 国际化：`intl`

## 4. 工程结构

```text
lib/
├── app.dart                      # 应用入口配置（GetMaterialApp/初始注入）
├── main.dart                     # 启动与全局异常兜底
├── data/                         # 数据层（按职责拆分）
│   ├── models/                   # 数据模型（DTO/实体）
│   ├── repositories/             # 仓储层（聚合 local/remote，对上提供统一接口）
│   ├── local/                    # 本地数据源（sqflite 持久化读写）
│   └── remote/                   # 远端数据源（后端接口请求与响应转换）
├── i18n/                         # 多语言资源
├── logger/                       # 文件日志与异常捕获
├── pages/
│   ├── splash/                   # 启动页
│   ├── login/                    # 登录页
│   ├── subject/                  # 仅页面层文件（binding/controller/page）
│   └── home/                     # 底部主框架与4个Tab
├── routes/                       # 路由常量、路由表、导航封装
├── services/                     # 网络服务与应用级服务控制器
└── theme/                        # 主题与设计令牌
```

目录职责说明：

- `data/models`：定义可复用的数据结构，不承载存储和网络逻辑。
- `data/repositories`：实现业务数据编排策略，例如“启动同步远端数据到本地”“页面菜单只读本地”。
- `data/local`：面向本地数据库的 CRUD 与查询，不关心页面状态与交互。
- `data/remote`：面向 API 的请求与解析，不关心缓存策略与 UI。
- `pages/*`：页面展示与交互状态管理；页面目录下仅放 `binding/controller/page`。

## 5. 快速开始

### 5.1 环境要求

- Flutter SDK（建议与项目当前稳定版保持一致）
- Dart SDK `^3.6.2`
- Xcode / Android Studio（按目标平台准备）

### 5.2 安装依赖

```bash
flutter pub get
```

### 5.3 运行

```bash
flutter run
```

## 6. 构建发布

```bash
# Android（dev，默认）
flutter build apk --release

# Android（test）
flutter build apk --release --dart-define=APP_ENV=test

# Android（prod）
flutter build apk --release --dart-define=APP_ENV=prod

# iOS（dev，默认）
flutter build ios --release

# iOS（test）
flutter build ios --release --dart-define=APP_ENV=test

# iOS（prod）
flutter build ios --release --dart-define=APP_ENV=prod
```

OpenHarmony 构建请按 `ohos/` 目录工程配置执行对应构建流程。

## 7. 配置说明

### 7.1 API 基础地址

当前 API 地址来自配置文件：

- `assets/config/app_config_dev.json`
- `assets/config/app_config_test.json`
- `assets/config/app_config_prod.json`

环境选择通过 `APP_ENV` 指定：

```bash
# 默认 dev（不传 APP_ENV）
flutter run

# 指定 test
flutter run --dart-define=APP_ENV=test

# 指定 prod
flutter run --dart-define=APP_ENV=prod
```

### 7.2 主题与品牌

- 色板：`lib/theme/app_colors.dart`
- 主题：`lib/theme/app_theme.dart`
- 样式：`lib/theme/app_text_styles.dart`

### 7.3 国际化

- Key：`lib/i18n/locale_keys.dart`
- 中文：`lib/i18n/zh_cn.dart`
- 英文：`lib/i18n/en_us.dart`

## 8. 当前状态与限制

- 当前多数业务数据为页面内 Mock 数据，尚未接入真实后端
- 登录成功后默认跳转考试选择页，`Home` 路由已存在但未作为当前主链路入口
- 首页轮播图引用了 `banner1.jpg/banner2.jpg/banner3.jpg`，但 `assets/images` 目前仅包含 `logo.webp`，需补齐素材或改为网络图
- 自动化测试仅保留 Flutter 默认样例，尚未覆盖关键业务流程

## 9. 企业化落地建议（下一阶段）

- 接入真实鉴权体系（Token 刷新、失效重登、权限模型）
- 建立分层架构（data/domain/presentation）与 Repository 规范
- 完善 API 错误码映射、重试策略、埋点与可观测性
- 建立测试基线（单测/组件测试/集成测试）与质量门禁
- 增加环境管理与发布流水线（多环境、多渠道、自动版本号）

## 10. 许可证

当前仓库未声明开源许可证，默认按内部项目管理策略使用。
