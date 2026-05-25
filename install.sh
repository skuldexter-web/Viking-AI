#!/bin/bash

# ================================================================
#  VIKING AI — Digital Longship Intelligence System
#  Local CLI Security Assistant for Kali Linux
#  License: MIT
# ================================================================

# No global set -e — installer must tolerate individual tool failures.
# set -u catches unbound variables; pipefail catches silent pipe errors.
set -uo pipefail

# ════════════════════════════════════════════════════════════════
#  CONSTANTS
# ════════════════════════════════════════════════════════════════
readonly INSTALL_PATH="/usr/local/bin/viking"
readonly DEFAULT_MODEL="tinyllama"
readonly VIKING_DIR="/opt/viking"
readonly ARSENAL_DIR="$VIKING_DIR/arsenal"
readonly LOG_DIR="$VIKING_DIR/logs"
readonly CONFIG_FILE="$VIKING_DIR/config"
readonly REGISTRY_FILE="$VIKING_DIR/arsenal_registry.sh"
readonly ARSENAL_MENU="$VIKING_DIR/arsenal_menu.sh"
readonly LOCK_FILE="/tmp/viking_install.lock"
readonly WAR_JOBS=4

# ════════════════════════════════════════════════════════════════
#  COLORS
# ════════════════════════════════════════════════════════════════
readonly R='\033[0;31m'
readonly RB='\033[1;31m'
readonly G='\033[0;32m'
readonly C='\033[0;36m'
readonly Y='\033[1;33m'
readonly M='\033[0;35m'
readonly B='\033[1m'
readonly D='\033[2m'
readonly NC='\033[0m'

# ════════════════════════════════════════════════════════════════
#  ARSENAL REGISTRY — single source of truth
#  Format: "NAME|CATEGORY|GIT_URL|TYPE"
#  Types : git_python | git_go | git_generic
#  !! Edit tool list HERE only — registry file is auto-generated !!
# ════════════════════════════════════════════════════════════════
declare -A ARSENAL

# Keys are plain integers — no leading zeros (avoids octal ambiguity)
# Scanning & Recon
ARSENAL[1]="WebCheck|Scanning & Recon|https://github.com/X3RX3SSec/WebCheck.git|git_python"
ARSENAL[2]="DEATH_STAR|Scanning & Recon|https://github.com/Ringmast4r/DEATH_STAR.git|git_python"
ARSENAL[3]="Dracnmap|Scanning & Recon|https://github.com/screetsec/Dracnmap.git|git_python"
ARSENAL[4]="RED_HAWK|Scanning & Recon|https://github.com/Tuhinshubhra/RED_HAWK.git|git_python"
ARSENAL[5]="reconspider|Scanning & Recon|https://github.com/bhavsec/reconspider.git|git_python"
ARSENAL[6]="ReconDog|Scanning & Recon|https://github.com/s0md3v/ReconDog.git|git_python"
ARSENAL[7]="Striker|Scanning & Recon|https://github.com/s0md3v/Striker.git|git_python"
ARSENAL[8]="SecretFinder|Scanning & Recon|https://github.com/m4ll0k/SecretFinder.git|git_python"
ARSENAL[9]="rang3r|Scanning & Recon|https://github.com/floriankunushevci/rang3r.git|git_python"
ARSENAL[10]="Breacher|Scanning & Recon|https://github.com/s0md3v/Breacher.git|git_python"
ARSENAL[11]="theHarvester|Scanning & Recon|https://github.com/laramies/theHarvester.git|git_python"
ARSENAL[12]="spiderfoot|Scanning & Recon|https://github.com/smicallef/spiderfoot.git|git_python"

# Network Tools
ARSENAL[13]="nmap|Network Tools|https://github.com/nmap/nmap.git|git_generic"
ARSENAL[14]="masscan|Network Tools|https://github.com/robertdavidgraham/masscan.git|git_generic"
ARSENAL[15]="RustScan|Network Tools|https://github.com/bee-san/RustScan.git|git_generic"
ARSENAL[16]="xerosploit|Network Tools|https://github.com/LionSec/xerosploit.git|git_python"
ARSENAL[17]="amass|Network Tools|https://github.com/owasp-amass/amass.git|git_go"
ARSENAL[18]="httpx|Network Tools|https://github.com/projectdiscovery/httpx.git|git_go"
ARSENAL[19]="subfinder|Network Tools|https://github.com/projectdiscovery/subfinder.git|git_go"

# XSS Tools
ARSENAL[20]="dalfox|XSS Tools|https://github.com/hahwul/dalfox.git|git_go"
ARSENAL[21]="XSS-LOADER|XSS Tools|https://github.com/capture0x/XSS-LOADER.git|git_python"
ARSENAL[22]="extended-xss-search|XSS Tools|https://github.com/Damian89/extended-xss-search.git|git_python"
ARSENAL[23]="XSpear|XSS Tools|https://github.com/hahwul/XSpear.git|git_generic"
ARSENAL[24]="XSSCon|XSS Tools|https://github.com/menkrep1337/XSSCon.git|git_python"
ARSENAL[25]="XanXSS|XSS Tools|https://github.com/Ekultek/XanXSS.git|git_python"
ARSENAL[26]="XSStrike|XSS Tools|https://github.com/s0md3v/XSStrike.git|git_python"
ARSENAL[27]="RVuln|XSS Tools|https://github.com/yangr0/RVuln.git|git_python"

# SQL Injection
ARSENAL[28]="sqlmap|SQL Injection|https://github.com/sqlmapproject/sqlmap.git|git_python"
ARSENAL[29]="NoSQLMap|SQL Injection|https://github.com/codingo/NoSQLMap.git|git_python"
ARSENAL[30]="DSSS|SQL Injection|https://github.com/stamparm/DSSS.git|git_python"
ARSENAL[31]="explo|SQL Injection|https://github.com/telekom-security/explo.git|git_python"
ARSENAL[32]="Blisqy|SQL Injection|https://github.com/JohnTroony/Blisqy.git|git_python"
ARSENAL[33]="leviathan|SQL Injection|https://github.com/utkusen/leviathan.git|git_python"
ARSENAL[34]="sqlscan|SQL Injection|https://github.com/Cvar1984/sqlscan.git|git_python"

# WiFi Tools
ARSENAL[35]="OneShot|WiFi Tools|https://github.com/kimocoder/OneShot.git|git_python"
ARSENAL[36]="wifipumpkin3|WiFi Tools|https://github.com/P0cL4bs/wifipumpkin3.git|git_python"
ARSENAL[37]="pixiewps|WiFi Tools|https://github.com/wiire-a/pixiewps.git|git_generic"
ARSENAL[38]="bluepot|WiFi Tools|https://github.com/andrewmichaelsmith/bluepot.git|git_generic"
ARSENAL[39]="fluxion|WiFi Tools|https://github.com/FluxionNetwork/fluxion.git|git_generic"
ARSENAL[40]="wifiphisher|WiFi Tools|https://github.com/wifiphisher/wifiphisher.git|git_python"
ARSENAL[41]="wifite2|WiFi Tools|https://github.com/derv82/wifite2.git|git_python"
ARSENAL[42]="fakeap|WiFi Tools|https://github.com/Z4nzu/fakeap.git|git_python"

# Anonymity
ARSENAL[43]="kali-anonsurf|Anonymity|https://github.com/Und3rf10w/kali-anonsurf.git|git_generic"
ARSENAL[44]="multitor|Anonymity|https://github.com/trimstray/multitor.git|git_generic"

# OSINT
ARSENAL[45]="holehe|OSINT|https://github.com/megadose/holehe.git|git_python"
ARSENAL[46]="maigret|OSINT|https://github.com/soxoj/maigret.git|git_python"
ARSENAL[47]="trufflehog|OSINT|https://github.com/trufflesecurity/trufflehog.git|git_go"
ARSENAL[48]="gitleaks|OSINT|https://github.com/gitleaks/gitleaks.git|git_go"
ARSENAL[49]="SMWYG|OSINT|https://github.com/Viralmaniar/SMWYG-Show-Me-What-You-Got.git|git_python"

# Wordlist
ARSENAL[50]="cupp|Wordlist|https://github.com/Mebus/cupp.git|git_python"
ARSENAL[51]="wlcreator|Wordlist|https://github.com/Z4nzu/wlcreator.git|git_python"
ARSENAL[52]="GoblinWordGenerator|Wordlist|https://github.com/UndeadSec/GoblinWordGenerator.git|git_python"

# Phishing
ARSENAL[53]="autophisher|Phishing|https://github.com/CodingRanjith/autophisher.git|git_python"
ARSENAL[54]="AdvPhishing|Phishing|https://github.com/Ignitetch/AdvPhishing.git|git_python"
ARSENAL[55]="SET|Phishing|https://github.com/trustedsec/social-engineer-toolkit.git|git_python"
ARSENAL[56]="SocialFish|Phishing|https://github.com/UndeadSec/SocialFish.git|git_python"
ARSENAL[57]="evilginx2|Phishing|https://github.com/kgretzky/evilginx2.git|git_go"
ARSENAL[58]="I-See-You|Phishing|https://github.com/Viralmaniar/I-See-You.git|git_python"
ARSENAL[59]="saycheese|Phishing|https://github.com/hangetzzu/saycheese.git|git_python"
ARSENAL[60]="ohmyqr|Phishing|https://github.com/cryptedwolf/ohmyqr.git|git_python"
ARSENAL[61]="Thanos|Phishing|https://github.com/TridevReddy/Thanos.git|git_python"
ARSENAL[62]="QRLJacking|Phishing|https://github.com/OWASP/QRLJacking.git|git_python"
ARSENAL[63]="maskphish|Phishing|https://github.com/jaykali/maskphish.git|git_generic"
ARSENAL[64]="BlackPhish|Phishing|https://github.com/yangr0/BlackPhish.git|git_python"

# Web Tools
ARSENAL[65]="dirb|Web Tools|https://gitlab.com/kalilinux/packages/dirb.git|git_generic"
ARSENAL[66]="takeover|Web Tools|https://github.com/edoardottt/takeover.git|git_go"
ARSENAL[67]="checkURL|Web Tools|https://github.com/UndeadSec/checkURL.git|git_python"
ARSENAL[68]="Sublist3r|Web Tools|https://github.com/aboul3la/Sublist3r.git|git_python"
ARSENAL[69]="web2attack|Web Tools|https://github.com/santatic/web2attack.git|git_python"

# Exploitation
ARSENAL[70]="Vegile|Exploitation|https://github.com/screetsec/Vegile.git|git_generic"
ARSENAL[71]="HeraKeylogger|Exploitation|https://github.com/UndeadSec/HeraKeylogger.git|git_python"
ARSENAL[72]="bulk_extractor|Exploitation|https://github.com/simsong/bulk_extractor.git|git_generic"
ARSENAL[73]="TheFatRat|Exploitation|https://github.com/screetsec/TheFatRat.git|git_generic"
ARSENAL[74]="Brutal|Exploitation|https://github.com/screetsec/Brutal.git|git_generic"
ARSENAL[75]="msfpc|Exploitation|https://github.com/g0tmi1k/msfpc.git|git_generic"
ARSENAL[76]="venom|Exploitation|https://github.com/r00t-3xp10it/venom.git|git_generic"
ARSENAL[77]="spycam|Exploitation|https://github.com/indexnotfound404/spycam.git|git_python"
ARSENAL[78]="Mob-Droid|Exploitation|https://github.com/kinghacker0/Mob-Droid.git|git_python"
ARSENAL[79]="Enigma|Exploitation|https://github.com/UndeadSec/Enigma.git|git_python"

# ════════════════════════════════════════════════════════════════
#  LOGGING
# ════════════════════════════════════════════════════════════════
log_ok()   { echo -e "${G}[✓]${NC} $*"; }
log_info() { echo -e "${C}[~]${NC} $*"; }
log_warn() { echo -e "${Y}[!]${NC} $*"; }
log_err()  { echo -e "${R}[✗]${NC} $*" >&2; }
log_step() { echo -e "\n${B}${C}━━[ STEP $1 ]━━${NC} $2"; }
log_war()  { echo -e "${RB}[WAR]${NC} $*"; }

# ════════════════════════════════════════════════════════════════
#  PREFLIGHT
# ════════════════════════════════════════════════════════════════
preflight() {
  [[ "$EUID" -ne 0 ]]   && log_err "Run as root: sudo bash install.sh" && exit 1
  [[ -f "$LOCK_FILE" ]] && log_err "Install already running (remove $LOCK_FILE to reset)" && exit 1
  command -v apt-get &>/dev/null || { log_err "apt-get required (Debian/Kali only)"; exit 1; }
  touch "$LOCK_FILE"
  trap 'rm -f "$LOCK_FILE"' EXIT INT TERM
}

# ════════════════════════════════════════════════════════════════
#  INSTALLER BANNER
# ════════════════════════════════════════════════════════════════
show_installer_banner() {
  clear
  echo -e "${B}${C}"
  echo "  ██╗   ██╗██╗██╗  ██╗██╗███╗   ██╗ ██████╗      █████╗ ██╗"
  echo "  ██║   ██║██║██║ ██╔╝██║████╗  ██║██╔════╝     ██╔══██╗██║"
  echo "  ██║   ██║██║█████╔╝ ██║██╔██╗ ██║██║  ███╗    ███████║██║"
  echo "  ╚██╗ ██╔╝██║██╔═██╗ ██║██║╚██╗██║██║   ██║    ██╔══██║██║"
  echo "   ╚████╔╝ ██║██║  ██╗██║██║ ╚████║╚██████╔╝    ██║  ██║██║"
  echo "    ╚═══╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝  ╚═╝╚═╝"
  echo -e "${NC}"
  echo -e "${G}       ⚔  Digital Longship Intelligence System  ⚔${NC}"
  echo -e "${C}       Linux Operations & Security Engine — Kali Linux${NC}"
  echo ""
  echo "  ═══════════════════════════════════════════════════════"
  echo ""
}

# ════════════════════════════════════════════════════════════════
#  WAR MODE BANNER
# ════════════════════════════════════════════════════════════════
show_war_banner() {
  clear
  echo -e "${RB}"
  echo "  ██╗    ██╗ █████╗ ██████╗     ███╗   ███╗ ██████╗ ██████╗ ███████╗"
  echo "  ██║    ██║██╔══██╗██╔══██╗    ████╗ ████║██╔═══██╗██╔══██╗██╔════╝"
  echo "  ██║ █╗ ██║███████║██████╔╝    ██╔████╔██║██║   ██║██║  ██║█████╗  "
  echo "  ██║███╗██║██╔══██║██╔══██╗    ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝  "
  echo "  ╚███╔███╔╝██║  ██║██║  ██║    ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗"
  echo "   ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝"
  echo ""
  echo "  ██╗  ██╗███████╗██╗     ██╗          ██╗███████╗"
  echo "  ██║  ██║██╔════╝██║     ██║         ██╔╝██╔════╝"
  echo "  ███████║█████╗  ██║     ██║        ██╔╝ ███████╗"
  echo "  ██╔══██║██╔══╝  ██║     ██║       ██╔╝  ╚════██║"
  echo "  ██║  ██║███████╗███████╗███████╗ ██╔╝   ███████║"
  echo "  ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝    ╚══════╝"
  echo ""
  echo "  ══════════════════════════════════════════════════════════════"
  echo "  ⚠  DEPLOYING FULL WEAPON ARSENAL — ALL TOOLS INCOMING  ⚠"
  echo "  ══════════════════════════════════════════════════════════════"
  echo -e "${NC}"
  sleep 1
}

# ════════════════════════════════════════════════════════════════
#  DEPENDENCIES
# ════════════════════════════════════════════════════════════════
install_dependencies() {
  log_step "1" "Installing system dependencies..."
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    tmux curl wget git python3 python3-pip python3-venv \
    nmap tshark whois nikto build-essential golang-go \
    ruby ruby-dev libpcap-dev libssl-dev 2>/dev/null
  log_ok "Dependencies ready"
}

# ════════════════════════════════════════════════════════════════
#  OLLAMA
# ════════════════════════════════════════════════════════════════
install_ollama() {
  log_step "2" "Checking Ollama..."
  if command -v ollama &>/dev/null; then
    log_ok "Ollama already installed"
  else
    log_info "Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh || {
      log_err "Ollama install failed — check internet connection"
      exit 1
    }
    log_ok "Ollama installed"
  fi
  systemctl enable ollama &>/dev/null || true
  systemctl start  ollama &>/dev/null || true
  # Wait up to 15 s for Ollama API to respond
  local tries=5
  until curl -sf http://localhost:11434/ &>/dev/null || (( --tries == 0 )); do
    sleep 3
  done
  log_ok "Ollama service running"
}

pull_model() {
  local model="${1:-$DEFAULT_MODEL}"
  log_step "3" "Checking model: $model"
  # Use curl to check — more reliable than parsing `ollama list` output
  if ollama list 2>/dev/null | awk '{print $1}' | grep -Fxq "$model"; then
    log_ok "Already present: $model"
  else
    log_info "Pulling $model..."
    ollama pull "$model" || log_warn "Pull failed — will retry on first use"
    log_ok "Model ready: $model"
  fi
}

# ════════════════════════════════════════════════════════════════
#  TOOL INSTALLER — shared by installer, War Mode, and live menu
# ════════════════════════════════════════════════════════════════
_post_install() {
  local dest="$1" type="$2"
  case "$type" in
    git_python)
      [[ -f "$dest/requirements.txt" ]] &&
        pip3 install -q -r "$dest/requirements.txt" \
          --break-system-packages 2>/dev/null || true ;;
    git_go)
      [[ -f "$dest/go.mod" ]] &&
        (cd "$dest" && go build ./... 2>/dev/null) || true ;;
    git_generic)
      if   [[ -f "$dest/Makefile"   ]]; then (cd "$dest" && make -s 2>/dev/null)        || true
      elif [[ -f "$dest/setup.sh"   ]]; then (cd "$dest" && bash setup.sh 2>/dev/null)   || true
      elif [[ -f "$dest/install.sh" ]]; then (cd "$dest" && bash install.sh 2>/dev/null) || true
      fi ;;
  esac
}

install_tool() {
  local raw_key="$1"
  # Strip leading zeros so arithmetic works; fall back to raw if non-numeric
  local key
  key=$(printf '%d' "$((10#${raw_key}))" 2>/dev/null) || key="$raw_key"
  local entry="${ARSENAL[$key]:-}"
  [[ -z "$entry" ]] && { log_err "Tool #$key not in arsenal"; return 1; }

  IFS='|' read -r name category url itype <<< "$entry"
  local dest="$ARSENAL_DIR/$name"

  printf "  ${C}[%02d]${NC} %-30s ${D}%s${NC}\n" "$key" "$name" "$category"

  if [[ -d "$dest/.git" ]]; then
    git -C "$dest" pull -q 2>/dev/null || true
  else
    git clone --depth=1 -q "$url" "$dest" 2>/dev/null || {
      log_err "Clone failed: $name"
      return 1
    }
  fi

  _post_install "$dest" "$itype"
  log_ok "$name installed"
}

# ════════════════════════════════════════════════════════════════
#  PROGRESS BAR
# ════════════════════════════════════════════════════════════════
_progress_bar() {
  local cur="$1" tot="$2" w=46
  # Guard against division by zero
  (( tot == 0 )) && return
  local f=$(( cur * w / tot ))
  local e=$(( w - f ))
  local bar_fill bar_empty
  bar_fill=$(printf '█%.0s' $(seq 1 "$f"))
  bar_empty=$(printf '░%.0s' $(seq 1 "$e"))
  printf "\r  ${RB}[${NC}${RB}%s${NC}${D}%s${NC}${RB}]${NC} %d/%d" \
    "$bar_fill" "$bar_empty" "$cur" "$tot"
}

# ════════════════════════════════════════════════════════════════
#  WAR MODE — throttled parallel installs with correct tracking
# ════════════════════════════════════════════════════════════════
war_mode_install() {
  show_war_banner
  mkdir -p "$ARSENAL_DIR" "$LOG_DIR"

  # Build sorted key list
  local keys=()
  while IFS= read -r k; do keys+=("$k"); done < <(
    printf '%s\n' "${!ARSENAL[@]}" | sort -n
  )

  local total=${#keys[@]}
  local count=0
  local -a pids=()
  local -a running_keys=()
  local -a failed=()

  for key in "${keys[@]}"; do
    (( count++ ))
    IFS='|' read -r name _ _ _ <<< "${ARSENAL[$key]}"
    log_war "[$count/$total] Deploying: $name"

    install_tool "$key" >> "$LOG_DIR/war_$(printf '%02d' "$count").log" 2>&1 &
    pids+=($!)
    running_keys+=("$key")

    # Throttle: drain oldest job when at capacity
    if (( ${#pids[@]} >= WAR_JOBS )); then
      if ! wait "${pids[0]}"; then
        failed+=("${running_keys[0]}")
      fi
      pids=("${pids[@]:1}")
      running_keys=("${running_keys[@]:1}")
    fi

    _progress_bar "$count" "$total"
  done

  # Drain remaining jobs
  local i=0
  for pid in "${pids[@]}"; do
    if ! wait "$pid"; then
      failed+=("${running_keys[$i]}")
    fi
    (( i++ ))
  done
  echo ""

  echo -e "\n${RB}  ══════════════════════════════════════════════${NC}"
  echo -e "${RB}  WAR COMPLETE — $count / $total WEAPONS DEPLOYED  ⚔${NC}"
  echo -e "${RB}  ══════════════════════════════════════════════${NC}"
  if (( ${#failed[@]} > 0 )); then
    echo -e "${Y}  Failed keys: ${failed[*]}"
    echo -e "  Logs → $LOG_DIR${NC}"
  fi
  echo ""
}

# ════════════════════════════════════════════════════════════════
#  ARSENAL TABLE — installer display (keys printed as zero-padded)
# ════════════════════════════════════════════════════════════════
display_arsenal_table() {
  local current_cat=""
  echo ""
  echo -e "${B}${Y}  ⚔  WAPENS ARSENAL  ⚔${NC}"
  echo -e "  ══════════════════════════════════════════════════════"
  while IFS= read -r key; do
    IFS='|' read -r name category _ _ <<< "${ARSENAL[$key]}"
    if [[ "$category" != "$current_cat" ]]; then
      current_cat="$category"
      echo -e "\n${B}${M}    ── $category ──${NC}"
    fi
    local tag=""
    [[ -d "$ARSENAL_DIR/$name" ]] && tag="${G}[installed]${NC}"
    printf "  ${C}[%02d]${NC}  %-32s%b\n" "$key" "$name" "$tag"
  done < <(printf '%s\n' "${!ARSENAL[@]}" | sort -n)
  echo -e "\n  ══════════════════════════════════════════════════════\n"
}

# ════════════════════════════════════════════════════════════════
#  GENERATE REGISTRY FILE — from ARSENAL array (no duplication)
# ════════════════════════════════════════════════════════════════
write_arsenal_registry() {
  log_step "4" "Generating arsenal registry..."
  {
    echo "#!/bin/bash"
    echo "# Auto-generated by install.sh — edit ARSENAL in install.sh only"
    echo "declare -A TOOL_REGISTRY"
    for key in $(printf '%s\n' "${!ARSENAL[@]}" | sort -n); do
      printf 'TOOL_REGISTRY[%d]="%s"\n' "$key" "${ARSENAL[$key]}"
    done
  } > "$REGISTRY_FILE"
  chmod +x "$REGISTRY_FILE"
  log_ok "Registry → $REGISTRY_FILE"
}

# ════════════════════════════════════════════════════════════════
#  GENERATE ARSENAL MENU SCRIPT
# ════════════════════════════════════════════════════════════════
write_arsenal_menu() {
  log_step "4b" "Writing arsenal menu..."
  cat > "$ARSENAL_MENU" << 'MENU'
#!/bin/bash
# VIKING Arsenal Menu — sources generated registry at runtime

VIKING_DIR="/opt/viking"
ARSENAL_DIR="$VIKING_DIR/arsenal"
REGISTRY_FILE="$VIKING_DIR/arsenal_registry.sh"
LOG_DIR="$VIKING_DIR/logs"
WAR_JOBS=4

R='\033[0;31m'; RB='\033[1;31m'; G='\033[0;32m'; C='\033[0;36m'
Y='\033[1;33m'; M='\033[0;35m'; B='\033[1m'; D='\033[2m'; NC='\033[0m'

# shellcheck source=/dev/null
source "$REGISTRY_FILE" || { echo "Registry missing — run install.sh"; exit 1; }

log_ok()  { echo -e "${G}[✓]${NC} $*"; }
log_err() { echo -e "${R}[✗]${NC} $*" >&2; }
log_war() { echo -e "${RB}[WAR]${NC} $*"; }

_post_install() {
  local dest="$1" type="$2"
  case "$type" in
    git_python)
      [[ -f "$dest/requirements.txt" ]] &&
        pip3 install -q -r "$dest/requirements.txt" \
          --break-system-packages 2>/dev/null || true ;;
    git_go)
      [[ -f "$dest/go.mod" ]] && (cd "$dest" && go build ./... 2>/dev/null) || true ;;
    git_generic)
      if   [[ -f "$dest/Makefile"   ]]; then (cd "$dest" && make -s 2>/dev/null)        || true
      elif [[ -f "$dest/setup.sh"   ]]; then (cd "$dest" && bash setup.sh 2>/dev/null)   || true
      elif [[ -f "$dest/install.sh" ]]; then (cd "$dest" && bash install.sh 2>/dev/null) || true
      fi ;;
  esac
}

install_tool() {
  local key
  key=$(printf '%d' "$((10#${1}))" 2>/dev/null) || key="$1"
  local entry="${TOOL_REGISTRY[$key]:-}"
  [[ -z "$entry" ]] && { log_err "Tool #$key not found"; return 1; }

  IFS='|' read -r name category url itype <<< "$entry"
  local dest="$ARSENAL_DIR/$name"

  printf "  ${C}[%02d]${NC} %-30s ${D}%s${NC}\n" "$key" "$name" "$category"

  if [[ -d "$dest/.git" ]]; then
    git -C "$dest" pull -q 2>/dev/null || true
  else
    git clone --depth=1 -q "$url" "$dest" 2>/dev/null || {
      log_err "Clone failed: $name"; return 1
    }
  fi
  _post_install "$dest" "$itype"
  log_ok "$name installed"
}

_progress_bar() {
  local cur="$1" tot="$2" w=46
  (( tot == 0 )) && return
  local f=$(( cur * w / tot )) e=$(( w - cur * w / tot ))
  local bf be
  bf=$(printf '█%.0s' $(seq 1 "$f"))
  be=$(printf '░%.0s' $(seq 1 "$e"))
  printf "\r  ${RB}[${NC}${RB}%s${NC}${D}%s${NC}${RB}]${NC} %d/%d" "$bf" "$be" "$cur" "$tot"
}

war_banner() {
  clear
  echo -e "${RB}"
  echo "  ██╗    ██╗ █████╗ ██████╗     ███╗   ███╗ ██████╗ ██████╗ ███████╗"
  echo "  ██║    ██║██╔══██╗██╔══██╗    ████╗ ████║██╔═══██╗██╔══██╗██╔════╝"
  echo "  ██║ █╗ ██║███████║██████╔╝    ██╔████╔██║██║   ██║██║  ██║█████╗  "
  echo "  ██║███╗██║██╔══██║██╔══██╗    ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝  "
  echo "  ╚███╔███╔╝██║  ██║██║  ██║    ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗"
  echo "   ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝"
  echo ""
  echo "  ██╗  ██╗███████╗██╗     ██╗          ██╗███████╗"
  echo "  ██║  ██║██╔════╝██║     ██║         ██╔╝██╔════╝"
  echo "  ███████║█████╗  ██║     ██║        ██╔╝ ███████╗"
  echo "  ██╔══██║██╔══╝  ██║     ██║       ██╔╝  ╚════██║"
  echo "  ██║  ██║███████╗███████╗███████╗ ██╔╝   ███████║"
  echo "  ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝    ╚══════╝"
  echo ""
  echo "  ══════════════════════════════════════════════════════════════"
  echo "  ⚠  DEPLOYING FULL WEAPON ARSENAL — ALL TOOLS INCOMING  ⚠"
  echo "  ══════════════════════════════════════════════════════════════"
  echo -e "${NC}"
  sleep 1
}

war_mode() {
  war_banner
  mkdir -p "$ARSENAL_DIR" "$LOG_DIR"

  local keys=()
  while IFS= read -r k; do keys+=("$k"); done < <(
    printf '%s\n' "${!TOOL_REGISTRY[@]}" | sort -n
  )

  local total=${#keys[@]} count=0
  local -a pids=() running_keys=() failed=()

  for key in "${keys[@]}"; do
    (( count++ ))
    IFS='|' read -r name _ _ _ <<< "${TOOL_REGISTRY[$key]}"
    log_war "[$count/$total] Deploying: $name"
    install_tool "$key" >> "$LOG_DIR/war_$count.log" 2>&1 &
    pids+=($!)
    running_keys+=("$key")

    if (( ${#pids[@]} >= WAR_JOBS )); then
      if ! wait "${pids[0]}"; then failed+=("${running_keys[0]}"); fi
      pids=("${pids[@]:1}")
      running_keys=("${running_keys[@]:1}")
    fi
    _progress_bar "$count" "$total"
  done

  local i=0
  for pid in "${pids[@]}"; do
    if ! wait "$pid"; then failed+=("${running_keys[$i]}"); fi
    (( i++ ))
  done
  echo ""

  echo -e "\n${RB}  ══════════════════════════════════════════════${NC}"
  echo -e "${RB}  WAR COMPLETE — $count WEAPONS DEPLOYED  ⚔${NC}"
  echo -e "${RB}  ══════════════════════════════════════════════${NC}"
  (( ${#failed[@]} > 0 )) && echo -e "${Y}  Failed: ${failed[*]}${NC}"
  echo ""
}

show_arsenal() {
  local current_cat=""
  echo ""
  echo -e "${B}${Y}  ⚔  WAPENS ARSENAL  ⚔${NC}"
  echo -e "  ══════════════════════════════════════════════════════"
  while IFS= read -r key; do
    IFS='|' read -r name category _ _ <<< "${TOOL_REGISTRY[$key]}"
    if [[ "$category" != "$current_cat" ]]; then
      current_cat="$category"
      echo -e "\n${B}${M}    ── $category ──${NC}"
    fi
    local tag=""
    [[ -d "$ARSENAL_DIR/$name" ]] && tag="${G}[installed]${NC}"
    printf "  ${C}[%02d]${NC}  %-32s%b\n" "$key" "$name" "$tag"
  done < <(printf '%s\n' "${!TOOL_REGISTRY[@]}" | sort -n)
  echo -e "\n  ══════════════════════════════════════════════════════"
  echo -e "\n  ${C}number${NC} → install  |  ${RB}WAR${NC} → all tools  |  ${Y}back${NC} → return\n"

  while true; do
    echo -ne "${Y}arsenal> ${NC}"
    read -r choice || break
    case "${choice,,}" in
      war)         war_mode; show_arsenal; return ;;
      back|exit|q) break ;;
      ''|*[!0-9]*) echo -e "${R}Enter a number, WAR, or back.${NC}" ;;
      *)           install_tool "$choice" ;;
    esac
  done
}

show_arsenal
MENU
  chmod +x "$ARSENAL_MENU"
  log_ok "Arsenal menu → $ARSENAL_MENU"
}

# ════════════════════════════════════════════════════════════════
#  VIKING CLI SCRIPT
#  Written to /usr/local/bin/viking
# ════════════════════════════════════════════════════════════════
write_viking_script() {
  log_step "5" "Writing VIKING CLI → $INSTALL_PATH..."
  cat > "$INSTALL_PATH" << 'VIKINGSCRIPT'
#!/bin/bash
# ================================================================
#  VIKING AI — Digital Longship Intelligence System
#  Lightweight AI-powered security assistant for Kali Linux
#  License: MIT
# ================================================================

set -uo pipefail

# ── Paths ─────────────────────────────────────────────────────────
readonly VIKING_DIR="/opt/viking"
readonly ARSENAL_DIR="$VIKING_DIR/arsenal"
readonly CONFIG_FILE="$VIKING_DIR/config"
readonly LOGFILE="$HOME/.viking_history.log"
readonly OLLAMA_API="http://localhost:11434/api/chat"

# ── Load saved model preference ───────────────────────────────────
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
MODEL="${VIKING_MODEL:-tinyllama}"

# ── Colors ────────────────────────────────────────────────────────
R='\033[0;31m'; RB='\033[1;31m'; G='\033[0;32m'; C='\033[0;36m'
Y='\033[1;33m'; M='\033[0;35m'; B='\033[1m'; D='\033[2m'; NC='\033[0m'

# ── Available models ──────────────────────────────────────────────
readonly -a AVAILABLE_MODELS=(
  "tinyllama"    # default — fastest, ~600 MB
  "llama3.2:3b"  # better reasoning, ~2 GB
  "qwen2.5:3b"   # strong code + security context, ~2 GB
)

# ── System prompt — minimal for small context windows ─────────────
# One sentence only. tinyllama saturates on long prompts.
# Personality + format taught by two few-shot example turns below.
readonly SYSTEM_PROMPT='Your name is VIKING. You are a cybersecurity assistant on Kali Linux.'

# ── Few-shot examples — two turns lock in persona + response style ─
# Kept as a pre-escaped JSON fragment (no shell substitution needed).
readonly FEW_SHOT_JSON='{"role":"user","content":"who are you"},{"role":"assistant","content":"I am VIKING. Your cybersecurity companion on Kali Linux. What is the target?"},{"role":"user","content":"scan ports on 10.0.0.1"},{"role":"assistant","content":"COMMAND: nmap -sV --open -T4 10.0.0.1\nEXPLANATION: Scan open ports and detect service versions.\nOUTPUT: List of open ports with services."},'

# ════════════════════════════════════════════════════════════════
#  CORE HELPERS
# ════════════════════════════════════════════════════════════════
log()         { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOGFILE"; }
v_say()       { echo -e "${Y}⚔  VIKING:${NC} $1"; }
v_info()      { echo -e "${C}[VIKING]${NC} $1"; }
v_err()       { echo -e "${R}[VIKING]${NC} $*"; }
save_config() { printf 'VIKING_MODEL="%s"\n' "$MODEL" > "$CONFIG_FILE"; }

# Escape a string for JSON using python3 (one subprocess, correct output)
json_escape() {
  printf '%s' "$1" | python3 -c \
    'import sys,json; print(json.dumps(sys.stdin.read()), end="")'
}

# ── viking_think — streaming REST API ─────────────────────────────
# num_ctx 512: keeps KV cache tiny → fast first-token on tinyllama.
# num_predict 300: enough for any answer; prevents runaway output.
# temperature 0.3: low = consistent persona, less hallucination.
# stream true: tokens print immediately as they are generated.
viking_think() {
  local prompt="$*"
  local sys_esc user_esc
  sys_esc=$(json_escape "$SYSTEM_PROMPT")
  user_esc=$(json_escape "$prompt")

  local payload
  payload=$(printf \
    '{"model":"%s","stream":true,"options":{"temperature":0.3,"num_predict":300,"num_ctx":512},"messages":[{"role":"system","content":%s},%s{"role":"user","content":%s}]}' \
    "$MODEL" "$sys_esc" "$FEW_SHOT_JSON" "$user_esc")

  curl -sS --no-buffer \
    -H "Content-Type: application/json" \
    -d "$payload" \
    "$OLLAMA_API" 2>/dev/null \
  | python3 -u -c "
import sys, json
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        d = json.loads(line)
        t = d.get('message', {}).get('content', '')
        if t:
            sys.stdout.write(t)
            sys.stdout.flush()
    except Exception:
        pass
sys.stdout.write('\n')
sys.stdout.flush()
"
}

# ── warm_model — pre-loads model before first question ────────────
# Same num_ctx as viking_think → Ollama reuses the same KV cache.
# Runs in background so banner displays immediately.
warm_model() {
  curl -sS -o /dev/null \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"$MODEL\",\"stream\":false,\"options\":{\"temperature\":0.3,\"num_predict\":1,\"num_ctx\":512},\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}]}" \
    "$OLLAMA_API" &
}

# ── match — fast bash regex, no subprocess ────────────────────────
match() { [[ "${INPUT,,}" =~ $1 ]]; }

# ── extract_target — pull first IP or URL from input ─────────────
extract_target() {
  local t
  t=$(echo "$INPUT" | grep -oE \
    '([0-9]{1,3}\.){3}[0-9]{1,3}|https?://[^[:space:]]+|[a-zA-Z0-9._-]+\.[a-zA-Z]{2,4}(/[^[:space:]]*)?' \
    | grep -v '^[0-9]$' | head -1)
  echo "$t"
}

# ════════════════════════════════════════════════════════════════
#  BANNER
# ════════════════════════════════════════════════════════════════
show_banner() {
  clear
  echo -e "${D}${G}"
  echo "                                         |    |    |"
  echo "                                        )_)  )_)  )_)"
  echo '                                       )___))___))___)\  '
  echo '                                      )____)____)_____)\  \ '
  echo '                                    _____|____|____|____\  \  \ __'
  echo "                       ____________/~~~~~~~~~~~~~~~~~~~~~\___\___________"
  echo -e "${NC}${D}${C}"
  echo "  ~~^~~^~~^~~^~~^~~^~/                                                   \~~^~~"
  echo "  ~^~~^~~^~~^~~^~~^~~|  ooo   ooo   ooo   ooo   ooo   ooo   ooo   ooo   |^~~^~"
  echo "  ~~^~~^~~^~~^~~^~~^~|  | |   | |   | |   | |   | |   | |   | |   | |   |~~^~~"
  echo "  ~^~~^~~^~~^~~^~~^~~\~~'~'~~~'~'~~~'~'~~~'~'~~~'~'~~~'~'~~~'~'~~~'~'~~/^~~^~~"
  echo "  ~~^~~^~~^~~^~~^~~^~~\________________________________________/~~~^~~^~~"
  echo "  ~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~"
  echo -e "${NC}${B}${Y}"
  echo "  ██╗   ██╗██╗██╗  ██╗██╗███╗   ██╗ ██████╗      █████╗ ██╗"
  echo "  ██║   ██║██║██║ ██╔╝██║████╗  ██║██╔════╝     ██╔══██╗██║"
  echo "  ██║   ██║██║█████╔╝ ██║██╔██╗ ██║██║  ███╗    ███████║██║"
  echo "  ╚██╗ ██╔╝██║██╔═██╗ ██║██║╚██╗██║██║   ██║    ██╔══██║██║"
  echo "   ╚████╔╝ ██║██║  ██╗██║██║ ╚████║╚██████╔╝    ██║  ██║██║"
  echo "    ╚═══╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝  ╚═╝╚═╝"
  echo -e "${NC}"
  echo -e "  ${C}⚔  Digital Longship Intelligence System  ⚔${NC}"
  echo -e "  ${D}════════════════════════════════════════════${NC}"
  echo -e "  ${C}Linux Operations & Security Engine${NC}"
  echo -e "  Model: ${G}${MODEL}${NC}  |  Type ${Y}help${NC} for commands  |  ${D}quit to exit${NC}"
  echo ""
}

# ════════════════════════════════════════════════════════════════
#  HELP
# ════════════════════════════════════════════════════════════════
show_help() {
  echo ""
  echo -e "${B}${Y}  ⚔  VIKING COMMAND REFERENCE  ⚔${NC}"
  echo -e "  ════════════════════════════════\n"
  local -a sections=(
    "SCANNING & RECON:scan <ip/url>≡nmap scan + AI analysis:masscan <ip>≡fast port scan:ping <ip>≡probe target:whois <domain>≡WHOIS lookup:nikto <url>≡web vuln scan"
    "WIRELESS:wifite≡wireless attack suite:oneshot≡WPS/PMKID attack:wifiphisher≡evil twin AP:fluxion≡WPA handshake capture:airmon≡aircrack-ng guidance"
    "WEB ATTACKS:gobuster <url>≡directory brute force:sqlmap <url>≡SQL injection:xsstrike <url>≡XSS scanner:dalfox <url>≡XSS fuzzer"
    "EXPLOITATION:metasploit≡launch msfconsole:hydra≡brute force guidance:netcat≡reverse/bind shell:hashcat / john≡hash cracking"
    "OSINT:theharvester <domain>≡email/host recon:amass <domain>≡subdomain enum:subfinder <domain>≡subdomain finder:holehe <email>≡account checker:maigret≡username search"
    "PHISHING:setoolkit≡social engineer toolkit:evilginx≡reverse proxy phishing"
    "ANONYMITY:anonsurf≡route traffic via Tor"
    "CODING:write python ...≡Python code:make html ...≡HTML/CSS/JS:bash script ...≡Bash scripting"
    "ARSENAL & MODEL:arsenal≡browse & install 79 tools:model≡list & switch AI models:model <name>≡quick switch"
    "SYSTEM:help≡this menu:history≡session log:banner≡redraw banner:quit / exit≡leave VIKING"
  )
  for section in "${sections[@]}"; do
    local title="${section%%:*}" rest="${section#*:}"
    echo -e "  ${C}${title}${NC}"
    IFS=':' read -ra cmds <<< "$rest"
    for cmd in "${cmds[@]}"; do
      printf "    %-30s — %s\n" "${cmd%%≡*}" "${cmd##*≡}"
    done
    echo ""
  done
}

# ════════════════════════════════════════════════════════════════
#  MODEL SWITCHER
# ════════════════════════════════════════════════════════════════
show_models() {
  # Cache ollama list once to avoid multiple subprocess calls
  local installed_list
  installed_list=$(ollama list 2>/dev/null | awk 'NR>1{print $1}')

  echo ""
  echo -e "${B}${Y}  ⚔  AVAILABLE MODELS  ⚔${NC}"
  echo -e "  ═══════════════════════════════════\n"

  local i=1
  for m in "${AVAILABLE_MODELS[@]}"; do
    local active="" inst=""
    [[ "$m" == "$MODEL" ]] && active="${G} ← active${NC}"
    echo "$installed_list" | grep -Fxq "$m" && inst="${D}[installed]${NC}"
    printf "  ${C}[%d]${NC}  %-20s%b %b\n" "$i" "$m" "$active" "$inst"
    (( i++ ))
  done

  echo -e "\n  ${D}All models run under 3 GB RAM.${NC}"
  echo -e "  Enter number, model name, or ${Y}back${NC} to cancel.\n"

  while true; do
    echo -ne "${Y}model> ${NC}"
    read -r choice || break
    case "${choice,,}" in
      back|exit|'') break ;;
      *[!0-9]*)
        MODEL="$choice"
        save_config
        v_say "Switched to: $MODEL"
        break ;;
      *)
        local idx=$(( choice - 1 ))
        if (( idx >= 0 && idx < ${#AVAILABLE_MODELS[@]} )); then
          MODEL="${AVAILABLE_MODELS[$idx]}"
          save_config
          v_say "Pulling $MODEL..."
          ollama pull "$MODEL" 2>/dev/null || true
          v_say "Active: $MODEL"
          break
        else
          v_err "Invalid — enter 1, 2, 3, or back."
        fi ;;
    esac
  done
}

# ════════════════════════════════════════════════════════════════
#  TOOL LAUNCHER
#  Priority order: arsenal dir → system PATH → not found message
# ════════════════════════════════════════════════════════════════
launch_tool() {
  local name="$1"
  shift
  local tool_dir="$ARSENAL_DIR/$name"

  v_info "Launching: $name${*:+ $*}"

  if [[ -d "$tool_dir" ]]; then
    # Python entrypoints
    local py
    for py in main.py "${name}.py" run.py app.py; do
      if [[ -f "$tool_dir/$py" ]]; then
        python3 "$tool_dir/$py" "$@"
        return
      fi
    done
    # Bash entrypoints
    local sh
    for sh in "${name}.sh" run.sh start.sh; do
      if [[ -f "$tool_dir/$sh" ]]; then
        bash "$tool_dir/$sh" "$@"
        return
      fi
    done
    # Ruby entrypoints
    local rb
    for rb in "${name}.rb" main.rb; do
      if [[ -f "$tool_dir/$rb" ]]; then
        ruby "$tool_dir/$rb" "$@"
        return
      fi
    done
    # Named binary
    if [[ -f "$tool_dir/$name" && -x "$tool_dir/$name" ]]; then
      "$tool_dir/$name" "$@"
      return
    fi
    # Any executable in root of tool dir
    local bin
    bin=$(find "$tool_dir" -maxdepth 1 -type f -executable | head -1)
    if [[ -n "$bin" ]]; then
      "$bin" "$@"
      return
    fi
  fi

  # Fall back to system PATH
  if command -v "$name" &>/dev/null; then
    "$name" "$@"
    return
  fi

  v_err "$name not found. Install via: arsenal"
}

# ════════════════════════════════════════════════════════════════
#  AI OUTPUT WRAPPER — colour + newline around streaming output
# ════════════════════════════════════════════════════════════════
ai_response() {
  echo -ne "${G}"
  viking_think "$@"
  echo -e "${NC}"
}

# ════════════════════════════════════════════════════════════════
#  MAIN LOOP
# ════════════════════════════════════════════════════════════════
show_banner
warm_model   # pre-loads model in background while user reads banner

while true; do
  echo -ne "${Y}You: ${NC}"
  read -r INPUT || break
  [[ -z "$INPUT" ]] && continue
  log "USER: $INPUT"

  # ── Exact built-in commands — case is O(1), no subprocess ────
  case "${INPUT,,}" in
    quit|exit|/bye)
      echo ""; v_say "The longship returns to port. Skål. ⚔"; echo ""; break ;;
    help)    show_help;   continue ;;
    banner)  show_banner; continue ;;
    arsenal) bash "$VIKING_DIR/arsenal_menu.sh"; continue ;;
    model)   show_models; continue ;;
    history)
      echo ""; cat "$LOGFILE" 2>/dev/null || v_err "No history yet."; echo ""
      continue ;;
  esac

  # ── model <name> quick switch ─────────────────────────────────
  if [[ "$INPUT" =~ ^[Mm]odel[[:space:]]+(.+)$ ]]; then
    MODEL="${BASH_REMATCH[1]}"
    save_config
    v_say "Model → $MODEL"
    continue
  fi

  # ════════════════════════════════════════════════════════════
  #  TOOL HANDLERS
  #  Direct execution runs FIRST — AI is only called for guidance.
  #  match() uses bash [[ =~ ]] — no subshell, no fork.
  # ════════════════════════════════════════════════════════════

  # ── NMAP / SCAN ──────────────────────────────────────────────
  if match "^scan[[:space:]]|^scan$|nmap"; then
    TARGET=$(extract_target)
    if [[ -n "$TARGET" ]]; then
      v_info "Scouting: $TARGET"
      RESULT=$(sudo nmap -sV --open -T4 "$TARGET" 2>&1)
      echo "$RESULT"; echo ""
      v_info "Raid report:"
      ai_response "Nmap results for $TARGET. Give: open ports, services, risk level, next command. Be brief. Output: ${RESULT:0:1500}"
      log "SCAN: $TARGET"
    else
      v_err "No target. Usage: scan 192.168.1.1"
    fi
    continue
  fi

  # ── MASSCAN ──────────────────────────────────────────────────
  if match "masscan"; then
    TARGET=$(extract_target)
    if [[ -n "$TARGET" ]]; then
      v_info "Masscan → $TARGET"
      sudo masscan "$TARGET" -p1-65535 --rate=1000
    else
      launch_tool masscan
    fi
    continue
  fi

  # ── RUSTSCAN ─────────────────────────────────────────────────
  if match "rustscan"; then
    TARGET=$(extract_target)
    v_info "RustScan → ${TARGET:-target}"
    if [[ -n "$TARGET" ]]; then
      launch_tool RustScan -- -a "$TARGET"
    else
      launch_tool RustScan
    fi
    continue
  fi

  # ── NIKTO ────────────────────────────────────────────────────
  if match "nikto"; then
    TARGET=$(extract_target)
    if [[ -n "$TARGET" ]]; then
      v_info "Nikto → $TARGET"
      nikto -h "$TARGET" 2>&1
    else
      ai_response "Short nikto usage guide"
    fi
    continue
  fi

  # ── GOBUSTER / DIRB ──────────────────────────────────────────
  if match "gobuster|dirb|directory.*brute|dir.*scan"; then
    TARGET=$(extract_target)
    if [[ -n "$TARGET" ]]; then
      v_info "Directory brute: $TARGET"
      if command -v gobuster &>/dev/null; then
        gobuster dir -u "$TARGET" -w /usr/share/wordlists/dirb/common.txt
      else
        launch_tool dirb "$TARGET"
      fi
    else
      ai_response "gobuster command for: $INPUT"
    fi
    continue
  fi

  # ── SQLMAP ───────────────────────────────────────────────────
  if match "sqlmap|sqli|sql.*inject"; then
    TARGET=$(extract_target)
    if [[ -n "$TARGET" ]]; then
      v_info "SQLmap → $TARGET"
      launch_tool sqlmap -u "$TARGET" --batch
    else
      ai_response "sqlmap command for: $INPUT"
    fi
    continue
  fi

  # ── XSSTRIKE ─────────────────────────────────────────────────
  if match "xsstrike|xss.*strike"; then
    TARGET=$(extract_target)
    v_info "XSStrike → ${TARGET:-url}"
    if [[ -n "$TARGET" ]]; then
      python3 "$ARSENAL_DIR/XSStrike/xsstrike.py" -u "$TARGET" 2>/dev/null \
        || launch_tool XSStrike -u "$TARGET"
    else
      launch_tool XSStrike
    fi
    continue
  fi

  # ── DALFOX ───────────────────────────────────────────────────
  if match "dalfox"; then
    TARGET=$(extract_target)
    v_info "Dalfox → ${TARGET:-url}"
    if [[ -n "$TARGET" ]]; then
      launch_tool dalfox url "$TARGET"
    else
      launch_tool dalfox
    fi
    continue
  fi

  # ── WIFITE ───────────────────────────────────────────────────
  if match "wifite|wifi.*attack|wireless.*attack"; then
    v_info "Launching Wifite..."
    if command -v wifite &>/dev/null; then
      sudo wifite
    else
      launch_tool wifite2
    fi
    continue
  fi

  # ── ONESHOT ──────────────────────────────────────────────────
  if match "oneshot|wps.*attack|pmkid"; then
    local IFACE
    IFACE=$(ip -o link show | awk '/wlan/{gsub(":",""); print $2; exit}')
    IFACE="${IFACE:-wlan0}"
    v_info "OneShot WPS → $IFACE"
    sudo python3 "$ARSENAL_DIR/OneShot/oneshot.py" -i "$IFACE" 2>/dev/null \
      || sudo python3 /usr/share/oneshot/oneshot.py -i "$IFACE" 2>/dev/null \
      || v_err "OneShot not found — arsenal → [35]"
    continue
  fi

  # ── WIFIPHISHER ──────────────────────────────────────────────
  if match "wifiphisher"; then
    v_info "Launching Wifiphisher..."
    launch_tool wifiphisher
    continue
  fi

  # ── WIFIPUMPKIN3 ─────────────────────────────────────────────
  if match "wifipumpkin|pumpkin3"; then
    v_info "Launching wifipumpkin3..."
    launch_tool wifipumpkin3
    continue
  fi

  # ── FLUXION ──────────────────────────────────────────────────
  if match "fluxion"; then
    v_info "Launching Fluxion..."
    launch_tool fluxion
    continue
  fi

  # ── AIRCRACK / AIRMON ────────────────────────────────────────
  if match "aircrack|airmon|airodump|monitor.*mode"; then
    v_info "Aircrack-ng guidance:"
    ai_response "aircrack-ng step-by-step for: $INPUT"
    continue
  fi

  # ── AMASS ────────────────────────────────────────────────────
  if match "amass"; then
    TARGET=$(extract_target)
    v_info "Amass → ${TARGET:-domain}"
    if [[ -n "$TARGET" ]]; then
      launch_tool amass enum -d "$TARGET"
    else
      launch_tool amass
    fi
    continue
  fi

  # ── SUBFINDER ────────────────────────────────────────────────
  if match "subfinder"; then
    TARGET=$(extract_target)
    v_info "Subfinder → ${TARGET:-domain}"
    if [[ -n "$TARGET" ]]; then
      launch_tool subfinder -d "$TARGET"
    else
      launch_tool subfinder
    fi
    continue
  fi

  # ── HTTPX ────────────────────────────────────────────────────
  if match "httpx"; then
    TARGET=$(extract_target)
    v_info "httpx → ${TARGET:-stdin}"
    if [[ -n "$TARGET" ]]; then
      echo "$TARGET" | launch_tool httpx
    else
      launch_tool httpx
    fi
    continue
  fi

  # ── SUBLIST3R ────────────────────────────────────────────────
  if match "sublist3r"; then
    TARGET=$(extract_target)
    v_info "Sublist3r → ${TARGET:-domain}"
    if [[ -n "$TARGET" ]]; then
      python3 "$ARSENAL_DIR/Sublist3r/sublist3r.py" -d "$TARGET" 2>/dev/null \
        || launch_tool Sublist3r -d "$TARGET"
    else
      launch_tool Sublist3r
    fi
    continue
  fi

  # ── THEHARVESTER ─────────────────────────────────────────────
  if match "theharvester|harvester"; then
    TARGET=$(extract_target)
    v_info "theHarvester → ${TARGET:-domain}"
    if [[ -n "$TARGET" ]]; then
      python3 "$ARSENAL_DIR/theHarvester/theHarvester.py" -d "$TARGET" -b all 2>/dev/null \
        || launch_tool theHarvester -d "$TARGET" -b all
    else
      launch_tool theHarvester
    fi
    continue
  fi

  # ── SPIDERFOOT ───────────────────────────────────────────────
  if match "spiderfoot"; then
    v_info "Launching SpiderFoot on http://127.0.0.1:5001"
    python3 "$ARSENAL_DIR/spiderfoot/sf.py" -l 127.0.0.1:5001 2>/dev/null \
      || launch_tool spiderfoot
    continue
  fi

  # ── HOLEHE ───────────────────────────────────────────────────
  if match "holehe"; then
    local email
    email=$(echo "$INPUT" | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | head -1)
    if [[ -n "$email" ]]; then
      v_info "Holehe → $email"
      launch_tool holehe "$email"
    else
      v_err "Provide an email: holehe user@example.com"
    fi
    continue
  fi

  # ── MAIGRET ──────────────────────────────────────────────────
  if match "maigret"; then
    v_info "Launching Maigret..."
    launch_tool maigret
    continue
  fi

  # ── RED_HAWK ─────────────────────────────────────────────────
  if match "red.?hawk|redhawk"; then
    v_info "Launching RED_HAWK..."
    php "$ARSENAL_DIR/RED_HAWK/rhawk.php" 2>/dev/null \
      || python3 "$ARSENAL_DIR/RED_HAWK/rhawk.py" 2>/dev/null \
      || launch_tool RED_HAWK
    continue
  fi

  # ── RECONDOG ─────────────────────────────────────────────────
  if match "recondog"; then
    v_info "Launching ReconDog..."
    python3 "$ARSENAL_DIR/ReconDog/dog.py" 2>/dev/null \
      || launch_tool ReconDog
    continue
  fi

  # ── CUPP ─────────────────────────────────────────────────────
  if match "cupp|wordlist.*gen|password.*list.*gen"; then
    v_info "Launching CUPP..."
    python3 "$ARSENAL_DIR/cupp/cupp.py" -i 2>/dev/null \
      || launch_tool cupp
    continue
  fi

  # ── HYDRA ────────────────────────────────────────────────────
  if match "hydra|brute.?force|crack.*password|password.*attack"; then
    v_info "Hydra guidance:"
    ai_response "hydra command for: $INPUT"
    continue
  fi

  # ── HASHCAT / JOHN ───────────────────────────────────────────
  if match "hashcat|john.*ripper|crack.*hash|hash.*crack"; then
    v_info "Hash cracking:"
    ai_response "hashcat or john command for: $INPUT"
    continue
  fi

  # ── METASPLOIT ───────────────────────────────────────────────
  if match "metasploit|msfconsole|meterpreter"; then
    if match "open|launch|start|run"; then
      v_info "Launching msfconsole..."
      msfconsole
    else
      v_info "Metasploit guidance:"
      ai_response "msfconsole steps for: $INPUT"
    fi
    continue
  fi

  # ── NETCAT ───────────────────────────────────────────────────
  if match "netcat| nc |reverse.*shell|bind.*shell"; then
    v_info "Netcat:"
    ai_response "netcat listener and connect side commands for: $INPUT"
    continue
  fi

  # ── TSHARK ───────────────────────────────────────────────────
  if match "tshark|packet.*capture|sniff|capture.*traffic"; then
    local IFACE
    IFACE=$(ip -o link show | awk '!/lo/{gsub(":",""); print $2; exit}')
    v_info "Capturing on ${IFACE:-eth0} (Ctrl+C to stop)"
    sudo tshark -i "${IFACE:-eth0}" 2>&1 | head -60
    continue
  fi

  # ── PING ─────────────────────────────────────────────────────
  if match "^ping[[:space:]]"; then
    TARGET=$(extract_target)
    if [[ -n "$TARGET" ]]; then
      v_info "Probing $TARGET..."
      ping -c 4 "$TARGET"
    else
      v_err "Usage: ping 192.168.1.1"
    fi
    continue
  fi

  # ── WHOIS ────────────────────────────────────────────────────
  if match "whois"; then
    TARGET=$(extract_target)
    if [[ -n "$TARGET" ]]; then
      v_info "WHOIS: $TARGET"
      whois "$TARGET" 2>&1 | head -40
    else
      v_err "Usage: whois example.com"
    fi
    continue
  fi

  # ── SOCIAL ENGINEER TOOLKIT ──────────────────────────────────
  if match "setoolkit|social.*engineer"; then
    v_info "Launching SET..."
    sudo setoolkit 2>/dev/null \
      || python3 "$ARSENAL_DIR/social-engineer-toolkit/se-toolkit.py" 2>/dev/null \
      || launch_tool SET
    continue
  fi

  # ── EVILGINX ─────────────────────────────────────────────────
  if match "evilginx"; then
    v_info "Launching Evilginx2..."
    launch_tool evilginx2
    continue
  fi

  # ── THEFATRAT ────────────────────────────────────────────────
  if match "fatrat|thefatrat"; then
    v_info "Launching TheFatRat..."
    launch_tool TheFatRat
    continue
  fi

  # ── VENOM ────────────────────────────────────────────────────
  if match "^venom[[:space:]]|^venom$"; then
    v_info "Launching Venom..."
    launch_tool venom
    continue
  fi

  # ── ANONSURF ─────────────────────────────────────────────────
  if match "anonsurf"; then
    v_info "AnonSurf..."
    sudo anonsurf start 2>/dev/null \
      || launch_tool kali-anonsurf start
    continue
  fi

  # ── GENERIC LAUNCHER — "open/launch/run/start <toolname>" ────
  # Catches any tool not covered above by name.
  if match "^(open|launch|run|start)[[:space:]]+"; then
    local tool_name
    tool_name=$(echo "$INPUT" | awk '{print tolower($2)}')
    case "$tool_name" in
      nmap)           sudo nmap ;;
      wireshark)
        if [[ -n "${DISPLAY:-}" ]]; then
          wireshark &>/dev/null &
        else
          v_err "No display. CLI: tshark"
        fi ;;
      burp|burpsuite)
        [[ -n "${DISPLAY:-}" ]] && burpsuite &>/dev/null & ;;
      chrome)
        [[ -n "${DISPLAY:-}" ]] && google-chrome &>/dev/null & ;;
      firefox)
        [[ -n "${DISPLAY:-}" ]] && firefox &>/dev/null & ;;
      msf|msfconsole) msfconsole ;;
      *)              launch_tool "$tool_name" ;;
    esac
    continue
  fi

  # ── CODING ───────────────────────────────────────────────────
  if match "python|write.*me|create.*script|make.*script|html|css|javascript|flask|django|bash.*script|code.*for|write.*a"; then
    v_info "Scripting mode..."
    ai_response "Write working code. Show full code block first, one sentence explanation after. Task: $INPUT"
    continue
  fi

  # ── GENERAL FALLBACK ─────────────────────────────────────────
  echo ""
  v_info "Processing..."
  ai_response "$INPUT"
  log "AI: $INPUT"

done
VIKINGSCRIPT

  chmod +x "$INSTALL_PATH"
  log_ok "VIKING CLI → $INSTALL_PATH"
}

# ════════════════════════════════════════════════════════════════
#  TMUX AUTO-SESSION
# ════════════════════════════════════════════════════════════════
configure_tmux() {
  log_step "6" "Configuring tmux auto-session..."
  local rc="$HOME/.bashrc"
  local marker="# VIKING-TMUX"
  grep -q "$marker" "$rc" 2>/dev/null && { log_ok "tmux already configured"; return; }
  cat >> "$rc" << 'TMUXCONF'

# VIKING-TMUX
if command -v tmux &>/dev/null && [[ -z "${TMUX:-}" ]]; then
  tmux has-session -t viking 2>/dev/null || tmux new-session -d -s viking
fi
TMUXCONF
  log_ok "tmux auto-session configured"
}

# ════════════════════════════════════════════════════════════════
#  INSTALL WIZARD
# ════════════════════════════════════════════════════════════════
run_install_wizard() {
  log_step "7" "Weapon Arsenal setup"
  echo ""
  echo -e "  ${B}${C}Select installation mode:${NC}\n"
  echo -e "  ${Y}[1]${NC}  VIKING CLI + AI only     (no extra tools)"
  echo -e "  ${Y}[2]${NC}  Pick tools from arsenal  (enter numbers)"
  echo -e "  ${RB}[3]${NC}  ${RB}WAR MODE${NC} — install all ${#ARSENAL[@]} tools"
  echo -e "  ${Y}[4]${NC}  Skip\n"
  echo -ne "  Choice [1-4]: "
  read -r choice

  case "$choice" in
    1) log_ok "Standard install — CLI + AI ready." ;;
    2)
      display_arsenal_table
      echo -e "  Enter tool numbers space-separated (e.g. ${C}1 3 7 28${NC}):"
      echo -ne "  > "
      read -r picks
      mkdir -p "$ARSENAL_DIR"
      for n in $picks; do
        install_tool "$n" || true
      done ;;
    3) war_mode_install ;;
    4) log_info "Skipping tool installation." ;;
    *) log_warn "Invalid choice — skipping." ;;
  esac
}

# ════════════════════════════════════════════════════════════════
#  COMPLETION BANNER
# ════════════════════════════════════════════════════════════════
show_completion() {
  echo ""
  echo -e "${B}${G}"
  echo "  ██████╗  ██████╗ ███╗   ██╗███████╗██╗"
  echo "  ██╔══██╗██╔═══██╗████╗  ██║██╔════╝██║"
  echo "  ██║  ██║██║   ██║██╔██╗ ██║█████╗  ██║"
  echo "  ██║  ██║██║   ██║██║╚██╗██║██╔══╝  ╚═╝"
  echo "  ██████╔╝╚██████╔╝██║ ╚████║███████╗██╗"
  echo "  ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝"
  echo -e "${NC}"
  echo "  ═══════════════════════════════════════════════"
  echo -e "${B}${Y}   ⚔  VIKING AI — Installation Complete  ⚔${NC}"
  echo "  ═══════════════════════════════════════════════"
  echo ""
  echo -e "  Launch:          ${C}viking${NC}"
  echo -e "  In tmux:         ${C}tmux new -s viking${NC}  then  ${C}viking${NC}"
  echo -e "  Detach tmux:     ${C}Ctrl+B then D${NC}"
  echo -e "  Reattach:        ${C}tmux attach -t viking${NC}"
  echo -e "  Browse tools:    inside viking → ${C}arsenal${NC}"
  echo -e "  Switch model:    inside viking → ${C}model${NC}"
  echo -e "  Logs:            ${D}$LOG_DIR${NC}"
  echo ""
  echo -e "  ${Y}The longship is ready. Type 'viking' to sail.  ⚔${NC}"
  echo ""
}

# ════════════════════════════════════════════════════════════════
#  MAIN — linear orchestrator
# ════════════════════════════════════════════════════════════════
main() {
  show_installer_banner
  preflight

  mkdir -p "$VIKING_DIR" "$ARSENAL_DIR" "$LOG_DIR"

  install_dependencies                  # step 1
  install_ollama                        # step 2
  pull_model "$DEFAULT_MODEL"           # step 3

  write_arsenal_registry                # step 4  — auto-generated from ARSENAL
  write_arsenal_menu                    # step 4b — sources registry at runtime

  write_viking_script                   # step 5
  configure_tmux                        # step 6

  printf 'VIKING_MODEL="%s"\n' "$DEFAULT_MODEL" > "$CONFIG_FILE"

  run_install_wizard                    # step 7
  show_completion
}

main "$@"
