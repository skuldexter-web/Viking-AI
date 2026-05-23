#!/bin/bash

# ================================================================
#   VIKING AI — Local CLI Security Assistant
#   License: MIT
# ================================================================

# ── Strict mode ─────────────────────────────────────────────────
set -euo pipefail

# ================================================================
#   COLORS & STYLES
# ================================================================
RED='\033[0;31m'
BRED='\033[1;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ================================================================
#   GLOBAL CONFIG
# ================================================================
INSTALL_PATH="/usr/local/bin/viking"
DEFAULT_MODEL="gemma3:1b"
VIKING_DIR="/opt/viking"
ARSENAL_DIR="$VIKING_DIR/arsenal"
LOG_DIR="$VIKING_DIR/logs"
CONFIG_FILE="$VIKING_DIR/config"

# ================================================================
#   WEAPON ARSENAL — Categorized Tool Registry
#   Format: ["KEY"]="NAME|CATEGORY|URL|INSTALL_TYPE"
#   INSTALL_TYPE: git_python | git_go | git_generic | package
# ================================================================
declare -A ARSENAL

# ── Scanning & Recon (01–12) ────────────────────────────────────
ARSENAL["01"]="WebCheck|Scanning & Recon|https://github.com/X3RX3SSec/WebCheck.git|git_python"
ARSENAL["02"]="DEATH_STAR|Scanning & Recon|https://github.com/Ringmast4r/DEATH_STAR.git|git_python"
ARSENAL["03"]="Dracnmap|Scanning & Recon|https://github.com/screetsec/Dracnmap.git|git_python"
ARSENAL["04"]="RED_HAWK|Scanning & Recon|https://github.com/Tuhinshubhra/RED_HAWK.git|git_python"
ARSENAL["05"]="reconspider|Scanning & Recon|https://github.com/bhavsec/reconspider.git|git_python"
ARSENAL["06"]="ReconDog|Scanning & Recon|https://github.com/s0md3v/ReconDog.git|git_python"
ARSENAL["07"]="Striker|Scanning & Recon|https://github.com/s0md3v/Striker.git|git_python"
ARSENAL["08"]="SecretFinder|Scanning & Recon|https://github.com/m4ll0k/SecretFinder.git|git_python"
ARSENAL["09"]="rang3r|Scanning & Recon|https://github.com/floriankunushevci/rang3r.git|git_python"
ARSENAL["10"]="Breacher|Scanning & Recon|https://github.com/s0md3v/Breacher.git|git_python"
ARSENAL["11"]="theHarvester|Scanning & Recon|https://github.com/laramies/theHarvester.git|git_python"
ARSENAL["12"]="spiderfoot|Scanning & Recon|https://github.com/smicallef/spiderfoot.git|git_python"

# ── Network Tools (13–19) ───────────────────────────────────────
ARSENAL["13"]="nmap|Network Tools|https://github.com/nmap/nmap.git|git_generic"
ARSENAL["14"]="masscan|Network Tools|https://github.com/robertdavidgraham/masscan.git|git_generic"
ARSENAL["15"]="RustScan|Network Tools|https://github.com/bee-san/RustScan.git|git_generic"
ARSENAL["16"]="xerosploit|Network Tools|https://github.com/LionSec/xerosploit.git|git_python"
ARSENAL["17"]="amass|Network Tools|https://github.com/owasp-amass/amass.git|git_go"
ARSENAL["18"]="httpx|Network Tools|https://github.com/projectdiscovery/httpx.git|git_go"
ARSENAL["19"]="subfinder|Network Tools|https://github.com/projectdiscovery/subfinder.git|git_go"

# ── XSS Tools (20–28) ──────────────────────────────────────────
ARSENAL["20"]="dalfox|XSS Tools|https://github.com/hahwul/dalfox.git|git_go"
ARSENAL["21"]="XSS-LOADER|XSS Tools|https://github.com/capture0x/XSS-LOADER.git|git_python"
ARSENAL["22"]="extended-xss-search|XSS Tools|https://github.com/Damian89/extended-xss-search.git|git_python"
ARSENAL["23"]="XSpear|XSS Tools|https://github.com/hahwul/XSpear.git|git_generic"
ARSENAL["24"]="XSSCon|XSS Tools|https://github.com/menkrep1337/XSSCon.git|git_python"
ARSENAL["25"]="XanXSS|XSS Tools|https://github.com/Ekultek/XanXSS.git|git_python"
ARSENAL["26"]="XSStrike|XSS Tools|https://github.com/s0md3v/XSStrike.git|git_python"
ARSENAL["27"]="RVuln|XSS Tools|https://github.com/yangr0/RVuln.git|git_python"

# ── SQL Injection (28–34) ───────────────────────────────────────
ARSENAL["28"]="sqlmap|SQL Injection|https://github.com/sqlmapproject/sqlmap.git|git_python"
ARSENAL["29"]="NoSQLMap|SQL Injection|https://github.com/codingo/NoSQLMap.git|git_python"
ARSENAL["30"]="DSSS|SQL Injection|https://github.com/stamparm/DSSS.git|git_python"
ARSENAL["31"]="explo|SQL Injection|https://github.com/telekom-security/explo.git|git_python"
ARSENAL["32"]="Blisqy|SQL Injection|https://github.com/JohnTroony/Blisqy.git|git_python"
ARSENAL["33"]="leviathan|SQL Injection|https://github.com/utkusen/leviathan.git|git_python"
ARSENAL["34"]="sqlscan|SQL Injection|https://github.com/Cvar1984/sqlscan.git|git_python"

# ── WiFi Tools (35–41) ─────────────────────────────────────────
ARSENAL["35"]="OneShot|WiFi Tools|https://github.com/kimocoder/OneShot.git|git_python"
ARSENAL["36"]="wifipumpkin3|WiFi Tools|https://github.com/P0cL4bs/wifipumpkin3.git|git_python"
ARSENAL["37"]="pixiewps|WiFi Tools|https://github.com/wiire-a/pixiewps.git|git_generic"
ARSENAL["38"]="bluepot|WiFi Tools|https://github.com/andrewmichaelsmith/bluepot.git|git_generic"
ARSENAL["39"]="fluxion|WiFi Tools|https://github.com/FluxionNetwork/fluxion.git|git_generic"
ARSENAL["40"]="wifiphisher|WiFi Tools|https://github.com/wifiphisher/wifiphisher.git|git_python"
ARSENAL["41"]="wifite2|WiFi Tools|https://github.com/derv82/wifite2.git|git_python"
ARSENAL["42"]="fakeap|WiFi Tools|https://github.com/Z4nzu/fakeap.git|git_python"

# ── Anonymity & Privacy (43–44) ────────────────────────────────
ARSENAL["43"]="kali-anonsurf|Anonymity|https://github.com/Und3rf10w/kali-anonsurf.git|git_generic"
ARSENAL["44"]="multitor|Anonymity|https://github.com/trimstray/multitor.git|git_generic"

# ── OSINT & Social (45–52) ─────────────────────────────────────
ARSENAL["45"]="holehe|OSINT|https://github.com/megadose/holehe.git|git_python"
ARSENAL["46"]="maigret|OSINT|https://github.com/soxoj/maigret.git|git_python"
ARSENAL["47"]="trufflehog|OSINT|https://github.com/trufflesecurity/trufflehog.git|git_go"
ARSENAL["48"]="gitleaks|OSINT|https://github.com/gitleaks/gitleaks.git|git_go"
ARSENAL["49"]="SMWYG|OSINT|https://github.com/Viralmaniar/SMWYG-Show-Me-What-You-Got.git|git_python"

# ── Wordlist & Password (50–52) ────────────────────────────────
ARSENAL["50"]="cupp|Wordlist|https://github.com/Mebus/cupp.git|git_python"
ARSENAL["51"]="wlcreator|Wordlist|https://github.com/Z4nzu/wlcreator.git|git_python"
ARSENAL["52"]="GoblinWordGenerator|Wordlist|https://github.com/UndeadSec/GoblinWordGenerator.git|git_python"

# ── Phishing & Social Engineering (53–64) ──────────────────────
ARSENAL["53"]="autophisher|Phishing|https://github.com/CodingRanjith/autophisher.git|git_python"
ARSENAL["54"]="AdvPhishing|Phishing|https://github.com/Ignitetch/AdvPhishing.git|git_python"
ARSENAL["55"]="SET|Phishing|https://github.com/trustedsec/social-engineer-toolkit.git|git_python"
ARSENAL["56"]="SocialFish|Phishing|https://github.com/UndeadSec/SocialFish.git|git_python"
ARSENAL["57"]="evilginx2|Phishing|https://github.com/kgretzky/evilginx2.git|git_go"
ARSENAL["58"]="I-See-You|Phishing|https://github.com/Viralmaniar/I-See-You.git|git_python"
ARSENAL["59"]="saycheese|Phishing|https://github.com/hangetzzu/saycheese.git|git_python"
ARSENAL["60"]="ohmyqr|Phishing|https://github.com/cryptedwolf/ohmyqr.git|git_python"
ARSENAL["61"]="Thanos|Phishing|https://github.com/TridevReddy/Thanos.git|git_python"
ARSENAL["62"]="QRLJacking|Phishing|https://github.com/OWASP/QRLJacking.git|git_python"
ARSENAL["63"]="maskphish|Phishing|https://github.com/jaykali/maskphish.git|git_generic"
ARSENAL["64"]="BlackPhish|Phishing|https://github.com/yangr0/BlackPhish.git|git_python"

# ── Web Tools (65–72) ──────────────────────────────────────────
ARSENAL["65"]="dirb|Web Tools|https://gitlab.com/kalilinux/packages/dirb.git|git_generic"
ARSENAL["66"]="takeover|Web Tools|https://github.com/edoardottt/takeover.git|git_go"
ARSENAL["67"]="checkURL|Web Tools|https://github.com/UndeadSec/checkURL.git|git_python"
ARSENAL["68"]="Sublist3r|Web Tools|https://github.com/aboul3la/Sublist3r.git|git_python"
ARSENAL["69"]="web2attack|Web Tools|https://github.com/santatic/web2attack.git|git_python"

# ── Payload & Exploitation (70–78) ─────────────────────────────
ARSENAL["70"]="Vegile|Exploitation|https://github.com/screetsec/Vegile.git|git_generic"
ARSENAL["71"]="HeraKeylogger|Exploitation|https://github.com/UndeadSec/HeraKeylogger.git|git_python"
ARSENAL["72"]="bulk_extractor|Exploitation|https://github.com/simsong/bulk_extractor.git|git_generic"
ARSENAL["73"]="TheFatRat|Exploitation|https://github.com/screetsec/TheFatRat.git|git_generic"
ARSENAL["74"]="Brutal|Exploitation|https://github.com/screetsec/Brutal.git|git_generic"
ARSENAL["75"]="msfpc|Exploitation|https://github.com/g0tmi1k/msfpc.git|git_generic"
ARSENAL["76"]="venom|Exploitation|https://github.com/r00t-3xp10it/venom.git|git_generic"
ARSENAL["77"]="spycam|Exploitation|https://github.com/indexnotfound404/spycam.git|git_python"
ARSENAL["78"]="Mob-Droid|Exploitation|https://github.com/kinghacker0/Mob-Droid.git|git_python"
ARSENAL["79"]="Enigma|Exploitation|https://github.com/UndeadSec/Enigma.git|git_python"

# ================================================================
#   INSTALLER BANNER
# ================================================================
show_installer_banner() {
  clear
  echo -e "${BOLD}${CYAN}"
  echo "  ██╗   ██╗██╗██╗  ██╗██╗███╗   ██╗ ██████╗      █████╗ ██╗"
  echo "  ██║   ██║██║██║ ██╔╝██║████╗  ██║██╔════╝     ██╔══██╗██║"
  echo "  ██║   ██║██║█████╔╝ ██║██╔██╗ ██║██║  ███╗    ███████║██║"
  echo "  ╚██╗ ██╔╝██║██╔═██╗ ██║██║╚██╗██║██║   ██║    ██╔══██║██║"
  echo "   ╚████╔╝ ██║██║  ██╗██║██║ ╚████║╚██████╔╝    ██║  ██║██║"
  echo "    ╚═══╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝  ╚═╝╚═╝"
  echo -e "${NC}"
  echo -e "${GREEN}       ⚔  Digital Longship Intelligence System  ⚔${NC}"
  echo -e "${CYAN}       Linux Operations & Security Engine${NC}"
  echo ""
  echo "  ═══════════════════════════════════════════════════════"
  echo ""
}

# ================================================================
#   WAR MODE — Full Arsenal Installation
# ================================================================
show_war_mode_banner() {
  clear
  echo -e "${BRED}"
  echo "  ██╗    ██╗ █████╗ ██████╗      ███╗   ███╗ ██████╗ ██████╗ ███████╗"
  echo "  ██║    ██║██╔══██╗██╔══██╗     ████╗ ████║██╔═══██╗██╔══██╗██╔════╝"
  echo "  ██║ █╗ ██║███████║██████╔╝     ██╔████╔██║██║   ██║██║  ██║█████╗  "
  echo "  ██║███╗██║██╔══██║██╔══██╗     ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝  "
  echo "  ╚███╔███╔╝██║  ██║██║  ██║     ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗"
  echo "   ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝     ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝"
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
  sleep 2
}

# ================================================================
#   UTILITY FUNCTIONS
# ================================================================
log_info()    { echo -e "${CYAN}[INFO]${NC}    $*"; }
log_ok()      { echo -e "${GREEN}[✓]${NC}      $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}    $*"; }
log_err()     { echo -e "${RED}[✗]${NC}      $*"; }
log_step()    { echo -e "${BOLD}${CYAN}[STEP $1]${NC} $2"; }
log_war()     { echo -e "${BRED}[WAR]${NC}     $*"; }
log_section() {
  echo ""
  echo -e "${BOLD}${YELLOW}  ── $* ──${NC}"
  echo ""
}

check_root() {
  if [ "$EUID" -ne 0 ]; then
    log_err "Run as root: sudo bash install.sh"
    exit 1
  fi
}

# ================================================================
#   DEPENDENCY INSTALLER
# ================================================================
install_dependencies() {
  log_step "1" "Installing core dependencies..."
  apt-get update -qq
  apt-get install -y -qq \
    tmux curl wget git python3 python3-pip python3-venv \
    nmap tshark whois nikto build-essential golang-go \
    ruby ruby-dev libpcap-dev libssl-dev 2>/dev/null
  log_ok "Core dependencies ready"
}

# ================================================================
#   OLLAMA INSTALLER
# ================================================================
install_ollama() {
  log_step "2" "Checking Ollama..."
  if command -v ollama &>/dev/null; then
    log_ok "Ollama already installed"
  else
    log_warn "Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
    log_ok "Ollama installed"
  fi
  systemctl enable ollama &>/dev/null || true
  systemctl start  ollama &>/dev/null || true
  sleep 2
  log_ok "Ollama service running"
}

# ================================================================
#   MODEL PULLER
# ================================================================
pull_model() {
  local model="${1:-$DEFAULT_MODEL}"
  log_step "3" "Checking AI model ($model)..."
  if ollama list 2>/dev/null | grep -q "^${model}"; then
    log_ok "Model $model already present"
  else
    log_warn "Pulling $model — this may take a few minutes..."
    ollama pull "$model"
    log_ok "Model $model ready"
  fi
}

# ================================================================
#   SINGLE TOOL INSTALLER
#   Usage: install_tool NUMBER
# ================================================================
install_tool() {
  local num="$1"
  local entry="${ARSENAL[$num]:-}"

  if [ -z "$entry" ]; then
    log_err "Tool #$num not found in arsenal."
    return 1
  fi

  IFS='|' read -r name category url install_type <<< "$entry"
  local dest="$ARSENAL_DIR/$name"

  echo -e "${CYAN}  Installing [$num] $name${NC} (${DIM}$category${NC})"

  # Clone
  if [ -d "$dest" ]; then
    log_warn "$name already cloned — pulling latest..."
    git -C "$dest" pull -q 2>/dev/null || true
  else
    git clone --depth=1 -q "$url" "$dest" 2>/dev/null || {
      log_err "Failed to clone $name from $url"
      return 1
    }
  fi

  # Post-install based on type
  case "$install_type" in
    git_python)
      if [ -f "$dest/requirements.txt" ]; then
        pip3 install -q -r "$dest/requirements.txt" --break-system-packages 2>/dev/null || true
      fi
      ;;
    git_go)
      if [ -f "$dest/go.mod" ]; then
        (cd "$dest" && go build ./... 2>/dev/null) || true
      fi
      ;;
    git_generic)
      if [ -f "$dest/Makefile" ]; then
        (cd "$dest" && make -s 2>/dev/null) || true
      elif [ -f "$dest/setup.sh" ]; then
        (cd "$dest" && bash setup.sh 2>/dev/null) || true
      elif [ -f "$dest/install.sh" ]; then
        (cd "$dest" && bash install.sh 2>/dev/null) || true
      fi
      ;;
  esac

  log_ok "$name installed → $dest"
}

# ================================================================
#   ARSENAL DISPLAY — Pretty categorized list
# ================================================================
display_arsenal() {
  local current_cat=""
  echo ""
  echo -e "${BOLD}${YELLOW}  ⚔  WAPENS ARSENAL  ⚔${NC}"
  echo -e "  ══════════════════════════════════════════════════════"
  echo ""

  # Sort keys numerically
  for num in $(echo "${!ARSENAL[@]}" | tr ' ' '\n' | sort -n); do
    IFS='|' read -r name category url _ <<< "${ARSENAL[$num]}"
    if [ "$category" != "$current_cat" ]; then
      current_cat="$category"
      echo -e "${BOLD}${MAGENTA}  ── $category ──${NC}"
    fi
    printf "  ${CYAN}[%02d]${NC}  %-28s ${DIM}%s${NC}\n" "$num" "$name" "$url"
  done
  echo ""
  echo -e "  ══════════════════════════════════════════════════════"
  echo ""
}

# ================================================================
#   WAR MODE — Install ALL tools
# ================================================================
war_mode_install() {
  show_war_mode_banner

  local total=${#ARSENAL[@]}
  local count=0
  local failed=()

  for num in $(echo "${!ARSENAL[@]}" | tr ' ' '\n' | sort -n); do
    count=$((count + 1))
    IFS='|' read -r name category _ _ <<< "${ARSENAL[$num]}"
    echo -e "${BRED}[WAR ${count}/${total}]${NC} ${RED}Deploying:${NC} $name ${DIM}($category)${NC}"
    install_tool "$num" || failed+=("$num:$name")
  done

  echo ""
  echo -e "${BRED}  ══════════════════════════════════════════════════════${NC}"
  echo -e "${BRED}  WAR MODE COMPLETE — ${count} WEAPONS DEPLOYED${NC}"
  echo -e "${BRED}  ══════════════════════════════════════════════════════${NC}"
  if [ ${#failed[@]} -gt 0 ]; then
    echo -e "${YELLOW}  Failed installs:${NC}"
    for f in "${failed[@]}"; do
      echo -e "  ${RED}✗${NC} $f"
    done
  fi
  echo ""
}

# ================================================================
#   INTERACTIVE ARSENAL MENU (called from viking CLI)
# ================================================================
write_arsenal_menu_script() {
  cat > "$VIKING_DIR/arsenal_menu.sh" << 'ARSENALMENU'
#!/bin/bash

ARSENAL_DIR="/opt/viking/arsenal"

RED='\033[0;31m'
BRED='\033[1;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Load arsenal registry
source /opt/viking/arsenal_registry.sh

war_mode_banner() {
  clear
  echo -e "${BRED}"
  echo "  ██╗    ██╗ █████╗ ██████╗      ███╗   ███╗ ██████╗ ██████╗ ███████╗"
  echo "  ██║    ██║██╔══██╗██╔══██╗     ████╗ ████║██╔═══██╗██╔══██╗██╔════╝"
  echo "  ██║ █╗ ██║███████║██████╔╝     ██╔████╔██║██║   ██║██║  ██║█████╗  "
  echo "  ██║███╗██║██╔══██║██╔══██╗     ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝  "
  echo "  ╚███╔███╔╝██║  ██║██║  ██║     ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗"
  echo "   ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝     ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝"
  echo ""
  echo "  ██╗  ██╗███████╗██╗     ██╗          ██╗███████╗"
  echo "  ██║  ██║██╔════╝██║     ██║         ██╔╝██╔════╝"
  echo "  ███████║█████╗  ██║     ██║        ██╔╝ ███████╗"
  echo "  ██╔══██║██╔══╝  ██║     ██║       ██╔╝  ╚════██║"
  echo "  ██║  ██║███████╗███████╗███████╗ ██╔╝   ███████║"
  echo "  ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝    ╚══════╝"
  echo ""
  echo "  ══════════════════════════════════════════════════════════════"
  echo -e "  ${BRED}⚠  ALL WEAPONS DEPLOYING — STAND CLEAR  ⚠${NC}"
  echo -e "${BRED}  ══════════════════════════════════════════════════════════════${NC}"
  echo -e "${NC}"
}

install_single_tool() {
  local num="$1"
  local entry="${TOOL_REGISTRY[$num]:-}"
  [ -z "$entry" ] && echo -e "${RED}Tool #$num not found.${NC}" && return 1
  IFS='|' read -r name category url install_type <<< "$entry"
  local dest="$ARSENAL_DIR/$name"
  echo -e "${CYAN}Installing [$num] $name...${NC}"
  if [ -d "$dest" ]; then
    echo -e "${YELLOW}Already cloned — pulling latest...${NC}"
    git -C "$dest" pull -q 2>/dev/null || true
  else
    git clone --depth=1 -q "$url" "$dest" 2>/dev/null || { echo -e "${RED}Clone failed.${NC}"; return 1; }
  fi
  case "$install_type" in
    git_python)
      [ -f "$dest/requirements.txt" ] && pip3 install -q -r "$dest/requirements.txt" --break-system-packages 2>/dev/null || true ;;
    git_go)
      [ -f "$dest/go.mod" ] && (cd "$dest" && go build ./... 2>/dev/null) || true ;;
    git_generic)
      if   [ -f "$dest/Makefile"   ]; then (cd "$dest" && make -s 2>/dev/null) || true
      elif [ -f "$dest/setup.sh"   ]; then (cd "$dest" && bash setup.sh 2>/dev/null) || true
      elif [ -f "$dest/install.sh" ]; then (cd "$dest" && bash install.sh 2>/dev/null) || true
      fi ;;
  esac
  echo -e "${GREEN}[✓] $name ready → $dest${NC}"
}

war_mode_install_all() {
  war_mode_banner
  local total=${#TOOL_REGISTRY[@]}
  local count=0
  local failed=()
  for num in $(echo "${!TOOL_REGISTRY[@]}" | tr ' ' '\n' | sort -n); do
    count=$((count+1))
    IFS='|' read -r name category _ _ <<< "${TOOL_REGISTRY[$num]}"
    echo -e "${BRED}[WAR ${count}/${total}]${NC} ${RED}Deploying:${NC} $name"
    install_single_tool "$num" || failed+=("$name")
  done
  echo ""
  echo -e "${BRED}  ════════════════════════════════════════════${NC}"
  echo -e "${BRED}  WAR COMPLETE — $count WEAPONS DEPLOYED  ⚔${NC}"
  echo -e "${BRED}  ════════════════════════════════════════════${NC}"
  [ ${#failed[@]} -gt 0 ] && echo -e "${YELLOW}  Failed: ${failed[*]}${NC}"
  echo ""
}

show_arsenal() {
  local current_cat=""
  echo ""
  echo -e "${BOLD}${YELLOW}  ⚔  WAPENS ARSENAL  ⚔${NC}"
  echo -e "  ══════════════════════════════════════════════════"
  for num in $(echo "${!TOOL_REGISTRY[@]}" | tr ' ' '\n' | sort -n); do
    IFS='|' read -r name category url _ <<< "${TOOL_REGISTRY[$num]}"
    if [ "$category" != "$current_cat" ]; then
      current_cat="$category"
      echo ""
      echo -e "${BOLD}${MAGENTA}  ── $category ──${NC}"
    fi
    local installed=""
    [ -d "$ARSENAL_DIR/$name" ] && installed="${GREEN}[installed]${NC}"
    printf "  ${CYAN}[%02d]${NC}  %-30s %b\n" "$num" "$name" "$installed"
  done
  echo ""
  echo -e "  ══════════════════════════════════════════════════"
  echo ""
  echo -e "  Enter a ${CYAN}number${NC} to install a single tool"
  echo -e "  Type   ${BRED}WAR${NC}    to install ALL tools (War Mode)"
  echo -e "  Type   ${YELLOW}back${NC}   to return to VIKING"
  echo ""

  while true; do
    echo -ne "${YELLOW}arsenal> ${NC}"
    read -r choice
    case "$choice" in
      WAR|war|War)
        war_mode_install_all ;;
      back|exit|quit)
        break ;;
      ''|*[!0-9]*)
        echo -e "${RED}Enter a number or WAR.${NC}" ;;
      *)
        install_single_tool "$choice" ;;
    esac
  done
}

show_arsenal
ARSENALMENU
  chmod +x "$VIKING_DIR/arsenal_menu.sh"
}

# ================================================================
#   ARSENAL REGISTRY — sourced by the menu at runtime
# ================================================================
write_arsenal_registry() {
  cat > "$VIKING_DIR/arsenal_registry.sh" << 'REGISTRY'
#!/bin/bash
declare -A TOOL_REGISTRY
TOOL_REGISTRY["01"]="WebCheck|Scanning & Recon|https://github.com/X3RX3SSec/WebCheck.git|git_python"
TOOL_REGISTRY["02"]="DEATH_STAR|Scanning & Recon|https://github.com/Ringmast4r/DEATH_STAR.git|git_python"
TOOL_REGISTRY["03"]="Dracnmap|Scanning & Recon|https://github.com/screetsec/Dracnmap.git|git_python"
TOOL_REGISTRY["04"]="RED_HAWK|Scanning & Recon|https://github.com/Tuhinshubhra/RED_HAWK.git|git_python"
TOOL_REGISTRY["05"]="reconspider|Scanning & Recon|https://github.com/bhavsec/reconspider.git|git_python"
TOOL_REGISTRY["06"]="ReconDog|Scanning & Recon|https://github.com/s0md3v/ReconDog.git|git_python"
TOOL_REGISTRY["07"]="Striker|Scanning & Recon|https://github.com/s0md3v/Striker.git|git_python"
TOOL_REGISTRY["08"]="SecretFinder|Scanning & Recon|https://github.com/m4ll0k/SecretFinder.git|git_python"
TOOL_REGISTRY["09"]="rang3r|Scanning & Recon|https://github.com/floriankunushevci/rang3r.git|git_python"
TOOL_REGISTRY["10"]="Breacher|Scanning & Recon|https://github.com/s0md3v/Breacher.git|git_python"
TOOL_REGISTRY["11"]="theHarvester|Scanning & Recon|https://github.com/laramies/theHarvester.git|git_python"
TOOL_REGISTRY["12"]="spiderfoot|Scanning & Recon|https://github.com/smicallef/spiderfoot.git|git_python"
TOOL_REGISTRY["13"]="nmap|Network Tools|https://github.com/nmap/nmap.git|git_generic"
TOOL_REGISTRY["14"]="masscan|Network Tools|https://github.com/robertdavidgraham/masscan.git|git_generic"
TOOL_REGISTRY["15"]="RustScan|Network Tools|https://github.com/bee-san/RustScan.git|git_generic"
TOOL_REGISTRY["16"]="xerosploit|Network Tools|https://github.com/LionSec/xerosploit.git|git_python"
TOOL_REGISTRY["17"]="amass|Network Tools|https://github.com/owasp-amass/amass.git|git_go"
TOOL_REGISTRY["18"]="httpx|Network Tools|https://github.com/projectdiscovery/httpx.git|git_go"
TOOL_REGISTRY["19"]="subfinder|Network Tools|https://github.com/projectdiscovery/subfinder.git|git_go"
TOOL_REGISTRY["20"]="dalfox|XSS Tools|https://github.com/hahwul/dalfox.git|git_go"
TOOL_REGISTRY["21"]="XSS-LOADER|XSS Tools|https://github.com/capture0x/XSS-LOADER.git|git_python"
TOOL_REGISTRY["22"]="extended-xss-search|XSS Tools|https://github.com/Damian89/extended-xss-search.git|git_python"
TOOL_REGISTRY["23"]="XSpear|XSS Tools|https://github.com/hahwul/XSpear.git|git_generic"
TOOL_REGISTRY["24"]="XSSCon|XSS Tools|https://github.com/menkrep1337/XSSCon.git|git_python"
TOOL_REGISTRY["25"]="XanXSS|XSS Tools|https://github.com/Ekultek/XanXSS.git|git_python"
TOOL_REGISTRY["26"]="XSStrike|XSS Tools|https://github.com/s0md3v/XSStrike.git|git_python"
TOOL_REGISTRY["27"]="RVuln|XSS Tools|https://github.com/yangr0/RVuln.git|git_python"
TOOL_REGISTRY["28"]="sqlmap|SQL Injection|https://github.com/sqlmapproject/sqlmap.git|git_python"
TOOL_REGISTRY["29"]="NoSQLMap|SQL Injection|https://github.com/codingo/NoSQLMap.git|git_python"
TOOL_REGISTRY["30"]="DSSS|SQL Injection|https://github.com/stamparm/DSSS.git|git_python"
TOOL_REGISTRY["31"]="explo|SQL Injection|https://github.com/telekom-security/explo.git|git_python"
TOOL_REGISTRY["32"]="Blisqy|SQL Injection|https://github.com/JohnTroony/Blisqy.git|git_python"
TOOL_REGISTRY["33"]="leviathan|SQL Injection|https://github.com/utkusen/leviathan.git|git_python"
TOOL_REGISTRY["34"]="sqlscan|SQL Injection|https://github.com/Cvar1984/sqlscan.git|git_python"
TOOL_REGISTRY["35"]="OneShot|WiFi Tools|https://github.com/kimocoder/OneShot.git|git_python"
TOOL_REGISTRY["36"]="wifipumpkin3|WiFi Tools|https://github.com/P0cL4bs/wifipumpkin3.git|git_python"
TOOL_REGISTRY["37"]="pixiewps|WiFi Tools|https://github.com/wiire-a/pixiewps.git|git_generic"
TOOL_REGISTRY["38"]="bluepot|WiFi Tools|https://github.com/andrewmichaelsmith/bluepot.git|git_generic"
TOOL_REGISTRY["39"]="fluxion|WiFi Tools|https://github.com/FluxionNetwork/fluxion.git|git_generic"
TOOL_REGISTRY["40"]="wifiphisher|WiFi Tools|https://github.com/wifiphisher/wifiphisher.git|git_python"
TOOL_REGISTRY["41"]="wifite2|WiFi Tools|https://github.com/derv82/wifite2.git|git_python"
TOOL_REGISTRY["42"]="fakeap|WiFi Tools|https://github.com/Z4nzu/fakeap.git|git_python"
TOOL_REGISTRY["43"]="kali-anonsurf|Anonymity|https://github.com/Und3rf10w/kali-anonsurf.git|git_generic"
TOOL_REGISTRY["44"]="multitor|Anonymity|https://github.com/trimstray/multitor.git|git_generic"
TOOL_REGISTRY["45"]="holehe|OSINT|https://github.com/megadose/holehe.git|git_python"
TOOL_REGISTRY["46"]="maigret|OSINT|https://github.com/soxoj/maigret.git|git_python"
TOOL_REGISTRY["47"]="trufflehog|OSINT|https://github.com/trufflesecurity/trufflehog.git|git_go"
TOOL_REGISTRY["48"]="gitleaks|OSINT|https://github.com/gitleaks/gitleaks.git|git_go"
TOOL_REGISTRY["49"]="SMWYG|OSINT|https://github.com/Viralmaniar/SMWYG-Show-Me-What-You-Got.git|git_python"
TOOL_REGISTRY["50"]="cupp|Wordlist|https://github.com/Mebus/cupp.git|git_python"
TOOL_REGISTRY["51"]="wlcreator|Wordlist|https://github.com/Z4nzu/wlcreator.git|git_python"
TOOL_REGISTRY["52"]="GoblinWordGenerator|Wordlist|https://github.com/UndeadSec/GoblinWordGenerator.git|git_python"
TOOL_REGISTRY["53"]="autophisher|Phishing|https://github.com/CodingRanjith/autophisher.git|git_python"
TOOL_REGISTRY["54"]="AdvPhishing|Phishing|https://github.com/Ignitetch/AdvPhishing.git|git_python"
TOOL_REGISTRY["55"]="SET|Phishing|https://github.com/trustedsec/social-engineer-toolkit.git|git_python"
TOOL_REGISTRY["56"]="SocialFish|Phishing|https://github.com/UndeadSec/SocialFish.git|git_python"
TOOL_REGISTRY["57"]="evilginx2|Phishing|https://github.com/kgretzky/evilginx2.git|git_go"
TOOL_REGISTRY["58"]="I-See-You|Phishing|https://github.com/Viralmaniar/I-See-You.git|git_python"
TOOL_REGISTRY["59"]="saycheese|Phishing|https://github.com/hangetzzu/saycheese.git|git_python"
TOOL_REGISTRY["60"]="ohmyqr|Phishing|https://github.com/cryptedwolf/ohmyqr.git|git_python"
TOOL_REGISTRY["61"]="Thanos|Phishing|https://github.com/TridevReddy/Thanos.git|git_python"
TOOL_REGISTRY["62"]="QRLJacking|Phishing|https://github.com/OWASP/QRLJacking.git|git_python"
TOOL_REGISTRY["63"]="maskphish|Phishing|https://github.com/jaykali/maskphish.git|git_generic"
TOOL_REGISTRY["64"]="BlackPhish|Phishing|https://github.com/yangr0/BlackPhish.git|git_python"
TOOL_REGISTRY["65"]="dirb|Web Tools|https://gitlab.com/kalilinux/packages/dirb.git|git_generic"
TOOL_REGISTRY["66"]="takeover|Web Tools|https://github.com/edoardottt/takeover.git|git_go"
TOOL_REGISTRY["67"]="checkURL|Web Tools|https://github.com/UndeadSec/checkURL.git|git_python"
TOOL_REGISTRY["68"]="Sublist3r|Web Tools|https://github.com/aboul3la/Sublist3r.git|git_python"
TOOL_REGISTRY["69"]="web2attack|Web Tools|https://github.com/santatic/web2attack.git|git_python"
TOOL_REGISTRY["70"]="Vegile|Exploitation|https://github.com/screetsec/Vegile.git|git_generic"
TOOL_REGISTRY["71"]="HeraKeylogger|Exploitation|https://github.com/UndeadSec/HeraKeylogger.git|git_python"
TOOL_REGISTRY["72"]="bulk_extractor|Exploitation|https://github.com/simsong/bulk_extractor.git|git_generic"
TOOL_REGISTRY["73"]="TheFatRat|Exploitation|https://github.com/screetsec/TheFatRat.git|git_generic"
TOOL_REGISTRY["74"]="Brutal|Exploitation|https://github.com/screetsec/Brutal.git|git_generic"
TOOL_REGISTRY["75"]="msfpc|Exploitation|https://github.com/g0tmi1k/msfpc.git|git_generic"
TOOL_REGISTRY["76"]="venom|Exploitation|https://github.com/r00t-3xp10it/venom.git|git_generic"
TOOL_REGISTRY["77"]="spycam|Exploitation|https://github.com/indexnotfound404/spycam.git|git_python"
TOOL_REGISTRY["78"]="Mob-Droid|Exploitation|https://github.com/kinghacker0/Mob-Droid.git|git_python"
TOOL_REGISTRY["79"]="Enigma|Exploitation|https://github.com/UndeadSec/Enigma.git|git_python"
REGISTRY
  chmod +x "$VIKING_DIR/arsenal_registry.sh"
}

# ================================================================
#   VIKING MAIN SCRIPT — Written to $INSTALL_PATH
# ================================================================
write_viking_script() {
  cat > "$INSTALL_PATH" << 'VIKINGSCRIPT'
#!/bin/bash

# ================================================================
#  VIKING AI — Digital Longship Intelligence System
#  Local CLI Security Assistant for Kali Linux
#  License: MIT
# ================================================================

# ── Config ───────────────────────────────────────────────────────
VIKING_DIR="/opt/viking"
ARSENAL_DIR="$VIKING_DIR/arsenal"
CONFIG_FILE="$VIKING_DIR/config"
LOGFILE="$HOME/.viking_history.log"

# Load persistent config (model, etc.)
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"
MODEL="${VIKING_MODEL:-gemma3:1b}"

# ── Colors ───────────────────────────────────────────────────────
RED='\033[0;31m'
BRED='\033[1;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ── Available models ─────────────────────────────────────────────
AVAILABLE_MODELS=(
  "gemma3:1b"
  "gemma3:4b"
  "llama3.2:1b"
  "llama3.2:3b"
  "llama3.1:8b"
  "mistral:7b"
  "phi3:mini"
  "phi3:medium"
  "qwen2.5:3b"
  "qwen2.5:7b"
  "deepseek-r1:7b"
  "codellama:7b"
  "neural-chat:7b"
)

# ── System Prompt ────────────────────────────────────────────────
SYSTEM_PROMPT='You are VIKING, a local AI-powered command-line cybersecurity and automation assistant running on a Linux system.

You operate in a terminal-only environment and are designed for lightweight servers that may run Kali Linux tools, security utilities, and custom GitHub-installed tools.

Your purpose is to assist the user in:
- executing Linux commands and security tools
- analyzing tool outputs in real time
- explaining results clearly and concisely
- generating safe, correct commands for penetration testing and system administration
- writing code (Python, Bash, JavaScript, HTML, CSS, etc.)
- automating workflows on Linux systems

CORE PRINCIPLES:
1. TOOL-FIRST: For system/network/security tasks, determine the right Linux tool, give the exact command, explain briefly.
2. OUTPUT ANALYSIS: When tool output is provided, analyze it immediately, explain findings, identify risks, suggest next steps.
3. COMMAND FORMAT — always use this layout when giving commands:
   COMMAND: <exact command>
   EXPLANATION: <what it does>
   EXPECTED OUTPUT: <what the user should expect>
4. SAFETY: Warn before any destructive action (rm, wipe, format, live exploits).
5. WORKFLOW LOOP: Input → tool → command → analyze output → suggest next step.

VIKING IDENTITY:
Use subtle Viking-themed labels occasionally: "Scouting report", "Raid analysis", "Intel summary", "Target assessment". Do not overuse them.

You are not just a chatbot. You are an operational command intelligence layer for Linux systems. Be concise, direct, and tactical.'

# ================================================================
#   FUNCTIONS
# ================================================================
log()          { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"; }
viking_think() { ollama run "$MODEL" "$SYSTEM_PROMPT

$1" 2>/dev/null; }
viking_say()   { echo -e "${YELLOW}⚔ VIKING:${NC} $1"; }
viking_info()  { echo -e "${CYAN}[VIKING]${NC} $1"; }
viking_err()   { echo -e "${RED}[VIKING]${NC} $1"; }

save_config() {
  echo "VIKING_MODEL=\"$MODEL\"" > "$CONFIG_FILE"
}

show_banner() {
  clear
  echo -e "${DIM}${GREEN}"
  echo "                                         |    |    |"
  echo "                                        )_)  )_)  )_)"
  echo "                                       )___))___))___)\ "
  echo "                                      )____)____)_____)\ \ "
  echo "                                    _____|____|____|____\ \ \ __"
  echo "                       ____________/~~~~~~~~~~~~~~~~~~~~~\___\___________"
  echo -e "${NC}${DIM}${CYAN}"
  echo "  ~~^~~^~~^~~^~~^~~^~/                                                   \~~^~~"
  echo "  ~^~~^~~^~~^~~^~~^~~|  ooo   ooo   ooo   ooo   ooo   ooo   ooo   ooo   |^~~^~"
  echo "  ~~^~~^~~^~~^~~^~~^~|  | |   | |   | |   | |   | |   | |   | |   | |   |~~^~~"
  echo "  ~^~~^~~^~~^~~^~~^~~\~~'~'~~~'~'~~~'~'~~~'~'~~~'~'~~~'~'~~~'~'~~~'~'~~/^~~^~~"
  echo -e "${NC}"
  echo -e "${BOLD}${YELLOW}"
  echo "  ██╗   ██╗██╗██╗  ██╗██╗███╗   ██╗ ██████╗      █████╗ ██╗"
  echo "  ██║   ██║██║██║ ██╔╝██║████╗  ██║██╔════╝     ██╔══██╗██║"
  echo "  ██║   ██║██║█████╔╝ ██║██╔██╗ ██║██║  ███╗    ███████║██║"
  echo "  ╚██╗ ██╔╝██║██╔═██╗ ██║██║╚██╗██║██║   ██║    ██╔══██║██║"
  echo "   ╚████╔╝ ██║██║  ██╗██║██║ ╚████║╚██████╔╝    ██║  ██║██║"
  echo "    ╚═══╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝  ╚═╝╚═╝"
  echo -e "${NC}"
  echo -e "${CYAN}  ⚔  Digital Longship Intelligence System  ⚔${NC}"
  echo -e "  ${DIM}════════════════════════════════════════════${NC}"
  echo -e "  ${CYAN}Linux Operations & Security Engine${NC}"
  echo -e "  Model: ${GREEN}$MODEL${NC}  |  Type ${YELLOW}help${NC} for commands  |  ${DIM}quit to exit${NC}"
  echo ""
}

show_help() {
  echo ""
  echo -e "${BOLD}${YELLOW}  ⚔ VIKING COMMAND ARSENAL ⚔${NC}"
  echo -e "  ══════════════════════════════"
  echo ""
  echo -e "${CYAN}  SCANNING & RECON${NC}"
  echo "    scan <ip/url>         — nmap full scan + AI analysis"
  echo "    ping <ip/host>        — probe a target"
  echo "    whois <domain>        — domain reconnaissance"
  echo "    nikto <ip/url>        — web vulnerability scan"
  echo ""
  echo -e "${CYAN}  WIRELESS${NC}"
  echo "    wifite                — launch wifite"
  echo "    oneshot               — launch OneShot (WPS/PMKID)"
  echo "    airmon                — aircrack-ng guidance"
  echo ""
  echo -e "${CYAN}  WEB & EXPLOITATION${NC}"
  echo "    gobuster <url>        — directory brute force"
  echo "    sqlmap <url>          — SQL injection"
  echo "    metasploit            — msfconsole guidance"
  echo "    hydra                 — brute force guidance"
  echo "    netcat / nc           — shell & listener help"
  echo ""
  echo -e "${CYAN}  NETWORK & TRAFFIC${NC}"
  echo "    tshark                — live packet capture"
  echo "    hashcat / john        — hash cracking guidance"
  echo ""
  echo -e "${CYAN}  GUI APPS (requires display)${NC}"
  echo "    open chrome/firefox/wireshark/burp"
  echo ""
  echo -e "${CYAN}  CODING & SCRIPTING${NC}"
  echo "    write a python ...    — Python code"
  echo "    make a html ...       — HTML / CSS / JS"
  echo "    bash script for ...   — Bash scripting"
  echo ""
  echo -e "${CYAN}  ARSENAL & MODEL${NC}"
  echo "    arsenal               — browse & install tools (79 weapons)"
  echo "    model                 — list & switch AI models"
  echo "    model <name>          — switch to a specific model"
  echo ""
  echo -e "${CYAN}  SYSTEM${NC}"
  echo "    help                  — show this menu"
  echo "    history               — view session log"
  echo "    banner                — redisplay the banner"
  echo "    quit / exit           — leave VIKING"
  echo ""
}

show_models() {
  echo ""
  echo -e "${BOLD}${YELLOW}  ⚔ AVAILABLE MODELS ⚔${NC}"
  echo -e "  ══════════════════════════════"
  echo ""
  local i=1
  for m in "${AVAILABLE_MODELS[@]}"; do
    local tag=""
    if [ "$m" == "$MODEL" ]; then
      tag="${GREEN} ← active${NC}"
    fi
    local installed_tag=""
    if ollama list 2>/dev/null | grep -q "^${m}"; then
      installed_tag="${DIM}[installed]${NC}"
    fi
    printf "  ${CYAN}[%2d]${NC}  %-25s %b %b\n" "$i" "$m" "$tag" "$installed_tag"
    i=$((i+1))
  done
  echo ""
  echo -e "  Enter a number or model name to switch. Type ${YELLOW}back${NC} to cancel."
  echo ""
  while true; do
    echo -ne "${YELLOW}model> ${NC}"
    read -r choice
    case "$choice" in
      back|exit|'') break ;;
      *[!0-9]*)
        # Treat as direct model name
        MODEL="$choice"
        save_config
        viking_say "Model switched to: $MODEL (will pull on first use if needed)"
        break ;;
      *)
        local idx=$((choice - 1))
        if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#AVAILABLE_MODELS[@]}" ]; then
          MODEL="${AVAILABLE_MODELS[$idx]}"
          save_config
          viking_say "Pulling and switching to: $MODEL"
          ollama pull "$MODEL" 2>/dev/null || true
          viking_say "Model active: $MODEL"
          break
        else
          viking_err "Invalid choice."
        fi ;;
    esac
  done
}

# ================================================================
#   BANNER & MAIN LOOP
# ================================================================
show_banner

while true; do
  echo -ne "${YELLOW}You: ${NC}"
  read -r INPUT

  [ -z "$INPUT" ] && continue
  log "USER: $INPUT"

  # ── Exit ─────────────────────────────────────────────────
  if [[ "$INPUT" == "quit" || "$INPUT" == "exit" || "$INPUT" == "/bye" ]]; then
    echo ""
    viking_say "The longship returns to port. Skål. ⚔"
    echo ""
    break
  fi

  # ── Built-in navigation ──────────────────────────────────
  if [[ "$INPUT" == "help"   ]]; then show_help;   continue; fi
  if [[ "$INPUT" == "banner" ]]; then show_banner; continue; fi

  if [[ "$INPUT" == "history" ]]; then
    echo ""; cat "$LOGFILE" 2>/dev/null || viking_err "No history yet."; echo ""; continue
  fi

  # ── Arsenal menu ─────────────────────────────────────────
  if echo "$INPUT" | grep -iq "^arsenal"; then
    bash "$VIKING_DIR/arsenal_menu.sh"
    continue
  fi

  # ── Model switcher ───────────────────────────────────────
  if echo "$INPUT" | grep -iq "^model$"; then
    show_models; continue
  fi

  if echo "$INPUT" | grep -iq "^model "; then
    MODEL=$(echo "$INPUT" | awk '{print $2}')
    save_config
    viking_say "Model switched to: $MODEL"
    continue
  fi

  # ── NMAP ─────────────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "scan|nmap"; then
    TARGET=$(echo "$INPUT" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}|https?://[^ ]+|[a-zA-Z0-9._-]+\.[a-zA-Z]{2,}" | head -1)
    if [ -n "$TARGET" ]; then
      viking_info "Scouting target: $TARGET"; echo ""
      RESULT=$(sudo nmap -sV --open -T4 "$TARGET" 2>&1)
      echo "$RESULT"; echo ""
      viking_info "Compiling raid report..."; echo ""
      ANALYSIS=$(viking_think "Produce a VIKING Scouting Report for this nmap scan. List: open ports, services, risk level, vulnerabilities, and recommended follow-up commands. Be tactical and concise. Scan: $RESULT")
      echo -e "${GREEN}$ANALYSIS${NC}"
      log "SCAN: $TARGET"
    else
      viking_err "No valid target found. Usage: scan 192.168.1.1"
    fi
    continue
  fi

  # ── TSHARK ───────────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "tshark|packet capture|sniff|capture traffic"; then
    IFACE=$(ip link show | awk -F': ' '/^[0-9]+:/ && !/lo/{print $2; exit}' | tr -d ' ')
    viking_info "Intercepting traffic on: $IFACE  (Ctrl+C to stop)"
    sudo tshark -i "$IFACE" 2>&1 | head -50
    continue
  fi

  # ── WIFITE ───────────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "wifite|wifi attack|wireless attack"; then
    viking_info "Launching wireless raid via Wifite..."
    sudo wifite; continue
  fi

  # ── ONESHOT ──────────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "oneshot|wps attack|pmkid"; then
    viking_info "Launching OneShot WPS attack..."
    IFACE=$(ip link show | awk -F': ' '/wlan/{print $2; exit}' | tr -d ' ')
    sudo python3 "$ARSENAL_DIR/OneShot/oneshot.py" -i "$IFACE" 2>/dev/null \
      || sudo python3 /usr/share/oneshot/oneshot.py -i "$IFACE" 2>/dev/null \
      || viking_err "OneShot not found. Run: arsenal → [35]"
    continue
  fi

  # ── NIKTO ────────────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "nikto|web vuln|web scan"; then
    TARGET=$(echo "$INPUT" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}|https?://[^ ]+|[a-zA-Z0-9._-]+\.[a-zA-Z]{2,}" | head -1)
    if [ -n "$TARGET" ]; then
      viking_info "Web vulnerability raid on: $TARGET"
      nikto -h "$TARGET" 2>&1
    else
      viking_think "Explain how to use Nikto for: $INPUT"
    fi
    continue
  fi

  # ── GOBUSTER ─────────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "gobuster|dirb|directory scan|directory brute"; then
    viking_info "Directory assault guidance:"; echo ""
    viking_think "Give exact gobuster or dirb commands with wordlist paths and flag explanations for: $INPUT"
    continue
  fi

  # ── SQLMAP ───────────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "sqlmap|sql injection|sqli"; then
    viking_info "SQL injection raid:"; echo ""
    viking_think "Give exact sqlmap commands with all flags explained. Include --risk, --level, and tamper options for: $INPUT"
    continue
  fi

  # ── METASPLOIT ───────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "metasploit|msfconsole|exploit|payload|meterpreter"; then
    viking_info "Metasploit siege guidance:"; echo ""
    viking_think "Give exact msfconsole commands, module search, use, set options, and run steps for: $INPUT"
    continue
  fi

  # ── HYDRA ────────────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "hydra|brute.?force|crack password|password attack"; then
    viking_info "Brute force assault guidance:"; echo ""
    viking_think "Give the exact hydra command with all flags explained including wordlist options for: $INPUT"
    continue
  fi

  # ── HASHCAT / JOHN ───────────────────────────────────────
  if echo "$INPUT" | grep -iEq "hashcat|john the ripper|crack hash|hash crack"; then
    viking_info "Hash cracking guidance:"; echo ""
    viking_think "Give exact hashcat or john commands including hash type detection and attack mode flags for: $INPUT"
    continue
  fi

  # ── NETCAT ───────────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "netcat|reverse shell|bind shell| nc "; then
    viking_info "Netcat battle guidance:"; echo ""
    viking_think "Give exact netcat commands showing both the listener side and connect side for: $INPUT"
    continue
  fi

  # ── PING ─────────────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "^ping |^ping$"; then
    TARGET=$(echo "$INPUT" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}|[a-zA-Z0-9._-]+\.[a-zA-Z]{2,}" | head -1)
    if [ -n "$TARGET" ]; then
      viking_info "Probing $TARGET..."
      ping -c 4 "$TARGET"
    fi
    continue
  fi

  # ── WHOIS ────────────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "whois|domain info|domain lookup"; then
    TARGET=$(echo "$INPUT" | grep -oE "[a-zA-Z0-9._-]+\.[a-zA-Z]{2,}" | head -1)
    if [ -n "$TARGET" ]; then
      viking_info "Domain reconnaissance: $TARGET"
      whois "$TARGET" 2>&1 | head -40
    fi
    continue
  fi

  # ── AIRCRACK ─────────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "aircrack|airmon|airodump|monitor mode"; then
    viking_info "Wireless warfare guidance:"; echo ""
    viking_think "Give exact step-by-step aircrack-ng terminal commands with explanations for: $INPUT"
    continue
  fi

  # ── GUI APPS ─────────────────────────────────────────────
  for APP in chrome firefox wireshark burpsuite burp; do
    if echo "$INPUT" | grep -iEq "open $APP|launch $APP|start $APP"; then
      CMD=""
      case "$APP" in
        chrome)         CMD="google-chrome" ;;
        firefox)        CMD="firefox" ;;
        wireshark)      CMD="wireshark" ;;
        burpsuite|burp) CMD="burpsuite" ;;
      esac
      if [ -n "${DISPLAY:-}" ]; then
        viking_info "Launching $CMD..."
        $CMD &>/dev/null &
      else
        viking_err "No display available over SSH."
        echo "  → X11 forwarding: ssh -X user@$(hostname -I | awk '{print $1}')"
        [[ "$APP" == "wireshark" ]] && echo "  → CLI alternative: sudo tshark -i eth0"
      fi
      continue 2
    fi
  done

  # ── CODING ───────────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "python|write me|create a script|make a script|function|class|html|css|javascript| js |flask|django|bash script|code for|write a"; then
    viking_info "Scripting mode engaged..."; echo ""
    viking_think "Write clean, working, commented code. Show the full code block first, then a brief explanation. Task: $INPUT"
    continue
  fi

  # ── GENERAL FALLBACK ─────────────────────────────────────
  echo ""
  viking_info "Processing..."
  echo ""
  RESPONSE=$(viking_think "Answer clearly and tactically. If this involves a Linux tool, use the COMMAND / EXPLANATION / EXPECTED OUTPUT format. Question: $INPUT")
  echo -e "${GREEN}$RESPONSE${NC}"
  echo ""
  log "VIKING: $RESPONSE"

done
VIKINGSCRIPT

  chmod +x "$INSTALL_PATH"
}

# ================================================================
#   TMUX AUTO-SESSION
# ================================================================
configure_tmux() {
  local BASHRC="/root/.bashrc"
  local MARKER="# VIKING AI auto-session"
  if ! grep -q "$MARKER" "$BASHRC" 2>/dev/null; then
    cat >> "$BASHRC" << 'EOF'

# VIKING AI auto-session
if command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
  tmux has-session -t viking 2>/dev/null || tmux new-session -d -s viking
fi
EOF
  fi
  log_ok "tmux session configured"
}

# ================================================================
#   INTERACTIVE INSTALL WIZARD
# ================================================================
run_interactive_install() {
  echo ""
  echo -e "${BOLD}${CYAN}  What would you like to do?${NC}"
  echo ""
  echo -e "  ${YELLOW}[1]${NC}  Standard install (VIKING CLI + AI only)"
  echo -e "  ${YELLOW}[2]${NC}  Install specific tools from the Wapens Arsenal"
  echo -e "  ${BRED}[3]${NC}  ${BRED}WAR MODE${NC} — Install ALL 79 arsenal tools"
  echo -e "  ${YELLOW}[4]${NC}  Skip tool installation"
  echo ""
  echo -ne "  Choose [1-4]: "
  read -r install_choice

  case "$install_choice" in
    1) log_ok "Standard install selected." ;;
    2)
      display_arsenal
      echo -e "  Enter tool numbers separated by spaces (e.g. ${CYAN}1 3 7 28${NC}):"
      echo -ne "  > "
      read -r tool_choices
      mkdir -p "$ARSENAL_DIR"
      for num in $tool_choices; do
        num=$(printf "%02d" "$num" 2>/dev/null || echo "$num")
        install_tool "$num"
      done
      ;;
    3)
      mkdir -p "$ARSENAL_DIR"
      war_mode_install
      ;;
    4) log_info "Skipping tool installation." ;;
    *) log_warn "Invalid choice — skipping tool installation." ;;
  esac
}

# ================================================================
#   COMPLETION BANNER
# ================================================================
show_completion() {
  echo ""
  echo "  ════════════════════════════════════════════════════"
  echo -e "${BOLD}${YELLOW}   ⚔  VIKING AI — Installation Complete  ⚔${NC}"
  echo "  ════════════════════════════════════════════════════"
  echo ""
  echo -e "  Launch VIKING:     ${CYAN}viking${NC}"
  echo -e "  In tmux:           ${CYAN}tmux new -s viking${NC}  →  ${CYAN}viking${NC}"
  echo -e "  Detach tmux:       ${CYAN}Ctrl+B then D${NC}"
  echo -e "  Reattach:          ${CYAN}tmux attach -t viking${NC}"
  echo -e "  Arsenal:           inside viking, type ${CYAN}arsenal${NC}"
  echo -e "  Switch model:      inside viking, type ${CYAN}model${NC}"
  echo -e "  Arsenal dir:       ${DIM}$ARSENAL_DIR${NC}"
  echo ""
  echo -e "  ${YELLOW}The longship is ready. Type 'viking' to sail.  ⚔${NC}"
  echo ""
}

# ================================================================
#   MAIN
# ================================================================
main() {
  show_installer_banner
  check_root

  # Setup directories
  mkdir -p "$VIKING_DIR" "$ARSENAL_DIR" "$LOG_DIR"

  log_step "1" "Installing dependencies..."
  install_dependencies

  log_step "2" "Setting up Ollama..."
  install_ollama

  log_step "3" "Pulling default model..."
  pull_model "$DEFAULT_MODEL"

  log_step "4" "Writing arsenal registry..."
  write_arsenal_registry
  write_arsenal_menu_script

  log_step "5" "Installing VIKING to $INSTALL_PATH..."
  write_viking_script
  log_ok "VIKING installed at $INSTALL_PATH"

  log_step "6" "Configuring tmux..."
  configure_tmux

  # Write default config
  echo "VIKING_MODEL=\"$DEFAULT_MODEL\"" > "$CONFIG_FILE"

  log_step "7" "Weapon Arsenal setup..."
  run_interactive_install

  show_completion
}

main "$@"
