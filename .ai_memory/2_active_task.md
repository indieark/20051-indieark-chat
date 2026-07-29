# 当前任务

更新时间：2026-07-29

## 当前状态

- 用户已确认 GitHub 仓库改名为 `indieark/20051-indieark-chat`，本地目录继续保留 `gadget/open-webui`。
- 用户已授权将当前测试卷复制一次到生产环境，并通过 Portainer 在 `192.168.10.71:20051` 部署；不要求后续增量追平，不自动关闭测试环境，不切换域名。

- Open WebUI 私库兼容层结构迁移已完成，上游源码继续独立位于 `upstream/open-webui/`。
- 官方 subtree 已从 `ecd48e2f718220a6400ecf49eafd4867a38feb10` 同步到 `01f4282f1ffe0d6212f58d3afbeae21fffd0c4be`（Open WebUI `0.11.0`）；subtree tree 与上游 head 完全一致，根层私库路径未被 subtree 同步改动。
- Portainer compose 环境变量注入已完成：`CHAT_STREAM_RESPONSE_CHUNK_MAX_BUFFER_SIZE` 和 `AIOHTTP_READ_BUFSIZE` 已显式进入根层 `docker-compose.yml` 的 service `environment:`。
- 品牌化和自定义 UI 皮肤本地实现已完成：官方容器启动时生成 IndieArk 图标、manifest、`custom.css` 和 `loader.js`。
- `IndieArk Chat` 命名已统一，A 大写。
- CSS 已覆盖 4-qa-agent 风格明暗色调、dither 背景、暗色 surface、侧栏按钮、输入区按钮、工具/上传下拉菜单、浮动工具栏、右侧控制抽屉、滚动条和开关色调。
- 兼容验证已强化：自动检查 subtree 纯净性、Compose/data 边界、品牌资产与内嵌 bootstrap 一致性，以及当前上游关键 UI anchor。
- 上游 `0.11.0` 移除了消息输入区旧 `#create-note-button`，但 Notes 创建能力仍由 Notes 页面、侧栏入口和 `createNoteHandler` 保留；该无效 CSS 子选择器不影响同组其他按钮，也无需修改 upstream。
- GitHub 仓库已改名为 `indieark/20051-indieark-chat`，本地目录保持 `gadget/open-webui`；Compose 已参数化生产端口和镜像。
- 生产卷 `open-webui_open-webui` 已从测试环境做一次性时间点快照复制，主 SQLite 使用 online backup；主库和 Chroma 均通过 `quick_check`，不做后续增量同步。
- Portainer 已在 `vm-prod-01` 创建 Stack `20051-indieark-chat`（ID `296`），使用 `refs/heads/main` 和根级 `docker-compose.yml`，生产入口为 `192.168.10.71:20051`。
- 生产容器 running / healthy / restart count `0`，HTTP `200`，镜像固定到 digest `sha256:6a773e5c3a246b65cbe74ce942b294292c0e5f81c138f703d111bc162f7d7c3d`。
- 测试容器仍在 `192.168.10.66:3000` 正常运行，未停止、未重启、未 redeploy；域名未切换。

## 下一步

- 用户通过 `http://192.168.10.71:20051` 完成真实业务验收。
- 用户确认后自行关闭测试环境；如需将 `chat.indieark.tech` 切到生产，另行授权修改 Nginx Proxy Manager。

## 注意

- 不改 `upstream/open-webui/`。
- 不回到 static 单文件 bind mount 路线。
- 不提交 secret。
- Portainer redeploy、容器重启、镜像切换、volume/network 变更仍需用户明确确认。
