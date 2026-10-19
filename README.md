# Aerial 简体中文补丁（非官方）

给 [Aerial](https://github.com/AerialScreensaver/Aerial) 4.1.7 准备的社区简体中文补丁。补丁修改源码后重新编译，解决侧边栏、设置、首页仪表盘等位置的英文残留。

本仓库不包含 Aerial 应用二进制、图标或 Apple 视频素材。要使用补丁，请从上游源码自行构建。

> 非官方项目，与 Aerial 作者和 Apple 均无隶属关系。详见 [NOTICE.md](NOTICE.md)。

## 当前状态

- 目标版本：Aerial `v4.1.7`（上游提交 `29a2783`）
- 翻译条目：840 条
- 覆盖：设置侧边栏、视频库侧边栏、首页仪表盘、首次启动向导、设置选项、工具提示、常见弹窗
- 测试环境：macOS 27.0.1、Xcode 27.1、Apple Development 签名

## 两种使用方式

### 方式 A：源码构建（推荐，完整汉化）

要求：

- macOS 26 或更高
- Xcode 16 或更高（实测 Xcode 27.1）
- 一个 Apple Development 签名证书（Xcode 登录 Apple ID 后自动生成）

```bash
git clone https://github.com/Jason050413/Aerial-zh-Hans.git
cd Aerial-zh-Hans
bash scripts/setup-upstream.sh
bash scripts/build.sh --install
```

脚本会：

1. 拉取上游 Aerial `v4.1.7`；
2. 应用 `patches/aerial-4.1.7-zh-Hans.patch`；
3. 编译 Release 版本；
4. 复制 `translations/` 里的中文翻译；
5. 用本机 Apple Development 证书签名；
6. 备份并替换 `/Applications/Aerial.app`。

如果只想构建、不安装：

```bash
bash scripts/build.sh
```

### 方式 B：只注入翻译表（不装 Xcode，部分汉化）

适合已经安装官方 Aerial 4.1.x、但不想装 Xcode 的用户。

```bash
bash scripts/apply.sh
```

这种方式不修改源码，只能覆盖直接写在 SwiftUI 里的字符串。设置侧边栏、视频库侧边栏等通过 `String` 变量显示的文字仍是英文。

## 仓库结构

```text
Aerial-zh-Hans/
├── patches/                 # 对上游 v4.1.7 的源码补丁
├── translations/            # Localizable.strings 与权限提示
├── scripts/
│   ├── setup-upstream.sh    # 拉取上游并应用补丁
│   ├── build.sh             # 构建、复制翻译、签名、可选安装
│   ├── apply.sh             # 资源补丁模式（不编译）
│   ├── make-patch.sh        # 维护者：重新生成补丁
│   ├── extract_strings.py   # 提取直接字面量
│   └── extract_interpolated.py
├── docs/
│   ├── BUILDING.md          # 构建、签名、更新上游版本
│   ├── PERMISSIONS.md       # 权限、entitlements、TCC
│   ├── TRANSLATION.md       # 翻译格式与维护流程
│   └── COVERAGE.md          # 覆盖范围与已知英文残留
├── licenses/Aerial-MIT.txt  # 上游 MIT 许可证
├── NOTICE.md
├── CHANGELOG.md
└── CONTRIBUTING.md
```

## 已知限制

- 第三方扩展包的名称、作者、简介由扩展作者提供，不随界面翻译。
- Apple 航拍视频的名称和地点由 Apple 的 manifest 提供，通常已跟随系统语言。
- 少量动态错误信息、更新说明和 Sparkle 更新窗口仍可能显示英文。
- 如果上游以后加入官方本地化，本补丁可能与新版本冲突，需要按 [docs/BUILDING.md](docs/BUILDING.md) 重新适配。

更完整的覆盖说明见 [docs/COVERAGE.md](docs/COVERAGE.md)。

## 参与

欢迎提交漏翻、错翻和术语建议。请先看 [CONTRIBUTING.md](CONTRIBUTING.md) 和 [docs/TRANSLATION.md](docs/TRANSLATION.md)。

上游 Aerial 对较大的改动要求先开 issue 讨论。如果这个补丁要合并回上游，请遵循上游的贡献流程。

## 许可证

本仓库的补丁、翻译和脚本使用 MIT 许可证，见 [LICENSE](LICENSE)。

上游 Aerial 的 MIT 许可证和版权声明见 [NOTICE.md](NOTICE.md) 与 [licenses/Aerial-MIT.txt](licenses/Aerial-MIT.txt)。

## English summary

An unofficial Simplified Chinese localization patch for Aerial 4.1.7. It modifies the upstream source so SwiftUI strings that are passed as `String` variables are localized too. The repo contains only patches, translations and scripts — no app binary and no Apple video assets.

Build from upstream with `scripts/setup-upstream.sh` and `scripts/build.sh --install`. Requires macOS 26+, Xcode 16+ and an Apple Development certificate.

Licensed under MIT. Not affiliated with or endorsed by the Aerial project or Apple Inc.
