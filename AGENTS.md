# AGENTS.md

本文件定义 `zhisuo_flutter` 的扩展规则。后续新增功能、重构、修复请优先遵循本规范，保证目录结构、数据流和代码风格一致。

## 1. 项目现状基线

- 技术栈：Flutter + GetX + Dio + sqflite。
- 当前主链路：`Splash(初始化科目数据) -> Login -> Subject`。
- 应用入口：`lib/main.dart`，全局注入在 `lib/app.dart` 的 `InitBinding`。
- 核心分层：
  - `pages/`：页面、交互、状态管理（GetX Controller）。
  - `data/`：模型、本地数据源、远端数据源、仓储聚合。
  - `services/`：基础设施服务（HTTP、应用级状态）。
  - `routes/`：路由常量、页面注册、导航封装。
  - `theme/`、`i18n/`、`logger/`：设计系统、多语言、日志。

## 2. 目录职责（必须遵守）

- `lib/pages/*`
  - 仅放页面相关文件：`xxx_page.dart`、`xxx_controller.dart`、`xxx_binding.dart`。
  - 不直接写 SQL，不直接操作 Dio。
- `lib/data/models/*`
  - 仅定义数据结构与序列化转换。
  - 不写 UI 逻辑，不依赖 GetX Controller。
- `lib/data/local/*`
  - 只做本地持久化读写（SQLite 查询、事务、迁移配套）。
- `lib/data/remote/*`
  - 只做接口请求与响应转换。
- `lib/data/repositories/*`
  - 聚合 local/remote，输出可供页面直接消费的数据。
  - 负责缓存策略、默认值策略、排序策略等业务编排。
- `lib/services/*`
  - 放跨模块通用服务（如 HTTP、全局服务控制器）。

## 3. 数据流规则

- 标准路径：`Page -> Controller -> Repository -> Local/Remote`。
- Controller 禁止直接依赖 LocalDataSource 或 RemoteService。
- Page 禁止直接调用 Repository。
- Repository 可以同时调用 local/remote 并对结果做聚合。
- 若新增业务需要“启动初始化”，在 `SplashController` 或专用初始化流程中统一触发，不要散落在页面 `build` 内。

## 4. 新增业务模块模板

新增业务（例如 `exam_plan`）时，按下列结构创建：

```text
lib/pages/exam_plan/
  exam_plan_page.dart
  exam_plan_controller.dart
  exam_plan_binding.dart

lib/data/models/exam_plan/
  exam_plan_models.dart

lib/data/local/
  exam_plan_local_data_source.dart

lib/data/remote/
  exam_plan_remote_service.dart

lib/data/repositories/exam_plan/
  exam_plan_repository.dart
```

同时必须同步：

1. 在 `lib/app.dart` 的 `InitBinding` 中注册基础依赖（如 repository、data source、service）。
2. 在 `lib/routes/app_routes.dart` 新增路由常量。
3. 在 `lib/routes/app_pages.dart` 注册 `GetPage` 与对应 `Binding`。
4. 如果有导航快捷方法，在 `lib/routes/app_navigator.dart` 增加封装方法。

## 5. GetX 约定

- `Binding` 负责注入当前模块 Controller（及必要依赖）。
- 依赖注入边界：
  - 全局单例（如 `HttpService`、`AppDatabase`、全局 repository）仅在 `InitBinding` 注册。
  - 页面级依赖仅在对应模块 `Binding` 注册，禁止在 `Widget build` 或业务方法里临时 `Get.put`。
  - Controller 优先使用构造函数注入依赖，减少隐式 `Get.find()` 扩散。
- `Controller` 字段规范：
  - 业务状态用 `Rx`（如 `final isLoading = false.obs;`）。
  - UI 输入建议使用 `TextEditingController` + `onClose` 释放。
  - 异步任务必须显式维护 `loading/error` 状态。
- 生命周期：
  - 初始化请求放 `onInit` 或 `onReady`，根据是否依赖首帧渲染选择。
  - `Worker`、`Timer`、`Controller` 必须在 `onClose` 释放。

## 6. 网络与异常处理

- 所有 HTTP 请求统一通过 `HttpService`。
- 新接口优先在 `remote service` 新增方法，不在 Controller 直接拼 URL。
- 接口地址统一走配置文件（`assets/config/app_config_<env>.json`），禁止在页面/业务代码硬编码环境地址。
- 异常处理规则：
  - Repository/Controller 捕获后给出用户可理解的错误文案。
  - 同时使用 `Logger` 记录上下文（方法名、关键参数、错误栈）。
- 严禁吞异常：`catch` 后至少要“设置错误态”或“日志记录 + 上抛”。
- 敏感信息保护：
  - 日志中禁止输出密码、验证码、Token、完整手机号等敏感字段。
  - 打点或日志需脱敏（如手机号仅保留前3后4）。

## 7. 本地数据库规范

- 统一由 `AppDatabase` 管理建表与升级。
- 每次新增表/字段必须：
  - 增加数据库版本号。
  - 在 `onUpgrade` 补充增量迁移。
  - 保证旧版本可平滑升级。
- 批量写入优先使用事务和 batch，避免中间态。

## 8. UI、主题与文案

- 自定义颜色统一定义在 `lib/theme/app_colors.dart` 的 `AppColors` 中，业务页面禁止直接新增零散 `Color(0x...)` 常量。
- 字体样式统一定义在 `lib/theme/app_text_styles.dart` 的 `AppTextStyles` 中，页面与组件优先复用，不重复硬编码字号/字重/颜色组合。
- 圆角与间距优先复用 `lib/theme/app_radius.dart` 与 `lib/theme/app_spacing.dart`，避免重复魔法数字。
- 颜色、圆角、间距优先复用 `lib/theme/*`，避免页面硬编码。
- 新增文案默认进入 i18n：
  - `lib/i18n/locale_keys.dart` 增加 key。
  - `lib/i18n/zh_cn.dart`、`lib/i18n/en_us.dart` 同步补齐。
- 图片资源新增后需要同步更新 `pubspec.yaml` 的 `assets`。

## 9. 命名与代码风格

- 文件名：`snake_case.dart`。
- 类型名：`UpperCamelCase`。
- 方法与变量：`lowerCamelCase`。
- 新增或修改函数时，必须使用中文注释说明“函数功能作用”；状态流转、聚合组装、兼容分支、兜底策略等关键逻辑必须补充中文注释说明。
- 保持单一职责：
  - Page 负责视图。
  - Controller 负责状态与交互。
  - Repository 负责业务数据编排。

## 10. 开发自检清单

提交前至少完成：

1. `dart format lib test` 执行后无格式漂移。
2. `flutter analyze` 无新增错误。
3. `flutter test` 至少通过现有测试；新增核心逻辑需补充对应测试或给出人工回归步骤。
4. 路由可达，页面能正常进入与返回。
5. 异步流程具备加载态和失败态。
6. 新增文本已国际化（至少 `zh_CN`、`en_US`）。
7. 新增数据库变更已覆盖迁移逻辑。
8. 关键路径日志可定位问题（初始化、请求失败、状态切换）。
9. 新增颜色已沉淀到 `AppColors`，新增字体样式已沉淀到 `AppTextStyles`。
10. 新增圆角/间距已复用 `AppRadius`/`AppSpacing`。
11. 环境地址变更仅修改 `assets/config/app_config_<env>.json`，不修改业务代码。
12. 新增后端接口已与 `zhisuo/internal/api/routes.go` 对齐（路径、方法、请求体字段）。

## 11. 代码评审重点

评审时优先检查：

1. 是否违反分层（Controller 直接调 local/remote）。
2. 是否遗漏 `Binding` / 路由注册 / 依赖注入，是否把依赖注册在了错误层级。
3. 是否有资源泄漏（`Timer`、`Worker`、`TextEditingController` 未释放）。
4. 是否存在硬编码文案、颜色、字体样式、尺寸且未复用主题。
5. 是否在失败场景下提供用户可见反馈。
6. 是否记录了必要日志且未泄露敏感信息。
7. 是否补齐对应测试/回归说明。

## 12. 当前已知约束

- 目前测试覆盖率较低，新增核心业务时建议至少补充最小单测或流程自测说明。
- `Subject` 模块已形成“remote 全量拉取 + local 查询渲染”的参考实现，后续模块可优先复用该模式。

## 13. 配置与环境管理（企业基线）

- 环境分层最少包含 `dev/test/prod`，禁止通过改源码切环境。
- 环境配置文件统一放在 `assets/config/`，命名为 `app_config_<env>.json`。
- 通过 `--dart-define=APP_ENV=dev|test|prod` 选择配置文件；禁止通过 `--dart-define` 直接传业务地址。
- 仓库内禁止提交密钥、Token、证书私钥等敏感信息。

## 14. 测试基线（企业基线）

- 新增 `repository`：至少补 1 个单测，覆盖成功路径和失败路径之一。
- 新增复杂 `controller`（含异步、分页、搜索、防抖）：至少补 1 个状态流转测试。
- 修复线上问题时，优先补“可复现该问题”的回归测试，避免同类问题重复出现。

## 15. 变更管理与文档同步

- 发生以下变更时，必须同步更新 `README.md` 或本 `AGENTS.md`：
  - 架构分层调整；
  - 路由主链路调整；
  - 数据库 schema/version 调整；
  - 构建与运行命令调整。
- 重大变更（数据库迁移、登录链路、路由重构）在提交说明中写清“影响范围 + 回滚方案”。

## 16. 后端接口规范（对齐 zhisuo）

- 规范来源（以代码为准）：
  - `/Users/kun/Documents/GitHub/zhisuo/internal/api/routes.go`
  - `/Users/kun/Documents/GitHub/zhisuo/internal/api/middleware.go`
  - `/Users/kun/Documents/GitHub/zhisuo/internal/api/swagger.go`
  - `/Users/kun/Documents/GitHub/zhisuo/pkg/errcode/errcode.go`
  - `/Users/kun/Documents/GitHub/zhisuo/configs/api.yaml`
- 网关业务前缀默认是 `/api/v1`；探活接口是 `GET /healthz`、`GET /readyz`（不走业务前缀）。
- 业务接口统一使用 `POST + application/json`，禁止前端擅自改为 `GET/PUT/DELETE`。
- 响应按统一包裹结构处理：
  - 成功：`code = 0`，字段包含 `code/message/request_id/data`。
  - 失败：`code != 0` 视为业务失败；panic 场景可能返回 HTTP 500 且 `code = 50000`。
- 业务错误码对齐（当前后端已定义）：
  - `500000`：内部错误（`ErrorInternal`）
  - `500001`：参数错误（`ErrorArgs`）
  - `500002`：无权限（`ErrorNoPermission`）
  - `500003`：资源不存在（`ErrorNoFound`）
  - `600005`：验证码发送重复（`ErrorVerityCodeSend`）
- Header 协议约定：
  - 推荐传 `X-Request-Id`；网关会回传同值或自动生成。
  - 可透传：`X-Trace-Id`、`Authorization`、`user-id`、`platform-id`。
- 接口文档与联调：
  - 网关 OpenAPI：`/openapi.json`
  - Swagger UI：`/swagger/index.html`
  - 新接口接入前，先核对 `routes.go` 实际路由，不仅看 README。
- 路由命名约定（按后端现状）：
  - `subject`、`cms` 多为 `snake_case`（如 `/subject/get_subject_tags`）。
  - `file`、部分 `user` 存在 `camelCase`（如 `/file/getUploadUrl`、`/user/getVerifyCode`）。
  - 前端不得按个人习惯改写大小写或下划线。

---

如后续架构发生变更（例如引入 domain 层、状态管理替换、模块化拆包），请第一时间更新本文件，确保规范与代码保持一致。
