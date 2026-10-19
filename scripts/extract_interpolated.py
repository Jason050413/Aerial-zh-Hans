#!/usr/bin/env python3
"""Extract interpolated SwiftUI literals with ordered placeholders."""
import json
import re
import sys
from pathlib import Path

CALLS = [
    "Text", "Label", "Button", "Toggle", "Picker", "Section", "Menu", "Link",
    "TextField", "SecureField", "Stepper", "GroupBox", "CommandMenu",
    "MenuBarExtra", "Window", "WindowGroup", "ProgressView",
    "navigationTitle", "help", "alert", "confirmationDialog",
    "accessibilityLabel", "accessibilityHint", "navigationSubtitle",
]
call_re = re.compile(r'(?<![\w.])(?P<name>' + "|".join(CALLS) + r')\s*\(\s*"', re.MULTILINE)

def parse(src, start):
    i = start + 1
    parts = []
    exprs = []
    buf = []

    def flush():
        if buf:
            parts.append("".join(buf))
            buf.clear()

    while i < len(src):
        ch = src[i]
        if ch == "\\":
            nxt = src[i + 1] if i + 1 < len(src) else ""
            if nxt == "(":
                flush()
                depth = 1
                j = i + 2
                estart = j
                while j < len(src) and depth > 0:
                    c = src[j]
                    if c == "\\":
                        j += 2
                        continue
                    if c == '"':
                        k = j + 1
                        while k < len(src):
                            if src[k] == "\\":
                                k += 2
                                continue
                            if src[k] == '"':
                                break
                            k += 1
                        j = k + 1
                        continue
                    if c == "(":
                        depth += 1
                    elif c == ")":
                        depth -= 1
                    j += 1
                exprs.append(src[estart:j - 1].strip())
                parts.append("{" + str(len(exprs) - 1) + "}")
                i = j
                continue
            mapping = {"n": "\n", "t": "\t", "r": "\r", '"': '"', "\\": "\\"}
            buf.append(mapping.get(nxt, "\\" + nxt))
            i += 2
            continue
        if ch == '"':
            flush()
            return "".join(parts), exprs
        if ch == "\n":
            return None
        buf.append(ch)
        i += 1
    return None

def main(root):
    rootp = Path(root)
    out = []
    for path in sorted(rootp.rglob("*.swift")):
        rel = str(path.relative_to(rootp))
        if "Tests" in rel:
            continue
        src = path.read_text(encoding="utf-8", errors="ignore")
        for m in call_re.finditer(src):
            parsed = parse(src, m.end() - 1)
            if not parsed:
                continue
            template, exprs = parsed
            if not exprs:
                continue
            line = src.count("\n", 0, m.end()) + 1
            out.append({"file": rel, "line": line, "call": m.group("name"),
                        "template": template, "exprs": exprs})
    json.dump(out, sys.stdout, ensure_ascii=False, indent=1)

if __name__ == "__main__":
    main(sys.argv[1])
