# 构建与签名

## 环境

实测环境：macOS 27.0.1、Xcode 27.1、Apple Development 证书。

上游要求 macOS 26+、Xcode 16+。

## 准备和构建

```bash
bash scripts/setup-upstream.sh
bash scripts/build.sh --install
```

`setup-upstream.sh` 拉取上游 `v4.1.7` 到 `vendor/Aerial`，并应用 `patches/aerial-4.1.7-zh-Hans.patch`。

`build.sh` 依次执行：

1. `xcodebuild -resolvePackageDependencies` 拉取 Sparkle、PaperSaver、KeyboardShortcuts、swift-argument-parser。
2. 用 `CODE_SIGNING_ALLOWED=NO` 构建 Release。
3. 把 `translations/` 复制到 App 和壁纸扩展的 `zh-Hans.lproj`。
4. 关闭自动更新默认值，避免官方更新覆盖汉化。
5. 用本机 Apple Development 证书签名 Sparkle、扩展和主 App。
6. 验证签名。

`--install` 会先备份当前 `/Applications/Aerial.app` 到 `backup/`，再替换并重启墙纸代理。

只构建不安装：

```bash
bash scripts/build.sh
```

产物：

```text
build/DerivedData/Build/Products/Release/Aerial.app
```

## 签名证书

```bash
security find-identity -v -p codesigning
```

没有 Apple Development 证书时，脚本会使用临时签名。墙纸扩展可能无法加载，建议在 Xcode 登录 Apple ID。

## 常见问题

### `xcodebuild` 要求安装 Xcode

脚本已设置 `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`。如果 Xcode 在其他位置：

```bash
DEVELOPER_DIR=/path/to/Xcode.app/Contents/Developer bash scripts/build.sh
```

### CoreSimulator 版本警告

构建 macOS App 不受影响，可以忽略。

### SPM 依赖拉取失败

检查网络或代理，然后重试：

```bash
xcodebuild -project vendor/Aerial/Aerial.xcodeproj -scheme Aerial -resolvePackageDependencies
```

### 壁纸扩展没有启动

```bash
killall WallpaperAgent
pluginkit -m -v -i com.glouel.Aerial-App.Aerial4WallpaperExtension
```

然后重新打开 Aerial。必要时在系统设置里重新选择 Aerial 4 墙纸或屏幕保护程序。

### 提示 App 已损坏

```bash
codesign --verify --deep --strict /Applications/Aerial.app
```

签名通过仍无法启动时，从 `backup/` 恢复，或重新安装上游版本。

## 适配新的上游版本

1. 修改 `scripts/setup-upstream.sh` 里的 `AERIAL_TAG`，或手动克隆新 tag。
2. 尝试三方合并补丁：

   ```bash
   git -C vendor/Aerial apply --3way patches/aerial-4.1.7-zh-Hans.patch
   ```

3. 解决冲突，构建并检查新界面。
4. 用提取脚本补翻译。
5. 重新生成补丁：

   ```bash
   git -C vendor/Aerial diff -- . ':(exclude)BuildNumber.xcconfig' \
     > patches/aerial-4.1.7-zh-Hans.patch
   ```

6. 更新 README、CHANGELOG 和补丁文件名里的版本号。

补丁把 `MARKETING_VERSION` 设为 4.1.7，避免 Sparkle 把本地构建当成旧版本。
