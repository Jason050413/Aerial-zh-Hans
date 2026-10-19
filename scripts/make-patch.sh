#!/bin/bash
# 维护者用：把 vendor/Aerial 工作区的改动重新生成补丁。
# 用法：bash scripts/make-patch.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${AERIAL_SRC:-$ROOT/vendor/Aerial}"
OUT="$ROOT/patches/aerial-4.1.7-zh-Hans.patch"

if [ ! -d "$SRC/.git" ]; then
    echo "没有找到源码仓库：$SRC"
    exit 1
fi

git -C "$SRC" diff -- . ':(exclude)BuildNumber.xcconfig' > "$OUT"
echo "已生成 $OUT"
wc -l "$OUT"
