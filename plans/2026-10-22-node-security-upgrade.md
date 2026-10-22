# 内置 Playwright Node.js 安全升级

状态：`[in-progress]`；已授权完整发布，配置和数据已备份，正在执行 CI 与原 Stack 更新。

2026-10-22 生产 Stack 296 的 Open WebUI 未在 PATH 提供 Node，但
`/usr/local/lib/python3.11/site-packages/playwright/driver/node` 实测为 24.15.0。
需升级至 [24.22.1 安全版](https://nodejs.org/en/blog/release/v24.22.1)。

## 实施范围

- 根 Dockerfile 保留当前线上 Open WebUI 镜像 digest，只替换 Python Playwright 内置的 Node 二进制。
- 保留 Playwright 包、浏览器、上游源码、Compose 与数据卷。
- 新增根级 GHCR 发布 workflow，提供 `ghcr.io/indieark/20051-indieark-chat` 的安全运行镜像。
- 构建时执行内置 Node 的版本断言；本地 Docker daemon 不可用，镜像构建待 CI 验证。

## 发布与回滚

现有 Compose 仍默认公共上游镜像，单独推送本补丁不会切换服务。
用户明确授权提交、推送、发布和私有镜像切换后：备份 SQLite 与原 Stack 配置，
等 CI 成功，将原 Stack 296 的 `OPEN_WEBUI_IMAGE` 指向新镜像 SHA tag，保留其他配置。
发布后验证内置 Node 24.22.1、健康、会话及原数据；真实聊天与浏览器交互由用户验收。
失败时恢复原 `OPEN_WEBUI_IMAGE`，不删除 `open-webui_open-webui` 卷。

完整工作区证据：`../../_work/office_runs/2026-10-22-node-security/report.md`。
