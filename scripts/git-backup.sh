#!/bin/bash
# OpenClaw workspace 自动备份脚本
export GIT_DIR=/workspace/.git
export GIT_WORK_TREE=/workspace

cd /workspace

git add -A
git diff --cached --quiet && echo "无变更，跳过" && exit 0

git commit -m "自动备份 $(date '+%Y-%m-%d %H:%M')"
git push origin main && echo "备份成功" || echo "推送失败"
