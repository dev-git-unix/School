#!/bin/bash

REPO_DIR="$(pwd)"
BRANCH="main"
TIMER=30  # check every 30 seconds

cd "$REPO_DIR" || exit 1

echo "🔄 Auto-pull running in $REPO_DIR every $TIMER sec..."

while true; do
    git fetch origin "$BRANCH"

    LOCAL=$(git rev-parse "$BRANCH")
    REMOTE=$(git rev-parse origin/"$BRANCH")

    if [ "$LOCAL" != "$REMOTE" ]; then
        echo "🌐 Remote has new changes. Pulling..."
        git pull --rebase origin "$BRANCH"
    else
        echo "✅ Already up to date."
    fi

    sleep "$TIMER"
done

