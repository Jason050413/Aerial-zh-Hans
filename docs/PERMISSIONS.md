# 权限与签名

汉化补丁不新增或删除任何权限。下面是上游 Aerial 4.1.7 自带的权限，以及重新签名后需要注意的地方。

## Entitlements

| 组件 | 文件 | 权限 | 值 | 用途 |
|---|---|---|---|---|
| 主 App | `Aerial/Aerial.entitlements` | `com.apple.security.app-sandbox` | `false` | App 需要访问缓存、下载目录和本地文件 |
| 主 App | 同上 | `com.apple.security.cs.disable-library-validation` | `true` | 加载 PaperSaver 等动态框架 |
| 主 App | 同上 | `com.apple.security.files.user-selected.read-only` | `false` | 允许用户选择文件夹后读写 |
| 壁纸扩展 | `WallpaperExtension/Aerial4WallpaperExtension.entitlements` | `com.apple.security.app-sandbox` | `true` | 扩展运行在沙盒里 |
| 壁纸扩展 | 同上 | `com.apple.security.network.client` | `true` | 播放直播流和下载视频 |
| 壁纸扩展 | 同上 | `com.apple.security.temporary-exception.files.absolute-path.read-write` | `/Users/Shared/` | 读取 Aerial 的缓存和视频 |
| 壁纸扩展 | 同上 | `com.apple.security.cs.disable-library-validation` | `true` | 加载 PaperSaver |

源码位置：

```text
vendor/Aerial/Aerial/Aerial.entitlements
vendor/Aerial/WallpaperExtension/Aerial4WallpaperExtension.entitlements
```

## Info.plist 权限说明

| 键 | 中文说明 | 何时出现 |
|---|---|---|
| `NSLocationUsageDescription` | 读取 Wi-Fi 名称、显示天气、计算日出日落 | 首次使用定位相关功能 |
| `NSAppleEventsUsageDescription` | 与“音乐”通信以显示正在播放 | 启用音乐叠加层 |
| `NSAppDataUsageDescription` | 访问 macOS 屏幕保护程序以安装和更新 Aerial | 注册屏幕保护程序/扩展 |

这些说明已经随 `translations/InfoPlist.strings` 汉化。

## 系统隐私权限（TCC）

| 权限 | 用途 | 说明 |
|---|---|---|
| 定位服务 | 天气、Wi-Fi 名称、日出日落 | 拒绝后天气和自动时段不可用 |
| 自动化 / Apple Events | 读取“音乐”正在播放 | 拒绝后音乐叠加层不可用 |
| 完全磁盘访问权限 | 迁移旧版 Aerial 数据 | 只在旧版迁移时需要，可选 |
| 屏幕保护程序 / App 数据 | 注册壁纸和屏幕保护程序扩展 | 系统自动管理 |

## 重新签名的影响

替换或重新签名 App 后，Team ID 会变化。macOS 可能把权限视为新的应用，需要重新授权定位、自动化等权限。

如果墙纸或屏幕保护程序没有自动恢复：

1. 打开“系统设置 → 墙纸”，重新选择 Aerial 4。
2. 打开“系统设置 → 屏幕保护程序”，重新选择 Aerial。
3. 必要时运行：

   ```bash
   killall WallpaperAgent
   ```

## 分发说明

本仓库只分发补丁、翻译和脚本，不分发签名后的 App 二进制。

如果你要分发构建好的 App：

- 需要遵守 Apple Developer Program 的签名和公证要求；
- 需要遵守上游 Aerial 的 MIT 许可证，保留版权声明；
- 不应包含 Apple 的视频素材、图标或其他受版权保护的内容；
- 建议只分发源码和构建说明，让用户自行签名。
