#!/bin/sh
# Claude가 main/master 브랜치에서 git commit 하는 것을 차단하는 PreToolUse hook.
# study/<주제> 브랜치를 거치도록 강제.
cmd=$(jq -r '.tool_input.command // ""')
echo "$cmd" | grep -qE 'git[[:space:]]+commit' || exit 0

branch=$(git symbolic-ref --short HEAD 2>/dev/null)
if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
  cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"main/master 브랜치에는 직접 커밋할 수 없습니다. 'git switch -c study/<주제>' 로 주제 브랜치를 만든 뒤 커밋하세요."}}
JSON
fi
exit 0
