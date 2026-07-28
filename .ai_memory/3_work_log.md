# 工作日志

## 2026-07-07

- 执行 Open WebUI 兼容层迁移：官方上游进入 `upstream/open-webui/`，根目录改为 IndieArk 兼容层。
- 增加同步脚本和兼容层验证脚本，Bash / PowerShell no-op 检查通过。
- 补齐 `00000-model` 项目模板风格的本地治理骨架。
- 修复 Portainer Git stack 的根层 compose：显式注入 `CHAT_STREAM_RESPONSE_CHUNK_MAX_BUFFER_SIZE` 和 `AIOHTTP_READ_BUFSIZE`，避免 Portainer 变量表只参与 `${VAR}` 替换但不进入容器 runtime env。
- 完成 Open WebUI 品牌化部署层实现：不挂载 static 文件，不改上游源码，改为官方容器启动时生成 IndieArk 图标、manifest、`custom.css` 和 `loader.js`。
- 按用户截图反馈收口深色 UI 灰面：覆盖右侧控制抽屉、侧栏按钮、输入区按钮、工具/上传下拉菜单、富文本/选中文本悬浮栏、滚动条和开关色调。
- 同步 README、docs、plans 和 `.ai_memory`，保持品牌化 bootstrap、部署约束和后续 Portainer redeploy 核验口径一致。

## 2026-07-28

- Compare-first 确认官方上游从 `ecd48e2f718220a6400ecf49eafd4867a38feb10` 前进到 `01f4282f1ffe0d6212f58d3afbeae21fffd0c4be`，共 618 个提交。
- 通过 `git subtree pull --squash` 同步 Open WebUI `0.11.0`；subtree tree 与官方 head 完全一致，根层私库路径无同步差异。
- 验证 Compose project/service/container、`3000:8080`、公共 `main` 镜像和 `open-webui:/app/backend/data` 数据卷语义保持不变；未操作测试环境、容器或 volume。
- 增加品牌 bootstrap 与部署资产逐字一致性校验，并把关键上游 UI anchor 纳入同步后的兼容验证。
- 核实上游 UI 重构移除了旧 `#create-note-button`，Notes 创建能力仍保留在 Notes 页面、侧栏和现有 handler 中，无需私库 upstream 补丁。
- 上游 head 的 49 个 GitHub check run 已终态：48 success、1 skipped；本地 Alembic 图验证为 55 个 revision、单一 head `f0bd01a18a3d`。
- 更新上游 split、部署快照说明、维护文档和项目记忆，区分仓库源码同步与测试环境部署状态。
