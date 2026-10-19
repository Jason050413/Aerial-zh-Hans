# 参与贡献

## 报告漏翻或错翻

请附上：

- Aerial 版本
- macOS 版本
- 出现位置
- 截图
- 英文原文和期望译文

## 修改翻译

1. 编辑 `translations/Localizable.strings`，保持左侧的键不变。
2. 运行 `plutil -lint translations/Localizable.strings`。
3. 提交 PR。

## 修改源码

1. 运行 `bash scripts/setup-upstream.sh`。
2. 修改 `vendor/Aerial`。
3. 重新生成补丁：

   ```bash
   git -C vendor/Aerial diff -- . ':(exclude)BuildNumber.xcconfig' \
     > patches/aerial-4.1.7-zh-Hans.patch
   ```

4. 用 `bash scripts/build.sh --install` 构建并检查设置、视频库侧边栏和弹窗。

## 翻译风格

- 使用 Apple 中文术语：墙纸、屏幕保护程序、菜单栏、访达、定位服务、完全磁盘访问权限。
- 保留 Aerial、Dock、Sparkle、Ko-fi、HDR、4K、RTSP、HLS。
- 不翻译视频名称、扩展包名称、作者名和地点名。
- 保持格式占位符不变：`%lld`、`%@`、`%lf`、`%%`。
- 中文使用全角标点，句子尽量短。

## 许可证

提交的代码和翻译以 MIT 许可证发布，见 [LICENSE](LICENSE)。
