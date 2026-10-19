# 参与贡献

感谢你帮忙完善汉化。提交前请先看 [docs/TRANSLATION.md](docs/TRANSLATION.md) 和 [docs/COVERAGE.md](docs/COVERAGE.md)。

## 报告漏翻或错翻

请附上：

- Aerial 版本（例如 4.1.7）
- macOS 版本
- 出现位置（设置 → 缓存、视频库侧边栏等）
- 截图
- 英文原文和期望的中文

## 修改翻译

只改文字、不涉及源码的情况：

1. 编辑 `translations/Localizable.strings`。
2. 保持左侧的键完全不变。
3. 运行 `plutil -lint translations/Localizable.strings` 检查格式。
4. 提交 PR。

涉及新的界面字符串或源码改动：

1. 按 [docs/BUILDING.md](docs/BUILDING.md) 准备工作区。
2. 修改 `vendor/Aerial` 下的源码和 `translations/Localizable.strings`。
3. 运行 `bash scripts/make-patch.sh` 重新生成补丁。
4. 按 [docs/BUILDING.md](docs/BUILDING.md) 构建并测试。
5. 提交 PR。

较大的改动请先开 issue 讨论，避免白做工。

## 翻译风格

- 使用 Apple 的中文术语：墙纸、屏幕保护程序、菜单栏、访达、定位服务、完全磁盘访问权限。
- 保留产品名和技术缩写：Aerial、Dock、Sparkle、Ko-fi、HDR、4K、RTSP、HLS。
- 不翻译视频名称、扩展包名称、作者名和地点名；这些属于内容，不属于界面。
- 保持格式占位符完全一致：`%lld`、`%@`、`%lf`、`%%`。
- 中文标点使用全角，句末不加多余空格。
- 一句话尽量短，避免直译腔。

## 测试清单

构建后至少检查：

- 设置窗口左侧分类标题和右侧面板。
- 视频库左侧分类标题（Home、All Videos、By Location 等）。
- 首页仪表盘卡片和状态文字。
- 首次启动向导（如能触发）。
- 缓存、重置、退出等弹窗。
- `codesign --verify --deep --strict /Applications/Aerial.app` 通过。
- 没有新的崩溃日志。

## 不要提交

- Aerial 应用二进制、图标或 Apple 视频素材。
- 个人备份、构建产物、DerivedData。
- 从第三方下载站拿到的汉化包。

## 许可证

提交的代码和翻译默认以 MIT 许可证发布，见 [LICENSE](LICENSE)。

上游 Aerial 的贡献流程要求较大的改动先开 issue。若计划合并回上游，请遵循上游仓库的说明。
