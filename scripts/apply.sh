#!/bin/bash
# 资源补丁模式：不重新编译，把翻译表注入已安装的 Aerial.app。
# 适用于只想要大部分界面中文、且不想安装 Xcode 的用户。
# 用法：bash scripts/apply.sh
# 注意：这种方式只覆盖直接写在 SwiftUI 里的字符串，侧边栏标题等变量字符串仍是英文。

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="/Applications/Aerial.app"
EXT="$APP/Contents/Extensions/Aerial4WallpaperExtension.appex"

if [ ! -d "$APP" ]; then
    echo "没有找到 ${APP}，请先从官方安装 Aerial 4.1.x。"
    exit 1
fi

VERSION="$(defaults read "$APP/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "?")"
echo "检测到 Aerial $VERSION"

echo "退出 Aerial…"
osascript -e 'tell application "Aerial" to quit' >/dev/null 2>&1 || true
sleep 2

echo "复制翻译文件…"
mkdir -p "$APP/Contents/Resources/zh-Hans.lproj"
cp "$ROOT/translations/Localizable.strings" "$APP/Contents/Resources/zh-Hans.lproj/Localizable.strings"
cp "$ROOT/translations/InfoPlist.strings" "$APP/Contents/Resources/zh-Hans.lproj/InfoPlist.strings"

if [ -d "$EXT" ]; then
    mkdir -p "$EXT/Contents/Resources/zh-Hans.lproj"
    cp "$ROOT/translations/Localizable.strings" "$EXT/Contents/Resources/zh-Hans.lproj/Localizable.strings"
    cp "$ROOT/translations/InfoPlist-extension.strings" "$EXT/Contents/Resources/zh-Hans.lproj/InfoPlist.strings"
fi

IDENTITY="$(security find-identity -v -p codesigning 2>/dev/null | awk -F'"' '/Apple Development/ {print $2; exit}')"
if [ -z "$IDENTITY" ]; then
    echo "没有找到 Apple Development 证书，改用本机临时签名。"
    IDENTITY="-"
fi

echo "重新签名…"
if [ -d "$EXT" ]; then
    codesign --force --preserve-metadata=entitlements,flags --sign "$IDENTITY" "$EXT"
fi
codesign --force --preserve-metadata=entitlements,flags --sign "$IDENTITY" "$APP"
codesign --verify --deep --strict "$APP"
xattr -cr "$APP"

echo "重启墙纸代理…"
killall WallpaperAgent >/dev/null 2>&1 || true
sleep 2

echo "打开 Aerial…"
open -a "$APP"
echo "完成。"
