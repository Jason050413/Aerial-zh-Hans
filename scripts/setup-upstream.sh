#!/bin/bash
# 拉取指定版本的上游 Aerial 源码，并应用简体中文补丁。
# 用法：bash scripts/setup-upstream.sh
# 可用环境变量：AERIAL_REPO、AERIAL_TAG

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/vendor/Aerial"
TAG="${AERIAL_TAG:-v4.1.7}"
REPO_URL="${AERIAL_REPO:-https://github.com/AerialScreensaver/Aerial.git}"
PATCH="$ROOT/patches/aerial-4.1.7-zh-Hans.patch"

if [ -d "$DEST/.git" ]; then
    echo "上游源码已存在：$DEST"
    echo "如需重新拉取，请先删除该目录。"
    exit 0
fi

if [ ! -f "$PATCH" ]; then
    echo "补丁不存在：$PATCH"
    exit 1
fi

mkdir -p "$ROOT/vendor"
echo "克隆 Aerial ${TAG}…"
git clone --depth 1 --branch "$TAG" "$REPO_URL" "$DEST"

echo "应用补丁…"
git -C "$DEST" apply --check "$PATCH"
git -C "$DEST" apply "$PATCH"

echo "完成。源码在 $DEST"
echo "下一步：bash scripts/build.sh"
