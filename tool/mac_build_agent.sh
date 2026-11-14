#!/bin/bash
# mac_build_agent.sh — pull-baserad byggagent för navimusic (kör på MacBooken).
#
# Arkitektur: Linux-AI:n pushar kod till Forgejo. Denna agent pollar repot,
# bygger i användarens GUI-session (där nyckelringen fungerar utan krångel),
# installerar på iPhone via devicectl och rapporterar tillbaka i git.
# Ingen inkommande nätverksåtkomst behövs — bara utgående https till
# git-servern på LAN.
#
# Installeras som launchd LaunchAgent, se docs/HANDOVER.md.

set -u

REPO="$HOME/dev/navimusic/app"
DEVICE_ID="1D920962-79E9-5D8D-8B42-398C727AA1E8"   # Simon – iPhone
STATE_FILE="$HOME/.navimusic-buildagent-last"
LOCK_FILE="/tmp/navimusic-buildagent.lock"
LOG_FILE="$HOME/Library/Logs/navimusic-buildagent.log"
STATUS_JSON="docs/BUILD_STATUS.json"

# launchd har minimal PATH — flutter/pod/git måste läggas till explicit.
export PATH="$HOME/development/flutter/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"; }

# En körning åt gången.
if [ -f "$LOCK_FILE" ] && kill -0 "$(cat "$LOCK_FILE")" 2>/dev/null; then
  exit 0
fi
echo $$ > "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

mkdir -p "$(dirname "$LOG_FILE")"
cd "$REPO" || { log "FEL: hittar inte $REPO"; exit 1; }

git fetch origin main >> "$LOG_FILE" 2>&1 || { log "FEL: git fetch misslyckades (nås git-servern?)"; exit 1; }

# Hoppa över agentens egna status-commits — annars triggar varje egen
# status-push ett nytt bygge i en oändlig loop.
# (--invert-grep påverkar bara --grep, inte --author — därför filtreras
# agentens egna status-commits på meddelandeprefixet "build: " i stället.)
REMOTE=$(git log -1 --format=%H --invert-grep --grep="^build: " origin/main)
LAST_BUILT=$(cat "$STATE_FILE" 2>/dev/null || echo "")

if [ "$REMOTE" = "$LAST_BUILT" ]; then
  exit 0   # inget nytt att bygga
fi

log "Ny commit upptäckt: $REMOTE (senast byggd ${LAST_BUILT:-aldrig})"
git pull --ff-only origin main >> "$LOG_FILE" 2>&1 || { log "FEL: pull misslyckades (ej fast-forward)"; exit 1; }

RESULT="failed"
STEP="pub get"
if flutter pub get >> "$LOG_FILE" 2>&1; then
  STEP="flutter test"
  if flutter test >> "$LOG_FILE" 2>&1; then
    STEP="flutter build ios --release"
    if flutter build ios --release >> "$LOG_FILE" 2>&1; then
      STEP="devicectl install"
      if xcrun devicectl device install app --device "$DEVICE_ID" \
           build/ios/iphoneos/Runner.app >> "$LOG_FILE" 2>&1; then
        RESULT="ok"
        STEP="done"
        echo "$REMOTE" > "$STATE_FILE"
        log "KLART: $REMOTE byggd och installerad på iPhone"
      fi
    fi
  fi
fi

[ "$RESULT" = "failed" ] && log "MISSLYCKADES i steg: $STEP (commit $REMOTE)"

# Rapportera status tillbaka till repot (best effort — får aldrig stoppa agenten).
cat > "$STATUS_JSON" <<EOF
{
  "commit": "$REMOTE",
  "built_at": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
  "result": "$RESULT",
  "failed_step": "$STEP",
  "device": "Simon – iPhone ($DEVICE_ID)",
  "log": "~/Library/Logs/navimusic-buildagent.log"
}
EOF
git add "$STATUS_JSON" >> "$LOG_FILE" 2>&1
git -c user.name="mac-build-agent" -c user.email="buildagent@local" \
    commit -qm "build: $RESULT $REMOTE ($STEP)" >> "$LOG_FILE" 2>&1
git push origin main >> "$LOG_FILE" 2>&1 || log "VARNING: kunde inte pusha status (kolliderar med annan commit — löses vid nästa körning)"

exit 0
