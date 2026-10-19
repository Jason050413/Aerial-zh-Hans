# 翻译与维护

## 需要改源码的原因

```swift
Text("Settings")   // 字面量，会查 Localizable.strings
Text(title)        // String 变量，原样显示
```

Aerial 的侧边栏、设置分类和首次启动卡片大量使用第二种写法。补丁把这类调用改成：

```swift
Text(LocalizedStringKey(title))
```

AppKit 的 `NSAlert` 和 `NSMenuItem` 改用：

```swift
String(localized: "Quit Aerial?")
Bundle.main.localizedString(forKey: title, value: title, table: nil)
```

## 键的格式

```text
"Settings" = "设置";
```

| 插值类型 | 占位符 | 例子 |
|---|---|---|
| `Int` | `%lld` | `"Step %lld of %lld"` |
| `String` | `%@` | `"Downloading %@"` |
| `Double` | `%lf` | `"Opacity: %lf%%"` |
| 字面量 `%` | `%%` | `"Opacity: %lld%%"` |
| 调整顺序 | `%1$lld`、`%2$@` | `"距离切换到 %1$@ 还有 %2$@"` |

- 键必须和源码字符串完全一致，区分大小写、空格和标点。
- 占位符不能写错或漏掉。
- 引号、反斜杠、换行分别转义为 `\"`、`\\`、`\n`。
- 修改后用 `plutil -lint translations/Localizable.strings` 检查。

## 修改源码

```swift
// 变量标题
Text(title)
→ Text(LocalizedStringKey(title))

// String 属性
return "Cloned"
→ return String(localized: "Cloned")

// AppKit 弹窗
alert.messageText = "Nothing to trim"
→ alert.messageText = String(localized: "Nothing to trim")
```

不要包装视频标题、扩展包名称、作者、地点、SSID 和文件路径。

## 提取字符串

```bash
python3 scripts/extract_strings.py vendor/Aerial/Aerial > /tmp/direct-app.json
python3 scripts/extract_strings.py vendor/Aerial/Shared > /tmp/direct-shared.json
python3 scripts/extract_interpolated.py vendor/Aerial/Aerial > /tmp/interp-app.json
python3 scripts/extract_interpolated.py vendor/Aerial/Shared > /tmp/interp-shared.json
```

`extract_strings.py` 覆盖 `Text`、`Label`、`Button`、`Toggle`、`Picker`、`.help`、`.alert`、`.navigationTitle` 和 `Text(.init(...))`。

`extract_interpolated.py` 列出带 `\(...)` 的字符串，需要按参数类型换算占位符。

把输出里的 `key` 和现有翻译表对比，补齐缺失的条目。

## 流程

1. `bash scripts/setup-upstream.sh`
2. 修改 `vendor/Aerial` 和 `translations/Localizable.strings`
3. 提取并补翻译
4. `bash scripts/build.sh --install`
5. 重新生成补丁：

   ```bash
   git -C vendor/Aerial diff -- . ':(exclude)BuildNumber.xcconfig' \
     > patches/aerial-4.1.7-zh-Hans.patch
   ```

## 风格

- 使用 Apple 中文术语：墙纸、屏幕保护程序、菜单栏、访达、定位服务、完全磁盘访问权限。
- 保留 Aerial、Dock、Sparkle、Ko-fi、HDR、4K、RTSP、HLS。
- 不翻译内容名称。
- 中文使用全角标点，句子尽量短。

## 边界

- 第三方扩展包的名称、作者和简介由扩展作者提供。
- Apple 视频的名称和地点由 Apple manifest 提供。
- 动态错误信息、日志和更新说明可能仍是英文。
