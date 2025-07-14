#!/bin/bash

# === CONFIG ===
REPO_DIR="$(pwd)"              # ← No need to edit if script is inside repo
BRANCH="main"
TIMER=10
COUNTER_FILE="$REPO_DIR/.autosync_count"

cd "$REPO_DIR" || exit 1

# Initialize counter file if not present
if [ ! -f "$COUNTER_FILE" ]; then
  echo "1" > "$COUNTER_FILE"
fi

echo "🔁 Watching $REPO_DIR for changes..."

fswatch -o . | while read; do
    echo "🔍 Change detected. Waiting $TIMER seconds to debounce..."
    sleep "$TIMER"

    # Check if there are changes to commit
    if [[ -n $(git status --porcelain) ]]; then
        # Read and increment counter
        COUNT=$(cat "$COUNTER_FILE")
        NEXT_COUNT=$((COUNT + 1))
        echo "$NEXT_COUNT" > "$COUNTER_FILE"

        # Build commit message
        COMMIT_MSG="#$COUNT | Auto-sync: $(hostname) on $(date '+%Y-%m-%d %H:%M:%S')"

        echo "📦 Staging changes..."
        git add .

        echo "📝 Committing with: $COMMIT_MSG"
        git commit -m "$COMMIT_MSG"

        echo "🚀 Pulling latest before pushing..."
        git pull --rebase origin "$BRANCH"

        echo "📤 Pushing to GitHub..."
        git push origin "$BRANCH"
    else
        echo "✅ No changes to commit."
    fi
done
