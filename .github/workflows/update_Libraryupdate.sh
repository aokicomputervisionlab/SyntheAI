#!/bin/bash

# --- 自動パス解決 ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../.."
ROOT_DIR=$(pwd)
TARGET_DIR_NAME="py3"
LOG_FILE="LIBRARY_UPDATE.md"
DATE=$(date +'%Y-%m-%d %H:%M:%S')

echo "--- Generating Detailed Library Update Log ---"

# 1. GPU情報の取得
GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n 1 || echo "Unknown GPU")

# 2. バージョン比較ロジック (Pythonを活用して確実に抽出)
cd "$TARGET_DIR_NAME"

DIFF_CONTENT=$(python3 - <<EOF
import re

def parse_requirements(filename):
    pkgs = {}
    try:
        with open(filename, 'r') as f:
            for line in f:
                # コメントを除外して パッケージ名==バージョン を抽出
                line = line.strip()
                if line and not line.startswith('#'):
                    match = re.match(r'^([a-zA-Z0-9._-]+)==([a-zA-Z0-9._-]+)', line)
                    if match:
                        pkgs[match.group(1)] = match.group(2)
    except FileNotFoundError:
        pass
    return pkgs

old_pkgs = parse_requirements('requirements.txt.bak')
new_pkgs = parse_requirements('requirements.txt')

changes = []
# 更新または新規追加されたパッケージをチェック
for name, new_ver in new_pkgs.items():
    old_ver = old_pkgs.get(name)
    if old_ver != new_ver:
        if old_ver:
            changes.append(f"{name}: {old_ver} -> {new_ver}")
        else:
            changes.append(f"{name}: (NEW) -> {new_ver}")

# 削除されたパッケージも一応チェック
for name, old_ver in old_pkgs.items():
    if name not in new_pkgs:
        changes.append(f"{name}: {old_ver} -> (DELETED)")

if changes:
    print("\n".join(sorted(changes)))
EOF
)

if [ -z "$DIFF_CONTENT" ]; then
    echo "No package changes detected. Skipping log update."
    exit 0
fi

# 3. LIBRARY_UPDATE.md を生成
cd "$ROOT_DIR"

cat <<EOF > "$LOG_FILE"
# 📦 Library Update Report

## 🛰️ 検証環境
- **GPU**: $GPU_NAME (Tesla P40)
- **最終更新日時**: $DATE

## 🚀 アップデート詳細
今回の実行で以下のパッケージ構成が変更されました。

\`\`\`text
$DIFF_CONTENT
\`\`\`

---
*このファイルは .workflow/update_library_log.sh によって自動生成されました。*
EOF

echo "--- SUCCESS! $LOG_FILE has been replaced with the latest info! "