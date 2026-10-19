# 翻译与维护

## 为什么需要改源码

SwiftUI 有两种常见的文字写法：

```swift
Text("Settings")        // 字面量，会自动查 Localizable.strings
Text(title)             // String 变量，原样显示，不会查表
```

Aerial 4.1.7 的侧边栏、设置分类、首次启动卡片等大量使用第二种写法。只放翻译表无法覆盖，所以补丁把这类调用改成：

```swift
Text(LocalizedStringKey(title))
```

AppKit 的 `NSAlert`、`NSMenuItem` 不参与 SwiftUI 的自动查表，补丁改用：

```swift
String(localized: "Quit Aerial?")
Bundle.main.localizedString(forKey: key, value: key, table: nil)
```

## 键的格式

`translations/Localizable.strings` 左边是键，必须与源码里的字符串完全一致，区分大小写、空格和标点。

```text
"Settings" = "设置";
```

带插值的字符串会变成格式字符串：

| 插值类型 | 占位符 | 例子 |
|---|---|---|
| `Int` | `%lld` | `"Step %lld of %lld"` |
| `String` | `%@` | `"Downloading %@"` |
| `Double` | `%lf` | `"Opacity: %lf%%"` |
| 字面量 `%` | `%%` | `"Opacity: %lld%%"` |
| 需要调整顺序 | `%1$lld`、`%2$@` | `"距离切换到 %1$@ 还有 %2$@"` |

几条规则：

- 不要把 `%lld`、`%@` 写错或漏掉；写错时该条会回退英文，严重时格式会显示异常。
- 中文里可以省略多余的复数占位符，例如 `"%lld video%@"` 可以翻成 `"%lld 个视频"`。需要跳过中间参数时用位置参数。
- 键里的引号、反斜杠、换行需要转义：`\"`、`\\`、`\n`。
- 修改后用 `plutil -lint translations/Localizable.strings` 检查。

## 修改源码

工作区：

```bash
bash scripts/setup-upstream.sh
cd vendor/Aerial
```

常见改法：

```swift
// 变量标题
Text(title)
→ Text(LocalizedStringKey(title))

// Swift String 属性
return "Cloned"
→ return String(localized: "Cloned")

// 带插值
Text("Downloading \(count)...")
→ 原文已经是 LocalizedStringKey，直接加键即可

// AppKit 弹窗
alert.messageText = "Nothing to trim"
→ alert.messageText = String(localized: "Nothing to trim")

// AppKit 菜单
NSMenuItem(title: title, ...)
→ NSMenuItem(title: Bundle.main.localizedString(forKey: title, value: title, table: nil), ...)
```

不要包装用户内容，例如视频标题、扩展包名称、作者、地点、SSID、文件路径。这些字符串不应该查翻译表。

## 提取新增字符串

脚本只读源码：

```bash
python3 scripts/extract_strings.py vendor/Aerial/Aerial > /tmp/direct-app.json
python3 scripts/extract_strings.py vendor/Aerial/Shared > /tmp/direct-shared.json
python3 scripts/extract_interpolated.py vendor/Aerial/Aerial > /tmp/interp-app.json
python3 scripts/extract_interpolated.py vendor/Aerial/Shared > /tmp/interp-shared.json
```

`extract_strings.py` 覆盖：

- `Text`、`Label`、`Button`、`Toggle`、`Picker` 等直接字面量；
- `.help`、`.alert`、`.navigationTitle`、`.accessibilityLabel` 等修饰符；
- `Text(.init("..."))`。

`extract_interpolated.py` 单独列出带 `\(...)` 的字符串，需要根据参数类型换算占位符。

把输出里的 `key` 和 `translations/Localizable.strings` 里已有的键对比，缺的就是需要补的条目。

## 测试

1. 检查 `.strings` 格式：

   ```bash
   plutil -lint translations/Localizable.strings
   ```

2. 构建：

   ```bash
   bash scripts/build.sh --install
   ```

3. 检查这些界面：

   - 菜单栏 Aerial 菜单；
   - 设置窗口左侧分类和右侧面板；
   - 视频库左侧分类；
   - 首页仪表盘；
   - 首次启动向导；
   - 缓存、重置、退出等弹窗。

4. 签名和崩溃：

   ```bash
   codesign --verify --deep --strict /Applications/Aerial.app
   ls -t ~/Library/Logs/DiagnosticReports/*Aerial* | head
   ```

## 风格

- 使用 Apple 中文术语：墙纸、屏幕保护程序、菜单栏、访达、定位服务、完全磁盘访问权限。
- 保留 Aerial、Dock、Sparkle、Ko-fi、HDR、4K、RTSP、HLS。
- 不翻译内容名称。
- 中文使用全角标点。
- 句子尽量短，避免直译腔。

## 已知边界

- 第三方扩展包的名称、作者和简介由扩展作者提供。
- Apple 视频的名称和地点由 Apple manifest 提供，通常跟随系统语言。
- 动态错误信息、日志文本、更新说明和 Sparkle 更新窗口可能仍是英文。
- 资源补丁模式（`scripts/apply.sh`）不修改源码，只覆盖直接字面量；侧边栏等变量文字仍为英文。
