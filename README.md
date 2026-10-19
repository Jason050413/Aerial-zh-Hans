# Aerial 简体中文补丁

给 Aerial 4.1.7 的社区简体中文补丁。覆盖设置、视频库、首页仪表盘、首次启动向导和常见弹窗，共 840 条翻译。

上游项目：[Aerial](https://github.com/AerialScreensaver/Aerial)（MIT），官网：[aerialscreensaver.github.io](https://aerialscreensaver.github.io/)。本项目基于 `v4.1.7`。

## 下载

先安装官方 [Aerial 4.1.7](https://github.com/AerialScreensaver/Aerial/releases/tag/v4.1.7)。

到 [Releases](https://github.com/Jason050413/Aerial-zh-Hans/releases) 下载最新的 `Aerial-4.1.7-zh-Hans-v0.1.0-patch.zip`。

解压后右键 `Install.command` → 打开。脚本会备份旧版、替换程序文件和翻译、重新签名并启动。首次运行如果系统拦截，右键 `/Applications/Aerial.app` → 打开。

要求 macOS 26+，支持 Apple Silicon 和 Intel，只适用于 Aerial 4.1.7。

## 构建

要求：macOS 26+、Xcode 16+、Apple Development 证书。

```bash
git clone https://github.com/Jason050413/Aerial-zh-Hans.git
cd Aerial-zh-Hans
bash scripts/setup-upstream.sh
bash scripts/build.sh --install
```

脚本会拉取上游 `v4.1.7`、应用补丁、构建、复制翻译、签名，并替换 `/Applications/Aerial.app`。安装前会备份到 `backup/`。

只构建不安装：

```bash
bash scripts/build.sh
```

产物在：

```text
build/DerivedData/Build/Products/Release/Aerial.app
```

## 目录

| 路径 | 内容 |
|---|---|
| `patches/` | 对上游 `v4.1.7` 的源码补丁 |
| `translations/` | 界面翻译和权限提示 |
| `scripts/setup-upstream.sh` | 拉取上游源码并应用补丁 |
| `scripts/build.sh` | 构建、复制翻译、签名、可选安装 |
| `scripts/extract_strings.py` | 提取直接字面量 |
| `scripts/extract_interpolated.py` | 提取插值字符串 |
| `docs/` | 构建、权限、翻译、覆盖范围 |
| `licenses/` | 上游 MIT 许可证 |

## 覆盖范围

已汉化：菜单、设置侧边栏和面板、视频库侧边栏、首页仪表盘、首次启动向导、设置下拉选项、工具提示、常见弹窗。

仍为英文：第三方扩展包的名称和简介、部分动态错误信息、更新说明。

详见 [docs/COVERAGE.md](docs/COVERAGE.md)。

## 参与

漏翻和错翻请开 issue，或直接修改 `translations/Localizable.strings` 发 PR。

源码改动流程见 [CONTRIBUTING.md](CONTRIBUTING.md) 和 [docs/TRANSLATION.md](docs/TRANSLATION.md)。

## 许可证

本仓库使用 MIT 许可证，见 [LICENSE](LICENSE)。

上游 Aerial 的版权声明和 MIT 许可证见 [NOTICE.md](NOTICE.md) 与 [licenses/Aerial-MIT.txt](licenses/Aerial-MIT.txt)。
