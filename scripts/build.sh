#!/bin/bash
# 从已打好补丁的上游源码构建中文版，并复制翻译、签名。
# 用法：
#   bash scripts/build.sh            # 只构建，产物在 build/DerivedData/...
#   bash scripts/build.sh --install  # 构建并替换 /Applications/Aerial.app
# 可用环境变量：AERIAL_SRC、DEVELOPER_DIR

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${AERIAL_SRC:-$ROOT/vendor/Aerial}"
BUILD="$ROOT/build"
APP="$BUILD/DerivedData/Build/Products/Release/Aerial.app"
EXT="$APP/Contents/Extensions/Aerial4WallpaperExtension.appex"
EXPORT_DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

if [ ! -d "$EXPORT_DEVELOPER_DIR" ]; then
    echo "没有找到 Xcode：$EXPORT_DEVELOPER_DIR"
    echo "请从 App Store 安装 Xcode，或用 DEVELOPER_DIR 指定路径。"
    exit 1
fi
export DEVELOPER_DIR="$EXPORT_DEVELOPER_DIR"

if [ ! -d "$SRC/Aerial.xcodeproj" ]; then
    echo "没有找到上游源码：$SRC"
    echo "先运行：bash scripts/setup-upstream.sh"
    exit 1
fi

if ! grep -q "LocalizedStringKey(panel.title)" "$SRC/Aerial/UI/Settings/SettingsView.swift"; then
    echo "源码看起来还没有应用汉化补丁。"
    echo "先运行：bash scripts/setup-upstream.sh"
    exit 1
fi

IDENTITY="${SIGN_IDENTITY:-}"
if [ -z "$IDENTITY" ]; then
    IDENTITY="$(security find-identity -v -p codesigning 2>/dev/null | awk -F'"' '/Apple Development/ {print $2; exit}')"
fi
if [ -z "$IDENTITY" ]; then
    echo "警告：没有找到 Apple Development 证书，将使用本机临时签名。"
    echo "墙纸扩展可能无法加载；建议在 Xcode 中登录 Apple ID 后重试。"
    IDENTITY="-"
fi

echo "== 解析依赖 =="
xcodebuild -project "$SRC/Aerial.xcodeproj" -scheme Aerial \
    -resolvePackageDependencies

echo "== 构建 Release（不签名） =="
xcodebuild -project "$SRC/Aerial.xcodeproj" -scheme Aerial \
    -configuration Release -destination 'platform=macOS' \
    -derivedDataPath "$BUILD/DerivedData" \
    ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO \
    CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" \
    build

if [ ! -d "$APP" ]; then
    echo "构建产物不存在：$APP"
    exit 1
fi

echo "== 复制翻译 =="
mkdir -p "$APP/Contents/Resources/zh-Hans.lproj"
cp "$ROOT/translations/Localizable.strings" "$APP/Contents/Resources/zh-Hans.lproj/Localizable.strings"
cp "$ROOT/translations/InfoPlist.strings" "$APP/Contents/Resources/zh-Hans.lproj/InfoPlist.strings"

if [ -d "$EXT" ]; then
    mkdir -p "$EXT/Contents/Resources/zh-Hans.lproj"
    cp "$ROOT/translations/Localizable.strings" "$EXT/Contents/Resources/zh-Hans.lproj/Localizable.strings"
    cp "$ROOT/translations/InfoPlist-extension.strings" "$EXT/Contents/Resources/zh-Hans.lproj/InfoPlist.strings"
fi

echo "== 关闭自动更新默认值 =="
/usr/libexec/PlistBuddy -c "Delete :SUEnableAutomaticChecks" "$APP/Contents/Info.plist" >/dev/null 2>&1 || true
/usr/libexec/PlistBuddy -c "Add :SUEnableAutomaticChecks bool false" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Delete :SUAutomaticallyUpdate" "$APP/Contents/Info.plist" >/dev/null 2>&1 || true
/usr/libexec/PlistBuddy -c "Add :SUAutomaticallyUpdate bool false" "$APP/Contents/Info.plist"

echo "== 签名 =="
if [ -d "$APP/Contents/Frameworks/Sparkle.framework" ]; then
    codesign --force --deep --sign "$IDENTITY" "$APP/Contents/Frameworks/Sparkle.framework"
fi
if [ -d "$EXT" ]; then
    codesign --force --sign "$IDENTITY" --options runtime \
        --entitlements "$SRC/WallpaperExtension/Aerial4WallpaperExtension.entitlements" "$EXT"
fi
codesign --force --sign "$IDENTITY" --options runtime \
    --entitlements "$SRC/Aerial/Aerial.entitlements" "$APP"
codesign --verify --deep --strict "$APP"
xattr -cr "$APP"
echo "签名验证通过"

if [ "${1:-}" != "--install" ]; then
    echo "构建完成：$APP"
    echo "如需安装，运行：bash scripts/build.sh --install"
    exit 0
fi

echo "== 安装到 /Applications =="
osascript -e 'tell application "Aerial" to quit' >/dev/null 2>&1 || true
sleep 2

if [ -d "/Applications/Aerial.app" ]; then
    mkdir -p "$ROOT/backup"
    BACKUP="$ROOT/backup/Aerial-before-install-$(date +%Y%m%d-%H%M%S).app"
    ditto "/Applications/Aerial.app" "$BACKUP"
    echo "已备份当前版本到 $BACKUP"
    rm -rf "/Applications/Aerial.app"
fi

ditto "$APP" "/Applications/Aerial.app"
xattr -cr "/Applications/Aerial.app"
killall WallpaperAgent >/dev/null 2>&1 || true
sleep 2
open -a "/Applications/Aerial.app"
echo "完成。"
