---
trigger: always_on
description: "Open WebUI 上游独立性与部署兼容层规则"
---

# Open WebUI 兼容层规则

- 官方上游只从 `upstream-open-webui` 进入 `upstream/open-webui/`。
- 同步脚本读取 subtree commit message 的 `git-subtree-split` 判断 no-op，不直接把 `git subtree split` 输出和 upstream head 等值比较。
- 根级 `docker-compose.yml` 是当前 Portainer stable compose，必须保留 `open-webui` service/container、`${HOST_PORT:-3000}:8080`、显式卷名 `open-webui_open-webui` 和默认镜像 `ghcr.io/open-webui/open-webui:main`。
- 第一阶段不切 `ghcr.io/indieark/20051-indieark-chat:*` 私有镜像，除非已有真实 runtime patch、镜像 digest、smoke test 和回滚 tag。
- 测试环境 `192.168.10.66` 只读核验可以执行；Portainer redeploy、容器重启、image pull、volume 改动必须另行确认。
