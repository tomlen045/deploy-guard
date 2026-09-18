#!/usr/bin/env bash
# deploy-guard v1.0 — Should I deploy? Let me check.
# Usage: bash deploy-guard.sh [--strict] [--skip-weekend]
set -u

G="\033[32m"; Y="\033[33m"; R="\033[31m"; B="\033[36m"; Bd="\033[1m"; D="\033[2m"; _="\033[0m"
STRICT=false
[[ "${1:-}" == "--strict" ]] && STRICT=true
SKIP_WEEKEND=false
[[ "${1:-}" == "--skip-weekend" ]] && SKIP_WEEKEND=true

GO=0; NOGO=0; THINK=0
PASS=(); WARN=(); FAIL=()

ok(){ GO=$((GO+1)); PASS+=("$1"); }
warn(){ THINK=$((THINK+1)); WARN+=("$1"); }
fail(){ NOGO=$((NOGO+1)); FAIL+=("$1"); }

echo -e "\n${Bd}🚦 deploy-guard — Should I deploy?${_}\n"
echo -e "${D}   $(date '+%Y-%m-%d %H:%M:%S %Z')${_}\n"

# ━━ 1. Day of week ━━
DAY=$(date +%u) # 1=Mon ... 5=Fri 6=Sat 7=Sun
HOUR=$(date +%H)
DAY_NAME=$(date +%A)

if [[ $DAY -eq 5 && $HOUR -ge 12 ]]; then
  fail "It's Friday afternoon. You KNOW how this ends."
  HARDEN="Deploy on Monday. Your future self will thank you."
elif [[ $DAY -ge 6 ]]; then
  fail "It's $DAY_NAME. Even if you're on-call, ask yourself: is this actually urgent?"
else
  if [[ $HOUR -ge 17 ]]; then
    warn "It's $DAY_NAME ${HOUR}:00 — late in the day. Do you have a rollback plan?"
  else
    ok "It's $DAY_NAME ${HOUR}:00 — good deployment window."
  fi
fi

# ━━ 2. Git status ━━
if command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null; then
  DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [[ $DIRTY -gt 0 ]]; then
    fail "$DIRTY uncommitted change(s) — commit or stash before deploying"
  else
    ok "Working directory clean"
  fi

  AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "?")
  if [[ "$AHEAD" == "?" ]]; then
    warn "No upstream tracking branch — is this even in a repo?"
  elif [[ $AHEAD -gt 0 ]]; then
    fail "$AHEAD unpushed commit(s) — push first"
  else
    ok "All commits pushed"
  fi

  # Check if last commit message contains WIP or fix or hotfix
  LAST_MSG=$(git log -1 --pretty=%B 2>/dev/null)
  if echo "$LAST_MSG" | grep -qiE "wip|tmp|temp|fix later|don't deploy|DO NOT"; then
    fail "Last commit message says: '$LAST_MSG' — seriously?"
  fi
else
  warn "Not in a git repository — no version control = no rollback"
fi

# ━━ 3. Tests ━━
if [[ -f "package.json" ]] && grep -q '"test"' package.json 2>/dev/null; then
  warn "Found test script in package.json — did you run npm test?"
elif [[ -f "Makefile" ]] && grep -q "^test:" Makefile 2>/dev/null; then
  warn "Found Makefile test target — did you run make test?"
elif [[ -f "pytest.ini" ]] || [[ -f "setup.py" ]] || [[ -f "pyproject.toml" ]]; then
  warn "Python project detected — did you run your tests?"
else
  ok "No test configuration detected (skipping test check)"
fi

# ━━ 4. Environment files ━━
for f in .env .env.local .env.production secrets.json credentials.json; do
  if [[ -f "$f" ]]; then
    if git ls-files --error-unmatch "$f" &>/dev/null 2>&1; then
      fail "$f is tracked by git! Remove it: git rm --cached $f"
    else
      ok "$f is properly gitignored"
    fi
  fi
done

# ━━ 5. Check for TODO/FIXME/HACK in recent changes ━━
if command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null; then
  TODOS=$(git diff --cached 2>/dev/null | grep -c "TODO\|FIXME\|HACK\|XXX" || true)
  if [[ $TODOS -gt 0 ]]; then
    warn "$TODO TODO/FIXME/HACK comment(s) in staged changes"
  fi
fi

# ━━ 6. Check branch ━━
if command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
    if [[ "$STRICT" == true ]]; then
      fail "Deploying directly to $BRANCH — use a feature branch + PR"
    else
      warn "Deploying directly to $BRANCH — consider using a branch + PR workflow"
    fi
  else
    ok "Deploying from feature branch: $BRANCH"
  fi
fi

# ━━ 7. Disk space ━━
DISK=$(df / 2>/dev/null | awk 'NR==2{gsub(/%/,"",$5);print $5}')
if [[ -n "$DISK" && $DISK -ge 90 ]]; then
  fail "Disk usage at ${DISK}% — deploy might fail mid-way"
elif [[ -n "$DISK" && $DISK -ge 80 ]]; then
  warn "Disk usage at ${DISK}% — getting tight"
else
  ok "Disk usage OK (${DISK:-?}%)"
fi

# ━━ 8. Memory ━━
if [[ -f /proc/meminfo ]]; then
  MEM_TOTAL=$(awk '/MemTotal/{print int($2/1024)}' /proc/meminfo)
  MEM_AVAIL=$(awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo)
  MEM_PCT=$(( (MEM_TOTAL-MEM_AVAIL)*100/MEM_TOTAL ))
  if [[ $MEM_PCT -ge 90 ]]; then
    fail "Memory at ${MEM_PCT}% — deploy might cause OOM"
  elif [[ $MEM_PCT -ge 80 ]]; then
    warn "Memory at ${MEM_PCT}%"
  else
    ok "Memory at ${MEM_PCT}%"
  fi
fi

# ━━ Verdict ━━
echo -e "\n${Bd}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_}"

if [[ $NOGO -gt 0 ]]; then
  echo -e "  ${R}${Bd}🚫 NO-GO — Fix these first:${_}"
  for f in "${FAIL[@]}"; do echo -e "    ${R}•${_} $f"; done
  [[ ${#WARN[@]} -gt 0 ]] && { echo -e "\n  ${Y}${Bd}Also consider:${_}"; for w in "${WARN[@]}"; do echo -e "    ${Y}•${_} $w"; done; }
  EXIT=1
elif [[ $THINK -gt 2 ]]; then
  echo -e "  ${Y}${Bd}🤔 THINK TWICE — ${THINK} warning(s):${_}"
  for w in "${WARN[@]}"; do echo -e "    ${Y}•${_} $w"; done
  echo -e "\n  ${Y}Are you sure? If yes, type: yes I am sure${_}"
  EXIT=2
elif [[ $THINK -gt 0 ]]; then
  echo -e "  ${Y}${Bd}🤔 THINK TWICE${_}"
  for w in "${WARN[@]}"; do echo -e "    ${Y}•${_} $w"; done
  echo -e "\n  ${G}${Bd}But overall: GO 🚀${_}"
  EXIT=0
else
  echo -e "  ${G}${Bd}✅ GO — All checks passed. Ship it! 🚀${_}"
  EXIT=0
fi

echo -e "  Checks: ${G}${GO} passed${_} · ${Y}${THINK} warnings${_} · ${R}${NOGO} critical${_}"
echo ""
exit $EXIT
