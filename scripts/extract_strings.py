#!/usr/bin/env python3
"""Extract all non-interpolated localizable SwiftUI literals, including modifiers."""
import json
import re
import sys
from pathlib import Path

INITIALIZERS = [
    "Text", "Label", "Button", "Toggle", "Picker", "Section", "Menu", "Link",
    "TextField", "SecureField", "Stepper", "GroupBox", "CommandMenu",
    "MenuBarExtra", "Window", "WindowGroup", "ProgressView",
    "DatePicker", "ColorPicker", "LabeledContent", "DisclosureGroup",
    "NavigationLink", "ShareLink", "TableColumn", "Tab",
]
MODIFIERS = [
    "navigationTitle", "navigationSubtitle", "help", "alert",
    "confirmationDialog", "accessibilityLabel", "accessibilityHint",
]
init_re = re.compile(r'(?<![\w.])(?P<name>' + "|".join(INITIALIZERS) + r')\s*\(\s*"', re.MULTILINE)
mod_re = re.compile(r'\.(?P<name>' + "|".join(MODIFIERS) + r')\s*\(\s*"', re.MULTILINE)
dotinit_re = re.compile(r'(?<![\w.])Text\s*\(\s*\.init\s*\(\s*"', re.MULTILINE)

def parse(src, start):
    i = start + 1
    out = []
    interp = False
    while i < len(src):
        ch = src[i]
        if ch == "\\":
            nxt = src[i+1] if i+1 < len(src) else ""
            if nxt == "(":
                interp = True
                depth = 1
                j = i + 2
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
                i = j
                continue
            m = {"n":"\n","t":"\t","r":"\r",'"':'"',"\\":"\\"}
            out.append(m.get(nxt, "\\"+nxt)); i += 2; continue
        if ch == '"':
            return "".join(out), i+1, interp
        if ch == "\n":
            return None
        out.append(ch); i += 1
    return None

def main(root):
    rootp = Path(root)
    found = {}
    interp = []
    for path in sorted(rootp.rglob("*.swift")):
        rel = str(path.relative_to(rootp))
        if "Tests" in rel: continue
        src = path.read_text(encoding="utf-8", errors="ignore")
        for rx, kind in [(init_re,"init"),(mod_re,"mod"),(dotinit_re,"dotinit")]:
            for m in rx.finditer(src):
                parsed = parse(src, m.end()-1)
                if not parsed: continue
                text, end, has_interp = parsed
                line = src.count("\n",0,m.end())+1
                if has_interp:
                    interp.append({"file":rel,"line":line,"kind":kind,"text":text})
                    continue
                if not text.strip(): continue
                entry = found.setdefault(text, {"count":0,"locations":[]})
                entry["count"] += 1
                if len(entry["locations"])<4:
                    entry["locations"].append(f"{rel}:{line}")
    out=[{"key":k,"count":v["count"],"locations":v["locations"]} for k,v in found.items()]
    out.sort(key=lambda x:(-x["count"], x["key"].lower()))
    json.dump({"unique":len(out),"strings":out,"interpolated":interp}, sys.stdout, ensure_ascii=False, indent=1)

if __name__ == "__main__":
    main(sys.argv[1])
