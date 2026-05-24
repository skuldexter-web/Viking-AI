#!/bin/bash

# ================================================================
#  VIKING AI — Digital Longship Intelligence System
#  Local CLI Security Assistant for Kali Linux
#  License: MIT
# ================================================================

set -uo pipefail

# ════════════════════════════════════════════════════════════════
#  CONSTANTS  — change only here, propagates everywhere
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
readonly WAR_JOBS=4          # parallel git clones in War Mode

# ════════════════════════════════════════════════════════════════
#  COLORS  — short names for readability inside heredocs too
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
#  ARSENAL REGISTRY  — single source of truth
#  Format: "NAME|CATEGORY|GIT_URL|TYPE"
#  Types : git_python | git_go | git_generic
#  !! Add/remove tools HERE only — registry file is auto-generated !!
# ════════════════════════════════════════════════════════════════
declare -A ARSENAL

# ── Scanning & Recon ────────────────────────────────────────────
ARSENAL[01]="WebCheck|Scanning & Recon|https://github.com/X3RX3SSec/WebCheck.git|git_python"
ARSENAL[02]="DEATH_STAR|Scanning & Recon|https://github.com/Ringmast4r/DEATH_STAR.git|git_python"
ARSENAL[03]="Dracnmap|Scanning & Recon|https://github.com/screetsec/Dracnmap.git|git_python"
ARSENAL[04]="RED_HAWK|Scanning & Recon|https://github.com/Tuhinshubhra/RED_HAWK.git|git_python"
ARSENAL[05]="reconspider|Scanning & Recon|https://github.com/bhavsec/reconspider.git|git_python"
ARSENAL[06]="ReconDog|Scanning & Recon|https://github.com/s0md3v/ReconDog.git|git_python"
ARSENAL[07]="Striker|Scanning & Recon|https://github.com/s0md3v/Striker.git|git_python"
ARSENAL[08]="SecretFinder|Scanning & Recon|https://github.com/m4ll0k/SecretFinder.git|git_python"
ARSENAL[09]="rang3r|Scanning & Recon|https://github.com/floriankunushevci/rang3r.git|git_python"
ARSENAL[10]="Breacher|Scanning & Recon|https://github.com/s0md3v/Breacher.git|git_python"
ARSENAL[11]="theHarvester|Scanning & Recon|https://github.com/laramies/theHarvester.git|git_python"
ARSENAL[12]="spiderfoot|Scanning & Recon|https://github.com/smicallef/spiderfoot.git|git_python"

# ── Network Tools ───────────────────────────────────────────────
ARSENAL[13]="nmap|Network Tools|https://github.com/nmap/nmap.git|git_generic"
ARSENAL[14]="masscan|Network Tools|https://github.com/robertdavidgraham/masscan.git|git_generic"
ARSENAL[15]="RustScan|Network Tools|https://github.com/bee-san/RustScan.git|git_generic"
ARSENAL[16]="xerosploit|Network Tools|https://github.com/LionSec/xerosploit.git|git_python"
ARSENAL[17]="amass|Network Tools|https://github.com/owasp-amass/amass.git|git_go"
ARSENAL[18]="httpx|Network Tools|https://github.com/projectdiscovery/httpx.git|git_go"
ARSENAL[19]="subfinder|Network Tools|https://github.com/projectdiscovery/subfinder.git|git_go"

# ── XSS Tools ───────────────────────────────────────────────────
ARSENAL[20]="dalfox|XSS Tools|https://github.com/hahwul/dalfox.git|git_go"
ARSENAL[21]="XSS-LOADER|XSS Tools|https://github.com/capture0x/XSS-LOADER.git|git_python"
ARSENAL[22]="extended-xss-search|XSS Tools|https://github.com/Damian89/extended-xss-search.git|git_python"
ARSENAL[23]="XSpear|XSS Tools|https://github.com/hahwul/XSpear.git|git_generic"
ARSENAL[24]="XSSCon|XSS Tools|https://github.com/menkrep1337/XSSCon.git|git_python"
ARSENAL[25]="XanXSS|XSS Tools|https://github.com/Ekultek/XanXSS.git|git_python"
ARSENAL[26]="XSStrike|XSS Tools|https://github.com/s0md3v/XSStrike.git|git_python"
ARSENAL[27]="RVuln|XSS Tools|https://github.com/yangr0/RVuln.git|git_python"

# ── SQL Injection ───────────────────────────────────────────────
ARSENAL[28]="sqlmap|SQL Injection|https://github.com/sqlmapproject/sqlmap.git|git_python"
ARSENAL[29]="NoSQLMap|SQL Injection|https://github.com/codingo/NoSQLMap.git|git_python"
ARSENAL[30]="DSSS|SQL Injection|https://github.com/stamparm/DSSS.git|git_python"
ARSENAL[31]="explo|SQL Injection|https://github.com/telekom-security/explo.git|git_python"
ARSENAL[32]="Blisqy|SQL Injection|https://github.com/JohnTroony/Blisqy.git|git_python"
ARSENAL[33]="leviathan|SQL Injection|https://github.com/utkusen/leviathan.git|git_python"
ARSENAL[34]="sqlscan|SQL Injection|https://github.com/Cvar1984/sqlscan.git|git_python"

# ── WiFi Tools ──────────────────────────────────────────────────
ARSENAL[35]="OneShot|WiFi Tools|https://github.com/kimocoder/OneShot.git|git_python"
ARSENAL[36]="wifipumpkin3|WiFi Tools|https://github.com/P0cL4bs/wifipumpkin3.git|git_python"
ARSENAL[37]="pixiewps|WiFi Tools|https://github.com/wiire-a/pixiewps.git|git_generic"
ARSENAL[38]="bluepot|WiFi Tools|https://github.com/andrewmichaelsmith/bluepot.git|git_generic"
ARSENAL[39]="fluxion|WiFi Tools|https://github.com/FluxionNetwork/fluxion.git|git_generic"
ARSENAL[40]="wifiphisher|WiFi Tools|https://github.com/wifiphisher/wifiphisher.git|git_python"
ARSENAL[41]="wifite2|WiFi Tools|https://github.com/derv82/wifite2.git|git_python"
ARSENAL[42]="fakeap|WiFi Tools|https://github.com/Z4nzu/fakeap.git|git_python"

# ── Anonymity ───────────────────────────────────────────────────
ARSENAL[43]="kali-anonsurf|Anonymity|https://github.com/Und3rf10w/kali-anonsurf.git|git_generic"
ARSENAL[44]="multitor|Anonymity|https://github.com/trimstray/multitor.git|git_generic"

# ── OSINT ───────────────────────────────────────────────────────
ARSENAL[45]="holehe|OSINT|https://github.com/megadose/holehe.git|git_python"
ARSENAL[46]="maigret|OSINT|https://github.com/soxoj/maigret.git|git_python"
ARSENAL[47]="trufflehog|OSINT|https://github.com/trufflesecurity/trufflehog.git|git_go"
ARSENAL[48]="gitleaks|OSINT|https://github.com/gitleaks/gitleaks.git|git_go"
ARSENAL[49]="SMWYG|OSINT|https://github.com/Viralmaniar/SMWYG-Show-Me-What-You-Got.git|git_python"

# ── Wordlist ────────────────────────────────────────────────────
ARSENAL[50]="cupp|Wordlist|https://github.com/Mebus/cupp.git|git_python"
ARSENAL[51]="wlcreator|Wordlist|https://github.com/Z4nzu/wlcreator.git|git_python"
ARSENAL[52]="GoblinWordGenerator|Wordlist|https://github.com/UndeadSec/GoblinWordGenerator.git|git_python"

# ── Phishing ────────────────────────────────────────────────────
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

# ── Web Tools ───────────────────────────────────────────────────
ARSENAL[65]="dirb|Web Tools|https://gitlab.com/kalilinux/packages/dirb.git|git_generic"
ARSENAL[66]="takeover|Web Tools|https://github.com/edoardottt/takeover.git|git_go"
ARSENAL[67]="checkURL|Web Tools|https://github.com/UndeadSec/checkURL.git|git_python"
ARSENAL[68]="Sublist3r|Web Tools|https://github.com/aboul3la/Sublist3r.git|git_python"
ARSENAL[69]="web2attack|Web Tools|https://github.com/santatic/web2attack.git|git_python"

# ── Exploitation ────────────────────────────────────────────────
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
#  LOGGING HELPERS
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
#  INSTALLER BANNER  — thick block letters
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
#  WAR MODE BANNER  — thick full-red block letters
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
    tmux curl wget git \
    python3 python3-pip python3-venv \
    nmap tshark whois nikto \
    build-essential golang-go \
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
  # Wait for Ollama to become responsive (max ~15 s)
  local tries=5
  until ollama list &>/dev/null || (( --tries == 0 )); do sleep 3; done
  log_ok "Ollama service running"
}

pull_model() {
  local model="${1:-$DEFAULT_MODEL}"
  log_step "3" "Checking model: $model"
  if ollama list 2>/dev/null | awk '{print $1}' | grep -qx "$model"; then
    log_ok "Already present: $model"
  else
    log_info "Pulling $model — lightweight, won't take long..."
    ollama pull "$model" || log_warn "Pull failed — will retry on first use"
    log_ok "Model ready: $model"
  fi
}

# ════════════════════════════════════════════════════════════════
#  TOOL INSTALLER  — shared by installer, War Mode, and live menu
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
  # Accept "3" or "03" — normalise to zero-padded
  local key; key=$(printf "%02d" "$((10#$1))" 2>/dev/null) || key="$1"
  local entry="${ARSENAL[$key]:-}"
  [[ -z "$entry" ]] && { log_err "Tool #$key not in arsenal"; return 1; }

  IFS='|' read -r name category url itype <<< "$entry"
  local dest="$ARSENAL_DIR/$name"

  echo -e "  ${C}[${key}]${NC} $name  ${D}($category)${NC}"

  if [[ -d "$dest/.git" ]]; then
    git -C "$dest" pull -q 2>/dev/null || true
  else
    git clone --depth=1 -q "$url" "$dest" 2>/dev/null || {
      log_err "Clone failed: $name"; return 1
    }
  fi

  _post_install "$dest" "$itype"
  log_ok "$name → $dest"
}

# ════════════════════════════════════════════════════════════════
#  PROGRESS BAR
# ════════════════════════════════════════════════════════════════
_progress_bar() {
  local cur="$1" tot="$2" w=46
  local f=$(( cur * w / tot ))
  local e=$(( w - f ))
  printf "\r  ${RB}[${NC}${RB}%s${NC}${D}%s${NC}${RB}]${NC} %d/%d" \
    "$(printf '█%.0s' $(seq 1 "$f"))" \
    "$(printf '░%.0s' $(seq 1 "$e"))" \
    "$cur" "$tot"
}

# ════════════════════════════════════════════════════════════════
#  WAR MODE — throttled parallel installs
# ════════════════════════════════════════════════════════════════
war_mode_install() {
  show_war_banner
  mkdir -p "$ARSENAL_DIR" "$LOG_DIR"

  local keys=()
  while IFS= read -r k; do keys+=("$k"); done < <(
    printf '%s\n' "${!ARSENAL[@]}" | sort -n
  )
  local total=${#keys[@]} count=0 pids=() failed=()

  for key in "${keys[@]}"; do
    (( count++ ))
    IFS='|' read -r name _ _ _ <<< "${ARSENAL[$key]}"
    log_war "[$count/$total] ${RB}Deploying:${NC} $name"

    install_tool "$key" >> "$LOG_DIR/war_$(printf '%02d' "$count").log" 2>&1 &
    pids+=($!)

    # Throttle concurrency
    if (( ${#pids[@]} >= WAR_JOBS )); then
      wait "${pids[0]}" || failed+=("${keys[$((count - WAR_JOBS))]}")
      pids=("${pids[@]:1}")
    fi
    _progress_bar "$count" "$total"
  done

  # Drain remaining background jobs
  for pid in "${pids[@]}"; do wait "$pid" || true; done
  echo ""

  echo -e "\n${RB} ════════════════════════════════════════════════${NC}"
  echo -e "${RB}  WAR COMPLETE — $count / $total WEAPONS DEPLOYED  ⚔${NC}"
  echo -e "${RB} ════════════════════════════════════════════════${NC}"
  (( ${#failed[@]} > 0 )) && \
    echo -e "${Y}  Failed: ${failed[*]}\n  Logs → $LOG_DIR${NC}"
  echo ""
}

# ════════════════════════════════════════════════════════════════
#  ARSENAL TABLE  — shared display function (installer + menu)
# ════════════════════════════════════════════════════════════════
display_arsenal_table() {
  local current_cat=""
  echo ""
  echo -e "${B}${Y} ⚔  WAPENS ARSENAL  ⚔${NC}"
  echo -e " ══════════════════════════════════════════════════════"
  while IFS= read -r key; do
    IFS='|' read -r name category _ _ <<< "${ARSENAL[$key]}"
    if [[ "$category" != "$current_cat" ]]; then
      current_cat="$category"
      echo -e "\n${B}${M}  ── $category ──${NC}"
    fi
    local tag=""
    [[ -d "$ARSENAL_DIR/$name" ]] && tag="${G}[installed]${NC}"
    printf "  ${C}[%02d]${NC}  %-32s%b\n" "$key" "$name" "$tag"
  done < <(printf '%s\n' "${!ARSENAL[@]}" | sort -n)
  echo -e "\n ══════════════════════════════════════════════════════\n"
}

# ════════════════════════════════════════════════════════════════
#  WRITE REGISTRY  — auto-generated from ARSENAL array (no duplication)
# ════════════════════════════════════════════════════════════════
write_arsenal_registry() {
  log_step "4" "Generating arsenal registry..."
  {
    echo "#!/bin/bash"
    echo "# Auto-generated by install.sh — edit ARSENAL array in install.sh only"
    echo "declare -A TOOL_REGISTRY"
    for key in $(printf '%s\n' "${!ARSENAL[@]}" | sort -n); do
      printf 'TOOL_REGISTRY[%02d]="%s"\n' "$key" "${ARSENAL[$key]}"
    done
  } > "$REGISTRY_FILE"
  chmod +x "$REGISTRY_FILE"
  log_ok "Registry → $REGISTRY_FILE"
}

# ════════════════════════════════════════════════════════════════
#  WRITE ARSENAL MENU SCRIPT
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

# ── Post-install handler ──────────────────────────────────────
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

# ── Install single tool ───────────────────────────────────────
install_tool() {
  local key; key=$(printf "%02d" "$((10#$1))" 2>/dev/null) || key="$1"
  local entry="${TOOL_REGISTRY[$key]:-}"
  [[ -z "$entry" ]] && log_err "Tool #$key not found" && return 1

  IFS='|' read -r name category url itype <<< "$entry"
  local dest="$ARSENAL_DIR/$name"
  echo -e "  ${C}[$key]${NC} $name  ${D}($category)${NC}"

  if [[ -d "$dest/.git" ]]; then
    git -C "$dest" pull -q 2>/dev/null || true
  else
    git clone --depth=1 -q "$url" "$dest" 2>/dev/null || {
      log_err "Clone failed: $name"; return 1
    }
  fi
  _post_install "$dest" "$itype"
  log_ok "$name → $dest"
}

# ── Progress bar ──────────────────────────────────────────────
_progress_bar() {
  local cur="$1" tot="$2" w=46
  local f=$(( cur * w / tot )) e=$(( w - cur * w / tot ))
  printf "\r  ${RB}[${NC}${RB}%s${NC}${D}%s${NC}${RB}]${NC} %d/%d" \
    "$(printf '█%.0s' $(seq 1 "$f"))" \
    "$(printf '░%.0s' $(seq 1 "$e"))" \
    "$cur" "$tot"
}

# ── War Mode banner ───────────────────────────────────────────
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

# ── War Mode install ──────────────────────────────────────────
war_mode() {
  war_banner
  mkdir -p "$ARSENAL_DIR" "$LOG_DIR"
  local keys=()
  while IFS= read -r k; do keys+=("$k"); done < <(
    printf '%s\n' "${!TOOL_REGISTRY[@]}" | sort -n
  )
  local total=${#keys[@]} count=0 pids=() failed=()
  for key in "${keys[@]}"; do
    (( count++ ))
    IFS='|' read -r name _ _ _ <<< "${TOOL_REGISTRY[$key]}"
    log_war "[$count/$total] ${RB}Deploying:${NC} $name"
    install_tool "$key" >> "$LOG_DIR/war_$count.log" 2>&1 &
    pids+=($!)
    if (( ${#pids[@]} >= WAR_JOBS )); then
      wait "${pids[0]}" || failed+=("${keys[$((count - WAR_JOBS))]}")
      pids=("${pids[@]:1}")
    fi
    _progress_bar "$count" "$total"
  done
  for pid in "${pids[@]}"; do wait "$pid" || true; done
  echo ""
  echo -e "\n${RB} ════════════════════════════════════════════${NC}"
  echo -e "${RB}  WAR COMPLETE — $count WEAPONS DEPLOYED  ⚔${NC}"
  echo -e "${RB} ════════════════════════════════════════════${NC}"
  (( ${#failed[@]} > 0 )) && echo -e "${Y}  Failed: ${failed[*]}${NC}"
  echo ""
}

# ── Arsenal display ───────────────────────────────────────────
show_arsenal() {
  local current_cat=""
  echo ""
  echo -e "${B}${Y} ⚔  WAPENS ARSENAL  ⚔${NC}"
  echo -e " ══════════════════════════════════════════════════════"
  while IFS= read -r key; do
    IFS='|' read -r name category _ _ <<< "${TOOL_REGISTRY[$key]}"
    if [[ "$category" != "$current_cat" ]]; then
      current_cat="$category"
      echo -e "\n${B}${M}  ── $category ──${NC}"
    fi
    local tag=""
    [[ -d "$ARSENAL_DIR/$name" ]] && tag="${G}[installed]${NC}"
    printf "  ${C}[%02d]${NC}  %-32s%b\n" "$key" "$name" "$tag"
  done < <(printf '%s\n' "${!TOOL_REGISTRY[@]}" | sort -n)
  echo -e "\n ══════════════════════════════════════════════════════"
  echo -e "\n  ${C}number${NC} → install  |  ${RB}WAR${NC} → all tools  |  ${Y}back${NC} → return\n"

  while true; do
    echo -ne "${Y}arsenal> ${NC}"
    read -r choice
    case "${choice,,}" in
      war)          war_mode; show_arsenal; return ;;
      back|exit|q)  break ;;
      ''|*[!0-9]*)  echo -e "${R}Enter a number, WAR, or back.${NC}" ;;
      *)            install_tool "$choice" ;;
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
#  Optimised for lightweight models (tinyllama, llama3.2:3b, qwen2.5:3b)
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

# ── Paths ────────────────────────────────────────────────────────
readonly VIKING_DIR="/opt/viking"
readonly ARSENAL_DIR="$VIKING_DIR/arsenal"
readonly CONFIG_FILE="$VIKING_DIR/config"
readonly LOGFILE="$HOME/.viking_history.log"

[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
MODEL="${VIKING_MODEL:-tinyllama}"

# ── Colors ───────────────────────────────────────────────────────
R='\033[0;31m'; RB='\033[1;31m'; G='\033[0;32m'; C='\033[0;36m'
Y='\033[1;33m'; M='\033[0;35m'; B='\033[1m'; D='\033[2m'; NC='\033[0m'

# ── Available lightweight models ─────────────────────────────────
readonly -a AVAILABLE_MODELS=(
  "tinyllama"       # default — fastest, ~600 MB, great on any machine
  "llama3.2:3b"     # better reasoning, ~2 GB RAM
  "qwen2.5:3b"      # strong coding + security context, ~2 GB RAM
)

# ── Prompt strategy — few-shot conversation history ──────────────
# tinyllama (1.1B) ignores abstract rules but reliably mimics
# patterns it sees in prior turns. We inject a short fake
# conversation as assistant messages so the model learns the
# exact tone and format by example, not instruction.
# System prompt is kept to one sentence — small models saturate
# quickly and extra rules make them hallucinate format tokens.

readonly SYSTEM_PROMPT='You are VIKING, a sharp cybersecurity assistant on Kali Linux. You give short, direct answers. No filler words. No fake format labels.'

# Few-shot examples injected as real message history.
# Each pair teaches one behaviour: greeting, command format, analysis.
# Stored as a reusable JSON fragment so viking_think() can prepend it.
readonly FEW_SHOT_MESSAGES='
  {"role":"user",      "content":"hey how are you"},
  {"role":"assistant", "content":"Ready to raid. What is the target?"},
  {"role":"user",      "content":"how do I scan open ports on 192.168.1.1"},
  {"role":"assistant", "content":"COMMAND: nmap -sV --open -T4 192.168.1.1\nEXPLANATION: Detects open ports and service versions.\nOUTPUT: List of open ports with service names and versions."},
  {"role":"user",      "content":"write a python port scanner"},
  {"role":"assistant", "content":"import socket\n\ndef scan(host, ports):\n    for port in ports:\n        s = socket.socket()\n        s.settimeout(0.5)\n        if s.connect_ex((host, port)) == 0:\n            print(f\"[OPEN] {port}\")\n        s.close()\n\nscan(\"192.168.1.1\", range(1, 1025))\n\nRuns a TCP connect scan. Adjust timeout for speed vs accuracy."},
  {"role":"user",      "content":"what is sqlmap used for"},
  {"role":"assistant", "content":"Automated SQL injection tool. Detects and exploits SQLi vulnerabilities in web apps.\nCOMMAND: sqlmap -u \"http://target.com/page?id=1\" --dbs\nEXPLANATION: Tests the id parameter and lists databases if vulnerable.\nOUTPUT: Database names if injection succeeds, else no vulnerability found."},'

# ── Core helpers ──────────────────────────────────────────────────
readonly OLLAMA_API="http://localhost:11434/api/chat"

log()         { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOGFILE"; }
v_say()       { echo -e "${Y}⚔  VIKING:${NC} $1"; }
v_info()      { echo -e "${C}[VIKING]${NC} $1"; }
v_err()       { echo -e "${R}[VIKING]${NC} $*"; }
save_config() { echo "VIKING_MODEL=\"$MODEL\"" > "$CONFIG_FILE"; }

# ── json_escape — safely escapes a string for JSON ───────────────
json_escape() {
  printf '%s' "$1" | python3 -c \
    'import sys,json; print(json.dumps(sys.stdin.read()), end="")'
}

# ── viking_think — few-shot REST API with streaming ──────────────
# Builds a messages array:  system → few-shot examples → user query
# The model sees concrete examples and mimics them instead of
# trying to parse abstract rules it's too small to follow.
# stream:true means tokens print immediately — no wait for full reply.
viking_think() {
  local prompt="$*"
  local sys_escaped user_escaped
  sys_escaped=$(json_escape "$SYSTEM_PROMPT")
  user_escaped=$(json_escape "$prompt")

  local payload
  payload=$(printf '{"model":"%s","stream":true,"options":{"temperature":0.4,"num_predict":400},"messages":[{"role":"system","content":%s},%s{"role":"user","content":%s}]}' \
    "$MODEL" \
    "$sys_escaped" \
    "$FEW_SHOT_MESSAGES" \
    "$user_escaped")

  curl -sS --no-buffer \
    -H "Content-Type: application/json" \
    -d "$payload" \
    "$OLLAMA_API" 2>/dev/null \
  | python3 -c "
import sys, json
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        d = json.loads(line)
        t = d.get('message', {}).get('content', '')
        if t:
            print(t, end='', flush=True)
    except Exception:
        pass
print()
"
}

# ── warm_model — pre-loads model into memory on startup ──────────
# Fires a silent background request so the first real question
# hits a hot model instead of a cold load.
warm_model() {
  curl -sS -o /dev/null \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"$MODEL\",\"stream\":false,\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}],\"options\":{\"temperature\":0.4,\"num_predict\":1}}" \
    "$OLLAMA_API" &
}

# ── Input helpers ─────────────────────────────────────────────────
match()          { echo "$INPUT" | grep -iEq "$1"; }
extract_target() {
  echo "$INPUT" | grep -oE \
    '([0-9]{1,3}\.){3}[0-9]{1,3}|https?://[^ ]+|[a-zA-Z0-9._-]+\.[a-zA-Z]{2,}' \
    | head -1
}

# ════════════════════════════════════════════════════════════════
#  BANNER — thick block letters + Viking ship
# ════════════════════════════════════════════════════════════════
show_banner() {
  clear
  echo -e "${D}${G}"
  echo "                                         |    |    |"
  echo "                                        )_)  )_)  )_)"
  echo "                                       )___))___))___)\  "
  echo "                                      )____)____)_____)\  \ "
  echo "                                    _____|____|____|____\  \  \ __"
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
#  HELP MENU
# ════════════════════════════════════════════════════════════════
show_help() {
  echo ""
  echo -e "${B}${Y} ⚔  VIKING COMMAND REFERENCE  ⚔${NC}"
  echo -e " ════════════════════════════════\n"
  # Section format: "TITLE:cmd≡desc:cmd≡desc"
  local -a sections=(
    "SCANNING & RECON:scan <ip/url>≡nmap scan + AI analysis:ping <ip>≡probe target:whois <domain>≡WHOIS lookup:nikto <url>≡web vuln scan"
    "WIRELESS:wifite≡wireless attack suite:oneshot≡WPS/PMKID attack:airmon≡aircrack-ng guidance"
    "WEB & EXPLOITATION:gobuster <url>≡directory brute force:sqlmap <url>≡SQL injection:metasploit≡msfconsole guidance:hydra≡brute force:netcat≡shell/listener help"
    "NETWORK & TRAFFIC:tshark≡live packet capture:hashcat / john≡hash cracking"
    "CODING:write python ...≡Python code:make html ...≡HTML/CSS/JS:bash script ...≡Bash scripting"
    "ARSENAL & MODEL:arsenal≡browse & install 79 tools:model≡list & switch AI models:model <name>≡quick switch"
    "SYSTEM:help≡this menu:history≡session log:banner≡redraw banner:quit / exit≡leave VIKING"
  )
  for section in "${sections[@]}"; do
    local title="${section%%:*}" rest="${section#*:}"
    echo -e " ${C}${title}${NC}"
    IFS=':' read -ra cmds <<< "$rest"
    for cmd in "${cmds[@]}"; do
      printf "   %-28s — %s\n" "${cmd%%≡*}" "${cmd##*≡}"
    done
    echo ""
  done
}

# ════════════════════════════════════════════════════════════════
#  MODEL SWITCHER — 3 light models only
# ════════════════════════════════════════════════════════════════
show_models() {
  local installed_list; installed_list=$(ollama list 2>/dev/null | awk '{print $1}')

  echo ""
  echo -e "${B}${Y} ⚔  LIGHT MODELS  ⚔${NC}"
  echo -e " ═══════════════════════════════════\n"

  local i=1
  for m in "${AVAILABLE_MODELS[@]}"; do
    local active="" inst=""
    [[ "$m" == "$MODEL" ]] && active="${G} ← active${NC}"
    echo "$installed_list" | grep -qx "$m" && inst="${D}[installed]${NC}"
    printf " ${C}[%d]${NC}  %-20s%b %b\n" "$i" "$m" "$active" "$inst"
    (( i++ ))
  done

  echo -e "\n ${D}All models run under 3 GB RAM.${NC}"
  echo -e " Number, model name, or ${Y}back${NC} to cancel.\n"

  while true; do
    echo -ne "${Y}model> ${NC}"
    read -r choice
    case "${choice,,}" in
      back|exit|'') break ;;
      *[!0-9]*)
        MODEL="$choice"; save_config
        v_say "Switched to: $MODEL"; break ;;
      *)
        local idx=$(( choice - 1 ))
        if (( idx >= 0 && idx < ${#AVAILABLE_MODELS[@]} )); then
          MODEL="${AVAILABLE_MODELS[$idx]}"; save_config
          v_say "Pulling: $MODEL..."
          ollama pull "$MODEL" 2>/dev/null || true
          v_say "Active: $MODEL"; break
        else
          v_err "Invalid — enter 1, 2, 3, or back."
        fi ;;
    esac
  done
}

# ════════════════════════════════════════════════════════════════
#  MAIN LOOP
# ════════════════════════════════════════════════════════════════
show_banner
warm_model   # silently pre-loads model into memory in background

while true; do
  echo -ne "${Y}You: ${NC}"
  read -r INPUT || break
  [[ -z "$INPUT" ]] && continue
  log "USER: $INPUT"

  # ── Built-in commands (exact match first, fastest path) ──────
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
    MODEL="${BASH_REMATCH[1]}"; save_config
    v_say "Model → $MODEL"; continue
  fi

  # ── NMAP SCAN ─────────────────────────────────────────────────
  if match "^scan|nmap"; then
    TARGET=$(extract_target)
    if [[ -n "$TARGET" ]]; then
      v_info "Scouting: $TARGET"; echo ""
      RESULT=$(sudo nmap -sV --open -T4 "$TARGET" 2>&1)
      echo "$RESULT"; echo ""
      v_info "Compiling scouting report..."; echo ""
      echo -ne "${G}"
      # Feed trimmed output — tiny models have small context windows
      viking_think "VIKING Scouting Report. Nmap output below. List open ports, services, risk level, next commands. Keep it short.
---
${RESULT:0:2000}"
      echo -e "${NC}"
      log "SCAN: $TARGET"
    else
      v_err "No target found. Usage: scan 192.168.1.1"
    fi
    continue
  fi

  # ── TSHARK ───────────────────────────────────────────────────
  if match "tshark|packet capture|sniff|capture traffic"; then
    IFACE=$(ip -o link show | awk -F': ' '!/lo/{print $2; exit}')
    v_info "Capturing on ${IFACE} (Ctrl+C to stop)"
    sudo tshark -i "$IFACE" 2>&1 | head -60
    continue
  fi

  # ── WIFITE ───────────────────────────────────────────────────
  if match "wifite|wifi attack|wireless attack"; then
    v_info "Launching Wifite..."; sudo wifite; continue
  fi

  # ── ONESHOT ──────────────────────────────────────────────────
  if match "oneshot|wps attack|pmkid"; then
    IFACE=$(ip -o link show | awk '/wlan/{print $2; exit}' | tr -d ':')
    v_info "OneShot WPS attack on ${IFACE:-wlan0}"
    sudo python3 "$ARSENAL_DIR/OneShot/oneshot.py" -i "$IFACE" 2>/dev/null \
      || sudo python3 /usr/share/oneshot/oneshot.py  -i "$IFACE" 2>/dev/null \
      || v_err "OneShot not installed — run: arsenal → [35]"
    continue
  fi

  # ── NIKTO ────────────────────────────────────────────────────
  if match "nikto|web vuln|web scan"; then
    TARGET=$(extract_target)
    if [[ -n "$TARGET" ]]; then
      v_info "Nikto → $TARGET"; nikto -h "$TARGET" 2>&1
    else
      viking_think "Short nikto usage guide for: $INPUT"
    fi
    continue
  fi

  # ── GOBUSTER / DIRB ──────────────────────────────────────────
  if match "gobuster|dirb|directory scan|directory brute"; then
    v_info "Directory assault:"; echo ""
    viking_think "Exact gobuster or dirb command with wordlist path and key flags for: $INPUT"
    continue
  fi

  # ── SQLMAP ───────────────────────────────────────────────────
  if match "sqlmap|sql injection|sqli"; then
    v_info "SQL injection raid:"; echo ""
    viking_think "Exact sqlmap command with --risk --level --tamper flags for: $INPUT"
    continue
  fi

  # ── METASPLOIT ───────────────────────────────────────────────
  if match "metasploit|msfconsole|meterpreter|exploit|payload"; then
    v_info "Metasploit siege:"; echo ""
    viking_think "Exact msfconsole steps: search, use, set options, run for: $INPUT"
    continue
  fi

  # ── HYDRA ────────────────────────────────────────────────────
  if match "hydra|brute.?force|crack password|password attack"; then
    v_info "Brute force:"; echo ""
    viking_think "Exact hydra command with flags and wordlist path for: $INPUT"
    continue
  fi

  # ── HASHCAT / JOHN ───────────────────────────────────────────
  if match "hashcat|john the ripper|crack hash|hash crack"; then
    v_info "Hash cracking:"; echo ""
    viking_think "Exact hashcat or john command with hash type and attack mode for: $INPUT"
    continue
  fi

  # ── NETCAT ───────────────────────────────────────────────────
  if match "netcat|reverse shell|bind shell| nc "; then
    v_info "Netcat:"; echo ""
    viking_think "Exact netcat commands for both listener side and connect side for: $INPUT"
    continue
  fi

  # ── PING ─────────────────────────────────────────────────────
  if match "^ping"; then
    TARGET=$(extract_target)
    [[ -n "$TARGET" ]] && { v_info "Probing $TARGET..."; ping -c 4 "$TARGET"; }
    continue
  fi

  # ── WHOIS ────────────────────────────────────────────────────
  if match "whois|domain info|domain lookup"; then
    TARGET=$(extract_target)
    [[ -n "$TARGET" ]] && { v_info "WHOIS: $TARGET"; whois "$TARGET" 2>&1 | head -40; }
    continue
  fi

  # ── AIRCRACK ─────────────────────────────────────────────────
  if match "aircrack|airmon|airodump|monitor mode"; then
    v_info "Aircrack-ng guidance:"; echo ""
    viking_think "Step-by-step aircrack-ng commands with explanations for: $INPUT"
    continue
  fi

  # ── GUI APPS ─────────────────────────────────────────────────
  declare -A _GUI=([chrome]="google-chrome" [firefox]="firefox"
                   [wireshark]="wireshark"  [burpsuite]="burpsuite" [burp]="burpsuite")
  for _app in "${!_GUI[@]}"; do
    if match "open $_app|launch $_app|start $_app"; then
      if [[ -n "${DISPLAY:-}" ]]; then
        v_info "Launching ${_GUI[$_app]}..."
        "${_GUI[$_app]}" &>/dev/null &
      else
        v_err "No display (SSH). X11: ssh -X user@$(hostname -I | awk '{print $1}')"
        [[ "$_app" == "wireshark" ]] && echo "  CLI alt: sudo tshark -i eth0"
      fi
      unset _GUI; continue 2
    fi
  done
  unset _GUI

  # ── CODING ───────────────────────────────────────────────────
  if match "python|write me|create a script|make a script|html|css|javascript| js |flask|django|bash script|code for|write a"; then
    v_info "Scripting mode..."; echo ""
    viking_think "Full working commented code first, one short explanation after. Task: $INPUT"
    continue
  fi

  # ── GENERAL FALLBACK ─────────────────────────────────────────
  echo ""; v_info "Processing..."; echo ""
  echo -ne "${G}"
  viking_think "Tactical answer. COMMAND/EXPLANATION/OUTPUT format for tool tasks. Be brief. Question: $INPUT"
  echo -e "${NC}"
  log "USER: $INPUT"

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
  local rc="/root/.bashrc" marker="# VIKING-TMUX"
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
  echo -e " ${B}${C}Select installation mode:${NC}\n"
  echo -e " ${Y}[1]${NC}  VIKING CLI + AI only     (no extra tools)"
  echo -e " ${Y}[2]${NC}  Pick tools from arsenal  (enter numbers)"
  echo -e " ${RB}[3]${NC}  ${RB}WAR MODE${NC} — install all ${#ARSENAL[@]} tools in parallel"
  echo -e " ${Y}[4]${NC}  Skip\n"
  echo -ne " Choice [1-4]: "
  read -r choice

  case "$choice" in
    1) log_ok "Standard install — CLI + AI ready." ;;
    2)
      display_arsenal_table
      echo -e " Tool numbers, space-separated (e.g. ${C}1 3 7 28${NC}):"
      echo -ne " > "; read -r picks
      mkdir -p "$ARSENAL_DIR"
      for n in $picks; do install_tool "$n" || true; done ;;
    3) war_mode_install ;;
    4) log_info "Skipping tool installation." ;;
    *) log_warn "Invalid choice — skipping." ;;
  esac
}

# ════════════════════════════════════════════════════════════════
#  COMPLETION BANNER  — thick block letter finish
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
#  MAIN  — linear orchestrator
# ════════════════════════════════════════════════════════════════
main() {
  show_installer_banner
  preflight

  mkdir -p "$VIKING_DIR" "$ARSENAL_DIR" "$LOG_DIR"

  install_dependencies          # step 1
  install_ollama                # step 2
  pull_model "$DEFAULT_MODEL"   # step 3 — tinyllama, fast pull

  write_arsenal_registry        # step 4  — generated from ARSENAL array
  write_arsenal_menu            # step 4b — sources the registry at runtime

  write_viking_script           # step 5
  configure_tmux                # step 6

  echo "VIKING_MODEL=\"$DEFAULT_MODEL\"" > "$CONFIG_FILE"

  run_install_wizard            # step 7 — choose tools
  show_completion
}

main "$@"
