# AGENTS.md

你是在 `gadget/open-webui` 内协作的编码代理。GitHub 仓库是 `indieark/20051-indieark-chat`，本地目录不随远端仓库改名。默认使用简体中文。

本仓库保留 `00000-model/02-项目模板` 风格的 `.agents/` 与 `.ai_memory/`，新会话按下方「启动流程」读取上下文。

## 项目定位

本仓库是 IndieArk 的 Open WebUI 私库兼容层：

- GitHub 仓库为 `indieark/20051-indieark-chat`，本地目录继续使用 `gadget/open-webui`。
- 官方上游源码独立放在 `upstream/open-webui/`。
- 根目录承载 IndieArk 兼容层、部署入口、同步脚本、文档和计划。
- 当前测试环境仍使用公共上游镜像 `ghcr.io/open-webui/open-webui:main`，不是私有 runtime 镜像。

## 启动流程

1. 读取 `.ai_memory/1_project_context.md`，确认长期事实和不变量。
2. 读取 `.ai_memory/2_active_task.md`，确认当前任务状态。
3. 读取 `.ai_memory/0_archive_context.md` 的最后 50 行，了解最近迁移脉络。
4. 阅读 [UPSTREAMS.md](UPSTREAMS.md) 和 [docs/deployment.md](docs/deployment.md)，再处理上游同步或部署问题。

## 目录与权限

| 目录/文件 | 用途 | 规则 |
| --- | --- | --- |
| `upstream/open-webui/` | 官方上游 subtree | 默认只通过同步脚本更新 |
| `compat/` | IndieArk 兼容层 | 优先放私库配置、pipe/function/adapter、补丁入口 |
| `docs/` | 当前事实文档 | 部署和维护口径以这里为准 |
| `plans/` | 计划和执行记录 | 新增计划必须同步 `plans/README.md` |
| `.agents/rules/` | AI 行为规则 | 与本文件保持一致 |
| `.ai_memory/` | 跨会话记忆 | 结构性变更后同步更新 |
| `.exp/` | 可复用经验沉淀 | 需要提炼经验时再扩展 |
| `.ui/` | UI 风格入口 | 如未来做前端定制，再引用共享 UI 规范 |
| `MEMO.md` | 人类私人笔记 | AI 不读取、不引用 |

## 仓库边界

- `upstream/open-webui/` 是官方 `open-webui/open-webui` subtree，默认不直接改。
- 根目录、`compat/`、`scripts/`、`docs/`、`plans/`、`.agents/`、`.ai_memory/` 是 IndieArk 私库兼容层和本地治理结构。
- 能通过 Compose、环境变量、entrypoint、脚本、post-build patch、Open WebUI pipe/function 或 adapter 解决的问题，不进入 upstream subtree。
- 上游同步必须 compare-first；无 delta 时 no-op。
- 必须修改 upstream subtree 时，先在 `docs/compatibility-layer.md` 登记例外，写清原因、文件、恢复规则和验证命令。

## 部署约束

- 测试环境是 `192.168.10.66:3000`，Portainer stack / Compose project 为 `open-webui`。
- 生产环境目标是 `192.168.10.71:20051`，Portainer stack 为 `20051-indieark-chat`；通过 `HOST_PORT=20051` 覆盖测试默认端口。
- 服务名和容器名保持 `open-webui`。
- 数据卷保持 `open-webui:/app/backend/data`，两台主机实际 Docker volume 都显式命名为 `open-webui_open-webui`。
- 默认稳定入口继续使用 `ghcr.io/open-webui/open-webui:main`；生产首次部署可通过 `OPEN_WEBUI_IMAGE` 固定已验证 digest。
- `WEBUI_SECRET_KEY`、搜索 provider key、OpenAI key、Portainer credential 不得写入仓库。
- 不得执行会影响测试环境的重启、redeploy、volume/network 改动，除非用户明确确认。

## 常用验证

```bash
WEBUI_SECRET_KEY=verify-placeholder docker compose config --quiet
bash scripts/verify-compat.sh
bash scripts/sync-upstream.sh
```

Windows 原生命令环境可用：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/sync-upstream.ps1
```

## 计划与文档

- 新计划放在 `plans/`，并同步更新 `plans/README.md`。
- 当前部署事实以 `docs/deployment.md` 为准。
- 上游同步规则以 `UPSTREAMS.md` 和 `docs/repository-maintenance.md` 为准。
- 结构性变更后同步 `.ai_memory/`、`README.md`、`AGENTS.md` 和 `docs/README.md`。
- `MEMO.md` 是人类私人笔记，AI 不读取、不引用。
