# 构建与签名

## 环境

实测环境：

- macOS 27.0.1
- Xcode 27.1（App Store 版）
- Apple Development 证书
- 约 20 GB 可用磁盘空间（Xcode 另算）

上游要求 macOS 26+、Xcode 16+。

## 准备源码

```bash
bash scripts/setup-upstream.sh
```

脚本会：

1. 浅克隆 `AerialScreensaver/Aerial` 的 `v4.1.7`；
2. 检查并应用 `patches/aerial-4.1.7-zh-Hans.patch`；
3. 把源码放在 `vendor/Aerial`。

也可以手动操作：

```bash
git clone --depth 1 --branch v4.1.7 \
  https://github.com/AerialScreensaver/Aerial.git vendor/Aerial
git -C vendor/Aerial apply --check patches/aerial-4.1.7-zh-Hans.patch
git -C vendor/Aerial apply patches/aerial-4.1.7-zh-Hans.patch
```

## 构建

```bash
bash scripts/build.sh
```

只构建，不安装。产物在：

```text
build/DerivedData/Build/Products/Release/Aerial.app
```

构建并安装：

```bash
bash scripts/build.sh --install
```

安装前会备份当前 `/Applications/Aerial.app` 到 `backup/`，然后替换并重启墙纸代理。

## 脚本内部做了什么

1. `xcodebuild -resolvePackageDependencies` 拉取 Sparkle、PaperSaver、KeyboardShortcuts、swift-argument-parser。
2. `xcodebuild` 以 `CODE_SIGNING_ALLOWED=NO` 构建 Release。
3. 把 `translations/` 复制进 App 和壁纸扩展的 `zh-Hans.lproj`。
4. 用本机 Apple Development 证书签名：
   - 先签 `Sparkle.framework`；
   - 再签 `Aerial4WallpaperExtension.appex`，使用 `WallpaperExtension/Aerial4WallpaperExtension.entitlements`；
   - 最后签 `Aerial.app`，使用 `Aerial/Aerial.entitlements`。
5. `codesign --verify --deep --strict` 验证。

签名证书可以用下面的命令确认：

```bash
security find-identity -v -p codesigning
```

没有 Apple Development 证书时，脚本会退回临时签名，但墙纸扩展可能无法加载。

## 常见问题

### `xcodebuild` 提示需要 Xcode

系统当前指向 Command Line Tools。脚本会自动设置：

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
```

### CoreSimulator 警告

```text
CoreSimulator is out of date
```

这是模拟器组件版本提示，构建 macOS App 不受影响。

### SwiftLint

没安装 SwiftLint 时，项目里的 SwiftLint 脚本会直接跳过，不影响构建。

### SPM 拉取失败

检查网络或代理。可以先手动克隆依赖，或重试：

```bash
xcodebuild -project vendor/Aerial/Aerial.xcodeproj -scheme Aerial -resolvePackageDependencies
```

### 扩展没有启动

```bash
killall WallpaperAgent
pluginkit -m -v -i com.glouel.Aerial-App.Aerial4WallpaperExtension
```

然后重新打开 Aerial。如果系统设置里的墙纸或屏幕保护程序没有自动恢复，重新选择一次 Aerial 4。

### 提示 App 已损坏

先检查签名：

```bash
codesign --verify --deep --strict /Applications/Aerial.app
```

签名通过仍无法启动时，用 `backup/` 里的备份恢复，或从上游重新安装。

## 适配新的上游版本

1. 修改 `scripts/setup-upstream.sh` 里的 `AERIAL_TAG`，或手动克隆新 tag。
2. 尝试三方合并：

   ```bash
   git -C vendor/Aerial apply --3way patches/aerial-4.1.7-zh-Hans.patch
   ```

3. 解决冲突后，构建并检查新界面。
4. 用提取脚本找出新增字符串，补翻译。
5. 重新生成补丁：

   ```bash
   bash scripts/make-patch.sh
   ```

6. 更新 README、CHANGELOG 和补丁文件名中的版本号。

补丁里把 `MARKETING_VERSION` 设成了 4.1.7，避免 Sparkle 把本地构建当成旧版本。适配新版本时按需要修改。
