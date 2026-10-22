FROM node:24.22.1-bookworm-slim AS node-runtime

# 保留现有 Open WebUI 应用版本，仅更新 Python Playwright 的内置 Node.js。
FROM ghcr.io/open-webui/open-webui@sha256:6a773e5c3a246b65cbe74ce942b294292c0e5f81c138f703d111bc162f7d7c3d

COPY --from=node-runtime /usr/local/bin/node /tmp/node-security
RUN python -c "import pathlib, playwright, shutil, subprocess; target = pathlib.Path(playwright.__file__).parent / 'driver' / 'node'; assert target.is_file(); shutil.copyfile('/tmp/node-security', target); assert subprocess.check_output([str(target), '--version'], text=True).strip() == 'v24.22.1'" \
    && rm /tmp/node-security

LABEL org.opencontainers.image.source="https://github.com/indieark/20051-indieark-chat"
LABEL tech.indieark.layer="compatibility"
