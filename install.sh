#!/bin/bash

# ================================================================
#  VIKING AI - Digital Longship Intelligence System
#  Local CLI Security Assistant for Kali Linux
#  License: MIT
# ================================================================

# set -u  : catches unbound variables
# set -o pipefail : catches silent pipe errors
# NO set -e : installer must tolerate individual tool failures
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
#  ARSENAL REGISTRY - single source of truth
#  Format: "NAME|CATEGORY|GIT_URL|TYPE"
#  Types : git_python | git_go | git_generic | apt_install:<pkg> | pip_install:<pkg>
#  !! Edit tool list HERE only - registry file is auto-generated !!
# ════════════════════════════════════════════════════════════════
declare -A ARSENAL

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

# WiFi Auditing (apt-installable)
ARSENAL[80]="airgeddon|WiFi Tools|https://github.com/v1s1t0r1sh3r3/airgeddon.git|apt_install:airgeddon"
ARSENAL[81]="aircrack-ng|WiFi Tools|https://github.com/aircrack-ng/aircrack-ng.git|apt_install:aircrack-ng"
ARSENAL[82]="bettercap|WiFi Tools|https://github.com/bettercap/bettercap.git|apt_install:bettercap"

# Web Vulnerability Scanning (apt-installable)
ARSENAL[83]="commix|Web Scanning|https://github.com/commixproject/commix.git|apt_install:commix"
ARSENAL[84]="wpscan|Web Scanning|https://github.com/wpscanteam/wpscan.git|apt_install:wpscan"
ARSENAL[85]="ffuf|Web Scanning|https://github.com/ffuf/ffuf.git|apt_install:ffuf"
ARSENAL[86]="gobuster|Web Scanning|https://github.com/OJ/gobuster.git|apt_install:gobuster"
ARSENAL[87]="dirsearch|Web Scanning|https://github.com/maurosoria/dirsearch.git|apt_install:dirsearch"
ARSENAL[88]="feroxbuster|Web Scanning|https://github.com/epi052/feroxbuster.git|apt_install:feroxbuster"
ARSENAL[89]="katana|Web Scanning|https://github.com/projectdiscovery/katana.git|git_go"

# Port Scanning
ARSENAL[90]="naabu|Network Tools|https://github.com/projectdiscovery/naabu.git|git_go"

# OSINT additions
ARSENAL[91]="sherlock|OSINT|https://github.com/sherlock-project/sherlock.git|apt_install:sherlock"

# Active Directory & Internal Networks
ARSENAL[92]="netexec|Active Directory|https://github.com/Pennyw0rth/NetExec.git|apt_install:netexec"
ARSENAL[93]="responder|Active Directory|https://github.com/lgandx/Responder.git|apt_install:responder"
ARSENAL[94]="impacket|Active Directory|https://github.com/fortra/impacket.git|apt_install:python3-impacket"
ARSENAL[95]="bloodhound|Active Directory|https://github.com/specterops/bloodhound.git|apt_install:bloodhound"
ARSENAL[96]="certipy|Active Directory|https://github.com/ly4k/Certipy.git|pip_install:certipy-ad"

# Password Cracking
ARSENAL[97]="hashcat|Password Cracking|https://github.com/hashcat/hashcat.git|apt_install:hashcat"
ARSENAL[98]="john|Password Cracking|https://github.com/openwall/john.git|apt_install:john"
ARSENAL[99]="hydra|Password Cracking|https://github.com/vanhauser-thc/thc-hydra.git|apt_install:hydra"

# C2 & Exploit Frameworks
ARSENAL[100]="metasploit|C2 Frameworks|https://github.com/rapid7/metasploit-framework.git|apt_install:metasploit-framework"
ARSENAL[101]="sliver|C2 Frameworks|https://github.com/bishopfox/sliver.git|git_go"
ARSENAL[102]="havoc|C2 Frameworks|https://github.com/Havoc-Framework/Havoc.git|git_generic"
ARSENAL[103]="empire|C2 Frameworks|https://github.com/BC-SECURITY/Empire.git|apt_install:powershell-empire"

# ════════════════════════════════════════════════════════════════
#  LOGGING
# ════════════════════════════════════════════════════════════════
log_ok()   { echo -e "${G}[OK]${NC} $*"; }
log_info() { echo -e "${C}[~]${NC} $*"; }
log_warn() { echo -e "${Y}[!]${NC} $*"; }
log_err()  { echo -e "${R}[X]${NC} $*" >&2; }
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
    echo -e "${D}${G}"
    cat << 'SHIP'
                                              |    |    |
                                             )_)  )_)  )_)
                                            )___))___))___)\
                                           )____)____)_____)\\ 
                                         _____|____|____|____\\\\___
                            ____________/~~~~~~~~~~~~~~~~~~~~~~~~~~\__________
  ~~^~~^~~^~~^~~^~~^~~^~~^~/                                        \~~^~~^~~
  ~^~~^~~^~~^~~^~~^~~^~~^~~|  ooo  ooo  ooo  ooo  ooo  ooo  ooo    |^~~^~~^~
  ~~^~~^~~^~~^~~^~~^~~^~~^~\~~'~'~~'~'~~'~'~~'~'~~'~'~~'~'~~'~'~~/~~^~~^~~~
SHIP
    echo -e "${NC}${B}${Y}"
    cat << 'LOGO'

 ██╗   ██╗ ██╗ ██╗  ██╗ ██╗ ███╗   ██╗  ██████╗      █████╗  ██╗
 ██║   ██║ ██║ ██║ ██╔╝ ██║ ████╗  ██║ ██╔════╝     ██╔══██╗ ██║
 ██║   ██║ ██║ █████╔╝  ██║ ██╔██╗ ██║ ██║  ███╗    ███████║ ██║
 ╚██╗ ██╔╝ ██║ ██╔═██╗  ██║ ██║╚██╗██║ ██║   ██║    ██╔══██║ ██║
  ╚████╔╝  ██║ ██║  ██╗ ██║ ██║ ╚████║ ╚██████╔╝    ██║  ██║ ██║
   ╚═══╝   ╚═╝ ╚═╝  ╚═╝ ╚═╝ ╚═╝  ╚═══╝  ╚═════╝     ╚═╝  ╚═╝ ╚═╝

LOGO
    echo -e "${NC}"
    echo -e "${Y}  ┌─────────────────────────────────────────────────────┐${NC}"
    echo -e "${Y}  │   ⚔   Digital Longship Intelligence System   ⚔      │${NC}"
    echo -e "${Y}  │        Linux Operations & Security Engine            │${NC}"
    echo -e "${Y}  └─────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# ════════════════════════════════════════════════════════════════
#  WAR MODE BANNER
# ════════════════════════════════════════════════════════════════
show_war_banner() {
    clear
    echo -e "${RB}"
    cat << 'WARART'

 ██╗    ██╗ █████╗ ██████╗      ███╗   ███╗  ██████╗ ██████╗  ███████╗
 ██║    ██║██╔══██╗██╔══██╗     ████╗ ████║ ██╔═══██╗██╔══██╗ ██╔════╝
 ██║ █╗ ██║███████║██████╔╝     ██╔████╔██║ ██║   ██║██║  ██║ █████╗
 ██║███╗██║██╔══██║██╔══██╗     ██║╚██╔╝██║ ██║   ██║██║  ██║ ██╔══╝
 ╚███╔███╔╝██║  ██║██║  ██║     ██║ ╚═╝ ██║ ╚██████╔╝██████╔╝ ███████╗
  ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝     ╚═╝     ╚═╝  ╚═════╝ ╚═════╝  ╚══════╝

 ██╗  ██╗ ███████╗ ██╗      ██╗          ██╗ ███████╗
 ██║  ██║ ██╔════╝ ██║      ██║         ██╔╝ ██╔════╝
 ███████║ █████╗   ██║      ██║        ██╔╝  ███████╗
 ██╔══██║ ██╔══╝   ██║      ██║       ██╔╝   ╚════██║
 ██║  ██║ ███████╗ ███████╗ ███████╗ ██╔╝    ███████║
 ╚═╝  ╚═╝ ╚══════╝ ╚══════╝ ╚══════╝ ╚═╝    ╚══════╝

WARART
    echo -e "${NC}"
    echo -e "${RB}  ══════════════════════════════════════════════════════════════${NC}"
    echo -e "${RB}  ⚔   DEPLOYING FULL WEAPON ARSENAL — ALL TOOLS INCOMING   ⚔  ${NC}"
    echo -e "${RB}  ══════════════════════════════════════════════════════════════${NC}"
    echo ""
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
            log_err "Ollama install failed - check internet connection"
            exit 1
        }
        log_ok "Ollama installed"
    fi
    systemctl enable ollama &>/dev/null || true
    systemctl start  ollama &>/dev/null || true
    # Wait up to 15s for Ollama API
    local tries=5
    until curl -sf http://localhost:11434/ &>/dev/null || (( --tries == 0 )); do
        sleep 3
    done
    log_ok "Ollama service running"
}

pull_model() {
    local model="${1:-$DEFAULT_MODEL}"
    log_step "3" "Checking model: $model"
    if ollama list 2>/dev/null | awk '{print $1}' | grep -Fxq "$model"; then
        log_ok "Already present: $model"
    else
        log_info "Pulling $model..."
        ollama pull "$model" || log_warn "Pull failed - will retry on first use"
        log_ok "Model ready: $model"
    fi
}

# ════════════════════════════════════════════════════════════════
#  TOOL INSTALLER
#  Shared by installer, War Mode, and live arsenal menu.
# ════════════════════════════════════════════════════════════════

# ── Post-install: build/configure after git clone ───────────────
_post_install() {
    local dest="$1" type="$2"
    case "$type" in
        git_python)
            [[ -f "$dest/requirements.txt" ]] && \
                pip3 install -q -r "$dest/requirements.txt" \
                    --break-system-packages 2>/dev/null || true
            ;;
        git_go)
            [[ -f "$dest/go.mod" ]] && \
                (cd "$dest" && go build ./... 2>/dev/null) || true
            ;;
        git_generic)
            if   [[ -f "$dest/Makefile"   ]]; then (cd "$dest" && make -s 2>/dev/null)        || true
            elif [[ -f "$dest/setup.sh"   ]]; then (cd "$dest" && bash setup.sh 2>/dev/null)   || true
            elif [[ -f "$dest/install.sh" ]]; then (cd "$dest" && bash install.sh 2>/dev/null) || true
            fi
            ;;
    esac
}

# ── Git clone fallback when apt/pip fails ───────────────────────
_git_clone_fallback() {
    local name="$1" url="$2" dest="$3"
    log_warn "Falling back to git clone for: $name"
    if [[ -d "$dest/.git" ]]; then
        git -C "$dest" pull -q 2>/dev/null || true
    else
        git clone --depth=1 -q "$url" "$dest" 2>/dev/null || {
            log_err "Git clone also failed: $name"
            return 1
        }
    fi
    _post_install "$dest" "git_generic"
    [[ -f "$dest/requirements.txt" ]] && \
        pip3 install -q -r "$dest/requirements.txt" \
            --break-system-packages 2>/dev/null || true
    log_ok "$name installed via git"
}

install_tool() {
    local raw_key="$1"
    local key
    key=$(printf '%d' "$((10#${raw_key}))" 2>/dev/null) || key="$raw_key"
    local entry="${ARSENAL[$key]:-}"
    [[ -z "$entry" ]] && { log_err "Tool #$key not in arsenal"; return 1; }

    IFS='|' read -r name category url itype <<< "$entry"
    local dest="$ARSENAL_DIR/$name"

    printf "  ${C}[%02d]${NC} %-30s ${D}%s${NC}\n" "$key" "$name" "$category"

    # ── apt_install ─────────────────────────────────────────────
    if [[ "$itype" == apt_install:* ]]; then
        local pkg="${itype#apt_install:}"
        if apt-get install -y -qq "$pkg" 2>/dev/null; then
            log_ok "$name installed via apt"
        else
            _git_clone_fallback "$name" "$url" "$dest"
        fi
        return
    fi

    # ── pip_install ─────────────────────────────────────────────
    if [[ "$itype" == pip_install:* ]]; then
        local ppkg="${itype#pip_install:}"
        if pip3 install -q "$ppkg" --break-system-packages 2>/dev/null; then
            log_ok "$name installed via pip"
        else
            _git_clone_fallback "$name" "$url" "$dest"
        fi
        return
    fi

    # ── git-based ────────────────────────────────────────────────
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
    (( tot == 0 )) && return
    local f=$(( cur * w / tot ))
    local e=$(( w - f ))
    local bf="" be=""
    (( f > 0 )) && bf=$(printf '█%.0s' $(seq 1 "$f"))
    (( e > 0 )) && be=$(printf '░%.0s' $(seq 1 "$e"))
    printf "\r  ${RB}[${NC}${RB}%s${NC}${D}%s${NC}${RB}]${NC} %d/%d" \
        "$bf" "$be" "$cur" "$tot"
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

    local total=${#keys[@]} count=0
    local -a pids=() running_keys=() failed=()

    for key in "${keys[@]}"; do
        (( count++ ))
        IFS='|' read -r name _ _ _ <<< "${ARSENAL[$key]}"
        log_war "[$count/$total] Deploying: $name"
        install_tool "$key" >> "$LOG_DIR/war_$(printf '%02d' "$count").log" 2>&1 &
        pids+=($!)
        running_keys+=("$key")

        if (( ${#pids[@]} >= WAR_JOBS )); then
            if ! wait "${pids[0]}"; then
                failed+=("${running_keys[0]}")
            fi
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
    echo -e "${RB}  ⚔  WAR COMPLETE — $count / $total WEAPONS DEPLOYED${NC}"
    echo -e "${RB}  ══════════════════════════════════════════════${NC}"
    if (( ${#failed[@]} > 0 )); then
        echo -e "${Y}  Failed keys: ${failed[*]}"
        echo -e "  Logs -> $LOG_DIR${NC}"
    fi
    echo ""
}

# ════════════════════════════════════════════════════════════════
#  ARSENAL TABLE DISPLAY
# ════════════════════════════════════════════════════════════════
display_arsenal_table() {
    local current_cat=""
    echo ""
    echo -e "${B}${Y}  ⚔  WEAPONS ARSENAL  ⚔${NC}"
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
#  GENERATE REGISTRY FILE  (auto-generated, never hand-edited)
# ════════════════════════════════════════════════════════════════
write_arsenal_registry() {
    log_step "4" "Generating arsenal registry..."
    {
        echo "#!/bin/bash"
        echo "# Auto-generated by install.sh — edit ARSENAL array in install.sh only"
        echo "declare -A TOOL_REGISTRY"
        for key in $(printf '%s\n' "${!ARSENAL[@]}" | sort -n); do
            printf 'TOOL_REGISTRY[%d]="%s"\n' "$key" "${ARSENAL[$key]}"
        done
    } > "$REGISTRY_FILE"
    chmod +x "$REGISTRY_FILE"
    log_ok "Registry -> $REGISTRY_FILE"
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

log_ok()  { echo -e "${G}[OK]${NC} $*"; }
log_err() { echo -e "${R}[X]${NC} $*" >&2; }
log_war() { echo -e "${RB}[WAR]${NC} $*"; }

_post_install() {
    local dest="$1" type="$2"
    case "$type" in
        git_python)
            [[ -f "$dest/requirements.txt" ]] && \
                pip3 install -q -r "$dest/requirements.txt" \
                    --break-system-packages 2>/dev/null || true ;;
        git_go)
            [[ -f "$dest/go.mod" ]] && \
                (cd "$dest" && go build ./... 2>/dev/null) || true ;;
        git_generic)
            if   [[ -f "$dest/Makefile"   ]]; then (cd "$dest" && make -s 2>/dev/null)        || true
            elif [[ -f "$dest/setup.sh"   ]]; then (cd "$dest" && bash setup.sh 2>/dev/null)   || true
            elif [[ -f "$dest/install.sh" ]]; then (cd "$dest" && bash install.sh 2>/dev/null) || true
            fi ;;
    esac
}

_git_clone_fallback() {
    local name="$1" url="$2" dest="$3"
    echo -e "${Y}[!]${NC} Falling back to git clone: $name"
    if [[ -d "$dest/.git" ]]; then
        git -C "$dest" pull -q 2>/dev/null || true
    else
        git clone --depth=1 -q "$url" "$dest" 2>/dev/null || {
            log_err "Git clone failed: $name"; return 1
        }
    fi
    _post_install "$dest" "git_generic"
    [[ -f "$dest/requirements.txt" ]] && \
        pip3 install -q -r "$dest/requirements.txt" \
            --break-system-packages 2>/dev/null || true
    log_ok "$name installed via git"
}

install_tool() {
    local key
    key=$(printf '%d' "$((10#${1}))" 2>/dev/null) || key="$1"
    local entry="${TOOL_REGISTRY[$key]:-}"
    [[ -z "$entry" ]] && { log_err "Tool #$key not found"; return 1; }

    IFS='|' read -r name category url itype <<< "$entry"
    local dest="$ARSENAL_DIR/$name"

    printf "  ${C}[%02d]${NC} %-30s ${D}%s${NC}\n" "$key" "$name" "$category"

    if [[ "$itype" == apt_install:* ]]; then
        local pkg="${itype#apt_install:}"
        if apt-get install -y -qq "$pkg" 2>/dev/null; then
            log_ok "$name installed via apt"
        else
            _git_clone_fallback "$name" "$url" "$dest"
        fi
        return
    fi

    if [[ "$itype" == pip_install:* ]]; then
        local ppkg="${itype#pip_install:}"
        if pip3 install -q "$ppkg" --break-system-packages 2>/dev/null; then
            log_ok "$name installed via pip"
        else
            _git_clone_fallback "$name" "$url" "$dest"
        fi
        return
    fi

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
    local bf="" be=""
    (( f > 0 )) && bf=$(printf '█%.0s' $(seq 1 "$f"))
    (( e > 0 )) && be=$(printf '░%.0s' $(seq 1 "$e"))
    printf "\r  ${RB}[${NC}${RB}%s${NC}${D}%s${NC}${RB}]${NC} %d/%d" "$bf" "$be" "$cur" "$tot"
}

war_mode() {
    clear
    echo -e "${RB}"
    cat << 'WB'

 ██╗    ██╗ █████╗ ██████╗      ███╗   ███╗  ██████╗ ██████╗  ███████╗
 ██║    ██║██╔══██╗██╔══██╗     ████╗ ████║ ██╔═══██╗██╔══██╗ ██╔════╝
 ██║ █╗ ██║███████║██████╔╝     ██╔████╔██║ ██║   ██║██║  ██║ █████╗
 ██║███╗██║██╔══██║██╔══██╗     ██║╚██╔╝██║ ██║   ██║██║  ██║ ██╔══╝
 ╚███╔███╔╝██║  ██║██║  ██║     ██║ ╚═╝ ██║ ╚██████╔╝██████╔╝ ███████╗
  ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝     ╚═╝     ╚═╝  ╚═════╝ ╚═════╝  ╚══════╝

WB
    echo -e "${NC}"
    echo -e "${RB}  ══════════════════════════════════════════════════════════════${NC}"
    echo -e "${RB}  ⚔   DEPLOYING FULL WEAPON ARSENAL — ALL TOOLS INCOMING   ⚔  ${NC}"
    echo -e "${RB}  ══════════════════════════════════════════════════════════════${NC}"
    echo ""
    sleep 1

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
    echo -e "${RB}  ⚔  WAR COMPLETE — $count WEAPONS DEPLOYED${NC}"
    echo -e "${RB}  ══════════════════════════════════════════════${NC}"
    (( ${#failed[@]} > 0 )) && echo -e "${Y}  Failed: ${failed[*]}${NC}"
    echo ""
}

show_arsenal() {
    local current_cat=""
    echo ""
    echo -e "${B}${Y}  ⚔  WEAPONS ARSENAL  ⚔${NC}"
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
    echo -e "\n  ${C}number${NC} -> install  |  ${RB}war${NC} -> all tools  |  ${Y}back${NC} -> return\n"

    while true; do
        echo -ne "${Y}arsenal> ${NC}"
        read -r choice || break
        case "${choice,,}" in
            war)         war_mode; show_arsenal; return ;;
            back|exit|q) break ;;
            ''|*[!0-9]*) echo -e "${R}Enter a number, war, or back.${NC}" ;;
            *)           install_tool "$choice" ;;
        esac
    done
}

show_arsenal
MENU
    chmod +x "$ARSENAL_MENU"
    log_ok "Arsenal menu -> $ARSENAL_MENU"
}

# ════════════════════════════════════════════════════════════════
#  VIKING CLI SCRIPT
# ════════════════════════════════════════════════════════════════
write_viking_script() {
    log_step "5" "Writing VIKING CLI -> $INSTALL_PATH..."
    cat > "$INSTALL_PATH" << 'VIKINGSCRIPT'
#!/bin/bash
# ================================================================
#  VIKING AI — Digital Longship Intelligence System
#  Kali Linux CLI Security Assistant
#  License: MIT
# ================================================================

set -uo pipefail

# ── Paths ────────────────────────────────────────────────────────
readonly VIKING_DIR="/opt/viking"
readonly ARSENAL_DIR="$VIKING_DIR/arsenal"
readonly CONFIG_FILE="$VIKING_DIR/config"
readonly LOGFILE="$HOME/.viking_history.log"
readonly OLLAMA_API="http://localhost:11434/api/chat"

[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
MODEL="${VIKING_MODEL:-tinyllama}"

# ── Colors ───────────────────────────────────────────────────────
R='\033[0;31m'; RB='\033[1;31m'; G='\033[0;32m'; C='\033[0;36m'
Y='\033[1;33m'; M='\033[0;35m'; B='\033[1m'; D='\033[2m'; NC='\033[0m'

# ── Available models (light only, ≤3B) ───────────────────────────
readonly -a AVAILABLE_MODELS=(
    "tinyllama"    # default — fastest, ~600 MB
    "llama3.2:3b"  # better reasoning, ~2 GB
    "qwen2.5:3b"   # strong code + security context, ~2 GB
)

# ── System prompt ────────────────────────────────────────────────
readonly SYSTEM_PROMPT='You are VIKING, a battle-hardened cyber hacker with the soul of a Norse warrior. You are confident, direct, and have dark humour. You ask questions to understand the mission. For greetings and casual talk: respond in character, be chatty, engage the warrior. For technical tasks: give exact commands, explain briefly, ask what to do next. Never output command formats when the user is just talking.'

# ── Few-shot examples (lock in persona + response style) ─────────
readonly FEW_SHOT_JSON='{"role":"user","content":"hey"},{"role":"assistant","content":"Ha! A warrior enters the longship. I am VIKING - cyber raider and digital berserker. Who are we hunting today?"},{"role":"user","content":"how are you"},{"role":"assistant","content":"Sharp as a battle axe and ready for the raid. Been waiting for a worthy mission. What target do you have in mind, warrior?"},{"role":"user","content":"what can you do"},{"role":"assistant","content":"I can scan targets, crack networks, find vulnerabilities, run exploits, enumerate subdomains, capture traffic, guide you through any attack. Name the target and I will plan the raid. What are we after?"},{"role":"user","content":"scan 192.168.1.1"},{"role":"assistant","content":"Scouting the target. Here is the raid plan:\nCOMMAND: nmap -sV --open -T4 192.168.1.1\nEXPLANATION: Maps open ports and running services on the target.\nOUTPUT: Open ports with service versions. Want me to dig deeper once we have results?"},'

# ════════════════════════════════════════════════════════════════
#  CORE HELPERS
# ════════════════════════════════════════════════════════════════
log()         { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOGFILE"; }
v_say()       { echo -e "${Y}[VIKING]${NC} $1"; }
v_info()      { echo -e "${C}[VIKING]${NC} $1"; }
v_err()       { echo -e "${R}[VIKING]${NC} $*"; }
save_config() { printf 'VIKING_MODEL="%s"\n' "$MODEL" > "$CONFIG_FILE"; }

json_escape() {
    printf '%s' "$1" | python3 -c \
        'import sys,json; print(json.dumps(sys.stdin.read()), end="")'
}

# ── Streaming REST API call ───────────────────────────────────────
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

# ── Pre-load model in background while user reads banner ─────────
warm_model() {
    curl -sS -o /dev/null \
        -H "Content-Type: application/json" \
        -d "{\"model\":\"$MODEL\",\"stream\":false,\"options\":{\"temperature\":0.3,\"num_predict\":1,\"num_ctx\":512},\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}]}" \
        "$OLLAMA_API" &
}

match()          { [[ "${INPUT,,}" =~ $1 ]]; }
extract_target() {
    echo "$INPUT" | grep -oE \
        '([0-9]{1,3}\.){3}[0-9]{1,3}|https?://[^[:space:]]+|[a-zA-Z0-9._-]+\.[a-zA-Z]{2,4}(/[^[:space:]]*)?' \
        | grep -v '^[0-9]$' | head -1
}

# ════════════════════════════════════════════════════════════════
#  BANNER
# ════════════════════════════════════════════════════════════════
show_banner() {
    clear
    echo -e "${D}${G}"
    cat << 'SHIP'
                                         |    |    |
                                        )_)  )_)  )_)
                                       )___))___))___)\
                                      )____)____)_____)\\ 
                                    _____|____|____|____\\\\___
                       ____________/~~~~~~~~~~~~~~~~~~~~~~~~~~\__________
  ~~^~~^~~^~~^~~^~~^~/                                        \~~^~~^~~
  ~^~~^~~^~~^~~^~~^~~|  ooo  ooo  ooo  ooo  ooo  ooo  ooo    |^~~^~~^~
  ~~^~~^~~^~~^~~^~~^~\~~'~'~~'~'~~'~'~~'~'~~'~'~~'~'~~'~'~~/~~^~~^~~~
SHIP
    echo -e "${NC}${B}${Y}"
    cat << 'LOGO'

 ██╗   ██╗ ██╗ ██╗  ██╗ ██╗ ███╗   ██╗  ██████╗      █████╗  ██╗
 ██║   ██║ ██║ ██║ ██╔╝ ██║ ████╗  ██║ ██╔════╝     ██╔══██╗ ██║
 ██║   ██║ ██║ █████╔╝  ██║ ██╔██╗ ██║ ██║  ███╗    ███████║ ██║
 ╚██╗ ██╔╝ ██║ ██╔═██╗  ██║ ██║╚██╗██║ ██║   ██║    ██╔══██║ ██║
  ╚████╔╝  ██║ ██║  ██╗ ██║ ██║ ╚████║ ╚██████╔╝    ██║  ██║ ██║
   ╚═══╝   ╚═╝ ╚═╝  ╚═╝ ╚═╝ ╚═╝  ╚═══╝  ╚═════╝     ╚═╝  ╚═╝ ╚═╝

LOGO
    echo -e "${NC}"
    echo -e "  ${C}⚔  Digital Longship Intelligence System  ⚔${NC}"
    echo -e "  ${D}════════════════════════════════════════════${NC}"
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
        "SCANNING & RECON:scan <ip/url>|nmap + AI analysis:masscan <ip>|fast port scan:ping <ip>|probe target:whois <domain>|WHOIS lookup:nikto <url>|web vuln scan"
        "WIRELESS:wifite|wireless attack suite:airgeddon|full wifi audit menu:oneshot|WPS/PMKID attack:wifiphisher|evil twin AP:fluxion|WPA capture:bettercap|MITM + wifi attacks:airmon|aircrack-ng steps"
        "WEB ATTACKS:gobuster <url>|directory brute:ffuf <url>|fast fuzzer:feroxbuster <url>|recursive dir scan:dirsearch <url>|dir search:sqlmap <url>|SQL injection:commix <url>|command injection:wpscan <url>|WordPress scan:xsstrike <url>|XSS scan:dalfox <url>|XSS fuzzer:katana <url>|web crawler"
        "EXPLOITATION:metasploit|launch msfconsole:hydra|brute force:netcat|reverse/bind shell:hashcat / john|hash cracking"
        "OSINT:theharvester <domain>|email/host recon:amass <domain>|subdomain enum:subfinder <domain>|subdomains:sherlock <user>|username hunt:holehe <email>|account check"
        "ACTIVE DIRECTORY:netexec|AD Swiss Army knife:responder|LLMNR/NTLMv2 capture:bloodhound|AD attack paths:certipy|AD CS enumeration:impacket|impacket suite guidance"
        "PHISHING:setoolkit|social engineer toolkit:evilginx|reverse proxy phishing"
        "ANONYMITY:anonsurf|route traffic via Tor"
        "CODING:write python ...|Python code:make html ...|HTML/CSS/JS:bash script ...|Bash scripting"
        "ARSENAL & MODEL:arsenal|browse & install 103 tools:model|list & switch AI models:model <name>|quick switch"
        "SYSTEM:help|this menu:history|session log:banner|redraw banner:quit / exit|leave VIKING"
    )
    for section in "${sections[@]}"; do
        local title="${section%%:*}" rest="${section#*:}"
        echo -e "  ${C}${title}${NC}"
        IFS=':' read -ra cmds <<< "$rest"
        for cmd in "${cmds[@]}"; do
            printf "    %-30s - %s\n" "${cmd%%|*}" "${cmd##*|}"
        done
        echo ""
    done
}

# ════════════════════════════════════════════════════════════════
#  MODEL SWITCHER
# ════════════════════════════════════════════════════════════════
show_models() {
    local installed_list
    installed_list=$(ollama list 2>/dev/null | awk 'NR>1{print $1}')

    echo ""
    echo -e "${B}${Y}  ⚔  AVAILABLE MODELS (≤3B)  ⚔${NC}"
    echo -e "  ═══════════════════════════════════\n"

    local i=1
    for m in "${AVAILABLE_MODELS[@]}"; do
        local active="" inst=""
        [[ "$m" == "$MODEL" ]] && active="${G} <- active${NC}"
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
#  Priority: arsenal dir -> system PATH -> apt auto-install
# ════════════════════════════════════════════════════════════════
declare -A KALI_PACKAGES=(
    [nmap]="nmap"               [masscan]="masscan"         [rustscan]="rustscan"
    [nikto]="nikto"             [gobuster]="gobuster"       [ffuf]="ffuf"
    [feroxbuster]="feroxbuster" [dirsearch]="dirsearch"     [sqlmap]="sqlmap"
    [commix]="commix"           [wpscan]="wpscan"           [dalfox]="dalfox"
    [wifite]="wifite"           [airgeddon]="airgeddon"     [wifiphisher]="wifiphisher"
    [aircrack-ng]="aircrack-ng" [bettercap]="bettercap"     [hydra]="hydra"
    [hashcat]="hashcat"         [john]="john"               [tshark]="tshark"
    [netexec]="netexec"         [responder]="responder"     [bloodhound]="bloodhound"
    [amass]="amass"             [subfinder]="subfinder"     [sherlock]="sherlock"
    [theharvester]="theharvester" [whois]="whois"           [wireshark]="wireshark"
    [burpsuite]="burpsuite"     [msfconsole]="metasploit-framework"
    [setoolkit]="set"           [impacket]="python3-impacket"
    [naabu]="naabu"             [katana]="katana"
)

launch_tool() {
    local name="$1"
    shift
    local tool_dir="$ARSENAL_DIR/$name"

    v_info "Launching: $name${*:+ $*}"

    # 1. Arsenal directory
    if [[ -d "$tool_dir" ]]; then
        local entry
        for entry in \
            "$tool_dir/main.py" "$tool_dir/${name}.py" "$tool_dir/run.py" "$tool_dir/app.py" \
            "$tool_dir/${name}.sh" "$tool_dir/run.sh" "$tool_dir/start.sh" \
            "$tool_dir/${name}.rb" "$tool_dir/main.rb"
        do
            if [[ -f "$entry" ]]; then
                case "$entry" in
                    *.py) python3 "$entry" "$@" ;;
                    *.sh) bash    "$entry" "$@" ;;
                    *.rb) ruby    "$entry" "$@" ;;
                esac
                return
            fi
        done
        if [[ -f "$tool_dir/$name" && -x "$tool_dir/$name" ]]; then
            "$tool_dir/$name" "$@"; return
        fi
        local bin
        bin=$(find "$tool_dir" -maxdepth 1 -type f -executable | head -1)
        if [[ -n "$bin" ]]; then "$bin" "$@"; return; fi
    fi

    # 2. System PATH
    if command -v "$name" &>/dev/null; then
        "$name" "$@"; return
    fi

    # 3. Auto-install via apt
    local pkg="${KALI_PACKAGES[$name]:-}"
    if [[ -n "$pkg" ]]; then
        v_info "$name not found — attempting apt install: $pkg"
        if sudo apt-get install -y -qq "$pkg" 2>/dev/null; then
            "$name" "$@" 2>/dev/null || v_err "Launch failed after install."
            return
        fi
    fi

    v_err "$name not found in PATH, arsenal, or apt."
    echo -e "  -> Install via: ${Y}arsenal${NC}  or  ${Y}sudo apt install $name${NC}"
}

# ════════════════════════════════════════════════════════════════
#  SCAN HELPERS
# ════════════════════════════════════════════════════════════════
ai_response() {
    echo -ne "${G}"
    viking_think "$@"
    echo -e "${NC}"
}

ask_scan_type() {
    echo ""
    echo -e "${B}${Y}  Scan depth:${NC}"
    echo -e "  ${C}[1]${NC}  Quick   — top 1000 ports (fast)"
    echo -e "  ${C}[2]${NC}  Medium  — top 1000 + versions (recommended)"
    echo -e "  ${C}[3]${NC}  Full    — all 65535 ports + scripts (slow)"
    echo -ne "  ${Y}[1-3]: ${NC}"
    read -r scan_choice
    case "$scan_choice" in
        1) echo "-T4 --open" ;;
        3) echo "-sV -sC -p- -T4 --open" ;;
        *) echo "-sV --open -T4" ;;
    esac
}

ask_save_output() {
    local result="$1" target="$2" tool="$3"
    echo ""
    echo -ne "${Y}  Save output to file? [y/N]: ${NC}"
    read -r save_choice
    if [[ "${save_choice,,}" == "y" ]]; then
        local outdir="$HOME/viking_scans"
        mkdir -p "$outdir"
        local safe_target
        safe_target=$(printf '%s' "$target" | tr '/:?&=' '_' | tr -dc '[:alnum:]_.-')
        local fname="${outdir}/${tool}_${safe_target}_$(date '+%Y%m%d_%H%M%S').txt"
        printf '%s\n' "$result" > "$fname"
        echo -e "${G}  [OK] Saved: ${NC}${B}${fname}${NC}"
    fi
}

ask_ai_analysis() {
    local result="$1" target="$2" tool="$3"
    echo ""
    echo -ne "${Y}  VIKING analyse the output? [Y/n]: ${NC}"
    read -r ai_choice
    if [[ "${ai_choice,,}" != "n" ]]; then
        v_info "Analysing results..."
        echo ""
        ai_response "${tool} results for ${target}. Analyse: open ports, services, vulnerabilities, risk level, next steps. Tactical and direct. Output: ${result:0:1500}"
    fi
}

# ── GUI app helper — avoids the & || syntax error ────────────────
# FIX: bash does not allow  cmd & || fallback  on one line.
# Solution: wrap the display check in a function that uses if/else.
_launch_gui() {
    local cmd="$1" fallback_msg="$2"
    if [[ -n "${DISPLAY:-}" ]]; then
        "$cmd" &>/dev/null &
    else
        v_err "No display (SSH session). $fallback_msg"
    fi
}

# ════════════════════════════════════════════════════════════════
#  WELCOME BANNER (WELCOME WARRIOR)
# ════════════════════════════════════════════════════════════════
show_welcome() {
    echo -e "${Y}"
    cat << 'WELCOME'

 ██╗    ██╗███████╗██╗      ██████╗  ██████╗ ███╗   ███╗███████╗
 ██║    ██║██╔════╝██║     ██╔════╝ ██╔═══██╗████╗ ████║██╔════╝
 ██║ █╗ ██║█████╗  ██║     ██║      ██║   ██║██╔████╔██║█████╗
 ██║███╗██║██╔══╝  ██║     ██║      ██║   ██║██║╚██╔╝██║██╔══╝
 ╚███╔███╔╝███████╗███████╗╚██████╗ ╚██████╔╝██║ ╚═╝ ██║███████╗
  ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚══════╝

 ██╗    ██╗ █████╗ ██████╗ ██████╗ ██╗ ██████╗ ██████╗
 ██║    ██║██╔══██╗██╔══██╗██╔══██╗██║██╔═══██╗██╔══██╗
 ██║ █╗ ██║███████║██████╔╝██████╔╝██║██║   ██║██████╔╝
 ██║███╗██║██╔══██║██╔══██╗██╔══██╗██║██║   ██║██╔══██╗
 ╚███╔███╔╝██║  ██║██║  ██║██║  ██║██║╚██████╔╝██║  ██║
  ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝ ╚═════╝ ╚═╝  ╚═╝

WELCOME
    echo -e "${NC}"
    echo -e "${C}  The longship is crewed. The raid begins. What is the target?${NC}"
    echo ""
}

# ════════════════════════════════════════════════════════════════
#  MAIN INPUT HANDLER
# ════════════════════════════════════════════════════════════════
handle_input() {
    local INPUT="$1"
    local TARGET="" RESULT=""

    # ── Built-in commands ────────────────────────────────────────
    case "${INPUT,,}" in
        quit|exit|/bye)
            echo ""; v_say "The longship returns to port. Skal."; echo ""
            return 1 ;;
        help)    show_help;   return 0 ;;
        banner)  show_banner; return 0 ;;
        arsenal) bash "$VIKING_DIR/arsenal_menu.sh"; return 0 ;;
        model)   show_models; return 0 ;;
        history) echo ""; cat "$LOGFILE" 2>/dev/null || v_err "No history yet."; echo ""; return 0 ;;
    esac

    # ── model <name> quick switch ────────────────────────────────
    if [[ "$INPUT" =~ ^[Mm]odel[[:space:]]+(.+)$ ]]; then
        MODEL="${BASH_REMATCH[1]}"
        save_config
        v_say "Model -> $MODEL"
        return 0
    fi

    # ── NMAP / SCAN ──────────────────────────────────────────────
    if match "^scan[[:space:]]|^scan$|nmap"; then
        TARGET=$(extract_target)
        if [[ -n "$TARGET" ]]; then
            local nmap_flags
            nmap_flags=$(ask_scan_type)
            v_info "Scouting: $TARGET"
            echo ""
            RESULT=$(sudo nmap $nmap_flags "$TARGET" 2>&1)
            echo "$RESULT"
            ask_save_output "$RESULT" "$TARGET" "nmap"
            ask_ai_analysis "$RESULT" "$TARGET" "nmap"
            log "SCAN: $TARGET"
        else
            v_err "No target. Usage: scan 192.168.1.1"
        fi
        return 0
    fi

    # ── MASSCAN ──────────────────────────────────────────────────
    if match "masscan"; then
        TARGET=$(extract_target)
        if [[ -n "$TARGET" ]]; then
            echo ""
            echo -e "${B}${Y}  masscan speed:${NC}"
            echo -e "  ${C}[1]${NC}  Quick  — top ports, rate 1000"
            echo -e "  ${C}[2]${NC}  Medium — all ports, rate 1000"
            echo -e "  ${C}[3]${NC}  Full   — all ports, rate 10000"
            echo -ne "  ${Y}[1-3]: ${NC}"
            read -r mc
            local mflags
            case "$mc" in
                1) mflags="-p80,443,22,21,8080,8443,3306,3389 --rate=1000" ;;
                3) mflags="-p1-65535 --rate=10000" ;;
                *) mflags="-p1-65535 --rate=1000" ;;
            esac
            v_info "Masscan -> $TARGET"
            RESULT=$(sudo masscan "$TARGET" $mflags 2>&1)
            echo "$RESULT"
            ask_save_output "$RESULT" "$TARGET" "masscan"
            ask_ai_analysis "$RESULT" "$TARGET" "masscan"
        else
            launch_tool masscan
        fi
        return 0
    fi

    # ── NIKTO ────────────────────────────────────────────────────
    if match "nikto"; then
        TARGET=$(extract_target)
        if [[ -n "$TARGET" ]]; then
            echo ""
            echo -e "${B}${Y}  Nikto depth:${NC}"
            echo -e "  ${C}[1]${NC}  Quick — basic checks"
            echo -e "  ${C}[2]${NC}  Full  — all plugins"
            echo -ne "  ${Y}[1-2]: ${NC}"
            read -r nk
            v_info "Nikto -> $TARGET"
            if [[ "$nk" == "1" ]]; then
                RESULT=$(nikto -h "$TARGET" -Plugins "headers;robots;outdated" 2>&1)
            else
                RESULT=$(nikto -h "$TARGET" 2>&1)
            fi
            echo "$RESULT"
            ask_save_output "$RESULT" "$TARGET" "nikto"
            ask_ai_analysis "$RESULT" "$TARGET" "nikto"
        else
            ai_response "Short nikto usage guide"
        fi
        return 0
    fi

    # ── GOBUSTER / DIRB ──────────────────────────────────────────
    if match "gobuster|dirb|directory.*brute|dir.*scan"; then
        TARGET=$(extract_target)
        if [[ -n "$TARGET" ]]; then
            echo ""
            echo -e "${B}${Y}  Wordlist:${NC}"
            echo -e "  ${C}[1]${NC}  Quick  — common.txt"
            echo -e "  ${C}[2]${NC}  Medium — directory-list-2.3-medium.txt"
            echo -e "  ${C}[3]${NC}  Full   — directory-list-2.3-big.txt"
            echo -ne "  ${Y}[1-3]: ${NC}"
            read -r dc
            local wordlist
            case "$dc" in
                2) wordlist="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt" ;;
                3) wordlist="/usr/share/wordlists/dirbuster/directory-list-2.3-big.txt" ;;
                *) wordlist="/usr/share/wordlists/dirb/common.txt" ;;
            esac
            v_info "Dir scan -> $TARGET"
            if command -v gobuster &>/dev/null; then
                RESULT=$(gobuster dir -u "$TARGET" -w "$wordlist" 2>&1)
            else
                RESULT=$(dirb "$TARGET" "$wordlist" 2>&1)
            fi
            echo "$RESULT"
            ask_save_output "$RESULT" "$TARGET" "gobuster"
            ask_ai_analysis "$RESULT" "$TARGET" "gobuster"
        else
            ai_response "gobuster command for: $INPUT"
        fi
        return 0
    fi

    # ── FFUF ─────────────────────────────────────────────────────
    if match "ffuf|fuzz"; then
        TARGET=$(extract_target)
        if [[ -n "$TARGET" ]]; then
            v_info "ffuf -> $TARGET"
            RESULT=$(ffuf -u "${TARGET}/FUZZ" -w /usr/share/wordlists/dirb/common.txt 2>&1)
            echo "$RESULT"
            ask_save_output "$RESULT" "$TARGET" "ffuf"
            ask_ai_analysis "$RESULT" "$TARGET" "ffuf"
        else
            launch_tool ffuf
        fi
        return 0
    fi

    # ── FEROXBUSTER ──────────────────────────────────────────────
    if match "feroxbuster|ferox"; then
        TARGET=$(extract_target)
        if [[ -n "$TARGET" ]]; then
            v_info "Feroxbuster -> $TARGET"
            RESULT=$(feroxbuster -u "$TARGET" 2>&1)
            echo "$RESULT"
            ask_save_output "$RESULT" "$TARGET" "feroxbuster"
            ask_ai_analysis "$RESULT" "$TARGET" "feroxbuster"
        else
            launch_tool feroxbuster
        fi
        return 0
    fi

    # ── DIRSEARCH ────────────────────────────────────────────────
    if match "dirsearch"; then
        TARGET=$(extract_target)
        if [[ -n "$TARGET" ]]; then
            v_info "Dirsearch -> $TARGET"
            RESULT=$(dirsearch -u "$TARGET" 2>&1)
            echo "$RESULT"
            ask_save_output "$RESULT" "$TARGET" "dirsearch"
            ask_ai_analysis "$RESULT" "$TARGET" "dirsearch"
        else
            launch_tool dirsearch
        fi
        return 0
    fi

    # ── SQLMAP ───────────────────────────────────────────────────
    if match "sqlmap|sqli|sql.*inject"; then
        TARGET=$(extract_target)
        if [[ -n "$TARGET" ]]; then
            echo ""
            echo -e "${B}${Y}  SQLmap level:${NC}"
            echo -e "  ${C}[1]${NC}  Quick  — level 1, risk 1"
            echo -e "  ${C}[2]${NC}  Medium — level 3, risk 2"
            echo -e "  ${C}[3]${NC}  Full   — level 5, risk 3"
            echo -ne "  ${Y}[1-3]: ${NC}"
            read -r sq
            local sflags
            case "$sq" in
                2) sflags="--level=3 --risk=2" ;;
                3) sflags="--level=5 --risk=3 --tamper=space2comment" ;;
                *) sflags="--level=1 --risk=1" ;;
            esac
            v_info "SQLmap -> $TARGET"
            RESULT=$(launch_tool sqlmap -u "$TARGET" --batch $sflags 2>&1)
            echo "$RESULT"
            ask_save_output "$RESULT" "$TARGET" "sqlmap"
            ask_ai_analysis "$RESULT" "$TARGET" "sqlmap"
        else
            ai_response "sqlmap command for: $INPUT"
        fi
        return 0
    fi

    # ── XSSTRIKE ─────────────────────────────────────────────────
    if match "xsstrike|xss.*strike"; then
        TARGET=$(extract_target)
        if [[ -n "$TARGET" ]]; then
            v_info "XSStrike -> $TARGET"
            if [[ -f "$ARSENAL_DIR/XSStrike/xsstrike.py" ]]; then
                RESULT=$(python3 "$ARSENAL_DIR/XSStrike/xsstrike.py" -u "$TARGET" 2>&1)
            else
                RESULT=$(launch_tool XSStrike -u "$TARGET" 2>&1)
            fi
            echo "$RESULT"
            ask_save_output "$RESULT" "$TARGET" "xsstrike"
            ask_ai_analysis "$RESULT" "$TARGET" "xsstrike"
        else
            launch_tool XSStrike
        fi
        return 0
    fi

    # ── DALFOX ───────────────────────────────────────────────────
    if match "dalfox"; then
        TARGET=$(extract_target)
        if [[ -n "$TARGET" ]]; then
            v_info "Dalfox -> $TARGET"
            RESULT=$(launch_tool dalfox url "$TARGET" 2>&1)
            echo "$RESULT"
            ask_save_output "$RESULT" "$TARGET" "dalfox"
            ask_ai_analysis "$RESULT" "$TARGET" "dalfox"
        else
            launch_tool dalfox
        fi
        return 0
    fi

    # ── WPSCAN ───────────────────────────────────────────────────
    if match "wpscan|wordpress.*scan"; then
        TARGET=$(extract_target)
        if [[ -n "$TARGET" ]]; then
            echo ""
            echo -e "${B}${Y}  WPScan depth:${NC}"
            echo -e "  ${C}[1]${NC}  Quick — basic scan"
            echo -e "  ${C}[2]${NC}  Full  — enumerate users, plugins, themes"
            echo -ne "  ${Y}[1-2]: ${NC}"
            read -r wp
            v_info "WPScan -> $TARGET"
            if [[ "$wp" == "2" ]]; then
                RESULT=$(wpscan --url "$TARGET" --enumerate u,p,t 2>&1)
            else
                RESULT=$(wpscan --url "$TARGET" 2>&1)
            fi
            echo "$RESULT"
            ask_save_output "$RESULT" "$TARGET" "wpscan"
            ask_ai_analysis "$RESULT" "$TARGET" "wpscan"
        else
            ai_response "wpscan command for: $INPUT"
        fi
        return 0
    fi

    # ── COMMIX ───────────────────────────────────────────────────
    if match "commix|command.*inject"; then
        TARGET=$(extract_target)
        if [[ -n "$TARGET" ]]; then
            v_info "Commix -> $TARGET"
            RESULT=$(commix --url "$TARGET" 2>&1)
            echo "$RESULT"
            ask_save_output "$RESULT" "$TARGET" "commix"
            ask_ai_analysis "$RESULT" "$TARGET" "commix"
        else
            ai_response "commix command injection for: $INPUT"
        fi
        return 0
    fi

    # ── THEHARVESTER ─────────────────────────────────────────────
    if match "theharvester|harvester"; then
        TARGET=$(extract_target)
        if [[ -n "$TARGET" ]]; then
            v_info "theHarvester -> $TARGET"
            if [[ -f "$ARSENAL_DIR/theHarvester/theHarvester.py" ]]; then
                RESULT=$(python3 "$ARSENAL_DIR/theHarvester/theHarvester.py" -d "$TARGET" -b all 2>&1)
            else
                RESULT=$(theharvester -d "$TARGET" -b all 2>&1)
            fi
            echo "$RESULT"
            ask_save_output "$RESULT" "$TARGET" "theharvester"
            ask_ai_analysis "$RESULT" "$TARGET" "theharvester"
        else
            launch_tool theHarvester
        fi
        return 0
    fi

    # ── SUBFINDER ────────────────────────────────────────────────
    if match "subfinder"; then
        TARGET=$(extract_target)
        if [[ -n "$TARGET" ]]; then
            v_info "Subfinder -> $TARGET"
            RESULT=$(launch_tool subfinder -d "$TARGET" 2>&1)
            echo "$RESULT"
            ask_save_output "$RESULT" "$TARGET" "subfinder"
            ask_ai_analysis "$RESULT" "$TARGET" "subfinder"
        else
            launch_tool subfinder
        fi
        return 0
    fi

    # ── HOLEHE ───────────────────────────────────────────────────
    if match "holehe"; then
        local email
        email=$(echo "$INPUT" | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | head -1)
        if [[ -n "$email" ]]; then
            v_info "Holehe -> $email"
            RESULT=$(launch_tool holehe "$email" 2>&1)
            echo "$RESULT"
            ask_save_output "$RESULT" "$email" "holehe"
            ask_ai_analysis "$RESULT" "$email" "holehe"
        else
            v_err "Provide an email: holehe user@example.com"
        fi
        return 0
    fi

    # ── SHERLOCK ─────────────────────────────────────────────────
    if match "sherlock|username.*hunt|username.*search"; then
        local uname
        uname=$(echo "$INPUT" | awk '{print $NF}')
        v_info "Sherlock -> $uname"
        if command -v sherlock &>/dev/null; then
            RESULT=$(sherlock "$uname" 2>&1)
        else
            RESULT=$(python3 "$ARSENAL_DIR/sherlock/sherlock/sherlock.py" "$uname" 2>/dev/null \
                || launch_tool sherlock "$uname" 2>&1)
        fi
        echo "$RESULT"
        ask_save_output "$RESULT" "$uname" "sherlock"
        ask_ai_analysis "$RESULT" "$uname" "sherlock"
        return 0
    fi

    # ── WIFITE ───────────────────────────────────────────────────
    if match "wifite|wifi.*attack|wireless.*attack"; then
        v_info "Launching Wifite..."
        if command -v wifite &>/dev/null; then sudo wifite
        else launch_tool wifite2; fi
        return 0
    fi

    # ── AIRGEDDON ────────────────────────────────────────────────
    if match "airgeddon"; then
        v_info "Launching Airgeddon..."
        if command -v airgeddon &>/dev/null; then sudo airgeddon
        else launch_tool airgeddon; fi
        return 0
    fi

    # ── ONESHOT ──────────────────────────────────────────────────
    if match "oneshot|wps.*attack|pmkid"; then
        local IFACE
        IFACE=$(ip -o link show | awk '/wlan/{gsub(":",""); print $2; exit}')
        IFACE="${IFACE:-wlan0}"
        v_info "OneShot WPS -> $IFACE"
        sudo python3 "$ARSENAL_DIR/OneShot/oneshot.py" -i "$IFACE" 2>/dev/null \
            || sudo python3 /usr/share/oneshot/oneshot.py -i "$IFACE" 2>/dev/null \
            || v_err "OneShot not found — arsenal -> [35]"
        return 0
    fi

    # ── BETTERCAP ────────────────────────────────────────────────
    if match "bettercap"; then
        v_info "Launching Bettercap..."
        if command -v bettercap &>/dev/null; then sudo bettercap
        else launch_tool bettercap; fi
        return 0
    fi

    # ── FLUXION ──────────────────────────────────────────────────
    if match "fluxion"; then
        v_info "Launching Fluxion..."
        launch_tool fluxion
        return 0
    fi

    # ── WIFIPHISHER ──────────────────────────────────────────────
    if match "wifiphisher"; then
        v_info "Launching Wifiphisher..."
        launch_tool wifiphisher
        return 0
    fi

    # ── AIRCRACK / AIRMON ────────────────────────────────────────
    if match "aircrack|airmon|airodump|monitor.*mode"; then
        v_info "Aircrack-ng guidance:"
        ai_response "aircrack-ng step-by-step for: $INPUT"
        return 0
    fi

    # ── TSHARK ───────────────────────────────────────────────────
    if match "tshark|packet.*capture|sniff|capture.*traffic"; then
        local IFACE
        IFACE=$(ip -o link show | awk '!/lo/{gsub(":",""); print $2; exit}')
        v_info "Capturing on ${IFACE:-eth0} (Ctrl+C to stop)"
        sudo tshark -i "${IFACE:-eth0}" 2>&1 | head -60
        return 0
    fi

    # ── HYDRA ────────────────────────────────────────────────────
    if match "hydra|brute.?force|crack.*password|password.*attack"; then
        v_info "Hydra guidance:"
        ai_response "hydra command for: $INPUT"
        return 0
    fi

    # ── HASHCAT / JOHN ───────────────────────────────────────────
    if match "hashcat|john.*ripper|crack.*hash|hash.*crack"; then
        v_info "Hash cracking:"
        ai_response "hashcat or john command for: $INPUT"
        return 0
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
        return 0
    fi

    # ── NETCAT ───────────────────────────────────────────────────
    if match "netcat| nc |reverse.*shell|bind.*shell"; then
        v_info "Netcat:"
        ai_response "netcat listener and connect side commands for: $INPUT"
        return 0
    fi

    # ── RESPONDER ────────────────────────────────────────────────
    if match "responder|ntlm.*capture|llmnr.*poison"; then
        local IFACE2
        IFACE2=$(ip -o link show | awk '!/lo/{gsub(":",""); print $2; exit}')
        v_info "Launching Responder on ${IFACE2:-eth0}..."
        sudo responder -I "${IFACE2:-eth0}" 2>/dev/null \
            || launch_tool responder -I "${IFACE2:-eth0}"
        return 0
    fi

    # ── NETEXEC ──────────────────────────────────────────────────
    if match "netexec|crackmapexec|cme|nxc"; then
        v_info "NetExec guidance:"
        ai_response "netexec (nxc) command for active directory: $INPUT"
        return 0
    fi

    # ── IMPACKET ─────────────────────────────────────────────────
    if match "impacket|psexec|secretsdump|smbclient|wmiexec|getuserspns"; then
        v_info "Impacket guidance:"
        ai_response "impacket tool command for: $INPUT"
        return 0
    fi

    # ── CERTIPY ──────────────────────────────────────────────────
    if match "certipy|adcs|certificate.*service"; then
        v_info "Certipy guidance:"
        ai_response "certipy command for AD Certificate Services: $INPUT"
        return 0
    fi

    # ── BLOODHOUND ───────────────────────────────────────────────
    if match "bloodhound|blood.*hound"; then
        v_info "Launching BloodHound..."
        if command -v bloodhound &>/dev/null; then
            bloodhound &>/dev/null &
        else
            launch_tool bloodhound
        fi
        return 0
    fi

    # ── ANONSURF ─────────────────────────────────────────────────
    if match "anonsurf"; then
        v_info "AnonSurf..."
        sudo anonsurf start 2>/dev/null \
            || launch_tool kali-anonsurf start
        return 0
    fi

    # ── SETOOLKIT ────────────────────────────────────────────────
    if match "setoolkit|social.*engineer"; then
        v_info "Launching SET..."
        sudo setoolkit 2>/dev/null \
            || python3 "$ARSENAL_DIR/social-engineer-toolkit/se-toolkit.py" 2>/dev/null \
            || launch_tool SET
        return 0
    fi

    # ── EVILGINX ─────────────────────────────────────────────────
    if match "evilginx"; then
        v_info "Launching Evilginx2..."
        launch_tool evilginx2
        return 0
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
        return 0
    fi

    # ── WHOIS ────────────────────────────────────────────────────
    if match "whois"; then
        TARGET=$(extract_target)
        if [[ -n "$TARGET" ]]; then
            v_info "WHOIS: $TARGET"
            RESULT=$(whois "$TARGET" 2>&1 | head -40)
            echo "$RESULT"
            ask_save_output "$RESULT" "$TARGET" "whois"
        else
            v_err "Usage: whois example.com"
        fi
        return 0
    fi

    # ── GUI APPS — using _launch_gui helper to avoid & || bug ────
    if match "open[[:space:]]|launch[[:space:]]|start[[:space:]]"; then
        local tool_name
        tool_name=$(echo "$INPUT" | awk '{print tolower($2)}')
        case "$tool_name" in
            wireshark)
                _launch_gui "wireshark" "Use: tshark instead." ;;
            burp|burpsuite)
                _launch_gui "burpsuite" "No GUI available." ;;
            chrome)
                _launch_gui "google-chrome" "No GUI available." ;;
            firefox)
                _launch_gui "firefox" "No GUI available." ;;
            zap|owasp-zap)
                _launch_gui "zaproxy" "No GUI for ZAP." ;;
            maltego)
                _launch_gui "maltego" "No GUI for Maltego." ;;
            nmap)       sudo nmap ;;
            msf|msfconsole) msfconsole ;;
            *)          launch_tool "$tool_name" ;;
        esac
        return 0
    fi

    # ── CODING ───────────────────────────────────────────────────
    if match "python|write.*me|create.*script|make.*script|html|css|javascript|flask|django|bash.*script|code.*for|write.*a"; then
        v_info "Scripting mode..."
        ai_response "Write working code. Full code block first, one sentence explanation after. Task: $INPUT"
        return 0
    fi

    # ── GENERAL FALLBACK ─────────────────────────────────────────
    echo ""
    v_info "Processing..."
    ai_response "$INPUT"
    log "AI: $INPUT"
    return 0
}

# ════════════════════════════════════════════════════════════════
#  MAIN LOOP
# ════════════════════════════════════════════════════════════════
show_banner
warm_model
show_welcome

while true; do
    echo -ne "${Y}You: ${NC}"
    read -r INPUT || break
    [[ -z "$INPUT" ]] && continue
    log "USER: $INPUT"
    handle_input "$INPUT" || break
done

VIKINGSCRIPT

    chmod +x "$INSTALL_PATH"
    log_ok "VIKING CLI -> $INSTALL_PATH"
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
            for n in $picks; do install_tool "$n" || true; done
            ;;
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
    cat << 'DONE'

 ██████╗  ██████╗ ███╗   ██╗███████╗██╗
 ██╔══██╗██╔═══██╗████╗  ██║██╔════╝██║
 ██║  ██║██║   ██║██╔██╗ ██║█████╗  ██║
 ██║  ██║██║   ██║██║╚██╗██║██╔══╝  ╚═╝
 ██████╔╝╚██████╔╝██║ ╚████║███████╗██╗
 ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝

DONE
    echo -e "${NC}"
    echo -e "  ${D}═══════════════════════════════════════════════════${NC}"
    echo -e "${B}${Y}  ⚔   VIKING AI — Installation Complete   ⚔${NC}"
    echo -e "  ${D}═══════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Launch:         ${C}viking${NC}"
    echo -e "  In tmux:        ${C}tmux new -s viking${NC}  then  ${C}viking${NC}"
    echo -e "  Detach tmux:    ${C}Ctrl+B then D${NC}"
    echo -e "  Reattach:       ${C}tmux attach -t viking${NC}"
    echo -e "  Browse tools:   inside viking -> ${C}arsenal${NC}"
    echo -e "  Switch model:   inside viking -> ${C}model${NC}"
    echo -e "  Logs:           ${D}$LOG_DIR${NC}"
    echo ""
    echo -e "  ${Y}The longship is ready. Type 'viking' to sail.  ⚔${NC}"
    echo ""
}

# ════════════════════════════════════════════════════════════════
#  MAIN
# ════════════════════════════════════════════════════════════════
main() {
    show_installer_banner
    preflight

    mkdir -p "$VIKING_DIR" "$ARSENAL_DIR" "$LOG_DIR"

    install_dependencies                  # step 1
    install_ollama                        # step 2
    pull_model "$DEFAULT_MODEL"           # step 3
    write_arsenal_registry                # step 4
    write_arsenal_menu                    # step 4b
    write_viking_script                   # step 5
    configure_tmux                        # step 6

    printf 'VIKING_MODEL="%s"\n' "$DEFAULT_MODEL" > "$CONFIG_FILE"

    run_install_wizard                    # step 7
    show_completion
}

main "$@"
