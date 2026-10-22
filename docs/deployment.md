# 部署

## 2026-10-22 生产安全运行时

生产 Stack 296 的 `OPEN_WEBUI_IMAGE` 已固定为 `ghcr.io/indieark/20051-indieark-chat:sha-22519ca`。
根级 Dockerfile 沿用原上游应用 digest `sha256:6a773e5c3a246b65cbe74ce942b294292c0e5f81c138f703d111bc162f7d7c3d`，
仅将 Python Playwright 原位置的 Node 替换为 `24.22.1`。上游应用代码和浏览器版本保持。

- 兼容层提交：`22519ca354bfd6df6c398a28841a20becbcb9787`；[构建 CI](https://github.com/indieark/20051-indieark-chat/actions/runs/39716261249) 成功。
- 容器实际内置 Node 为 `v24.22.1`，healthy，`/health` 和首页均返回 HTTP 200。
- 原数据卷、端口、凭据及其他 Stack 环境保留；发布前保存完整加密备份及两份 SQLite online backup。
- `webui.db` 全部表指纹一致；Chroma 仅 `acquire_write` 锁记录由 10 增至 11，其余全部表指纹一致，两库 `quick_check=ok`。
- `.github/workflows/docker-publish.yml` 发布仅带 SHA 标签的兼容镜像，后续安全更新必须继续核对原内置 Node 的实际路径与版本。

本次只更新生产 Stack；以下 2026-07-29 表格保留迁移时的历史快照，不代表当前生产镜像。

## 测试环境快照

只读核验日期：2026-07-29

| 项 | 当前值 |
| --- | --- |
| Host | `192.168.10.66` |
| Hostname | `vm-dev-01` |
| Portainer stack / Compose project | `open-webui` |
| Service | `open-webui` |
| Container | `open-webui` |
| Published port | `0.0.0.0:3000->8080/tcp`, `[::]:3000->8080/tcp` |
| Image | `ghcr.io/open-webui/open-webui:main` |
| Image id | `sha256:6a773e5c3a246b65cbe74ce942b294292c0e5f81c138f703d111bc162f7d7c3d` |
| Image revision / `WEBUI_BUILD_VERSION` | `01f4282f1ffe0d6212f58d3afbeae21fffd0c4be` |
| Status | running, healthy, restart count `0` |
| Volume | `open-webui_open-webui:/app/backend/data` |
| HTTP smoke | `http://127.0.0.1:3000/` returned `200` |

本次生产迁移没有停止、重启或 redeploy 测试容器，也没有修改测试 Portainer Stack。迁移时仅创建 SQLite online backup 临时文件并在校验后删除；该文件位于容器临时层，不在持久化卷中。

仓库中的上游 subtree 已于 2026-07-28 更新到 `01f4282f1ffe0d6212f58d3afbeae21fffd0c4be`，测试环境当前运行同一 build 对应的公共 `main` 镜像。

## 生产环境快照

部署与只读核验日期：2026-07-29

| 项 | 当前值 |
| --- | --- |
| Host | `192.168.10.71` |
| Hostname | `vm-prod-01` |
| Portainer Stack | `20051-indieark-chat`，ID `296` |
| Compose source | `https://github.com/indieark/20051-indieark-chat`，`refs/heads/main`，`docker-compose.yml` |
| Service / container | `open-webui` |
| Published port | `0.0.0.0:20051->8080/tcp`, `[::]:20051->8080/tcp` |
| Image | `ghcr.io/open-webui/open-webui@sha256:6a773e5c3a246b65cbe74ce942b294292c0e5f81c138f703d111bc162f7d7c3d` |
| Image revision / `WEBUI_BUILD_VERSION` | `01f4282f1ffe0d6212f58d3afbeae21fffd0c4be` |
| Status | running, healthy, restart count `0` |
| Volume | `open-webui_open-webui:/app/backend/data` |
| HTTP smoke | `http://127.0.0.1:20051/` returned `200` |
| Database checks | `webui.db` and `vector_db/chroma.sqlite3` both returned `PRAGMA quick_check = ok` |
| OpenAI base | Persisted configuration contains `http://192.168.10.71:8317/v1`; unauthenticated `/models` probe returned `401` |

数据迁移为一次性时间点快照，不做后续增量同步：普通持久化文件通过卷间 tar 流复制，活动 `webui.db` 使用 SQLite online backup 后单独写入生产卷。源/目标数据库 SHA-256 一致，复制时除数据库 WAL/SHM 外的文件数均为 `3274`。测试环境和 `chat.indieark.tech` 当前路由保持不变，用户完成生产验收后自行关闭测试环境。

## 稳定 Compose

根级 [docker-compose.yml](../docker-compose.yml) 是当前 Portainer 稳定入口，必须保持：

- service: `open-webui`
- container: `open-webui`
- image: `${OPEN_WEBUI_IMAGE:-ghcr.io/open-webui/open-webui:main}`
- ports: `${HOST_PORT:-3000}:8080`
- volume: `open-webui:/app/backend/data`
- Docker volume name: `open-webui_open-webui`
- required env: `WEBUI_SECRET_KEY`
- Ollama: `OLLAMA_BASE_URL=http://host.docker.internal:11434`
- stream buffer env: `CHAT_STREAM_RESPONSE_CHUNK_MAX_BUFFER_SIZE=${CHAT_STREAM_RESPONSE_CHUNK_MAX_BUFFER_SIZE:-10485760}`
- aiohttp read buffer env: `AIOHTTP_READ_BUFSIZE=${AIOHTTP_READ_BUFSIZE:-1048576}`
- external PWA manifest: `EXTERNAL_PWA_MANIFEST_URL=http://127.0.0.1:8080/static/manifest.json`
- telemetry disabled: `SCARF_NO_ANALYTICS=true`, `DO_NOT_TRACK=true`, `ANONYMIZED_TELEMETRY=false`

Portainer stack 的 Environment variables 只会用于 compose `${VAR}` 替换。变量必须出现在 `docker-compose.yml` 的 service `environment:` 下，才会进入容器运行时环境。`CHAT_STREAM_RESPONSE_CHUNK_MAX_BUFFER_SIZE` 和 `AIOHTTP_READ_BUFSIZE` 已在根层 compose 显式传入，默认值分别为 `10485760` 和 `1048576`。

当前 `docker-compose.yml` 还包含 IndieArk 品牌资源启动 bootstrap：服务启动时在官方容器内部生成 `/app/backend/open_webui/static/custom.css`、`loader.js`、manifest、favicon、PWA 图标和 splash 图。该路径不依赖 Portainer 宿主机 bind mount，也不修改 `upstream/open-webui/` 或构建私有镜像。维护入口是 [../deploy/open-webui/static/](../deploy/open-webui/static/) 和 [../plans/2026-07-07-open-webui-branding-compose-mount-plan.md](../plans/2026-07-07-open-webui-branding-compose-mount-plan.md)。

更新 `deploy/open-webui/static/custom.css`、`loader.js` 或 `manifest.json` 后，必须同步更新 `docker-compose.yml` 内联常量并运行：

```bash
WEBUI_SECRET_KEY=verify-placeholder docker compose -f docker-compose.yml config
awk "/python - <<'PY'/{flag=1;next} /^        PY$/{flag=0} flag{sub(/^        /, \"\"); print}" docker-compose.yml | python -c "import sys; compile(sys.stdin.read(), 'compose-bootstrap', 'exec')"
```

配置验证：

```bash
WEBUI_SECRET_KEY=verify-placeholder docker compose config --quiet
```

生产环境使用相同 Compose，并在 Portainer Stack 环境变量中设置：

```text
HOST_PORT=20051
OPEN_WEBUI_IMAGE=ghcr.io/open-webui/open-webui@sha256:6a773e5c3a246b65cbe74ce942b294292c0e5f81c138f703d111bc162f7d7c3d
```

测试环境不设置这两个变量时，继续使用 `3000:8080` 和公共 `main` 标签。`WEBUI_SECRET_KEY`、流式缓冲和 aiohttp 缓冲变量由生产 Stack 安全复用测试 Stack 的现有值，不写入仓库。

## 本地构建

[docker-compose.local.yml](../docker-compose.local.yml) 是本地 override：

```bash
WEBUI_SECRET_KEY=local-dev docker compose -f docker-compose.yml -f docker-compose.local.yml config --quiet
```

第一阶段根级 `Dockerfile` 是薄包装，仍基于公共上游镜像。

## Web Search

当前 stable compose 未默认启用 Web Search。启用搜索至少要同时满足五个 gate：

1. 全局启用，例如 `ENABLE_WEB_SEARCH=true`。
2. 配置搜索引擎，例如 `WEB_SEARCH_ENGINE=searxng`。
3. 注入 provider URL 或 API key，不得提交真实 key。
4. 管理端给用户或角色打开对应权限。
5. 模型侧开启搜索 capability 或默认功能。

可选环境模板见 [../compat/config/web-search.env.example](../compat/config/web-search.env.example)。

OpenAI hosted `web_search` 不会因为模型本身支持就自动在 Open WebUI 生效。需要先确认 upstream 是否支持 Responses API hosted tool 透传；不支持时优先通过 pipe/function/adapter 承载，必须改 upstream 源码时先登记 subtree 例外。

## 部署确认门

以下操作必须用户明确确认：

- Portainer stack redeploy。
- `docker restart` / `docker compose up` / `docker compose down`。
- 切换到 `ghcr.io/indieark/20051-indieark-chat:*`。
- 改 project 名、container 名、端口、volume 名或 `/app/backend/data` 挂载路径。

禁止执行：

```bash
docker compose down -v
docker volume rm open-webui_open-webui
```
