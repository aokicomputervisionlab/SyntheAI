#!/bin/bash

# --- 自動パス解決 ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../.."
ROOT_DIR=$(pwd)
DATE=$(date +'%Y%m%d')
BRANCH_NAME="update-deps-$DATE"

echo "--- Git Push & PR Process Start ---"

# 1. GPU情報の取得 (nvidia-smi から名前だけを抽出)
# 複数のGPUがある場合も考慮して1行にまとめます
GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n 1)

if [ -z "$GPU_NAME" ]; then
    GPU_NAME="Unknown GPU"
fi

echo "Detected GPU: $GPU_NAME"

# 2. 差分があるか確認
if [ -z "$(git status --porcelain py3/requirements.txt LIBRARY_UPDATE.md)" ]; then
    echo "No changes detected. Nothing to push."
    exit 0
fi

# 3. ブランチの作成
echo "Creating new branch: $BRANCH_NAME"
git checkout -b "$BRANCH_NAME" || (git checkout "$BRANCH_NAME" && git pull origin "$BRANCH_NAME")

# 4. コミット
echo "Committing changes..."
git add py3/requirements.txt LIBRARY_UPDATE.md
git commit -m "chore: 依存ライブラリとLIBRARY_UPDATEを自動更新 ($DATE)"

# 5. プッシュ
echo "Pushing to remote..."
git push origin "$BRANCH_NAME" --force

# 6. Pull Requestの作成 (GPU名をボディに含める)
if command -v gh &> /dev/null; then
    echo "Creating Pull Request via GitHub CLI..."
    
    PR_BODY=$(cat <<EOF
🤖 **依存関係の自動アップデート報告**

- **検証環境**: $GPU_NAME (Local Server)
- **実行日**: $(date +'%Y-%m-%d %H:%M:%S JST')
- **内容**: requirements.txt の更新および LIBRARY_UPDATE の履歴追記。

ローカルの物理環境にて生成・検証済みの更新です。
EOF
)

    gh pr create \
        --title "🤖 依存関係の自動アップデート ($DATE)" \
        --body "$PR_BODY" \
        --base main \
        --head "Amenbo1219:$BRANCH_NAME" || echo "PR might already exist."
else
    echo "GitHub CLI (gh) not found. Skipping PR creation."
fi

echo "--- ALL DONE! Branch: $BRANCH_NAME ---"
