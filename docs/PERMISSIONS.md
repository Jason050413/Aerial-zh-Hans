# 权限与签名

## Entitlements

| 组件 | 文件 | 权限 | 值 |
|---|---|---|---|
| 主 App | `Aerial/Aerial.entitlements` | `com.apple.security.app-sandbox` | `false` |
| 主 App | 同上 | `com.apple.security.cs.disable-library-validation` | `true` |
| 主 App | 同上 | `com.apple.security.files.user-selected.read-only` | `false` |
| 壁纸扩展 | `WallpaperExtension/Aerial4WallpaperExtension.entitlements` | `com.apple.security.app-sandbox` | `true` |
| 壁纸扩展 | 同上 | `com.apple.security.network.client` | `true` |
| 壁纸扩展 | 同上 | `com.apple.security.temporary-exception.files.absolute-path.read-write` | `/Users/Shared/` |
| 壁纸扩展 | 同上 | `com.apple.security.cs.disable-library-validation` | `true` |

源码位置：

```text
vendor/Aerial/Aerial/Aerial.entitlements
vendor/Aerial/WallpaperExtension/Aerial4WallpaperExtension.entitlements
```

## Info.plist 权限说明

| 键 | 用途 |
|---|---|
| `NSLocationUsageDescription` | 读取 Wi-Fi 名称、显示天气、计算日出日落 |
| `NSAppleEventsUsageDescription` | 与“音乐”通信以显示正在播放 |
| `NSAppDataUsageDescription` | 访问 macOS 屏幕保护程序以注册扩展 |

这些说明随 `translations/InfoPlist.strings` 汉化。

## 系统隐私权限

| 权限 | 用途 |
|---|---|
| 定位服务 | 天气、Wi-Fi 名称、日出日落 |
| 自动化 / Apple Events | 读取“音乐”正在播放 |
| 完全磁盘访问权限 | 迁移旧版 Aerial 数据，可选 |
| 屏幕保护程序 / App 数据 | 注册壁纸和屏幕保护程序扩展 |

重新签名后 Team ID 会变化，定位和自动化权限可能需要重新授权。

如果墙纸或屏幕保护程序没有恢复，在系统设置里重新选择 Aerial 4，或运行：

```bash
killall WallpaperAgent
```
