#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(pwd)"
DRY_RUN=0
PULL_IF_EXISTS=0

while (($#)); do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --pull)
      PULL_IF_EXISTS=1
      ;;
    *)
      BASE_DIR="$1"
      ;;
  esac
  shift
done

if [[ ! -d "$BASE_DIR" ]]; then
  echo "[ERROR] Base directory does not exist: $BASE_DIR"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "[ERROR] git was not found in PATH."
  exit 1
fi

clone_repo() {
  local repo_url="$1"
  local repo_dir="$2"
  local target="$BASE_DIR/$repo_dir"

  if [[ -d "$target/.git" ]]; then
    echo "[SKIP] $repo_dir already exists as a git repo."
    if [[ $PULL_IF_EXISTS -eq 1 ]]; then
      if [[ $DRY_RUN -eq 1 ]]; then
        echo "[DRY-RUN] git -C \"$target\" pull --ff-only"
      else
        git -C "$target" pull --ff-only
      fi
    fi
    return
  fi

  if [[ -e "$target" ]]; then
    echo "[WARN] $repo_dir exists but is not a git repo. Skipping."
    return
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[DRY-RUN] git clone \"$repo_url\" \"$target\""
  else
    echo "[CLONE] $repo_dir"
    git clone "$repo_url" "$target"
  fi
}

echo "Base directory: $BASE_DIR"
echo "Dry run: $DRY_RUN"
echo "Pull existing repos: $PULL_IF_EXISTS"
echo

clone_repo "https://github.com/advprog-2026-A15-project/yomu-api-gateway.git" "api-gateway"
clone_repo "https://github.com/advprog-2026-A15-project/yomu-frontend.git" "frontend"
clone_repo "https://github.com/advprog-2026-A15-project/yomu-service-achievements.git" "service-achievements"
clone_repo "https://github.com/advprog-2026-A15-project/yomu-service-auth.git" "service-auth"
clone_repo "https://github.com/advprog-2026-A15-project/yomu-service-clan.git" "service-clan"
clone_repo "https://github.com/advprog-2026-A15-project/yomu-service-forum.git" "service-forum"
clone_repo "https://github.com/advprog-2026-A15-project/yomu-service-learning.git" "service-learning"
clone_repo "https://github.com/advprog-2026-A15-project/yomu-shared-lib.git" "shared-lib"

echo
echo "Done."
