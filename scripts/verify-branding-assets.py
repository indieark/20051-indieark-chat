#!/usr/bin/env python3
from __future__ import annotations

import ast
import json
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
COMPOSE_PATH = REPO_ROOT / "docker-compose.yml"
ASSET_PATHS = {
    "CUSTOM_CSS": REPO_ROOT / "deploy/open-webui/static/custom.css",
    "LOADER_JS": REPO_ROOT / "deploy/open-webui/static/loader.js",
    "MANIFEST_JSON": REPO_ROOT / "deploy/open-webui/static/manifest.json",
}


def extract_bootstrap_source(compose_text: str) -> str:
    marker = "python - <<'PY'"
    start = compose_text.index(marker) + len(marker)
    end = compose_text.index("\n        PY", start)
    payload = compose_text[start:end].lstrip("\n")
    return "\n".join(
        line[8:] if line.startswith("        ") else line
        for line in payload.splitlines()
    )


def extract_asset_constants(source: str) -> dict[str, str]:
    module = ast.parse(source)
    values: dict[str, str] = {}
    for node in module.body:
        if not isinstance(node, ast.Assign) or len(node.targets) != 1:
            continue
        target = node.targets[0]
        if isinstance(target, ast.Name) and target.id in ASSET_PATHS:
            values[target.id] = ast.literal_eval(node.value)
    return values


def main() -> None:
    compose_text = COMPOSE_PATH.read_text(encoding="utf-8")
    bootstrap_source = extract_bootstrap_source(compose_text)
    compile(bootstrap_source, "compose-bootstrap", "exec")

    embedded_assets = extract_asset_constants(bootstrap_source)
    missing = ASSET_PATHS.keys() - embedded_assets.keys()
    if missing:
        raise AssertionError(f"Missing embedded branding assets: {sorted(missing)}")

    for name, path in ASSET_PATHS.items():
        expected = path.read_text(encoding="utf-8")
        if embedded_assets[name] != expected:
            raise AssertionError(f"{name} differs from {path.relative_to(REPO_ROOT)}")

    json.loads(embedded_assets["MANIFEST_JSON"])
    print("Branding bootstrap and deploy assets are synchronized.")


if __name__ == "__main__":
    main()
