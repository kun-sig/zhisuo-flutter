# 企业级题库学习产品 Flutter 端执行计划

本文档是 `zhisuo_flutter` 的题库学习产品执行版计划。

目标不是只记录方向，而是让文档直接承担以下职责：

1. 说明当前 Flutter 端要交付哪些功能
2. 说明每个功能准备怎么做
3. 说明每个功能做到什么程度才算完成
4. 记录当前状态、依赖关系和阻塞项
5. 让 Flutter / Backend / Admin 三端可以按同一套任务边界协同推进

适用仓库：
- `/Users/kun/Documents/GitHub/zhisuo_flutter`

关联文档：
- [README_practice_backend_plan.md](/Users/kun/Documents/GitHub/zhisuo/README_practice_backend_plan.md)
- [README_practice_admin_plan.md](/Users/kun/Documents/GitHub/zhisuo/README_practice_admin_plan.md)

最后更新：
- `2026-03-14`

---

## 1. 使用方式

本执行计划按“模块卡片”维护，每个模块统一记录：

1. 功能范围
2. 实现路径
3. 依赖接口
4. 子任务清单
5. 完成定义（Definition of Done）
6. 当前状态
7. 阻塞项

状态枚举统一使用：

| 状态 | 含义 |
| --- | --- |
| `未开始` | 尚未进入开发 |
| `进行中` | 已开始编码，但未达到可验收状态 |
| `已完成` | 已完成开发与基础验证 |
| `联调中` | Flutter 端完成，正在与后端或管理端联调 |
| `阻塞` | 存在外部依赖或技术问题，无法继续推进 |
| `暂缓` | 当前优先级下调，暂不继续 |

勾选规则：

- `[ ]` 未完成
- `[x]` 已完成
- `（进行中）` 当前正在处理
- `（联调中）` 代码完成，联调未结束
- `（阻塞）` 存在依赖问题

---

## 2. 当前执行快照

### 2.1 当前目标

Flutter 客户端需要支持以下学习闭环：

1. 用户选择当前考试科目
2. 在题库首页查看“一级分类 + 二级练习单元 + 单元进度”学习状态
3. 按 `categoryCode + unitId` 进入不同练习单元开始做题
4. 完成提交并查看练习报告
5. 回看错题、记录、收藏、笔记等学习资产
6. 逐步补齐批改记录、问答、灰度配置等高级能力

### 2.2 当前里程碑状态

| 里程碑 | 目标 | 状态 | 说明 |
| --- | --- | --- | --- |
| `M1` | 客户端架构骨架完成 | `已完成` | 已补齐 dashboard 相关 models / remote / repository / route / binding |
| `M2` | 题库首页 Dashboard 完成 | `已完成` | 新版首页结构、单元列表页、统一单元跳转、状态治理和本地 HTTP 联调已完成 |
| `M3` | 练习闭环完成 | `进行中` | 会话、报告与继续练习恢复主链路已闭环，剩余自动推进等体验增强待补 |
| `M4` | 资产页完成 | `进行中` | 错题本、做题记录、收藏、笔记已接真实数据，筛选/编辑删除等增强能力仍待补齐 |
| `M5` | 高级模块完成 | `未开始` | 批改记录、问答、灰度等尚未开始 |

### 2.3 当前已落地内容

- [x] `CurrentSubjectService` 全局当前科目服务
- [x] 题库 dashboard 数据模型
- [x] 题库 dashboard 远端数据源
- [x] 题库 dashboard 仓储层
- [x] 题库 dashboard 页面 / Controller / Binding
- [x] 题库入口组件：当前科目卡片、继续练习卡片、分类区、单元预览区、资产工具区、学习摘要
- [x] 题库二级单元列表页 / 路由 / Binding
- [x] 当前科目卡片组件化
- [x] 首页继续练习与单元预览统一按 `categoryCode + unitId` 跳转
- [x] dashboard / unit list 已补齐无科目、禁用态、空态、失败态可见化
- [x] dashboard / unit list / session / report 最小 controller / repository 测试
- [x] dashboard / catalog / unit list 已完成本地 seed HTTP 联调
- [x] 练习会话页基础版、提交答案、交卷流程
- [x] 练习会话页已展示单元标题、分类上下文和单元聚合进度
- [x] 继续练习已改为按 `categoryCode + unitId` 恢复最近单元会话
- [x] 练习报告页已展示单元标题、分类和报告上下文
- [x] 练习报告页已补齐复习建议卡片
- [x] 错题本 / 做题记录 / 收藏 / 笔记路由与占位页
- [x] 最小仓储单测

### 2.4 当前未完成重点

- [ ] 练习会话体验增强（自动推进 / 交互打磨）
- [ ] 资产增强交互（筛选 / 编辑 / 删除）
- [ ] 批改记录页
- [ ] 问答页
- [ ] 公共题目渲染组件体系

### 2.5 新后端计划适配专项

Flutter 端必须同步适配后端新模型：

1. 题库首页从“模块入口”升级为“一级分类卡片 + 二级练习单元预览”
2. 新增统一单元列表页，按 `categoryCode` 查看全部二级单元
3. 继续练习与开始练习统一按 `categoryCode + unitId` 路由
4. 会话页、报告页、资产回练入口统一消费 `unitId`
5. 页面禁用态、空态、灰度态按分类与单元状态重做

---

## 3. 执行基线

### 3.1 目录基线

按当前项目规范，执行时必须遵循：

```text
Page -> Controller -> Repository -> Local/Remote
```

不得出现：

- Page 直接调 Repository 之外的数据层
- Controller 直接调 Dio / SQLite
- 页面内临时 `Get.put`
- 页面内硬编码后端地址

### 3.2 统一完成定义

除特别说明外，每个模块“已完成”至少满足：

1. 页面、路由、Binding 可达
2. Controller 有明确 `loading / error / empty` 状态
3. 数据通过 `Repository` 聚合输出
4. 接口通过 `Remote Service` 接入
5. 文案进入 i18n
6. 新增主题常量沉淀到 `theme/*`
7. `dart format lib test` 通过
8. `flutter analyze` 无新增错误
9. 至少补 1 个最小测试，或写清人工回归步骤

### 3.3 联调基线

接口联调统一以以下约定为准：

- 业务前缀：`/api/v1`
- 当前题库相关接口：
  - `POST /api/v1/catalog/get_current_subject`
  - `POST /api/v1/catalog/set_current_subject`
  - `POST /api/v1/catalog/get_exam_plan`
  - `POST /api/v1/practice/get_question_bank_dashboard`
  - `POST /api/v1/practice/get_practice_catalog`
  - `POST /api/v1/practice/get_practice_unit_list`
  - `POST /api/v1/practice/get_practice_unit_progress`
  - `POST /api/v1/practice/start_practice_session`
  - `POST /api/v1/practice/get_practice_session`
  - `POST /api/v1/practice/submit_practice_answer`
  - `POST /api/v1/practice/finish_practice_session`
  - `POST /api/v1/practice/get_practice_report`
  - `POST /api/v1/asset/get_wrong_questions`
  - `POST /api/v1/asset/get_practice_records`
  - `POST /api/v1/asset/toggle_question_favorite`
  - `POST /api/v1/asset/get_question_favorites`
  - `POST /api/v1/asset/create_practice_note`
  - `POST /api/v1/asset/update_practice_note`
  - `POST /api/v1/asset/delete_practice_note`
  - `POST /api/v1/asset/get_practice_notes`
  - `POST /api/v1/asset/get_review_records`
  - `POST /api/v1/asset/get_qa_threads`
  - `POST /api/v1/asset/get_qa_thread_detail`
  - `POST /api/v1/asset/create_qa_thread`
  - `POST /api/v1/asset/reply_qa_thread`

---

## 4. 阶段执行板

| Phase | 目标 | 输出 | 状态 | 说明 |
| --- | --- | --- | --- | --- |
| `Phase 0` | 架构准备 | models / remote / repository / route / binding 骨架 | `已完成` | 已落 `question_bank_dashboard` 基础骨架 |
| `Phase 1` | 当前科目 + Dashboard | 一级分类卡片 + 二级单元预览首页 | `已完成` | 新版首页结构、单元列表页、统一单元跳转、状态治理和本地联调已完成 |
| `Phase 2` | 练习最短闭环 | `PracticeUnitListPage` + `PracticeSessionPage` + `PracticeReportPage` | `进行中` | 会话、报告和继续练习恢复主链路已闭环，待补自动推进等体验增强 |
| `Phase 3` | 资产闭环 | 错题本、记录、收藏、笔记真实可用 | `进行中` | 四个基础资产页已接通，增强交互仍待实现 |
| `Phase 4` | 高级能力 | 真题、模考、批改、问答 | `未开始` | 依赖基础练习与资产闭环完成 |
| `Phase 5` | 体验治理 | 灰度、禁用态、埋点、异常、离线恢复 | `未开始` | 需在主功能稳定后进入 |

### 4.1 新模型适配专项任务

- [x] `FP-4.1` 重构 dashboard 数据模型，支持 `practiceCategories`、`practiceUnitsPreview`
- [x] `FP-4.2` 新增统一二级单元列表页，按 `categoryCode` 查看单元
- [x] `FP-4.3` 首页继续练习与单元预览统一跳转 `categoryCode + unitId`
- [x] `FP-4.4` 改造 `PracticeSession` 请求与响应模型，适配 `unitId`
- [x] `FP-4.5` 改造 `PracticeReport` 页面与仓储，适配 `unitId`
- [x] `FP-4.6` 接入分类禁用态、单元禁用态、空态和错误态
- [x] `FP-4.7` 补齐 dashboard / unit list / session / report 最小测试
- [x] `FP-4.8` 完成 Flutter 与后端新版 dashboard / catalog / unit list 联调

---

## 5. 模块执行卡片

## 5.1 当前科目上下文

### 模块目标

让“当前科目”在多个页面共享，科目切换后能自动刷新 dashboard 和练习入口。

### 当前状态

`已完成`

### 当前输出

- `lib/services/current_subject_service.dart`
- `lib/widgets/current_subject_card.dart`
- `lib/services/service_controller.dart`
- `lib/pages/subject/*`

### 功能范围

- [x] 全局读取当前科目
- [x] 页面间共享当前科目状态
- [x] 科目切换后触发 dashboard 刷新
- [x] 当前科目卡片可复用

### 实现路径

| 层级 | 实现方式 |
| --- | --- |
| Service | `CurrentSubjectService` 保存当前科目和 loading 状态 |
| Subject Page | 科目点击后更新本地记录并刷新当前科目 |
| Dashboard Controller | 监听当前科目变化，自动刷新 dashboard |
| Local Repository | 继续复用 `SubjectRepository` 读取最近点击科目 |

### 子任务清单

- [x] 抽离 `CurrentSubjectService`
- [x] 接入 `InitBinding`
- [x] 兼容现有 `ServiceController`
- [x] Subject 页切换后同步全局状态
- [x] Dashboard 页监听刷新

### 完成定义

- [x] 切换科目后无需重启 App
- [x] 切回题库页后内容自动刷新
- [x] 当前科目卡片在 dashboard 可复用

### 阻塞项

- 无

---

## 5.2 题库首页 Dashboard

### 模块目标

把题库 Tab 从旧版模块入口页改造成后端驱动的“一级分类 + 二级练习单元 + 单元进度”dashboard。

### 当前状态

`已完成`

### 当前输出

- `lib/pages/question_bank_dashboard/*`
- `lib/data/models/question_bank/question_bank_dashboard_models.dart`
- `lib/data/remote/question_bank_remote_service.dart`
- `lib/data/repositories/question_bank/question_bank_dashboard_repository.dart`
- `lib/widgets/question_bank/*`
- `lib/widgets/question_bank/practice_category_section.dart`
- `lib/widgets/question_bank/practice_unit_preview_list.dart`
- `lib/pages/practice_unit_list/*`

### 功能范围

- [x] 当前科目卡片
- [x] 继续练习卡片
- [x] 一级练习分类卡片区
- [x] 二级练习单元预览区
- [x] 单元列表入口页
- [x] 学习资产模块区
- [x] 今日学习摘要
- [x] 下拉刷新
- [x] 失败态展示
- [x] 科目变化自动刷新
- [x] 分类禁用态 / 单元禁用态（首页基础版）
- [x] 单元正确率 / 完成状态 / 最近练习时间展示

### 实现路径

| 层级 | 实现方式 |
| --- | --- |
| Page | `QuestionBankDashboardPage` 负责结构布局与状态渲染 |
| Controller | `QuestionBankDashboardController` 负责加载、刷新、点击分发 |
| Repository | `QuestionBankDashboardRepository` 负责 dashboard / catalog / unit list DTO 映射与 fallback 数据 |
| Remote | `QuestionBankRemoteService` 访问 `/practice/get_question_bank_dashboard`、`/practice/get_practice_catalog`、`/practice/get_practice_unit_list` |
| Widgets | `ContinuePracticeCard`、`PracticeCategorySection`、`PracticeUnitPreviewList`、`AssetToolGrid` |

### 依赖接口

| 接口 | 作用 | 当前状态 |
| --- | --- | --- |
| `catalog/get_current_subject` | 预留当前科目远端能力 | `已预留 Remote` |
| `practice/get_question_bank_dashboard` | Dashboard 主聚合接口 | `已接入` |
| `practice/get_practice_catalog` | 一级分类聚合接口 | `已接入` |
| `practice/get_practice_unit_list` | 二级单元列表接口 | `已接入` |
| `practice/get_practice_unit_progress` | 单元进度补查接口 | `待接入` |

### 子任务清单

- [x] 旧版 dashboard models / remote / repository / page 骨架
- [x] 接入 Home Tab
- [x] 接入当前科目变化监听
- [x] 增加资产入口路由
- [x] 增加最小单测
- [x] 扩展 dashboard models 支持 `practiceCategories` / `practiceUnitsPreview`
- [x] 扩展 remote service 支持 `get_practice_catalog` / `get_practice_unit_list`
- [x] 重构 repository 统一输出分类卡片和单元预览
- [x] 新建 `PracticeUnitListPage / Controller / Binding`
- [x] 首页点击一级分类跳单元列表页
- [x] 首页点击二级单元直接启动练习
- [x] 接入分类禁用态、单元禁用态和空态（首页基础版）
- [x] 补齐无科目 banner、分类灰态原因和单元灰态原因展示
- [x] 补充 dashboard 新模型单测
- [x] 核对本地 seed 接口返回并兼容 `correctRate` 比例值、继续练习空标题场景

### 完成定义

- [x] 题库页不再依赖旧模块入口结构
- [x] 首页稳定展示一级分类、预览单元、继续练习、资产工具、今日摘要
- [x] 一级分类点击可进入统一单元列表页
- [x] 二级单元点击可基于 `categoryCode + unitId` 启动练习
- [x] 科目切换能触发 dashboard 和单元列表联动刷新
- [x] 无科目、无分类、无单元、禁用态、接口失败态全部可见
- [x] `flutter analyze` 通过
- [x] dashboard / unit list 最小 repository / controller 测试通过

### 后续增量

- [ ] 接入 feature toggle / 灰度禁用态
- [ ] 接入单元搜索、筛选、排序
- [x] 接入真实“继续练习”跳转

### 阻塞项

- 无

---

## 5.3 练习会话页

### 模块目标

打通“单元列表/首页点击二级单元 -> 启动练习 -> 拉会话 -> 作答 -> 提交 -> 完成”的最短主链路。

### 当前状态

`已完成`

### 计划输出

- `lib/pages/practice_session/*`
- `lib/data/models/question_bank/practice_session_models.dart`
- `lib/data/models/question_bank/practice_report_models.dart`
- `lib/data/remote/practice_remote_service.dart`
- `lib/data/repositories/question_bank/practice_session_repository.dart`
- `lib/widgets/question_bank/question_stem_view.dart`
- `lib/widgets/question_bank/question_option_group_view.dart`
- `lib/widgets/question_bank/practice_progress_header.dart`

### 功能范围

- [x] 启动练习
- [x] 获取练习会话
- [x] 单题渲染（基础版）
- [x] 答题进度展示（基础版）
- [x] 提交单题答案
- [x] 自动推进下一题
- [x] 退出保留会话
- [x] 完成练习并跳报告
- [x] 按 `categoryCode + unitId` 启动
- [x] 会话页展示 `unitTitle / categoryName / unitProgress`
- [ ] 收藏题目
- [ ] 添加笔记

### 实现路径

| 层级 | 实现方式 |
| --- | --- |
| Route | 新增 `practice_session` 路由、Binding、导航封装 |
| Page | 负责题目区域、答题区、底部操作区、进度区 |
| Controller | 管理 `session / unit / unitProgress / currentIndex / submitLoading / finishLoading / localAnswerCache` |
| Repository | 聚合 `start_practice_session / get_practice_session / submit_practice_answer / finish_practice_session` |
| Remote | 新增 `PracticeRemoteService` |
| Widgets | 抽离题干、选项组、操作条、答题进度组件 |

### 依赖接口

| 接口 | 作用 | 当前状态 |
| --- | --- | --- |
| `practice/start_practice_session` | 从 dashboard / unit list 按 `categoryCode + unitId` 启动练习 | `已切新版参数` |
| `practice/get_practice_session` | 获取会话详情与单元进度 | `已接新版基础结构，待补更多聚合字段消费` |
| `practice/submit_practice_answer` | 提交单题答案 | `已接入` |
| `practice/finish_practice_session` | 完成练习 | `已接入` |
| `asset/toggle_question_favorite` | 收藏题目 | `待接入` |
| `asset/create_practice_note` | 写笔记 | `待接入` |

### 子任务清单

- [x] 定义会话模型
- [x] 接入 practice remote service
- [x] 实现 practice session repository
- [x] 实现旧版 start / get session 流程
- [x] 实现单选/多选/判断基础渲染（基础版）
- [x] 实现 submit answer
- [x] 实现 finish session
- [x] 从 dashboard 入口跳入会话页
- [x] 补最小 controller 或 repository 测试（controller + repository）
- [x] 扩展 session/request model 支持 `categoryCode` / `unitId` / `unitTitle`（入口参数 + session 基础字段）
- [x] 改造 session repository 统一消费新版 session / unitProgress
- [x] 从二级单元预览和单元列表页跳入会话页
- [x] 会话页头部展示当前分类和单元上下文
- [x] 继续练习改为按 `lastSession + unitProgress` 恢复
- [x] 补新版 session repository 单测

### 完成定义

- [x] 从 dashboard 二级单元预览和单元列表页都可启动练习
- [x] 练习页可按 `categoryCode + unitId` 恢复已有会话
- [x] 至少支持单选 / 多选 / 判断题（本地选择态）
- [x] 提交后 answeredCount / remainingCount / unitProgress 正确更新（会话基础版）
- [x] 完成后能跳报告页并带出 `unitId`
- [x] 页面具备 loading / error / empty / exit confirm

### 依赖关系

- 依赖当前科目上下文
- 依赖 dashboard 分类区 / 单元列表入口点击
- 依赖报告页路由准备完成

### 阻塞项

- 当前无

### Phase 2 详细开发任务列表

#### Phase 2 总体目标

在本阶段结束时，必须完成以下主链路：

1. 从 dashboard 点击练习入口
2. 启动练习会话
3. 拉取并展示会话内容
4. 提交单题答案并更新进度
5. 完成整场练习
6. 跳转练习报告页

#### Phase 2 任务看板

| 任务 ID | 任务 | 预计粒度 | 前置依赖 | 状态 |
| --- | --- | --- | --- | --- |
| `P2-01` | 补齐练习数据模型 | `0.5 天` | 无 | `已完成` |
| `P2-02` | 接入练习 remote service | `0.5 天` | `P2-01` | `已完成` |
| `P2-03` | 实现练习 repository | `0.5 天` | `P2-01`、`P2-02` | `已完成` |
| `P2-04` | 新建会话页路由与基础骨架 | `0.5 天` | `P2-03` | `已完成` |
| `P2-05` | 实现启动练习与进入会话页 | `0.5 天` | `P2-04` | `已完成` |
| `P2-06` | 实现会话详情拉取与状态管理 | `0.5 天` | `P2-05` | `已完成` |
| `P2-07` | 实现基础题目组件渲染 | `1 天` | `P2-06` | `已完成（基础版）` |
| `P2-08` | 实现提交答案与自动推进 | `0.5 天` | `P2-07` | `已完成` |
| `P2-09` | 实现退出保留与完成练习 | `0.5 天` | `P2-08` | `已完成` |
| `P2-10` | 新建报告页与报告 repository | `0.5 天` | `P2-09` | `已完成（骨架版）` |
| `P2-11` | 实现完成练习后跳转报告 | `0.5 天` | `P2-10` | `已完成` |
| `P2-12` | 补最小测试与回归验证 | `0.5 天` | `P2-11` | `已完成（repository + controller）` |

#### P2-01 补齐练习数据模型

目标：
- 建立会话、题目、提交结果、报告等 Flutter 端可直接消费的 view data。

建议文件：
- [practice_session_models.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/data/models/question_bank/practice_session_models.dart)
- [practice_report_models.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/data/models/question_bank/practice_report_models.dart)

建议内容：
- `PracticeSessionData`
- `PracticeQuestionData`
- `PracticeQuestionOptionData`
- `PracticeSubmitResult`
- `PracticeReportData`
- `PracticeReportSummaryData`
- `PracticeReportStatData`

完成标准：
- [ ] 可以完整映射 `start_practice_session`
- [ ] 可以完整映射 `get_practice_session`
- [ ] 可以完整映射 `submit_practice_answer`
- [ ] 可以完整映射 `get_practice_report`

#### P2-02 接入练习 remote service

目标：
- 建立练习域统一远端入口，后续页面不直接拼接口。

建议文件：
- [practice_remote_service.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/data/remote/practice_remote_service.dart)

接口接入顺序：
1. `start_practice_session`
2. `get_practice_session`
3. `submit_practice_answer`
4. `finish_practice_session`
5. `get_practice_report`

建议方法：
- `startPracticeSession`
- `getPracticeSession`
- `submitPracticeAnswer`
- `finishPracticeSession`
- `getPracticeReport`

完成标准：
- [ ] 全部方法统一通过 `HttpService`
- [ ] 请求参数按后端字段命名透传
- [ ] 对异常不吞掉，交由 repository/controller 处理

#### P2-03 实现练习 repository

目标：
- 把 remote DTO 转成页面直接消费的数据结构。

建议文件：
- [practice_session_repository.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/data/repositories/question_bank/practice_session_repository.dart)

建议职责：
- 启动会话参数归一化
- 会话详情映射
- 提交结果映射
- 完成练习后的跳转参数组织

建议方法：
- `startSession`
- `fetchSession`
- `submitAnswer`
- `finishSession`
- `fetchReport`

完成标准：
- [ ] Controller 不直接依赖 remote service
- [ ] repository 输出统一 view data
- [ ] 异常保留业务上下文日志

#### P2-04 新建会话页路由与基础骨架

目标：
- 先让练习会话页可进入、可带参数、可维护状态。

建议文件：
- [practice_session_page.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/pages/practice_session/practice_session_page.dart)
- [practice_session_controller.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/pages/practice_session/practice_session_controller.dart)
- [practice_session_binding.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/pages/practice_session/practice_session_binding.dart)

同步修改：
- [app_routes.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/routes/app_routes.dart)
- [app_pages.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/routes/app_pages.dart)
- [app_navigator.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/routes/app_navigator.dart)
- [app.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/app.dart)

建议页面参数：
- `practiceMode`
- `sourceType`
- `sourceId`
- `sourceTitle`
- `sessionId`
- `continueIfExists`

完成标准：
- [ ] 路由可达
- [ ] 支持带参数进入
- [ ] 页面具备基础 loading / error 容器

#### P2-05 实现启动练习与进入会话页

目标：
- 从 dashboard 模块入口真正发起练习，而不是只弹提示。

修改点：
- [question_bank_dashboard_controller.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/pages/question_bank_dashboard/question_bank_dashboard_controller.dart)
- [app_navigator.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/routes/app_navigator.dart)

实现要求：
- `moduleCode -> practiceMode/sourceType/sourceId` 映射先在 Controller 或 Navigator 封装
- 点击入口后先调 `start_practice_session`
- 成功后进入 `PracticeSessionPage`

建议首批支持：
- `chapter_practice`
- `knowledge_practice`

完成标准：
- [ ] Dashboard 至少两个入口能真实启动
- [ ] 启动失败时有可见错误提示

#### P2-06 实现会话详情拉取与状态管理

目标：
- 进入会话页后能展示当前会话，并维护当前题号和题目列表。

Controller 建议状态：
- `isPageLoading`
- `isSubmitLoading`
- `isFinishLoading`
- `errorText`
- `session`
- `questions`
- `currentIndex`
- `remainingCount`
- `selectedAnswers`

建议生命周期：
- 有 `sessionId` 时优先 `get_practice_session`
- 无 `sessionId` 时由启动接口结果初始化

完成标准：
- [ ] 进入页面后可看到当前题目
- [ ] 顶部进度与服务端数据一致
- [ ] 会话拉取失败可重试

#### P2-07 实现基础题目组件渲染

目标：
- 先支持最小可用题型渲染，保证闭环先跑通。

建议文件：
- [question_stem_view.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/widgets/question_bank/question_stem_view.dart)
- [question_option_group_view.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/widgets/question_bank/question_option_group_view.dart)
- [question_action_bar.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/widgets/question_bank/question_action_bar.dart)
- [practice_progress_header.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/widgets/question_bank/practice_progress_header.dart)

首批支持题型：
- 单选
- 多选
- 判断

后补题型：
- 填空
- 主观题

完成标准：
- [ ] 单选可选中并变更状态
- [ ] 多选可多选并本地维护答案
- [ ] 判断题按选项形式复用
- [ ] 当前题号与总题数展示正确

#### P2-08 实现提交答案与自动推进

目标：
- 答案提交后更新服务端状态，并推进到下一题。

建议步骤：
1. 本地校验答案是否为空
2. 调用 `submit_practice_answer`
3. 更新当前题 answered 状态
4. 更新 `answeredCount / remainingCount`
5. 如未完成则推进到下一题

建议交互：
- 提交中禁用重复点击
- 提交成功后可短暂展示正确/错误结果

完成标准：
- [ ] 同一道题不能连续重复提交
- [ ] 提交成功后进度正确更新
- [ ] 自动推进逻辑正常

#### P2-09 实现退出保留与完成练习

目标：
- 用户中途退出不丢会话，完成后能正确收口。

实现要求：
- 返回上一级时弹确认
- 未完成直接返回时不调用 `finish_practice_session`
- 点击“交卷/完成”时调用 `finish_practice_session`

完成标准：
- [x] 中途退出后可通过继续练习进入
- [x] 完成练习后拿到 `sessionId/reportId/status`

#### P2-10 新建报告页与报告 repository

目标：
- 把报告页最小骨架补齐，避免练习完成后无落点。

建议文件：
- [practice_report_page.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/pages/practice_report/practice_report_page.dart)
- [practice_report_controller.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/pages/practice_report/practice_report_controller.dart)
- [practice_report_binding.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/pages/practice_report/practice_report_binding.dart)
- [practice_result_summary_card.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/widgets/question_bank/practice_result_summary_card.dart)
- [chapter_stats_card.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/widgets/question_bank/chapter_stats_card.dart)
- [question_category_stats_card.dart](/Users/kun/Documents/GitHub/zhisuo_flutter/lib/widgets/question_bank/question_category_stats_card.dart)

完成标准：
- [x] 报告页路由可达
- [x] 可根据 `sessionId` 拉报告
- [x] 可展示摘要与统计骨架

#### P2-11 实现完成练习后跳转报告

目标：
- 主链路最终闭环。

实现要求：
- `finish_practice_session` 成功后跳 `PracticeReportPage`
- 报告页使用 `sessionId` 拉取，不依赖临时内存对象

完成标准：
- [x] 完成练习后自动跳报告
- [x] 页面返回路径正常

#### P2-12 补最小测试与回归验证

目标：
- 给 Phase 2 增加最低限度质量保护。

建议测试优先级：
1. `PracticeSessionRepository` 单测
2. `PracticeSessionController` 状态流转测试
3. `PracticeReportRepository` 单测

最低回归场景：
- [ ] 从 dashboard 进入章节练习
- [ ] 拉取会话成功
- [ ] 提交 1 题后进度变化正确
- [ ] 完成练习后跳报告
- [ ] 退出后重新进入可恢复

### Phase 2 开发顺序建议

推荐严格按以下顺序落地，避免返工：

1. `P2-01 -> P2-03`
   先把数据层搭好，再开页面。

2. `P2-04 -> P2-06`
   先把会话页作为“壳”跑起来，再补题目渲染。

3. `P2-07 -> P2-09`
   先做最小题型渲染，再做提交与完成。

4. `P2-10 -> P2-11`
   会话稳定后再接报告页，闭合主链路。

5. `P2-12`
   最后补测试和回归验证。

### Phase 2 预计验收结果

本阶段验收通过后，应能满足：

- [x] Dashboard 至少两个入口可真实启动练习
- [x] 练习页支持单选 / 多选 / 判断题（基础版）
- [x] 提交答案后进度正确更新
- [x] 退出后可继续练习
- [x] 完成后自动进入报告页
- [x] `flutter analyze` 无新增错误
- [x] `flutter test` 通过

---

## 5.4 练习报告页

### 模块目标

在练习完成后展示结果统计、错题和复习建议。

### 当前状态

`已完成`

### 计划输出

- `lib/pages/practice_report/*`
- `lib/data/models/question_bank/practice_report_models.dart`
- `lib/widgets/question_bank/practice_result_summary_card.dart`
- `lib/widgets/question_bank/practice_review_suggestion_card.dart`
- `lib/widgets/question_bank/chapter_stats_card.dart`
- `lib/widgets/question_bank/question_category_stats_card.dart`

### 功能范围

- [x] 正确率展示
- [x] 答对/答错数量
- [x] 章节统计
- [x] 题型统计
- [x] 错题列表（ID 基础版）
- [x] 单元上下文展示（`categoryCode / unitId / unitTitle`）
- [x] 复习建议

### 实现路径

| 层级 | 实现方式 |
| --- | --- |
| Route | 新增 `practice_report` 页面路由 |
| Controller | 根据 `sessionId` 拉报告并维护加载状态 |
| Repository | 聚合报告接口，输出报告 view data |
| Remote | 复用 `PracticeRemoteService.getPracticeReport` |
| Widgets | 统计卡片 + 错题列表组件 |

### 依赖接口

| 接口 | 作用 | 当前状态 |
| --- | --- | --- |
| `practice/get_practice_report` | 获取练习报告 | `已接入 unit 基础上下文` |

### 子任务清单

- [x] 定义报告模型
- [x] 实现报告 repository
- [x] 新建报告页面与 controller
- [x] 实现统计卡片
- [x] 实现错题列表
- [x] 解析并展示 `categoryCode / unitId / unitTitle`
- [x] 完成练习后自动跳入报告页
- [x] 生成并展示最小复习建议

### 完成定义

- [x] 从 `finish_practice_session` 跳入报告页
- [x] 报告页展示正确率、章节统计、题型统计、错题列表、复习建议
- [x] 网络失败时可重试

### 依赖关系

- 强依赖 `Practice Session` 完成

### 阻塞项

- 无

---

## 5.5 资产页闭环

### 模块目标

让错题、记录、收藏、笔记从 dashboard 入口进入后具备真实查询能力。

### 当前状态

`进行中`

### 当前输出

- `lib/pages/wrong_book/*`
- `lib/pages/practice_history/*`
- `lib/pages/favorites/*`
- `lib/pages/practice_notes/*`

当前已接通错题本、做题记录、收藏、做题笔记的基础列表能力。

### 子模块状态

| 子模块 | 页面骨架 | 路由 | 真实接口 | 状态 |
| --- | --- | --- | --- | --- |
| 错题本 | 已有 | 已有 | 已接 | `进行中` |
| 做题记录 | 已有 | 已有 | 已接 | `进行中` |
| 收藏 | 已有 | 已有 | 已接 | `进行中` |
| 笔记 | 已有 | 已有 | 已接 | `进行中` |
| 批改记录 | 无 | 无 | 未接 | `未开始` |
| 问答 | 无 | 无 | 未接 | `未开始` |

### 实现路径

| 层级 | 实现方式 |
| --- | --- |
| Route | 各资产模块独立 page / binding / navigator |
| Controller | 统一分页状态模型：`page / pageSize / isLoading / isLoadingMore / error / hasMore` |
| Repository | 统一封装分页查询和筛选参数 |
| Remote | 新增 `AssetRemoteService` |
| Widgets | 复用题目卡片、筛选条、空态与错误态组件 |

### 依赖接口

| 接口 | 作用 | 当前状态 |
| --- | --- | --- |
| `asset/get_wrong_questions` | 错题本分页 | `已接入` |
| `asset/get_practice_records` | 做题记录 | `已接入` |
| `asset/toggle_question_favorite` | 收藏切换 | `已接入` |
| `asset/get_question_favorites` | 收藏列表 | `已接入` |
| `asset/create_practice_note` | 创建笔记 | `已接入` |
| `asset/update_practice_note` | 更新笔记 | `待接入` |
| `asset/delete_practice_note` | 删除笔记 | `待接入` |
| `asset/get_practice_notes` | 笔记列表 | `已接入` |
| `asset/get_review_records` | 批改记录 | `待接入` |
| `asset/get_qa_threads` | 问答列表 | `待接入` |
| `asset/get_qa_thread_detail` | 问答详情 | `待接入` |
| `asset/create_qa_thread` | 发起提问 | `待接入` |
| `asset/reply_qa_thread` | 回复问答 | `待接入` |

### 子任务清单

#### 错题本

- [x] 新建 `AssetRemoteService` / `PracticeAssetRepository`
- [x] 接入 `get_wrong_questions`
- [x] 支持分页、章节筛选、题型筛选
- [x] 支持“重新练习”

#### 做题记录

- [x] 复用 `PracticeAssetRepository`
- [x] 接入 `get_practice_records`
- [x] 支持进入报告页

#### 收藏

- [x] 复用 `PracticeAssetRepository`
- [x] 接入 `get_question_favorites`
- [x] 支持取消收藏

#### 笔记

- [x] 复用 `PracticeAssetRepository`
- [x] 接入 `get_practice_notes`
- [ ] 支持编辑和删除
- [x] 支持最小创建流程

#### 批改记录

- [ ] 新建页面骨架
- [ ] 接入 `get_review_records`

#### 问答

- [ ] 新建问答列表页
- [ ] 新建问答详情页
- [ ] 接入发帖与回复接口

### 完成定义

- [ ] 四个基础资产模块支持真实查询
- [ ] 至少一个资产模块支持跳转到练习闭环
- [ ] 各列表支持空态、失败态、下拉刷新、加载更多

### 依赖关系

- 依赖公共题目组件复用
- “重新练习”依赖 `Practice Session`
- “进入报告”依赖 `Practice Report`

### 阻塞项

- 资产接口与题目组件体系尚未接入

---

## 5.6 公共题目组件体系

### 模块目标

抽出练习、报告、错题、收藏、笔记等模块可共用的题目渲染组件。

### 当前状态

`未开始`

### 计划输出

- `question_stem_view.dart`
- `question_option_group_view.dart`
- `question_action_bar.dart`
- `practice_progress_header.dart`
- `answer_sheet_bar.dart`
- 通用题目列表卡片

### 功能范围

- [ ] 题干渲染
- [ ] 选项渲染
- [ ] 已答/未答/正确/错误态
- [ ] 收藏、笔记、解析操作区
- [ ] 进度头部
- [ ] 答题卡底栏

### 实现路径

| 层级 | 实现方式 |
| --- | --- |
| Widgets | 放入 `lib/widgets/question_bank/` |
| Models | 统一题目展示模型，减少页面自行拼结构 |
| Pages | 练习、报告、错题、收藏直接复用组件 |

### 子任务清单

- [ ] 定义统一题目 view model
- [ ] 实现题干组件
- [ ] 实现选项组件
- [ ] 实现操作条
- [ ] 实现进度头部
- [ ] 实现答题卡

### 完成定义

- [ ] 至少被 `Practice Session` 与 `Wrong Book` 两处复用
- [ ] 不同页面不再重复拼题目结构

### 依赖关系

- 为 `Phase 2` 和 `Phase 3` 的公共基础

### 阻塞项

- 无

---

## 5.7 全局服务与缓存

### 模块目标

为题库学习产品补齐当前用户、当前科目、页面上下文、断点恢复等基础能力。

### 当前状态

`进行中`

### 当前输出

- `AppSessionService`
- `CurrentSubjectService`
- 兼容旧 `ServiceController`

### 后续功能范围

- [x] 当前用户默认会话上下文
- [x] 当前科目共享
- [ ] 练习恢复状态
- [ ] feature toggle / dashboard 配置缓存
- [ ] 页面级恢复策略

### 子任务清单

- [x] 新建 `AppSessionService`
- [x] 新建 `CurrentSubjectService`
- [ ] 新建练习恢复服务
- [ ] 增加模块灰度配置缓存
- [ ] 增加 dashboard 配置刷新策略

### 完成定义

- [ ] 当前用户、当前科目、练习恢复三类状态具备清晰边界
- [ ] 不再由页面分散维护全局上下文

### 阻塞项

- 练习恢复依赖 `Practice Session`

---

## 6. 下一阶段执行建议

当前推荐按以下顺序推进，避免返工：

1. `Dashboard 新模型改版`
   原因：首页结构、继续练习、单元列表、会话启动参数都依赖统一分类和单元模型。

2. `Practice Unit List + Practice Session`
   原因：二级单元列表是统一入口页，会话链路必须完成 `categoryCode + unitId` 切换。

3. `Practice Report`
   原因：报告页需要跟随 `unitId` 做上下文改造，才能闭合新版主链路。

4. `Wrong Book + Practice History`
   原因：这两个资产模块最容易复用练习结果和报告页。

5. `Favorites + Practice Notes`
   原因：依赖题目组件和基础资产仓储，但优先级略低于错题和记录。

6. `Review Records + QA`
   原因：属于增强模块，不应抢占主链路资源。

---

## 7. 建议工作拆分

为了方便进度跟踪，建议把后续开发任务拆成 0.5 到 2 天粒度的卡片。

推荐任务拆法：

### Sprint A：Dashboard 新模型改版

- [x] 扩展 `question_bank_dashboard_models.dart`
- [x] 新增 `PracticeCategoryCardData / PracticeUnitPreviewData / PracticeUnitProgressData`
- [x] 接通 `get_practice_catalog`
- [x] 接通 `get_practice_unit_list`
- [x] 重构 `QuestionBankDashboardRepository`
- [x] 首页替换为分类区 + 单元预览区
- [x] 新建 `PracticeUnitListPage / Controller / Binding`

### Sprint B：练习会话统一单元化

- [x] 扩展 `practice_session_models.dart`
- [x] 接通新版 `start_practice_session`
- [x] 接通新版 `get_practice_session`
- [x] 从预览单元和列表页启动练习
- [x] 支持 `unitTitle / unitProgress` 展示
- [x] 验证继续练习恢复

### Sprint C：练习作答与报告

- [x] 支持单选 / 多选 / 判断渲染
- [x] 接通 `submit_practice_answer`
- [ ] 自动推进下一题
- [x] 退出保留会话
- [x] 接通 `finish_practice_session`
- [x] 改造报告 models / repository / page 适配 `unitId`
- [x] 接通新版 `get_practice_report`
- [x] 从完成练习跳转报告

### Sprint D：第一批资产页

- [x] 错题本接真实接口
- [x] 做题记录接真实接口
- [x] 收藏页接真实接口
- [x] 笔记页接真实接口

---

## 8. 技术验收记录

### 已通过

- [x] `dart format lib test`
- [x] `flutter analyze`
- [x] `flutter test`

### 已补测试

- [x] `test/data/repositories/question_bank/question_bank_dashboard_repository_test.dart`
- [x] `test/data/repositories/question_bank/practice_session_repository_test.dart`

### 后续测试要求

- 新增 `repository`：至少补 1 个单测
- 新增复杂 `controller`：至少补 1 个状态流转测试
- 修复线上问题：优先补回归测试

---

## 9. 维护规则

后续每次开发完成后，必须同步更新本文档中的以下内容：

1. `当前执行快照`
2. `阶段执行板`
3. 对应模块卡片的 `状态`
4. 对应模块卡片的 `子任务清单`
5. `技术验收记录`

如果出现以下变化，也必须同步更新本文档或 `AGENTS.md`：

- 路由主链路变化
- 目录分层变化
- 数据库版本变化
- 运行命令变化
- 后端接口命名变化

---

## 10. 当前结论

当前执行结论如下：

1. `Phase 0` 与 `Phase 1` 已完成，题库首页已切到新版 dashboard 结构和状态治理实现。
2. `FP-4.8`、报告页“复习建议”和继续练习恢复切新已完成，当前最合理的下一步是进入 `Phase 3` 增量：优先补资产增强交互（笔记编辑/删除、筛选整理）。
3. Flutter 端所有练习入口、继续练习、报告页、资产回练都必须统一收敛到 `categoryCode + unitId`。
4. 资产模块已具备入口和页面壳，适合作为 `Phase 3` 在新版练习闭环完成后继续增强。
5. 后续所有任务应继续按本执行版文档维护，避免计划与实际代码脱节。
