# 内置 Playwright Node.js 安全升级

状态：`[done]`；安全版本已提交、推送，CI 成功并完成原 Stack 发布和运行数据核验。

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

## 发布证据

- 安全提交：`22519ca354bfd6df6c398a28841a20becbcb9787`。
- [CI 39716261249](https://github.com/indieark/20051-indieark-chat/actions/runs/39716261249) 成功。
- 原 Stack 296 已发布；运行实例 Node 为 `24.22.1`，镜像 revision 与对应安全提交一致，重启计数为 0。
- 页面及相关健康端点返回 HTTP 200。 原 GitOps、数据挂载保持一致；除明确记录的镜像选择变量外，其余 Stack 环境保持一致。
- 原上游应用作为固定基底，通过 OPEN_WEBUI_IMAGE 选择安全兼容镜像；原卷加密备份和 webui/chroma 两份在线备份已校验。webui 全部表和 Chroma 全部业务/索引表指纹一致；仅 acquire_write 锁表从 10 行变为 11 行；两库 quick_check=ok。
- 旧镜像及数据卷保留。真实页面交互由用户确认，代理未重放业务或发送测试通知。
