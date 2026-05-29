#!/bin/bash

# ================================================================
#  VIKING AI - Digital Longship Intelligence System
#  Local CLI Security Assistant for Kali Linux
#  License: MIT | Instagram: @s.k.7.l.d
# ================================================================

# No global set -e — installer must tolerate individual tool failures.
# set -u only — pipefail removed at top level (parallel war jobs need tolerance).
set -u

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
readonly GITHUB_RAW="https://raw.githubusercontent.com/skuldexter-web/Viking-AI/main/install.sh"
readonly VIKING_VERSION="2.1.0"

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
readonly W='\033[1;37m'
readonly NC='\033[0m'

# ════════════════════════════════════════════════════════════════
#  ARSENAL REGISTRY - single source of truth
#  Format : "NAME|CATEGORY|GIT_URL|TYPE"
#  Types  : git_python | git_go | git_generic | apt_install:<pkg> | pip_install:<pkg>
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
ARSENAL[13]="nmap|Network Tools|https://github.com/nmap/nmap.git|apt_install:nmap"
ARSENAL[14]="masscan|Network Tools|https://github.com/robertdavidgraham/masscan.git|apt_install:masscan"
ARSENAL[15]="RustScan|Network Tools|https://github.com/bee-san/RustScan.git|git_generic"
ARSENAL[16]="xerosploit|Network Tools|https://github.com/LionSec/xerosploit.git|git_python"
ARSENAL[17]="amass|Network Tools|https://github.com/owasp-amass/amass.git|apt_install:amass"
ARSENAL[18]="httpx|Network Tools|https://github.com/projectdiscovery/httpx.git|git_go"
ARSENAL[19]="subfinder|Network Tools|https://github.com/projectdiscovery/subfinder.git|git_go"
ARSENAL[90]="naabu|Network Tools|https://github.com/projectdiscovery/naabu.git|git_go"
ARSENAL[104]="dnsx|Network Tools|https://github.com/projectdiscovery/dnsx.git|git_go"

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
ARSENAL[28]="sqlmap|SQL Injection|https://github.com/sqlmapproject/sqlmap.git|apt_install:sqlmap"
ARSENAL[29]="NoSQLMap|SQL Injection|https://github.com/codingo/NoSQLMap.git|git_python"
ARSENAL[30]="DSSS|SQL Injection|https://github.com/stamparm/DSSS.git|git_python"
ARSENAL[31]="explo|SQL Injection|https://github.com/telekom-security/explo.git|git_python"
ARSENAL[32]="Blisqy|SQL Injection|https://github.com/JohnTroony/Blisqy.git|git_python"
ARSENAL[33]="leviathan|SQL Injection|https://github.com/utkusen/leviathan.git|git_python"
ARSENAL[34]="sqlscan|SQL Injection|https://github.com/Cvar1984/sqlscan.git|git_python"

# WiFi Tools
ARSENAL[35]="OneShot|WiFi Tools|https://github.com/kimocoder/OneShot.git|git_python"
ARSENAL[36]="wifipumpkin3|WiFi Tools|https://github.com/P0cL4bs/wifipumpkin3.git|git_python"
ARSENAL[37]="pixiewps|WiFi Tools|https://github.com/wiire-a/pixiewps.git|apt_install:pixiewps"
ARSENAL[38]="bluepot|WiFi Tools|https://github.com/andrewmichaelsmith/bluepot.git|git_generic"
ARSENAL[39]="fluxion|WiFi Tools|https://github.com/FluxionNetwork/fluxion.git|git_generic"
ARSENAL[40]="wifiphisher|WiFi Tools|https://github.com/wifiphisher/wifiphisher.git|git_python"
ARSENAL[41]="wifite2|WiFi Tools|https://github.com/derv82/wifite2.git|git_python"
ARSENAL[42]="fakeap|WiFi Tools|https://github.com/Z4nzu/fakeap.git|git_python"
ARSENAL[80]="airgeddon|WiFi Tools|https://github.com/v1s1t0r1sh3r3/airgeddon.git|apt_install:airgeddon"
ARSENAL[81]="aircrack-ng|WiFi Tools|https://github.com/aircrack-ng/aircrack-ng.git|apt_install:aircrack-ng"
ARSENAL[82]="bettercap|WiFi Tools|https://github.com/bettercap/bettercap.git|apt_install:bettercap"
ARSENAL[105]="hcxdumptool|WiFi Tools|https://github.com/ZerBea/hcxdumptool.git|apt_install:hcxdumptool"
ARSENAL[106]="hcxtools|WiFi Tools|https://github.com/ZerBea/hcxtools.git|apt_install:hcxtools"

# Anonymity
ARSENAL[43]="kali-anonsurf|Anonymity|https://github.com/Und3rf10w/kali-anonsurf.git|git_generic"
ARSENAL[44]="multitor|Anonymity|https://github.com/trimstray/multitor.git|git_generic"

# OSINT
ARSENAL[45]="holehe|OSINT|https://github.com/megadose/holehe.git|pip_install:holehe"
ARSENAL[46]="maigret|OSINT|https://github.com/soxoj/maigret.git|pip_install:maigret"
ARSENAL[47]="trufflehog|OSINT|https://github.com/trufflesecurity/trufflehog.git|git_go"
ARSENAL[48]="gitleaks|OSINT|https://github.com/gitleaks/gitleaks.git|git_go"
ARSENAL[49]="SMWYG|OSINT|https://github.com/Viralmaniar/SMWYG-Show-Me-What-You-Got.git|git_python"
ARSENAL[91]="sherlock|OSINT|https://github.com/sherlock-project/sherlock.git|apt_install:sherlock"
ARSENAL[107]="waybackurls|OSINT|https://github.com/tomnomnom/waybackurls.git|git_go"
ARSENAL[108]="gau|OSINT|https://github.com/lc/gau.git|git_go"
ARSENAL[109]="hakrawler|OSINT|https://github.com/hakluke/hakrawler.git|git_go"

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
ARSENAL[65]="dirb|Web Tools|https://gitlab.com/kalilinux/packages/dirb.git|apt_install:dirb"
ARSENAL[66]="takeover|Web Tools|https://github.com/edoardottt/takeover.git|git_go"
ARSENAL[67]="checkURL|Web Tools|https://github.com/UndeadSec/checkURL.git|git_python"
ARSENAL[68]="Sublist3r|Web Tools|https://github.com/aboul3la/Sublist3r.git|git_python"
ARSENAL[69]="web2attack|Web Tools|https://github.com/santatic/web2attack.git|git_python"
ARSENAL[83]="commix|Web Scanning|https://github.com/commixproject/commix.git|apt_install:commix"
ARSENAL[84]="wpscan|Web Scanning|https://github.com/wpscanteam/wpscan.git|apt_install:wpscan"
ARSENAL[85]="ffuf|Web Scanning|https://github.com/ffuf/ffuf.git|apt_install:ffuf"
ARSENAL[86]="gobuster|Web Scanning|https://github.com/OJ/gobuster.git|apt_install:gobuster"
ARSENAL[87]="dirsearch|Web Scanning|https://github.com/maurosoria/dirsearch.git|apt_install:dirsearch"
ARSENAL[88]="feroxbuster|Web Scanning|https://github.com/epi052/feroxbuster.git|apt_install:feroxbuster"
ARSENAL[89]="katana|Web Scanning|https://github.com/projectdiscovery/katana.git|git_go"

# Exploitation
ARSENAL[70]="Vegile|Exploitation|https://github.com/screetsec/Vegile.git|git_generic"
ARSENAL[71]="HeraKeylogger|Exploitation|https://github.com/UndeadSec/HeraKeylogger.git|git_python"
ARSENAL[72]="bulk_extractor|Exploitation|https://github.com/simsong/bulk_extractor.git|apt_install:bulk-extractor"
ARSENAL[73]="TheFatRat|Exploitation|https://github.com/screetsec/TheFatRat.git|git_generic"
ARSENAL[74]="Brutal|Exploitation|https://github.com/screetsec/Brutal.git|git_generic"
ARSENAL[75]="msfpc|Exploitation|https://github.com/g0tmi1k/msfpc.git|git_generic"
ARSENAL[76]="venom|Exploitation|https://github.com/r00t-3xp10it/venom.git|git_generic"
ARSENAL[77]="spycam|Exploitation|https://github.com/indexnotfound404/spycam.git|git_python"
ARSENAL[78]="Mob-Droid|Exploitation|https://github.com/kinghacker0/Mob-Droid.git|git_python"
ARSENAL[79]="Enigma|Exploitation|https://github.com/UndeadSec/Enigma.git|git_python"

# Active Directory
ARSENAL[92]="netexec|Active Directory|https://github.com/Pennyw0rth/NetExec.git|apt_install:netexec"
ARSENAL[93]="responder|Active Directory|https://github.com/lgandx/Responder.git|apt_install:responder"
ARSENAL[94]="impacket|Active Directory|https://github.com/fortra/impacket.git|apt_install:python3-impacket"
ARSENAL[95]="bloodhound|Active Directory|https://github.com/specterops/bloodhound.git|apt_install:bloodhound"
ARSENAL[96]="certipy|Active Directory|https://github.com/ly4k/Certipy.git|pip_install:certipy-ad"

# Password Cracking
ARSENAL[97]="hashcat|Password Cracking|https://github.com/hashcat/hashcat.git|apt_install:hashcat"
ARSENAL[98]="john|Password Cracking|https://github.com/openwall/john.git|apt_install:john"
ARSENAL[99]="hydra|Password Cracking|https://github.com/vanhauser-thc/thc-hydra.git|apt_install:hydra"
ARSENAL[110]="name-that-hash|Password Cracking|https://github.com/HashPals/Name-That-Hash.git|pip_install:name-that-hash"

# C2 & Exploit Frameworks
ARSENAL[100]="metasploit|C2 Frameworks|https://github.com/rapid7/metasploit-framework.git|apt_install:metasploit-framework"
ARSENAL[101]="sliver|C2 Frameworks|https://github.com/bishopfox/sliver.git|git_go"
ARSENAL[102]="havoc|C2 Frameworks|https://github.com/Havoc-Framework/Havoc.git|git_generic"
ARSENAL[103]="empire|C2 Frameworks|https://github.com/BC-SECURITY/Empire.git|apt_install:powershell-empire"

# Vulnerability Scanning
ARSENAL[111]="nuclei|Vulnerability Scanning|https://github.com/projectdiscovery/nuclei.git|git_go"

# Post Exploitation
ARSENAL[112]="PEASS-ng|Post Exploitation|https://github.com/carlospolop/PEASS-ng.git|git_generic"
ARSENAL[113]="pspy|Post Exploitation|https://github.com/DominicBreuker/pspy.git|git_go"

# RTL-SDR & Radio Tools
ARSENAL[114]="rtl-sdr|RTL-SDR Radio|https://github.com/osmocom/rtl-sdr.git|apt_install:rtl-sdr"
ARSENAL[115]="dump1090|RTL-SDR Radio|https://github.com/antirez/dump1090.git|git_generic"
ARSENAL[116]="rtl_433|RTL-SDR Radio|https://github.com/merbanan/rtl_433.git|apt_install:rtl-433"
ARSENAL[117]="gqrx|RTL-SDR Radio|https://github.com/gqrx-sdr/gqrx.git|apt_install:gqrx"
ARSENAL[118]="gnuradio|RTL-SDR Radio|https://github.com/gnuradio/gnuradio.git|apt_install:gnuradio"
ARSENAL[119]="multimon-ng|RTL-SDR Radio|https://github.com/EliasOenal/multimon-ng.git|apt_install:multimon-ng"
ARSENAL[120]="kalibrate-rtl|RTL-SDR Radio|https://github.com/steve-m/kalibrate-rtl.git|git_generic"

# ════════════════════════════════════════════════════════════════
#  KNOWN ENTRYPOINTS MAP
#  Maps arsenal tool directory name -> the actual script/binary to run.
#  Used by install_tool (skip check) and _find_arsenal_entrypoint.
#  Format: "script_relative_path|interpreter"  (interpreter: python3|bash|ruby|binary)
# ════════════════════════════════════════════════════════════════
declare -A TOOL_ENTRYPOINTS=(
  [WebCheck]="webcheck.py|python3"
  [DEATH_STAR]="main.py|python3"
  [Dracnmap]="Dracnmap.py|python3"
  [RED_HAWK]="rhawk.php|php"
  [reconspider]="reconspider.py|python3"
  [ReconDog]="dog.py|python3"
  [Striker]="striker.py|python3"
  [SecretFinder]="SecretFinder.py|python3"
  [rang3r]="rang3r.py|python3"
  [Breacher]="breacher.py|python3"
  [theHarvester]="theHarvester.py|python3"
  [spiderfoot]="sf.py|python3"
  [xerosploit]="setup.py|python3"
  [XSS-LOADER]="XSS-LOADER.py|python3"
  [extended-xss-search]="extended_xss_search.py|python3"
  [XSpear]="run.rb|ruby"
  [XSSCon]="xsscon.py|python3"
  [XanXSS]="xanxss.py|python3"
  [XSStrike]="xsstrike.py|python3"
  [RVuln]="rvuln.py|python3"
  [NoSQLMap]="nosqlmap.py|python3"
  [DSSS]="dsss.py|python3"
  [explo]="explo|binary"
  [Blisqy]="blisqy.py|python3"
  [leviathan]="leviathan.py|python3"
  [sqlscan]="sqlscan.sh|bash"
  [OneShot]="oneshot.py|python3"
  [wifipumpkin3]="wifipumpkin3|binary"
  [fluxion]="fluxion.sh|bash"
  [wifiphisher]="wifiphisher|binary"
  [wifite2]="wifite.py|python3"
  [fakeap]="fakeap.sh|bash"
  [kali-anonsurf]="anonsurf|bash"
  [multitor]="multitor.sh|bash"
  [SMWYG]="SMWYG.py|python3"
  [cupp]="cupp.py|python3"
  [wlcreator]="wlcreator.py|python3"
  [GoblinWordGenerator]="GoblinWordGenerator.py|python3"
  [autophisher]="autophisher.py|python3"
  [AdvPhishing]="main.py|python3"
  [SET]="se-toolkit|binary"
  [SocialFish]="SocialFish.py|python3"
  [I-See-You]="I-See-You.py|python3"
  [saycheese]="saycheese.sh|bash"
  [ohmyqr]="ohmyqr.py|python3"
  [Thanos]="thanos.sh|bash"
  [QRLJacking]="server.py|python3"
  [maskphish]="maskphish.sh|bash"
  [BlackPhish]="blackphish.py|python3"
  [checkURL]="checkURL.py|python3"
  [Sublist3r]="sublist3r.py|python3"
  [web2attack]="web2attack.py|python3"
  [Vegile]="Vegile.sh|bash"
  [HeraKeylogger]="HeraKeylogger.py|python3"
  [TheFatRat]="fatrat|binary"
  [Brutal]="brutal.py|python3"
  [msfpc]="msfpc|bash"
  [venom]="venom.sh|bash"
  [spycam]="spycam.py|python3"
  [Mob-Droid]="mob-droid.sh|bash"
  [Enigma]="enigma.py|python3"
  [PEASS-ng]="linPEAS/linpeas.sh|bash"
)

# ════════════════════════════════════════════════════════════════
#  LOGGING
# ════════════════════════════════════════════════════════════════
log_ok()   { echo -e "${G}[OK]${NC} $*"; }
log_info() { echo -e "${C}[~]${NC} $*"; }
log_warn() { echo -e "${Y}[!]${NC} $*"; }
log_err()  { echo -e "${R}[X]${NC} $*" >&2; }
log_step() { echo -e "\n${B}${C}-- [ STEP $1 ] --${NC} $2"; }
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
  # Ship with colored striped sails and round shields
  echo -e "${D}${C}"
  echo "                              |                    |"
  echo "                             /|\\                  /|\\"
  echo -e "${NC}${RB}             \u250c\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2510             \u250c\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2510"
  echo -e "${W}             \u2551  ~ ~ WIND ~ ~ ~ ~  \u2551             \u2551  ~ ~ WIND ~ ~ ~ ~  \u2551"
  echo -e "${RB}             \u2560\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2563             \u2560\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2563"
  echo -e "${W}             \u2551                   \u2551             \u2551                   \u2551"
  echo -e "${RB}             \u2560\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2563             \u2560\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2563"
  echo -e "${W}             \u2551                   \u2551             \u2551                   \u2551"
  echo -e "${RB}             \u2514\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2518             \u2514\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2518"
  echo -e "${D}${C}                              |                    |"
  echo -e "${Y}   =========================${NC}${C}=========================${Y}=========================${NC}"
  echo -e "${Y}  (O)(O)(O)(O)(O)${NC}${C}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${Y}(O)(O)(O)(O)(O)${NC}"
  echo -e "${C}              /~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\\"
  echo "             / ooo  ooo  ooo  ooo  ooo  ooo  ooo  ooo  ooo \\"
  echo -e "${NC}${D}${C}  ~~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^${NC}"
  echo -e "${B}${Y}"
  echo "  ██╗   ██╗██╗██╗  ██╗██╗███╗   ██╗  ██████╗      █████╗ ██╗"
  echo "  ██║   ██║██║██║ ██╔╝██║████╗  ██║ ██╔════╝     ██╔══██╗██║"
  echo "  ██║   ██║██║█████╔╝ ██║██╔██╗ ██║ ██║  ███╗    ███████║██║"
  echo "  ╚██╗ ██╔╝██║██╔═██╗ ██║██║╚██╗██║ ██║   ██║    ██╔══██║██║"
  echo "   ╚████╔╝ ██║██║  ██╗██║██║ ╚████║ ╚██████╔╝    ██║  ██║██║"
  echo "    ╚═══╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝  ╚═════╝     ╚═╝  ╚═╝╚═╝"
  echo -e "${NC}"
  echo -e "${G}  Digital Longship Intelligence System  v${VIKING_VERSION}  |  @s.k.7.l.d${NC}"
  echo -e "${D}  ═══════════════════════════════════════════════════════${NC}"
  echo ""
}

# ════════════════════════════════════════════════════════════════
#  WAR MODE BANNER
# ════════════════════════════════════════════════════════════════
show_war_banner() {
  clear
  echo -e "${RB}"
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
  echo -e "${NC}"
  echo -e "${RB}  ══════════════════════════════════════════════════════════════${NC}"
  echo -e "${RB}  [!]  DEPLOYING FULL WEAPON ARSENAL - ALL TOOLS INCOMING  [!]  ${NC}"
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
    ruby ruby-dev libpcap-dev libssl-dev php 2>/dev/null
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
# ════════════════════════════════════════════════════════════════

# Check if an arsenal tool is already usable (binary in PATH or cloned dir exists)
_tool_is_installed() {
  local name="$1" dest="$2"
  # Check common binary names in PATH
  command -v "$name" &>/dev/null && return 0
  command -v "${name,,}" &>/dev/null && return 0
  # Check if arsenal dir has the tool cloned and entrypoint exists
  if [[ -d "$dest" ]]; then
    local ep="${TOOL_ENTRYPOINTS[$name]:-}"
    if [[ -n "$ep" ]]; then
      local script="${ep%%|*}"
      [[ -f "$dest/$script" ]] && return 0
    fi
    # Any executable file found
    find "$dest" -maxdepth 2 -type f \( -name "*.py" -o -name "*.sh" -o -executable \) \
      2>/dev/null | grep -q . && return 0
  fi
  return 1
}

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
  [[ -f "$dest/requirements.txt" ]] &&
    pip3 install -q -r "$dest/requirements.txt" --break-system-packages 2>/dev/null || true
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

  printf "  ${C}[%03d]${NC} %-30s ${D}%s${NC}\n" "$key" "$name" "$category"

  # apt_install: check system first, then apt, then git fallback
  if [[ "$itype" == apt_install:* ]]; then
    local pkg="${itype#apt_install:}"
    if _tool_is_installed "$name" "$dest"; then
      log_ok "$name already available"
      return 0
    fi
    if apt-get install -y -qq "$pkg" 2>/dev/null; then
      log_ok "$name installed via apt"
    else
      _git_clone_fallback "$name" "$url" "$dest"
    fi
    return 0
  fi

  # pip_install: check system first, then pip, then git fallback
  if [[ "$itype" == pip_install:* ]]; then
    local ppkg="${itype#pip_install:}"
    if _tool_is_installed "$name" "$dest"; then
      log_ok "$name already available"
      return 0
    fi
    if pip3 install -q "$ppkg" --break-system-packages 2>/dev/null; then
      log_ok "$name installed via pip"
    else
      _git_clone_fallback "$name" "$url" "$dest"
    fi
    return 0
  fi

  # git-based tools
  if _tool_is_installed "$name" "$dest"; then
    log_ok "$name already available (skipping clone)"
    return 0
  fi

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
  (( f > 0 )) && bf=$(printf '#%.0s' $(seq 1 "$f"))
  (( e > 0 )) && be=$(printf '.%.0s' $(seq 1 "$e"))
  printf "\r  ${RB}[${NC}${RB}%s${NC}${D}%s${NC}${RB}]${NC} %d/%d" \
    "$bf" "$be" "$cur" "$tot"
}

# ════════════════════════════════════════════════════════════════
#  WAR MODE
# ════════════════════════════════════════════════════════════════
war_mode_install() {
  show_war_banner
  mkdir -p "$ARSENAL_DIR" "$LOG_DIR"

  local keys=()
  while IFS= read -r k; do keys+=("$k"); done < <(
    printf '%s\n' "${!ARSENAL[@]}" | sort -n
  )

  local total=${#keys[@]} count=0
  local pids=() running_keys=() failed=()

  for key in "${keys[@]}"; do
    (( count++ ))
    IFS='|' read -r name _ _ _ <<< "${ARSENAL[$key]}"
    log_war "[$count/$total] Deploying: $name"
    install_tool "$key" >> "$LOG_DIR/war_$(printf '%03d' "$count").log" 2>&1 &
    pids+=($!)
    running_keys+=("$key")

    if (( ${#pids[@]} >= WAR_JOBS )); then
      if ! wait "${pids[0]}" 2>/dev/null; then
        failed+=("${running_keys[0]}")
      fi
      pids=("${pids[@]:1}")
      running_keys=("${running_keys[@]:1}")
    fi
    _progress_bar "$count" "$total"
  done

  # Drain remaining
  local i=0
  for pid in "${pids[@]}"; do
    if ! wait "$pid" 2>/dev/null; then
      failed+=("${running_keys[$i]:-?}")
    fi
    (( i++ )) || true
  done
  echo ""

  echo -e "\n${RB}  ══════════════════════════════════════════════${NC}"
  echo -e "${RB}  WAR COMPLETE - $count / $total WEAPONS DEPLOYED${NC}"
  echo -e "${RB}  ══════════════════════════════════════════════${NC}"
  if (( ${#failed[@]} > 0 )); then
    echo -e "${Y}  Failed keys: ${failed[*]}"
    echo -e "  Logs -> $LOG_DIR${NC}"
  fi
  echo ""
}

# ════════════════════════════════════════════════════════════════
#  ARSENAL TABLE
# ════════════════════════════════════════════════════════════════
display_arsenal_table() {
  local current_cat=""
  echo ""
  echo -e "${B}${Y}  [*]  WEAPONS ARSENAL  [*]${NC}"
  echo -e "  ══════════════════════════════════════════════════════"
  while IFS= read -r key; do
    IFS='|' read -r name category _ _ <<< "${ARSENAL[$key]}"
    if [[ "$category" != "$current_cat" ]]; then
      current_cat="$category"
      echo -e "\n${B}${M}    -- $category --${NC}"
    fi
    local tag=""
    if _tool_is_installed "$name" "$ARSENAL_DIR/$name"; then
      tag="${G}[installed]${NC}"
    fi
    printf "  ${C}[%03d]${NC}  %-32s%b\n" "$key" "$name" "$tag"
  done < <(printf '%s\n' "${!ARSENAL[@]}" | sort -n)
  echo -e "\n  ══════════════════════════════════════════════════════\n"
}

# ════════════════════════════════════════════════════════════════
#  GENERATE REGISTRY FILE
# ════════════════════════════════════════════════════════════════
write_arsenal_registry() {
  log_step "4" "Generating arsenal registry..."
  {
    echo "#!/bin/bash"
    echo "# Auto-generated by install.sh - edit ARSENAL in install.sh only"
    echo "declare -A TOOL_REGISTRY"
    for key in $(printf '%s\n' "${!ARSENAL[@]}" | sort -n); do
      printf 'TOOL_REGISTRY[%d]="%s"\n' "$key" "${ARSENAL[$key]}"
    done
    echo ""
    echo "declare -A TOOL_ENTRYPOINTS"
    for name in "${!TOOL_ENTRYPOINTS[@]}"; do
      printf 'TOOL_ENTRYPOINTS[%s]="%s"\n' "$name" "${TOOL_ENTRYPOINTS[$name]}"
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
# VIKING Arsenal Menu

VIKING_DIR="/opt/viking"
ARSENAL_DIR="$VIKING_DIR/arsenal"
REGISTRY_FILE="$VIKING_DIR/arsenal_registry.sh"
LOG_DIR="$VIKING_DIR/logs"
WAR_JOBS=4

R='\033[0;31m'; RB='\033[1;31m'; G='\033[0;32m'; C='\033[0;36m'
Y='\033[1;33m'; M='\033[0;35m'; B='\033[1m'; D='\033[2m'; NC='\033[0m'

source "$REGISTRY_FILE" || { echo "Registry missing - run install.sh"; exit 1; }

log_ok()  { echo -e "${G}[OK]${NC} $*"; }
log_err() { echo -e "${R}[X]${NC} $*" >&2; }
log_war() { echo -e "${RB}[WAR]${NC} $*"; }

_tool_is_installed() {
  local name="$1" dest="$2"
  command -v "$name" &>/dev/null && return 0
  command -v "${name,,}" &>/dev/null && return 0
  if [[ -d "$dest" ]]; then
    local ep="${TOOL_ENTRYPOINTS[$name]:-}"
    if [[ -n "$ep" ]]; then
      local script="${ep%%|*}"
      [[ -f "$dest/$script" ]] && return 0
    fi
    find "$dest" -maxdepth 2 -type f \( -name "*.py" -o -name "*.sh" -o -executable \) \
      2>/dev/null | grep -q . && return 0
  fi
  return 1
}

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
  [[ -f "$dest/requirements.txt" ]] &&
    pip3 install -q -r "$dest/requirements.txt" --break-system-packages 2>/dev/null || true
  log_ok "$name installed via git"
}

install_tool() {
  local key
  key=$(printf '%d' "$((10#${1}))" 2>/dev/null) || key="$1"
  local entry="${TOOL_REGISTRY[$key]:-}"
  [[ -z "$entry" ]] && { log_err "Tool #$key not found"; return 1; }

  IFS='|' read -r name category url itype <<< "$entry"
  local dest="$ARSENAL_DIR/$name"
  printf "  ${C}[%03d]${NC} %-30s ${D}%s${NC}\n" "$key" "$name" "$category"

  if [[ "$itype" == apt_install:* ]]; then
    local pkg="${itype#apt_install:}"
    if _tool_is_installed "$name" "$dest"; then log_ok "$name already on system"; return 0; fi
    if apt-get install -y -qq "$pkg" 2>/dev/null; then log_ok "$name via apt"
    else _git_clone_fallback "$name" "$url" "$dest"; fi
    return 0
  fi

  if [[ "$itype" == pip_install:* ]]; then
    local ppkg="${itype#pip_install:}"
    if _tool_is_installed "$name" "$dest"; then log_ok "$name already on system"; return 0; fi
    if pip3 install -q "$ppkg" --break-system-packages 2>/dev/null; then log_ok "$name via pip"
    else _git_clone_fallback "$name" "$url" "$dest"; fi
    return 0
  fi

  if _tool_is_installed "$name" "$dest"; then
    log_ok "$name already on system (skipping clone)"
    return 0
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
  (( f > 0 )) && bf=$(printf '#%.0s' $(seq 1 "$f"))
  (( e > 0 )) && be=$(printf '.%.0s' $(seq 1 "$e"))
  printf "\r  ${RB}[${NC}${RB}%s${NC}${D}%s${NC}${RB}]${NC} %d/%d" "$bf" "$be" "$cur" "$tot"
}

war_mode() {
  clear
  echo -e "${RB}"
  echo "  ██╗    ██╗ █████╗ ██████╗      ███╗   ███╗ ██████╗ ██████╗ ███████╗"
  echo "  ██║    ██║██╔══██╗██╔══██╗     ████╗ ████║██╔═══██╗██╔══██╗██╔════╝"
  echo "  ██║ █╗ ██║███████║██████╔╝     ██╔████╔██║██║   ██║██║  ██║█████╗  "
  echo "  ██║███╗██║██╔══██║██╔══██╗     ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝  "
  echo "  ╚███╔███╔╝██║  ██║██║  ██║     ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗"
  echo "   ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝     ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝"
  echo -e "${NC}${RB}  [!]  ALL WEAPONS DEPLOYING - STAND CLEAR  [!]${NC}"
  sleep 1

  mkdir -p "$ARSENAL_DIR" "$LOG_DIR"
  local keys=()
  while IFS= read -r k; do keys+=("$k"); done < <(
    printf '%s\n' "${!TOOL_REGISTRY[@]}" | sort -n
  )
  local total=${#keys[@]} count=0
  local pids=() running_keys=() failed=()

  for key in "${keys[@]}"; do
    (( count++ ))
    IFS='|' read -r name _ _ _ <<< "${TOOL_REGISTRY[$key]}"
    log_war "[$count/$total] Deploying: $name"
    install_tool "$key" >> "$LOG_DIR/war_$count.log" 2>&1 &
    pids+=($!)
    running_keys+=("$key")
    if (( ${#pids[@]} >= WAR_JOBS )); then
      if ! wait "${pids[0]}" 2>/dev/null; then failed+=("${running_keys[0]}"); fi
      pids=("${pids[@]:1}")
      running_keys=("${running_keys[@]:1}")
    fi
    _progress_bar "$count" "$total"
  done
  local i=0
  for pid in "${pids[@]}"; do
    if ! wait "$pid" 2>/dev/null; then failed+=("${running_keys[$i]:-?}"); fi
    (( i++ )) || true
  done
  echo ""
  echo -e "\n${RB}  WAR COMPLETE - $count WEAPONS DEPLOYED${NC}"
  (( ${#failed[@]} > 0 )) && echo -e "${Y}  Failed: ${failed[*]}${NC}"
  echo ""
}

show_arsenal() {
  local current_cat=""
  echo ""
  echo -e "${B}${Y}  [*]  WEAPONS ARSENAL  [*]${NC}"
  echo -e "  ══════════════════════════════════════════════════════"
  while IFS= read -r key; do
    IFS='|' read -r name category _ _ <<< "${TOOL_REGISTRY[$key]}"
    if [[ "$category" != "$current_cat" ]]; then
      current_cat="$category"
      echo -e "\n${B}${M}    -- $category --${NC}"
    fi
    local tag=""
    _tool_is_installed "$name" "$ARSENAL_DIR/$name" && tag="${G}[installed]${NC}"
    printf "  ${C}[%03d]${NC}  %-32s%b\n" "$key" "$name" "$tag"
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
#  VIKING AI - Digital Longship Intelligence System
#  Kali Linux CLI Security Assistant | MIT License
#  Instagram: @s.k.7.l.d
# ================================================================

set -u

# ── Paths ─────────────────────────────────────────────────────────
readonly VIKING_DIR="/opt/viking"
readonly ARSENAL_DIR="$VIKING_DIR/arsenal"
readonly CONFIG_FILE="$VIKING_DIR/config"
readonly TARGET_FILE="$VIKING_DIR/.current_target"
readonly LOGFILE="$HOME/.viking_history.log"
readonly SCAN_DIR="$HOME/viking_scans"
readonly OLLAMA_API="http://localhost:11434/api/chat"

[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE" 2>/dev/null || true
MODEL="${VIKING_MODEL:-tinyllama}"
CURRENT_TARGET=""
[[ -f "$TARGET_FILE" ]] && CURRENT_TARGET="$(cat "$TARGET_FILE" 2>/dev/null)" || true

# ── Colors ────────────────────────────────────────────────────────
R='\033[0;31m'; RB='\033[1;31m'; G='\033[0;32m'; C='\033[0;36m'
Y='\033[1;33m'; M='\033[0;35m'; B='\033[1m'; D='\033[2m'; W='\033[1;37m'; NC='\033[0m'

# ── Models ───────────────────────────────────────────────────────
readonly -a AVAILABLE_MODELS=(
  "tinyllama"    # default - fastest ~600MB
  "llama3.2:3b"  # better reasoning ~2GB
  "qwen2.5:3b"   # strong code + security ~2GB
)

# ── System prompt ────────────────────────────────────────────────
readonly SYSTEM_PROMPT='You are VIKING, a battle-hardened cyber hacker with the soul of a Norse warrior. Confident, direct, dark humour. For greetings respond in character and be chatty. For technical tasks give exact commands and suggest the next step. Never output command formats when the user is just talking.'

# ── Few-shot examples ────────────────────────────────────────────
readonly FEW_SHOT_JSON='{"role":"user","content":"hey"},{"role":"assistant","content":"Ha! A warrior enters the longship. I am VIKING - cyber raider and digital berserker. Who are we hunting today?"},{"role":"user","content":"what can you do"},{"role":"assistant","content":"Scan targets, crack networks, find vulnerabilities, run exploits, enumerate subdomains. Name the target and I plan the raid."},{"role":"user","content":"scan 192.168.1.1"},{"role":"assistant","content":"Scouting the target.\nCOMMAND: nmap -sV --open -T4 192.168.1.1\nEXPLANATION: Maps open ports and services.\nWant me to dig deeper once we have results?"},'

# ── Load entrypoints registry ─────────────────────────────────────
declare -A TOOL_ENTRYPOINTS=()
[[ -f "$VIKING_DIR/arsenal_registry.sh" ]] && \
  source "$VIKING_DIR/arsenal_registry.sh" 2>/dev/null || true

# ════════════════════════════════════════════════════════════════
#  CORE HELPERS
# ════════════════════════════════════════════════════════════════
log()         { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOGFILE" 2>/dev/null || true; }
v_say()       { echo -e "${Y}[VIKING]${NC} $1"; }
v_info()      { echo -e "${C}[VIKING]${NC} $1"; }
v_err()       { echo -e "${R}[VIKING]${NC} $*"; }
v_ok()        { echo -e "${G}[VIKING]${NC} $*"; }

save_config() {
  printf 'VIKING_MODEL="%s"\n' "$MODEL" > "$CONFIG_FILE" 2>/dev/null || true
}

set_target() {
  CURRENT_TARGET="$1"
  printf '%s' "$CURRENT_TARGET" > "$TARGET_FILE" 2>/dev/null || true
  save_config
  v_ok "Target locked: $CURRENT_TARGET"
}

json_escape() {
  printf '%s' "$1" | python3 -c \
    'import sys,json; print(json.dumps(sys.stdin.read()), end="")' 2>/dev/null
}

# ── Streaming AI ─────────────────────────────────────────────────
viking_think() {
  local prompt="$*"
  local sys_esc user_esc payload
  sys_esc=$(json_escape "$SYSTEM_PROMPT")
  user_esc=$(json_escape "$prompt")
  payload=$(printf \
    '{"model":"%s","stream":true,"options":{"temperature":0.3,"num_predict":350,"num_ctx":512},"messages":[{"role":"system","content":%s},%s{"role":"user","content":%s}]}' \
    "$MODEL" "$sys_esc" "$FEW_SHOT_JSON" "$user_esc")

  curl -sS --no-buffer \
    -H "Content-Type: application/json" \
    -d "$payload" \
    "$OLLAMA_API" 2>/dev/null \
  | python3 -u -c "
import sys, json
for line in sys.stdin:
    line = line.strip()
    if not line: continue
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
" 2>/dev/null
}

warm_model() {
  curl -sS -o /dev/null \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"$MODEL\",\"stream\":false,\"options\":{\"temperature\":0.3,\"num_predict\":1,\"num_ctx\":512},\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}]}" \
    "$OLLAMA_API" 2>/dev/null &
}

ai_response() {
  echo -ne "${G}"
  viking_think "$@"
  echo -e "${NC}"
}

# ── Input helpers ─────────────────────────────────────────────────
# match: takes the input string as first arg, pattern as second
# Called as: match "$INPUT" "pattern"
match() { [[ "${1,,}" =~ $2 ]]; }

extract_target() {
  # Takes the raw input string as argument
  local input_str="$1"
  local t
  t=$(echo "$input_str" | grep -oE \
    '([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?|https?://[^[:space:]]+|[a-zA-Z0-9._-]+\.[a-zA-Z]{2,4}(/[^[:space:]]*)?' \
    | grep -v '^[0-9]$' | head -1)
  # Fall back to persistent target if nothing found in input
  if [[ -z "$t" && -n "$CURRENT_TARGET" ]]; then
    t="$CURRENT_TARGET"
    echo -e "${D}  (using locked target: $CURRENT_TARGET)${NC}" >&2
  fi
  echo "$t"
}

# ════════════════════════════════════════════════════════════════
#  UNIVERSAL TOOL LAUNCHER
#  Checks in order:
#   1. System PATH (all Kali built-in tools)
#   2. Known entrypoint from TOOL_ENTRYPOINTS map
#   3. Auto-scan arsenal clone dir
#   4. apt auto-install
#   5. Ask user if they want to install
# ════════════════════════════════════════════════════════════════

# apt package map for auto-install
declare -A _APT=(
  [nmap]="nmap"                   [masscan]="masscan"
  [rustscan]="rustscan"           [nikto]="nikto"
  [gobuster]="gobuster"           [ffuf]="ffuf"
  [feroxbuster]="feroxbuster"     [dirsearch]="dirsearch"
  [sqlmap]="sqlmap"               [commix]="commix"
  [wpscan]="wpscan"               [dalfox]="dalfox"
  [wifite]="wifite"               [airgeddon]="airgeddon"
  [wifiphisher]="wifiphisher"     [aircrack-ng]="aircrack-ng"
  [bettercap]="bettercap"         [hydra]="hydra"
  [hashcat]="hashcat"             [john]="john"
  [tshark]="tshark"               [wireshark]="wireshark"
  [msfconsole]="metasploit-framework"
  [netexec]="netexec"             [responder]="responder"
  [bloodhound]="bloodhound"       [amass]="amass"
  [subfinder]="subfinder"         [sherlock]="sherlock"
  [theharvester]="theharvester"   [whois]="whois"
  [nuclei]="nuclei"               [naabu]="naabu"
  [katana]="katana"               [httpx]="httpx"
  [dnsx]="dnsx"                   [hcxdumptool]="hcxdumptool"
  [hcxtools]="hcxtools"           [burpsuite]="burpsuite"
  [zaproxy]="zaproxy"             [maltego]="maltego"
  [setoolkit]="set"               [pixiewps]="pixiewps"
  [reaver]="reaver"               [airmon-ng]="aircrack-ng"
  [airodump-ng]="aircrack-ng"     [aireplay-ng]="aircrack-ng"
  [bulk-extractor]="bulk-extractor"
  [powershell-empire]="powershell-empire"
  [holehe]="holehe"               [maigret]="maigret"
)

# tool name -> binary name for cases where they differ
declare -A _BIN_MAP=(
  [metasploit]="msfconsole"       [msf]="msfconsole"
  [airmon]="airmon-ng"            [airodump]="airodump-ng"
  [aireplay]="aireplay-ng"        [airbase]="airbase-ng"
  [set]="setoolkit"               [se-toolkit]="setoolkit"
  [nth]="nth"                     [name-that-hash]="nth"
  [rustscan]="rustscan"           [RustScan]="rustscan"
  [theharvester]="theHarvester"
)

# Check if a tool is installed (PATH or arsenal dir)
_tool_available() {
  local name="$1"
  local bin="${_BIN_MAP[$name]:-$name}"
  command -v "$bin" &>/dev/null && return 0
  command -v "$name" &>/dev/null && return 0
  command -v "${name,,}" &>/dev/null && return 0
  local tool_dir="$ARSENAL_DIR/$name"
  [[ -d "$tool_dir" ]] || return 1
  local ep="${TOOL_ENTRYPOINTS[$name]:-}"
  if [[ -n "$ep" ]]; then
    local script="${ep%%|*}"
    [[ -f "$tool_dir/$script" ]] && return 0
  fi
  find "$tool_dir" -maxdepth 2 -type f \( -name "*.py" -o -name "*.sh" -o -executable \) \
    2>/dev/null | grep -q . && return 0
  return 1
}

# Prompt user to install if tool not found
_prompt_install() {
  local name="$1"
  echo ""
  echo -e "${Y}  [!] $name is not installed.${NC}"
  echo -e "  Options:"
  echo -e "  ${C}[1]${NC}  Install via arsenal (recommended)"
  local pkg="${_APT[${name,,}]:-$name}"
  echo -e "  ${C}[2]${NC}  Quick apt install: sudo apt install $pkg"
  echo -e "  ${C}[3]${NC}  Skip"
  echo -ne "  ${Y}Choice [1-3]: ${NC}"
  read -r install_choice
  case "$install_choice" in
    1)
      bash "$VIKING_DIR/arsenal_menu.sh"
      ;;
    2)
      v_info "Installing $pkg..."
      if sudo apt-get install -y -qq "$pkg" 2>/dev/null; then
        v_ok "$pkg installed"
        return 0
      else
        v_err "apt install failed. Try: arsenal"
        return 1
      fi
      ;;
    *)
      v_info "Skipping installation."
      return 1
      ;;
  esac
}

# Run a tool from arsenal clone dir using known or auto-detected entrypoint
_run_from_arsenal() {
  local name="$1"
  shift
  local tool_dir="$ARSENAL_DIR/$name"
  local ep="${TOOL_ENTRYPOINTS[$name]:-}"

  # Use known entrypoint first
  if [[ -n "$ep" ]]; then
    local script="${ep%%|*}"
    local interp="${ep##*|}"
    local full_path="$tool_dir/$script"
    if [[ -f "$full_path" ]]; then
      case "$interp" in
        python3) python3 "$full_path" "$@"; return $? ;;
        bash)    bash   "$full_path" "$@"; return $? ;;
        ruby)    ruby   "$full_path" "$@"; return $? ;;
        php)     php    "$full_path" "$@"; return $? ;;
        binary)  [[ -x "$full_path" ]] && "$full_path" "$@"; return $? ;;
      esac
    fi
  fi

  # Auto-detect: try common Python entrypoints
  for py in "main.py" "${name}.py" "${name,,}.py" "run.py" "app.py" "start.py"; do
    [[ -f "$tool_dir/$py" ]] && { python3 "$tool_dir/$py" "$@"; return $?; }
  done

  # Auto-detect: shell scripts
  for sh in "${name}.sh" "${name,,}.sh" "run.sh" "start.sh" "main.sh"; do
    [[ -f "$tool_dir/$sh" ]] && { bash "$tool_dir/$sh" "$@"; return $?; }
  done

  # Auto-detect: Ruby
  for rb in "${name}.rb" "main.rb"; do
    [[ -f "$tool_dir/$rb" ]] && { ruby "$tool_dir/$rb" "$@"; return $?; }
  done

  # Auto-detect: executable binary with same name
  local lower_name="${name,,}"
  for bin in "$tool_dir/$name" "$tool_dir/$lower_name"; do
    [[ -f "$bin" && -x "$bin" ]] && { "$bin" "$@"; return $?; }
  done

  # Last resort: first executable found
  local found
  found=$(find "$tool_dir" -maxdepth 1 -type f -executable | head -1)
  [[ -n "$found" ]] && { "$found" "$@"; return $?; }

  return 1
}

# Main launch function
launch_tool() {
  local raw_name="$1"
  shift
  local name="$raw_name"

  v_info "Launching: $raw_name${*:+ $*}"

  # 1. Resolve alias -> real binary name
  local resolved="${_BIN_MAP[$raw_name]:-$raw_name}"

  # 2. System PATH (covers all Kali built-in tools)
  if command -v "$resolved" &>/dev/null; then
    "$resolved" "$@"
    return $?
  fi
  if command -v "$raw_name" &>/dev/null; then
    "$raw_name" "$@"
    return $?
  fi

  # 3. Arsenal clone directory
  if [[ -d "$ARSENAL_DIR/$raw_name" ]]; then
    _run_from_arsenal "$raw_name" "$@"
    local rc=$?
    if (( rc == 0 )); then return 0; fi
    v_err "Found arsenal dir for $raw_name but entrypoint failed (exit $rc)"
  fi

  # 4. Case-insensitive search of arsenal dir
  local found_dir
  found_dir=$(find "$ARSENAL_DIR" -maxdepth 1 -type d \
    -iname "$raw_name" 2>/dev/null | head -1)
  if [[ -n "$found_dir" ]]; then
    local dir_name; dir_name=$(basename "$found_dir")
    _run_from_arsenal "$dir_name" "$@"
    return $?
  fi

  # 5. apt auto-install
  local pkg="${_APT[${raw_name,,}]:-}"
  if [[ -n "$pkg" ]]; then
    v_info "$raw_name not found - attempting: sudo apt install $pkg"
    if sudo apt-get install -y -qq "$pkg" 2>/dev/null; then
      v_ok "Installed $pkg"
      if command -v "$resolved" &>/dev/null; then
        "$resolved" "$@"; return $?
      fi
      if command -v "$raw_name" &>/dev/null; then
        "$raw_name" "$@"; return $?
      fi
    fi
  fi

  # 6. Not found - prompt user
  _prompt_install "$raw_name"
  return 1
}

# GUI launcher - avoids & || syntax issues and checks display
launch_gui() {
  local cmd="$1"
  local fallback="${2:-Use CLI alternative}"
  if [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
    if command -v "$cmd" &>/dev/null; then
      nohup "$cmd" &>/dev/null &
      v_ok "$cmd launched in background"
    else
      v_err "$cmd not found."
      _prompt_install "$cmd"
    fi
  else
    v_err "No display detected (SSH without X11 forwarding)."
    echo -e "  ${Y}Tip:${NC} $fallback"
    echo -e "  ${Y}SSH tip:${NC} ssh -X user@host  then run: $cmd"
  fi
}

# Safe sudo wrapper: resolves binary path before sudo
# Fixes the "sudo cannot run shell functions" bug
sudo_tool() {
  local cmd="$1"
  shift
  local resolved="${_BIN_MAP[$cmd]:-$cmd}"
  local bin_path
  if bin_path=$(command -v "$resolved" 2>/dev/null); then
    sudo "$bin_path" "$@"
  elif bin_path=$(command -v "$cmd" 2>/dev/null); then
    sudo "$bin_path" "$@"
  else
    v_err "Cannot sudo $cmd - binary not found"
    _prompt_install "$cmd"
  fi
}

# ════════════════════════════════════════════════════════════════
#  SCAN / OUTPUT HELPERS
# ════════════════════════════════════════════════════════════════
mkdir -p "$SCAN_DIR" 2>/dev/null || true

ask_save_output() {
  local result="$1" target="$2" tool="$3"
  echo ""
  echo -ne "${Y}  Save output to .txt file? [y/N]: ${NC}"
  read -r sc
  if [[ "${sc,,}" == "y" ]]; then
    local safe; safe=$(printf '%s' "$target" | tr '/:?&= ' '_' | tr -dc '[:alnum:]_.-' | cut -c1-50)
    local fname="${SCAN_DIR}/${tool}_${safe}_$(date '+%Y%m%d_%H%M%S').txt"
    printf '%s\n' "$result" > "$fname"
    v_ok "Saved: $fname"
    echo -e "${D}  Open with: cat \"$fname\"  |  View folder: ls $SCAN_DIR/${NC}"
  fi
}

ask_ai_analysis() {
  local result="$1" target="$2" tool="$3"
  echo ""
  echo -ne "${Y}  VIKING analyse output? [Y/n]: ${NC}"
  read -r ac
  if [[ "${ac,,}" != "n" ]]; then
    v_info "Analysing..."
    echo ""
    ai_response "${tool} scan of ${target}. Analyse: findings, risk level, open ports/services, recommended next commands. Be tactical and concise. Scan output: ${result:0:1800}"
  fi
}

ask_scan_type() {
  echo ""
  echo -e "${B}${Y}  Scan depth:${NC}"
  echo -e "  ${C}[1]${NC}  Quick  - top 1000 ports  (fast)"
  echo -e "  ${C}[2]${NC}  Medium - top 1000 + versions  (default)"
  echo -e "  ${C}[3]${NC}  Full   - all 65535 ports + scripts  (slow)"
  echo -ne "  ${Y}[1-3]: ${NC}"
  read -r sc
  case "$sc" in
    1) echo "-T4 --open" ;;
    3) echo "-sV -sC -p- -T4 --open" ;;
    *) echo "-sV --open -T4" ;;
  esac
}

# ════════════════════════════════════════════════════════════════
#  BANNER
# ════════════════════════════════════════════════════════════════
show_banner() {
  clear
  # ── Masts ────────────────────────────────────────────────────
  echo -e "${D}${C}                              |                    |"
  echo -e "                             /|\\                  /|\\"
  # ── Sails: red/white stripes with box-drawing chars ──────────
  echo -e "${NC}${RB}             ┌═════════════════┐             ┌═════════════════┐${NC}"
  echo -e "${W}             ║  ~ ~ WIND ~ ~ ~ ~  ║             ║  ~ ~ WIND ~ ~ ~ ~  ║${NC}"
  echo -e "${RB}             ╠═════════════════╣             ╠═════════════════╣${NC}"
  echo -e "${W}             ║                   ║             ║                   ║${NC}"
  echo -e "${RB}             ╠═════════════════╣             ╠═════════════════╣${NC}"
  echo -e "${W}             ║                   ║             ║                   ║${NC}"
  echo -e "${RB}             └═════════════════┘             └═════════════════┘${NC}"
  # ── Mast base + yard ──────────────────────────────────────────
  echo -e "${D}${C}                              |                    |"
  echo -e "${NC}${Y}    ========================${NC}${C}==========================${Y}========================${NC}"
  # ── Shields (round) ──────────────────────────────────────────
  echo -e "  ${Y}(O)(O)(O)(O)(O)${NC}${C}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${Y}(O)(O)(O)(O)(O)${NC}"
  # ── Hull ─────────────────────────────────────────────────────
  echo -e "             ${C}   /~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\\${NC}"
  echo -e "                ${C}/ ooo  ooo  ooo  ooo  ooo  ooo  ooo  ooo  ooo \\${NC}"
  echo -e "  ${D}${C}~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^${NC}"
  # ── Logo ─────────────────────────────────────────────────────
  echo -e "${B}${Y}"
  echo "  ██╗   ██╗██╗██╗  ██╗██╗███╗   ██╗  ██████╗      █████╗ ██╗"
  echo "  ██║   ██║██║██║ ██╔╝██║████╗  ██║ ██╔════╝     ██╔══██╗██║"
  echo "  ██║   ██║██║█████╔╝ ██║██╔██╗ ██║ ██║  ███╗    ███████║██║"
  echo "  ╚██╗ ██╔╝██║██╔═██╗ ██║██║╚██╗██║ ██║   ██║    ██╔══██║██║"
  echo "   ╚████╔╝ ██║██║  ██╗██║██║ ╚████║ ╚██████╔╝    ██║  ██║██║"
  echo "    ╚═══╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝  ╚═════╝     ╚═╝  ╚═╝╚═╝"
  echo -e "${NC}"
  echo -e "  ${C}Digital Longship Intelligence System${NC}  ${D}| @s.k.7.l.d${NC}"
  echo -e "  ${D}════════════════════════════════════════════${NC}"
  local tgt_disp="${D}none${NC}"
  [[ -n "$CURRENT_TARGET" ]] && tgt_disp="${G}${CURRENT_TARGET}${NC}"
  echo -e "  Model: ${G}${MODEL}${NC}  |  Target: ${tgt_disp}  |  Type ${Y}help${NC}"
  echo ""
}

# ════════════════════════════════════════════════════════════════
#  WELCOME WARRIOR
# ════════════════════════════════════════════════════════════════
show_welcome() {
  echo -e "${Y}"
  echo "  ██╗    ██╗███████╗██╗      ██████╗  ██████╗ ███╗   ███╗███████╗"
  echo "  ██║    ██║██╔════╝██║     ██╔════╝ ██╔═══██╗████╗ ████║██╔════╝"
  echo "  ██║ █╗ ██║█████╗  ██║     ██║      ██║   ██║██╔████╔██║█████╗  "
  echo "  ██║███╗██║██╔══╝  ██║     ██║      ██║   ██║██║╚██╔╝██║██╔══╝  "
  echo "  ╚███╔███╔╝███████╗███████╗╚██████╗ ╚██████╔╝██║ ╚═╝ ██║███████╗"
  echo "   ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚══════╝"
  echo ""
  echo "  ██╗    ██╗ █████╗ ██████╗ ██████╗ ██╗ ██████╗ ██████╗ "
  echo "  ██║    ██║██╔══██╗██╔══██╗██╔══██╗██║██╔═══██╗██╔══██╗"
  echo "  ██║ █╗ ██║███████║██████╔╝██████╔╝██║██║   ██║██████╔╝"
  echo "  ██║███╗██║██╔══██║██╔══██╗██╔══██╗██║██║   ██║██╔══██╗"
  echo "  ╚███╔███╔╝██║  ██║██║  ██║██║  ██║██║╚██████╔╝██║  ██║"
  echo "   ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝ ╚═════╝ ╚═╝  ╚═╝"
  echo -e "${NC}"
  echo -e "${C}  The longship is crewed. The raid begins. What is the target?${NC}"
  [[ -n "$CURRENT_TARGET" ]] && echo -e "${G}  Active target: $CURRENT_TARGET${NC}"
  echo ""
}

# ════════════════════════════════════════════════════════════════
#  HELP
# ════════════════════════════════════════════════════════════════
show_help() {
  echo ""
  echo -e "${B}${Y}  [*]  VIKING COMMAND REFERENCE  [*]${NC}"
  echo -e "  ══════════════════════════════════════\n"
  echo -e "  ${C}TARGET MEMORY${NC}"
  printf "    %-32s — %s\n" "target <ip/url>" "lock target (all tools use it automatically)"
  printf "    %-32s — %s\n" "target clear" "clear locked target"
  printf "    %-32s — %s\n" "status" "show model, target, ollama status"
  echo ""

  local -a sections=(
    "SCANNING:scan [target]|nmap + AI analysis:masscan [target]|fast port scan:rustscan [target]|Rust port scan:naabu [target]|fast port finder:nuclei [target]|CVE template scan:nikto [target]|web vuln scan:ping <ip>|probe target:whois <domain>|WHOIS lookup"
    "WEB ATTACKS:gobuster [target]|directory brute:ffuf [target]|fast fuzzer:feroxbuster [target]|recursive dir:dirsearch [target]|dir search:sqlmap [target]|SQL injection:commix [target]|command injection:wpscan [target]|WordPress scan:xsstrike [target]|XSS scan:dalfox [target]|XSS fuzzer:katana [target]|web crawler"
    "PASSIVE RECON:waybackurls <domain>|historical URLs:gau <domain>|all URLs:hakrawler <url>|fast web crawler:dnsx <domain>|DNS brute force"
    "OSINT:theharvester <domain>|email + host recon:amass <domain>|subdomain enum:subfinder <domain>|subdomains:sherlock <user>|username hunt:holehe <email>|account check:maigret|username search"
    "WIRELESS:wifite|wireless attacks:airgeddon|full wifi audit:oneshot|WPS/PMKID attack:wifiphisher|evil twin AP:fluxion|WPA capture:bettercap|MITM + wifi:hcxdumptool|PMKID capture"
    "ACTIVE DIRECTORY:netexec|AD Swiss Army knife:responder|LLMNR/NTLMv2 capture:bloodhound|AD attack paths:certipy|AD CS enumeration:impacket|impacket suite"
    "POST EXPLOITATION:linpeas|Linux priv esc:pspy|process monitor (no root)"
    "PASSWORDS:hashcat|hash cracking:john|John the Ripper:hydra|brute force:name-that-hash|identify hash type"
    "EXPLOITATION:metasploit|msfconsole:netcat|reverse/bind shell:msfpc|payload creator:venom|shellcode generator"
    "PHISHING:setoolkit|social engineer toolkit:evilginx|reverse proxy phishing"
    "ANONYMITY:anonsurf|route traffic via Tor"
    "ARSENAL & MODEL:arsenal|browse + install all tools:model|switch AI models:model <name>|quick switch"
    "SYSTEM:help|this menu:history|session log:banner|redraw banner:quit|leave VIKING"
  )

  for section in "${sections[@]}"; do
    local title="${section%%:*}" rest="${section#*:}"
    echo -e "  ${C}${title}${NC}"
    IFS=':' read -ra cmds <<< "$rest"
    for cmd in "${cmds[@]}"; do
      printf "    %-32s — %s\n" "${cmd%%|*}" "${cmd##*|}"
    done
    echo ""
  done
}

# ════════════════════════════════════════════════════════════════
#  MODEL SWITCHER
# ════════════════════════════════════════════════════════════════
show_models() {
  local installed_list
  installed_list=$(ollama list 2>/dev/null | awk 'NR>1{print $1}') || installed_list=""

  echo ""
  echo -e "${B}${Y}  [*]  AVAILABLE MODELS  [*]${NC}"
  echo -e "  ════════════════════════════════════\n"

  local i=1
  for m in "${AVAILABLE_MODELS[@]}"; do
    local active="" inst=""
    [[ "$m" == "$MODEL" ]] && active="${G} <- active${NC}"
    echo "$installed_list" | grep -Fxq "$m" 2>/dev/null && inst="${D}[installed]${NC}"
    printf "  ${C}[%d]${NC}  %-22s%b %b\n" "$i" "$m" "$active" "$inst"
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
        MODEL="$choice"; save_config; v_say "Switched to: $MODEL"; break ;;
      *)
        local idx=$(( choice - 1 ))
        if (( idx >= 0 && idx < ${#AVAILABLE_MODELS[@]} )); then
          MODEL="${AVAILABLE_MODELS[$idx]}"; save_config
          v_say "Pulling $MODEL..."
          ollama pull "$MODEL" 2>/dev/null || true
          v_say "Active: $MODEL"; break
        else
          v_err "Invalid - enter 1, 2, 3, or back."
        fi ;;
    esac
  done
}

# ════════════════════════════════════════════════════════════════
#  MAIN INPUT HANDLER
#  All tool handlers live here so local variables are valid.
#  Returns 1 to exit the main loop, 0 to continue.
# ════════════════════════════════════════════════════════════════
handle_input() {
  local INPUT="$1"
  local TARGET="" RESULT=""

  # ── Built-in exact commands ───────────────────────────────────
  case "${INPUT,,}" in
    quit|exit|/bye)
      echo ""; v_say "The longship returns to port. Skal."; echo ""
      return 1 ;;
    help)    show_help;   return 0 ;;
    banner)  show_banner; return 0 ;;
    arsenal) bash "$VIKING_DIR/arsenal_menu.sh"; return 0 ;;
    model)   show_models; return 0 ;;
    history)
      echo ""; cat "$LOGFILE" 2>/dev/null || v_err "No history yet."; echo ""
      return 0 ;;
    "target clear")
      CURRENT_TARGET=""
      printf '' > "$TARGET_FILE" 2>/dev/null || true
      save_config; v_ok "Target cleared"; return 0 ;;
    status)
      echo ""
      echo -e "  Model   : ${G}$MODEL${NC}"
      echo -e "  Target  : ${G}${CURRENT_TARGET:-none}${NC}"
      local ollama_st
      curl -sf http://localhost:11434/ &>/dev/null && \
        ollama_st="${G}online${NC}" || ollama_st="${R}offline${NC}"
      echo -e "  Ollama  : $ollama_st"
      echo ""; return 0 ;;
  esac

  # ── model <name> quick switch ─────────────────────────────────
  if [[ "$INPUT" =~ ^[Mm]odel[[:space:]]+(.+)$ ]]; then
    MODEL="${BASH_REMATCH[1]}"; save_config
    v_say "Model -> $MODEL"; return 0
  fi

  # ── target <value> ───────────────────────────────────────────
  if [[ "$INPUT" =~ ^[Tt]arget[[:space:]]+(.+)$ ]]; then
    set_target "${BASH_REMATCH[1]}"; return 0
  fi

  # ════════════════════════════════════════════════════════════
  #  TOOL HANDLERS
  #  All variables declared local - valid because we are in a function.
  #  extract_target receives $INPUT explicitly - no global dependency.
  # ════════════════════════════════════════════════════════════

  # ── NMAP / SCAN ──────────────────────────────────────────────
  if match "$INPUT" "^scan[[:space:]]|^scan$|^nmap"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      local flags; flags=$(ask_scan_type)
      v_info "Scouting: $TARGET"
      echo ""
      RESULT=$(sudo nmap $flags "$TARGET" 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "nmap"
      ask_ai_analysis "$RESULT" "$TARGET" "nmap"
      log "SCAN: $TARGET"
    else
      v_err "No target. Usage: scan 192.168.1.1  or  target 192.168.1.1"
    fi
    return 0
  fi

  # ── NUCLEI ───────────────────────────────────────────────────
  if match "$INPUT" "nuclei|cve.*scan|vuln.*scan"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available nuclei; then _prompt_install nuclei || return 0; fi
      v_info "Nuclei CVE scan -> $TARGET"
      RESULT=$(launch_tool nuclei -u "$TARGET" -silent 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "nuclei"
      ask_ai_analysis "$RESULT" "$TARGET" "nuclei"
    else
      launch_tool nuclei
    fi
    return 0
  fi

  # ── MASSCAN ──────────────────────────────────────────────────
  if match "$INPUT" "masscan"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available masscan; then _prompt_install masscan || return 0; fi
      echo -e "${B}${Y}  masscan speed:${NC}"
      echo -e "  ${C}[1]${NC}  Quick - top ports rate 1000"
      echo -e "  ${C}[2]${NC}  Full  - all ports rate 10000"
      echo -ne "  ${Y}[1-2]: ${NC}"
      local mc; read -r mc
      local mf="-p1-65535 --rate=1000"
      [[ "$mc" == "2" ]] && mf="-p1-65535 --rate=10000"
      v_info "Masscan -> $TARGET"
      RESULT=$(sudo masscan "$TARGET" $mf 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "masscan"
      ask_ai_analysis "$RESULT" "$TARGET" "masscan"
    else
      launch_tool masscan
    fi
    return 0
  fi

  # ── RUSTSCAN ─────────────────────────────────────────────────
  if match "$INPUT" "rustscan"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available rustscan && ! _tool_available RustScan; then
        _prompt_install RustScan || return 0
      fi
      v_info "RustScan -> $TARGET"
      RESULT=$(launch_tool RustScan -- -a "$TARGET" 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "rustscan"
      ask_ai_analysis "$RESULT" "$TARGET" "rustscan"
    else
      launch_tool RustScan
    fi
    return 0
  fi

  # ── NAABU ────────────────────────────────────────────────────
  if match "$INPUT" "naabu"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available naabu; then _prompt_install naabu || return 0; fi
      v_info "Naabu -> $TARGET"
      RESULT=$(launch_tool naabu -host "$TARGET" 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "naabu"
      ask_ai_analysis "$RESULT" "$TARGET" "naabu"
    else
      launch_tool naabu
    fi
    return 0
  fi

  # ── DNSX ─────────────────────────────────────────────────────
  if match "$INPUT" "dnsx|dns.*brute"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available dnsx; then _prompt_install dnsx || return 0; fi
      v_info "dnsx -> $TARGET"
      RESULT=$(launch_tool dnsx -d "$TARGET" -silent 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "dnsx"
    else
      launch_tool dnsx
    fi
    return 0
  fi

  # ── NIKTO ────────────────────────────────────────────────────
  if match "$INPUT" "nikto"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available nikto; then _prompt_install nikto || return 0; fi
      echo -e "${B}${Y}  Nikto depth:${NC}"
      echo -e "  ${C}[1]${NC}  Quick - basic checks"
      echo -e "  ${C}[2]${NC}  Full  - all plugins"
      echo -ne "  ${Y}[1-2]: ${NC}"
      local nk; read -r nk
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
      ai_response "nikto usage guide"
    fi
    return 0
  fi

  # ── GOBUSTER / DIRB ──────────────────────────────────────────
  if match "$INPUT" "gobuster|dirb|directory.*brute|dir.*scan"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      echo -e "${B}${Y}  Wordlist:${NC}"
      echo -e "  ${C}[1]${NC}  Quick  - common.txt"
      echo -e "  ${C}[2]${NC}  Medium - directory-list-2.3-medium.txt"
      echo -e "  ${C}[3]${NC}  Full   - directory-list-2.3-big.txt"
      echo -ne "  ${Y}[1-3]: ${NC}"
      local dc; read -r dc
      local wl
      case "$dc" in
        2) wl="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt" ;;
        3) wl="/usr/share/wordlists/dirbuster/directory-list-2.3-big.txt" ;;
        *) wl="/usr/share/wordlists/dirb/common.txt" ;;
      esac
      v_info "Dir scan -> $TARGET"
      if command -v gobuster &>/dev/null; then
        RESULT=$(gobuster dir -u "$TARGET" -w "$wl" 2>&1)
      elif command -v dirb &>/dev/null; then
        RESULT=$(dirb "$TARGET" "$wl" 2>&1)
      else
        _prompt_install gobuster || return 0
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
  if match "$INPUT" "ffuf|fuzz"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available ffuf; then _prompt_install ffuf || return 0; fi
      v_info "ffuf -> $TARGET"
      RESULT=$(launch_tool ffuf -u "${TARGET}/FUZZ" \
        -w /usr/share/wordlists/dirb/common.txt 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "ffuf"
      ask_ai_analysis "$RESULT" "$TARGET" "ffuf"
    else
      launch_tool ffuf
    fi
    return 0
  fi

  # ── FEROXBUSTER ──────────────────────────────────────────────
  if match "$INPUT" "feroxbuster|ferox"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available feroxbuster; then _prompt_install feroxbuster || return 0; fi
      v_info "Feroxbuster -> $TARGET"
      RESULT=$(launch_tool feroxbuster -u "$TARGET" 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "feroxbuster"
      ask_ai_analysis "$RESULT" "$TARGET" "feroxbuster"
    else
      launch_tool feroxbuster
    fi
    return 0
  fi

  # ── DIRSEARCH ────────────────────────────────────────────────
  if match "$INPUT" "dirsearch"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available dirsearch; then _prompt_install dirsearch || return 0; fi
      v_info "Dirsearch -> $TARGET"
      RESULT=$(launch_tool dirsearch -u "$TARGET" 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "dirsearch"
      ask_ai_analysis "$RESULT" "$TARGET" "dirsearch"
    else
      launch_tool dirsearch
    fi
    return 0
  fi

  # ── SQLMAP ───────────────────────────────────────────────────
  if match "$INPUT" "sqlmap|sqli|sql.*inject"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available sqlmap; then _prompt_install sqlmap || return 0; fi
      echo -e "${B}${Y}  SQLmap level:${NC}"
      echo -e "  ${C}[1]${NC}  Quick  - level 1, risk 1"
      echo -e "  ${C}[2]${NC}  Medium - level 3, risk 2"
      echo -e "  ${C}[3]${NC}  Full   - level 5, risk 3"
      echo -ne "  ${Y}[1-3]: ${NC}"
      local sq; read -r sq
      local sf
      case "$sq" in
        2) sf="--level=3 --risk=2" ;;
        3) sf="--level=5 --risk=3 --tamper=space2comment" ;;
        *) sf="--level=1 --risk=1" ;;
      esac
      v_info "SQLmap -> $TARGET"
      RESULT=$(launch_tool sqlmap -u "$TARGET" --batch $sf 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "sqlmap"
      ask_ai_analysis "$RESULT" "$TARGET" "sqlmap"
    else
      ai_response "sqlmap command for: $INPUT"
    fi
    return 0
  fi

  # ── XSSTRIKE ─────────────────────────────────────────────────
  if match "$INPUT" "xsstrike|xss.*strike"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available XSStrike; then _prompt_install XSStrike || return 0; fi
      v_info "XSStrike -> $TARGET"
      RESULT=$(launch_tool XSStrike -u "$TARGET" 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "xsstrike"
      ask_ai_analysis "$RESULT" "$TARGET" "xsstrike"
    else
      launch_tool XSStrike
    fi
    return 0
  fi

  # ── DALFOX ───────────────────────────────────────────────────
  if match "$INPUT" "dalfox"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available dalfox; then _prompt_install dalfox || return 0; fi
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
  if match "$INPUT" "wpscan|wordpress.*scan"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available wpscan; then _prompt_install wpscan || return 0; fi
      echo -e "${B}${Y}  WPScan depth:${NC}"
      echo -e "  ${C}[1]${NC}  Quick - basic scan"
      echo -e "  ${C}[2]${NC}  Full  - enumerate users, plugins, themes"
      echo -ne "  ${Y}[1-2]: ${NC}"
      local wp; read -r wp
      v_info "WPScan -> $TARGET"
      if [[ "$wp" == "2" ]]; then
        RESULT=$(launch_tool wpscan --url "$TARGET" --enumerate u,p,t 2>&1)
      else
        RESULT=$(launch_tool wpscan --url "$TARGET" 2>&1)
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
  if match "$INPUT" "commix|command.*inject"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available commix; then _prompt_install commix || return 0; fi
      v_info "Commix -> $TARGET"
      RESULT=$(launch_tool commix --url "$TARGET" 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "commix"
      ask_ai_analysis "$RESULT" "$TARGET" "commix"
    else
      ai_response "commix command injection for: $INPUT"
    fi
    return 0
  fi

  # ── KATANA ───────────────────────────────────────────────────
  if match "$INPUT" "katana|web.*crawl"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available katana; then _prompt_install katana || return 0; fi
      v_info "Katana -> $TARGET"
      RESULT=$(launch_tool katana -u "$TARGET" 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "katana"
    else
      launch_tool katana
    fi
    return 0
  fi

  # ── WAYBACKURLS ──────────────────────────────────────────────
  if match "$INPUT" "wayback|waybackurls"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available waybackurls; then _prompt_install waybackurls || return 0; fi
      v_info "Waybackurls -> $TARGET"
      RESULT=$(echo "$TARGET" | launch_tool waybackurls 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "waybackurls"
    else
      v_err "Usage: waybackurls example.com"
    fi
    return 0
  fi

  # ── GAU ──────────────────────────────────────────────────────
  if match "$INPUT" "^gau[[:space:]]|^gau$"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available gau; then _prompt_install gau || return 0; fi
      v_info "gau -> $TARGET"
      RESULT=$(launch_tool gau "$TARGET" 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "gau"
    else
      launch_tool gau
    fi
    return 0
  fi

  # ── HAKRAWLER ────────────────────────────────────────────────
  if match "$INPUT" "hakrawler"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available hakrawler; then _prompt_install hakrawler || return 0; fi
      v_info "hakrawler -> $TARGET"
      RESULT=$(echo "$TARGET" | launch_tool hakrawler 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "hakrawler"
    else
      launch_tool hakrawler
    fi
    return 0
  fi

  # ── THEHARVESTER ─────────────────────────────────────────────
  if match "$INPUT" "theharvester|harvester"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available theHarvester && ! _tool_available theharvester; then
        _prompt_install theHarvester || return 0
      fi
      v_info "theHarvester -> $TARGET"
      RESULT=$(launch_tool theHarvester -d "$TARGET" -b all 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "theharvester"
      ask_ai_analysis "$RESULT" "$TARGET" "theharvester"
    else
      launch_tool theHarvester
    fi
    return 0
  fi

  # ── SUBFINDER ────────────────────────────────────────────────
  if match "$INPUT" "subfinder"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available subfinder; then _prompt_install subfinder || return 0; fi
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

  # ── AMASS ────────────────────────────────────────────────────
  if match "$INPUT" "amass"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      if ! _tool_available amass; then _prompt_install amass || return 0; fi
      echo -e "${B}${Y}  Amass mode:${NC}"
      echo -e "  ${C}[1]${NC}  Passive - no direct contact"
      echo -e "  ${C}[2]${NC}  Active  - full enum + brute"
      echo -ne "  ${Y}[1-2]: ${NC}"
      local am; read -r am
      v_info "Amass -> $TARGET"
      if [[ "$am" == "2" ]]; then
        RESULT=$(launch_tool amass enum -active -brute -d "$TARGET" 2>&1)
      else
        RESULT=$(launch_tool amass enum -passive -d "$TARGET" 2>&1)
      fi
      echo "$RESULT"
      ask_save_output "$RESULT" "$TARGET" "amass"
      ask_ai_analysis "$RESULT" "$TARGET" "amass"
    else
      launch_tool amass
    fi
    return 0
  fi

  # ── HOLEHE ───────────────────────────────────────────────────
  if match "$INPUT" "holehe"; then
    local email
    email=$(echo "$INPUT" | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | head -1)
    if [[ -n "$email" ]]; then
      if ! _tool_available holehe; then _prompt_install holehe || return 0; fi
      v_info "Holehe -> $email"
      RESULT=$(launch_tool holehe "$email" 2>&1)
      echo "$RESULT"
      ask_save_output "$RESULT" "$email" "holehe"
    else
      v_err "Usage: holehe user@example.com"
    fi
    return 0
  fi

  # ── SHERLOCK ─────────────────────────────────────────────────
  if match "$INPUT" "sherlock|username.*hunt"; then
    if ! _tool_available sherlock; then _prompt_install sherlock || return 0; fi
    local uname; uname=$(echo "$INPUT" | awk '{print $NF}')
    v_info "Sherlock -> $uname"
    RESULT=$(launch_tool sherlock "$uname" 2>&1)
    echo "$RESULT"
    ask_save_output "$RESULT" "$uname" "sherlock"
    return 0
  fi

  # ── NAME-THAT-HASH ───────────────────────────────────────────
  if match "$INPUT" "name.*that.*hash|nth|identify.*hash|what.*hash"; then
    if ! _tool_available nth; then _prompt_install name-that-hash || return 0; fi
    local hash_val; hash_val=$(echo "$INPUT" | awk '{print $NF}')
    v_info "Identifying hash: $hash_val"
    launch_tool nth --text "$hash_val"
    return 0
  fi

  # ── LINPEAS ──────────────────────────────────────────────────
  if match "$INPUT" "linpeas|linux.*priv.*esc|linux.*privesc"; then
    v_info "Running LinPEAS..."
    local peas_dir="$ARSENAL_DIR/PEASS-ng"
    if [[ -f "$peas_dir/linPEAS/linpeas.sh" ]]; then
      bash "$peas_dir/linPEAS/linpeas.sh" 2>&1 | tee "$SCAN_DIR/linpeas_$(date +%s).txt"
    else
      v_info "Downloading linpeas from GitHub..."
      curl -sL https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh \
        -o /tmp/linpeas.sh && bash /tmp/linpeas.sh 2>&1 | tee "$SCAN_DIR/linpeas_$(date +%s).txt"
    fi
    return 0
  fi

  # ── PSPY ─────────────────────────────────────────────────────
  if match "$INPUT" "pspy|process.*spy|monitor.*proc"; then
    v_info "Launching pspy..."
    local pspy_dir="$ARSENAL_DIR/pspy"
    if [[ -f "$pspy_dir/pspy64" ]]; then
      "$pspy_dir/pspy64"
    elif command -v pspy64 &>/dev/null; then
      pspy64
    else
      v_info "Downloading pspy64..."
      curl -sL https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64 \
        -o /tmp/pspy64 && chmod +x /tmp/pspy64 && /tmp/pspy64
    fi
    return 0
  fi

  # ── WIFITE ───────────────────────────────────────────────────
  if match "$INPUT" "wifite|wifi.*attack|wireless.*attack"; then
    if ! _tool_available wifite && ! _tool_available wifite2; then
      _prompt_install wifite || return 0
    fi
    v_info "Launching Wifite..."
    if command -v wifite &>/dev/null; then sudo wifite
    else launch_tool wifite2; fi
    return 0
  fi

  # ── AIRGEDDON ────────────────────────────────────────────────
  if match "$INPUT" "airgeddon"; then
    if ! _tool_available airgeddon; then _prompt_install airgeddon || return 0; fi
    v_info "Launching Airgeddon..."
    sudo_tool airgeddon
    return 0
  fi

  # ── ONESHOT ──────────────────────────────────────────────────
  if match "$INPUT" "oneshot|wps.*attack|pmkid"; then
    local IFACE
    IFACE=$(ip -o link show | awk '/wlan/{gsub(":",""); print $2; exit}') || IFACE="wlan0"
    IFACE="${IFACE:-wlan0}"
    v_info "OneShot WPS -> $IFACE"
    if [[ -f "$ARSENAL_DIR/OneShot/oneshot.py" ]]; then
      sudo python3 "$ARSENAL_DIR/OneShot/oneshot.py" -i "$IFACE"
    elif [[ -f "/usr/share/oneshot/oneshot.py" ]]; then
      sudo python3 /usr/share/oneshot/oneshot.py -i "$IFACE"
    else
      _prompt_install OneShot
    fi
    return 0
  fi

  # ── BETTERCAP ────────────────────────────────────────────────
  if match "$INPUT" "bettercap"; then
    if ! _tool_available bettercap; then _prompt_install bettercap || return 0; fi
    v_info "Launching Bettercap..."
    sudo_tool bettercap
    return 0
  fi

  # ── HCXDUMPTOOL ──────────────────────────────────────────────
  if match "$INPUT" "hcxdumptool|pmkid.*cap|handshake.*cap"; then
    if ! _tool_available hcxdumptool; then _prompt_install hcxdumptool || return 0; fi
    local IFACE
    IFACE=$(ip -o link show | awk '/wlan/{gsub(":",""); print $2; exit}') || IFACE="wlan0"
    IFACE="${IFACE:-wlan0}"
    v_info "hcxdumptool -> $IFACE (Ctrl+C to stop)"
    local pcap="$SCAN_DIR/capture_$(date +%s).pcapng"
    mkdir -p "$SCAN_DIR"
    # Use actual binary path for sudo (fixes the sudo + function bug)
    local hcx_bin; hcx_bin=$(command -v hcxdumptool 2>/dev/null) || hcx_bin=""
    if [[ -n "$hcx_bin" ]]; then
      sudo "$hcx_bin" -i "$IFACE" -o "$pcap" --enable_status=1
    else
      v_err "hcxdumptool binary not found"
    fi
    v_ok "Capture saved: $pcap"
    echo -e "  ${Y}Convert:${NC} hcxpcapngtool $pcap -o hash.hc22000"
    return 0
  fi

  # ── HCXTOOLS ─────────────────────────────────────────────────
  if match "$INPUT" "hcxtools|hcxpcap|convert.*pcap"; then
    v_info "hcxtools usage:"
    echo -e "  ${C}hcxpcapngtool capture.pcapng -o hash.hc22000${NC}"
    echo -e "  ${C}hashcat -m 22000 hash.hc22000 /usr/share/wordlists/rockyou.txt${NC}"
    return 0
  fi

  # ── FLUXION ──────────────────────────────────────────────────
  if match "$INPUT" "fluxion"; then
    if ! _tool_available fluxion; then _prompt_install fluxion || return 0; fi
    v_info "Launching Fluxion..."
    launch_tool fluxion
    return 0
  fi

  # ── WIFIPHISHER ──────────────────────────────────────────────
  if match "$INPUT" "wifiphisher"; then
    if ! _tool_available wifiphisher; then _prompt_install wifiphisher || return 0; fi
    v_info "Launching Wifiphisher..."
    sudo_tool wifiphisher
    return 0
  fi

  # ── AIRCRACK / AIRMON (guidance) ─────────────────────────────
  if match "$INPUT" "aircrack|airmon|airodump|monitor.*mode"; then
    if match "$INPUT" "open|launch|start|run"; then
      local tool_name; tool_name=$(echo "$INPUT" | awk '{print tolower($2)}')
      launch_tool "$tool_name"
    else
      v_info "Aircrack-ng guidance:"
      ai_response "aircrack-ng step-by-step commands for: $INPUT"
    fi
    return 0
  fi

  # ── TSHARK ───────────────────────────────────────────────────
  if match "$INPUT" "tshark|packet.*capture|sniff|capture.*traffic"; then
    if ! _tool_available tshark; then _prompt_install tshark || return 0; fi
    local IFACE
    IFACE=$(ip -o link show | awk '!/lo/{gsub(":",""); print $2; exit}') || IFACE="eth0"
    v_info "Capturing on ${IFACE:-eth0} (Ctrl+C to stop)"
    sudo tshark -i "${IFACE:-eth0}" 2>&1 | head -80
    return 0
  fi

  # ── HYDRA ────────────────────────────────────────────────────
  if match "$INPUT" "hydra|brute.?force|crack.*password|password.*attack"; then
    ai_response "hydra brute force command for: $INPUT"
    return 0
  fi

  # ── HASHCAT / JOHN ───────────────────────────────────────────
  if match "$INPUT" "hashcat|john.*ripper|crack.*hash|hash.*crack"; then
    ai_response "hashcat or john command with hash type detection for: $INPUT"
    return 0
  fi

  # ── METASPLOIT ───────────────────────────────────────────────
  if match "$INPUT" "metasploit|msfconsole|meterpreter"; then
    if match "$INPUT" "open|launch|start|run"; then
      if ! _tool_available msfconsole; then _prompt_install msfconsole || return 0; fi
      v_info "Launching msfconsole..."
      msfconsole
    else
      ai_response "msfconsole steps for: $INPUT"
    fi
    return 0
  fi

  # ── NETCAT ───────────────────────────────────────────────────
  if match "$INPUT" "netcat| nc |reverse.*shell|bind.*shell"; then
    ai_response "netcat listener and connect side commands for: $INPUT"
    return 0
  fi

  # ── RESPONDER ────────────────────────────────────────────────
  if match "$INPUT" "responder|ntlm.*capture|llmnr.*poison"; then
    if ! _tool_available responder; then _prompt_install responder || return 0; fi
    local IFACE2
    IFACE2=$(ip -o link show | awk '!/lo/{gsub(":",""); print $2; exit}') || IFACE2="eth0"
    v_info "Launching Responder -> ${IFACE2:-eth0}"
    # Use sudo_tool to avoid sudo + function bug
    sudo_tool responder -I "${IFACE2:-eth0}"
    return 0
  fi

  # ── NETEXEC ──────────────────────────────────────────────────
  if match "$INPUT" "netexec|crackmapexec|cme|nxc"; then
    ai_response "netexec (nxc) Active Directory command for: $INPUT"
    return 0
  fi

  # ── BLOODHOUND ───────────────────────────────────────────────
  if match "$INPUT" "bloodhound|blood.*hound"; then
    if ! _tool_available bloodhound; then _prompt_install bloodhound || return 0; fi
    v_info "Launching BloodHound..."
    launch_gui "bloodhound" "Run: sudo neo4j start && bloodhound"
    return 0
  fi

  # ── IMPACKET ─────────────────────────────────────────────────
  if match "$INPUT" "impacket|psexec|secretsdump|smbclient|wmiexec|getuserspns"; then
    ai_response "impacket tool command for: $INPUT"
    return 0
  fi

  # ── CERTIPY ──────────────────────────────────────────────────
  if match "$INPUT" "certipy|adcs|certificate.*service"; then
    ai_response "certipy command for AD Certificate Services: $INPUT"
    return 0
  fi

  # ── ANONSURF ─────────────────────────────────────────────────
  if match "$INPUT" "anonsurf"; then
    v_info "AnonSurf..."
    if command -v anonsurf &>/dev/null; then
      sudo_tool anonsurf start
    else
      launch_tool kali-anonsurf start
    fi
    return 0
  fi

  # ── SETOOLKIT / SET ──────────────────────────────────────────
  if match "$INPUT" "setoolkit|social.*engineer|se.toolkit"; then
    if ! _tool_available setoolkit && ! _tool_available SET; then
      _prompt_install setoolkit || return 0
    fi
    v_info "Launching Social Engineer Toolkit..."
    if command -v setoolkit &>/dev/null; then
      sudo setoolkit
    else
      launch_tool SET
    fi
    return 0
  fi

  # ── EVILGINX ─────────────────────────────────────────────────
  if match "$INPUT" "evilginx"; then
    if ! _tool_available evilginx2; then _prompt_install evilginx2 || return 0; fi
    v_info "Launching Evilginx2..."
    launch_tool evilginx2
    return 0
  fi

  # ── SLIVER ───────────────────────────────────────────────────
  if match "$INPUT" "sliver"; then
    if ! _tool_available sliver; then _prompt_install sliver || return 0; fi
    v_info "Launching Sliver C2..."
    launch_tool sliver
    return 0
  fi

  # ── HAVOC ────────────────────────────────────────────────────
  if match "$INPUT" "havoc"; then
    if ! _tool_available havoc; then _prompt_install havoc || return 0; fi
    v_info "Launching Havoc C2..."
    launch_tool havoc
    return 0
  fi

  # ── THEFATRAT ────────────────────────────────────────────────
  if match "$INPUT" "fatrat|thefatrat"; then
    if ! _tool_available TheFatRat; then _prompt_install TheFatRat || return 0; fi
    v_info "Launching TheFatRat..."
    launch_tool TheFatRat
    return 0
  fi

  # ── VENOM ────────────────────────────────────────────────────
  if match "$INPUT" "^venom[[:space:]]|^venom$"; then
    if ! _tool_available venom; then _prompt_install venom || return 0; fi
    v_info "Launching Venom..."
    launch_tool venom
    return 0
  fi

  # ── MSFPC ────────────────────────────────────────────────────
  if match "$INPUT" "msfpc|msfvenom.*payload|payload.*creator"; then
    if ! _tool_available msfpc; then _prompt_install msfpc || return 0; fi
    v_info "Launching msfpc..."
    launch_tool msfpc
    return 0
  fi

  # ── CUPP ─────────────────────────────────────────────────────
  if match "$INPUT" "cupp|wordlist.*gen|password.*profile"; then
    if ! _tool_available cupp; then _prompt_install cupp || return 0; fi
    v_info "Launching CUPP..."
    launch_tool cupp -i
    return 0
  fi

  # ── SPIDERFOOT ───────────────────────────────────────────────
  if match "$INPUT" "spiderfoot"; then
    v_info "Launching SpiderFoot on http://127.0.0.1:5001"
    if [[ -f "$ARSENAL_DIR/spiderfoot/sf.py" ]]; then
      python3 "$ARSENAL_DIR/spiderfoot/sf.py" -l 127.0.0.1:5001
    else
      _prompt_install spiderfoot
    fi
    return 0
  fi

  # ── PING ─────────────────────────────────────────────────────
  if match "$INPUT" "^ping[[:space:]]"; then
    TARGET=$(extract_target "$INPUT")
    if [[ -n "$TARGET" ]]; then
      v_info "Probing $TARGET..."
      ping -c 4 "$TARGET"
    else
      v_err "Usage: ping 192.168.1.1"
    fi
    return 0
  fi

  # ── WHOIS ────────────────────────────────────────────────────
  if match "$INPUT" "whois"; then
    TARGET=$(extract_target "$INPUT")
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

  # ── GENERIC OPEN/LAUNCH/RUN/START ────────────────────────────
  if match "$INPUT" "^(open|launch|run|start)[[:space:]]+"; then
    local tname; tname=$(echo "$INPUT" | awk '{print tolower($2)}')
    local raw_tname; raw_tname=$(echo "$INPUT" | awk '{print $2}')
    case "$tname" in
      wireshark)
        launch_gui "wireshark" "Use: sudo tshark -i eth0" ;;
      burp|burpsuite)
        launch_gui "burpsuite" "Use: nikto -h <target> for CLI web scanning" ;;
      chrome|google-chrome)
        launch_gui "google-chrome" "Use: curl or wget instead" ;;
      firefox)
        launch_gui "firefox" "Use: curl or wget instead" ;;
      zap|owasp-zap|zaproxy)
        launch_gui "zaproxy" "Use: nikto for CLI scanning" ;;
      maltego)
        launch_gui "maltego" "Use: theHarvester or spiderfoot for CLI OSINT" ;;
      msf|msfconsole|metasploit)
        if ! _tool_available msfconsole; then _prompt_install msfconsole || return 0; fi
        v_info "Launching msfconsole..."
        msfconsole ;;
      nmap)
        v_info "Launching nmap..."
        sudo nmap ;;
      *)
        # Check if installed first
        if ! _tool_available "$raw_tname"; then
          v_info "Checking if $raw_tname needs to be installed..."
          _prompt_install "$raw_tname" || return 0
        fi
        launch_tool "$raw_tname" ;;
    esac
    return 0
  fi

  # ── UPDATE ───────────────────────────────────────────────────
  if match "$INPUT" "^update$|^update viking|check.*update|new.*version"; then
    v_info "Checking for updates..."
    local tmp_upd="/tmp/viking_update_$$.sh"
    local remote_ver=""
    if ! curl -fsSL "https://raw.githubusercontent.com/skuldexter-web/Viking-AI/main/install.sh"         -o "$tmp_upd" 2>/dev/null; then
      v_err "Cannot reach GitHub. Check internet connection."
      rm -f "$tmp_upd"
      return 0
    fi
    remote_ver=$(grep 'readonly VIKING_VERSION=' "$tmp_upd" 2>/dev/null |       grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    remote_ver="${remote_ver:-unknown}"
    local cur_ver
    cur_ver=$(grep 'readonly VIKING_VERSION=' "$INSTALL_PATH" 2>/dev/null |       grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1) || cur_ver="unknown"
    echo ""
    echo -e "  Current : ${Y}${cur_ver}${NC}"
    echo -e "  Remote  : ${G}${remote_ver}${NC}"
    echo ""
    if [[ "$remote_ver" == "$cur_ver" ]]; then
      v_ok "Already up to date (v${cur_ver})"
      rm -f "$tmp_upd"
    else
      echo -ne "${Y}  Update to v${remote_ver}? [Y/n]: ${NC}"
      read -r uc
      if [[ "${uc,,}" != "n" ]]; then
        chmod +x "$tmp_upd"
        sudo bash "$tmp_upd"
        v_ok "Update applied. Restart viking."
      fi
      rm -f "$tmp_upd"
    fi
    return 0
  fi

  # ── SPLIT SCREEN ─────────────────────────────────────────────
  # Opens a second tmux pane for running parallel tools
  if match "$INPUT" "split.*screen|split.*term|second.*term|dual.*pane|open.*pane|new.*pane"; then
    if [[ -n "${TMUX:-}" ]]; then
      # Already in tmux - split the current window
      local direction="h"
      match "$INPUT" "vertical|below|bottom" && direction="v"
      echo ""
      echo -e "${C}  Opening split pane...${NC}"
      if [[ "$direction" == "h" ]]; then
        tmux split-window -h
      else
        tmux split-window -v
      fi
      v_ok "Split pane opened. Use Ctrl+B arrow keys to switch panes."
    else
      # Not in tmux - ask user if they want to launch tmux with a split
      echo ""
      echo -e "${Y}  Not currently inside a tmux session.${NC}"
      echo -ne "  Launch viking in tmux with a split pane? [Y/n]: "
      read -r ts_choice
      if [[ "${ts_choice,,}" != "n" ]]; then
        tmux new-session -d -s viking_split 2>/dev/null || true
        tmux split-window -h -t viking_split
        tmux attach-session -t viking_split
      else
        v_info "Tip: Start with 'tmux new -s viking' then type 'split screen'"
      fi
    fi
    return 0
  fi

  # ── DOUBLE CHECK (ask if user wants second terminal for tool) ─
  # Called by tool handlers when they think a second view is useful
  # e.g. "open second terminal for nikto"
  if match "$INPUT" "second.*terminal.*for|extra.*pane.*for|parallel.*run"; then
    local tool_req; tool_req=$(echo "$INPUT" | awk '{print $NF}')
    echo ""
    echo -ne "${Y}  Open a split pane and run $tool_req there? [Y/n]: ${NC}"
    read -r sp_choice
    if [[ "${sp_choice,,}" != "n" ]]; then
      if [[ -n "${TMUX:-}" ]]; then
        tmux split-window -h "bash -c 'echo Run: $tool_req here; bash'"
        v_ok "Split pane opened with $tool_req ready."
      else
        v_err "Start viking in tmux first: tmux new -s viking"
      fi
    fi
    return 0
  fi

  # ── RTL-SDR / RADIO TOOLS ────────────────────────────────────

  # ADS-B Flight Radar (dump1090)
  if match "$INPUT" "dump1090|flight.*radar|adsb|ads-b|aircraft|plane.*track"; then
    if ! _tool_available dump1090; then _prompt_install dump1090 || return 0; fi
    echo ""
    echo -e "${B}${Y}  [*] VIKING ADS-B FLIGHT RADAR [*]${NC}"
    echo -e "  ${C}[1]${NC}  Interactive mode (terminal display)"
    echo -e "  ${C}[2]${NC}  Raw output (pipe to other tools)"
    echo -e "  ${C}[3]${NC}  Net mode (feeds port 30003 for mapping)"
    echo -ne "  ${Y}[1-3]: ${NC}"
    local fr_mode; read -r fr_mode
    v_info "Starting dump1090 ADS-B receiver (needs RTL-SDR dongle)..."
    local d1090_bin; d1090_bin=$(command -v dump1090 2>/dev/null) ||       d1090_bin="$ARSENAL_DIR/dump1090/dump1090"
    if [[ ! -x "${d1090_bin}" ]]; then
      v_err "dump1090 binary not found or not executable"
      return 0
    fi
    case "$fr_mode" in
      2) "$d1090_bin" --quiet ;;
      3) "$d1090_bin" --net --net-ro-port 30003 ;;
      *) "$d1090_bin" --interactive --net ;;
    esac
    return 0
  fi

  # RTL_433 — decode IoT/weather/garage sensors
  if match "$INPUT" "rtl.?433|rtl433|sensor.*decode|weather.*sensor|iot.*radio|433.*mhz"; then
    if ! _tool_available rtl_433; then _prompt_install rtl_433 || return 0; fi
    echo ""
    echo -e "${B}${Y}  [*] RTL_433 SENSOR DECODER [*]${NC}"
    echo -e "  ${C}[1]${NC}  Auto-detect all signals"
    echo -e "  ${C}[2]${NC}  JSON output (pipe-friendly)"
    echo -e "  ${C}[3]${NC}  Specific frequency (enter MHz)"
    echo -ne "  ${Y}[1-3]: ${NC}"
    local r433_mode; read -r r433_mode
    v_info "Starting rtl_433 (needs RTL-SDR dongle)..."
    case "$r433_mode" in
      2) launch_tool rtl_433 -F json ;;
      3)
        echo -ne "  ${Y}Frequency (MHz, e.g. 433.92): ${NC}"
        local r433_freq; read -r r433_freq
        launch_tool rtl_433 -f "${r433_freq}M" ;;
      *) launch_tool rtl_433 ;;
    esac
    return 0
  fi

  # Ham Radio / General SDR spectrum view
  if match "$INPUT" "hamradio|ham.*radio|gqrx|sdr.*spectrum|spectrum.*view|radio.*scan|gnuradio"; then
    echo ""
    echo -e "${B}${Y}  [*] RADIO / SDR TOOLS [*]${NC}"
    echo -e "  ${C}[1]${NC}  gqrx       — GUI SDR receiver (needs display)"
    echo -e "  ${C}[2]${NC}  rtl_fm     — FM radio to audio (CLI)"
    echo -e "  ${C}[3]${NC}  multimon-ng — decode POCSAG/AFSK/AX25 pager signals"
    echo -e "  ${C}[4]${NC}  kalibrate  — measure GSM clock offset of RTL-SDR"
    echo -ne "  ${Y}[1-4]: ${NC}"
    local radio_mode; read -r radio_mode
    case "$radio_mode" in
      1) launch_gui "gqrx" "Use rtl_fm for CLI FM radio" ;;
      2)
        echo -ne "  ${Y}FM frequency (MHz, e.g. 99.9): ${NC}"
        local fm_freq; read -r fm_freq
        v_info "Tuning RTL-SDR to ${fm_freq} MHz FM..."
        echo -e "  ${D}Playing via speaker — Ctrl+C to stop${NC}"
        rtl_fm -f "${fm_freq}M" -M fm -s 200000 -r 48000 2>/dev/null |           aplay -r 48000 -f S16_LE -t raw - 2>/dev/null ||           v_err "aplay not found. Install: sudo apt install alsa-utils"
        ;;
      3)
        v_info "multimon-ng — decode radio signals (pipe from rtl_fm)..."
        echo -e "  ${C}Example: rtl_fm -f 152.04M -s 22050 | multimon-ng -t raw -a POCSAG512 -f alpha -${NC}"
        if ! _tool_available multimon-ng; then _prompt_install multimon-ng; fi
        ;;
      4)
        v_info "kalibrate-rtl — GSM calibration..."
        launch_tool kal -s GSM900
        ;;
    esac
    return 0
  fi

  # RTL-SDR general info / setup
  if match "$INPUT" "rtl.?sdr|software.*defined.*radio|sdr.*setup|rtl.*setup"; then
    echo ""
    echo -e "${B}${Y}  [*] RTL-SDR SETUP & INFO [*]${NC}"
    echo ""
    echo -e "  ${C}Check dongle detected:${NC}"
    echo -e "    rtl_test -t"
    echo ""
    echo -e "  ${C}Available CLI tools:${NC}"
    for tool in rtl_fm rtl_433 rtl_test dump1090 multimon-ng kalibrate-rtl; do
      if command -v "$tool" &>/dev/null; then
        printf "    ${G}[installed]${NC}  %s
" "$tool"
      else
        printf "    ${R}[missing]${NC}    %s
" "$tool"
      fi
    done
    echo ""
    echo -e "  ${Y}Install all RTL-SDR tools:${NC} arsenal -> [114-120]"
    ai_response "RTL-SDR software defined radio CLI setup guide and what you can do with a cheap USB dongle"
    return 0
  fi

  # ── HIDDEN TOOL (Rick Roll easter egg) ───────────────────────
  # secret command: vikingroll / rollrick / longship secret / hidden toll
  if match "$INPUT" "vikingroll|rollrick|hidden.?toll|longship.*secret|never.*gonna|rickroll|rick.*roll"; then
    echo ""
    echo -e "${Y}  The skalds have foretold this moment...${NC}"
    echo ""
    sleep 1
    echo -e "${RB}"
    echo "  ██████╗ ██╗ ██████╗██╗  ██╗    ██████╗  ██████╗ ██╗     ██╗      "
    echo "  ██╔══██╗██║██╔════╝██║ ██╔╝    ██╔══██╗██╔═══██╗██║     ██║      "
    echo "  ██████╔╝██║██║     █████╔╝     ██████╔╝██║   ██║██║     ██║      "
    echo "  ██╔══██╗██║██║     ██╔═██╗     ██╔══██╗██║   ██║██║     ██║      "
    echo "  ██║  ██║██║╚██████╗██║  ██╗    ██║  ██║╚██████╔╝███████╗███████╗ "
    echo "  ╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝"
    echo -e "${NC}"
    echo -e "${Y}  Never gonna give you up...${NC}"
    echo -e "${Y}  Never gonna let you down...${NC}"
    echo -e "${Y}  Never gonna run around and desert you...${NC}"
    echo ""
    echo -e "${C}  Opening in browser...${NC}"
    sleep 1
    # Try multiple ways to open — CLI-friendly
    if command -v xdg-open &>/dev/null && [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
      xdg-open "https://www.youtube.com/watch?v=dQw4w9WgXcQ" 2>/dev/null &
    elif command -v curl &>/dev/null; then
      echo ""
      echo -e "${D}  Direct link: https://www.youtube.com/watch?v=dQw4w9WgXcQ${NC}"
      echo ""
      echo -e "${C}  ASCII Rick Astley incoming from the longship...${NC}"
      echo ""
      sleep 1
      curl -sL "https://www.youtube.com/watch?v=dQw4w9WgXcQ" -o /dev/null
      # ASCII art fallback
      echo -e "${Y}"
      echo '   o   o   o   ooo   o   o o ooo  ooo  ooo   ooo  '
      echo '   oo  o  o o  o  o  oo  o   o   o     o  o  o  o '
      echo '   o o o o   o  ooo  o o o   o   o  oo  oooo  ooo  '
      echo '   o  oo o   o  o  o o  oo   o   o   o  o  o  o  o '
      echo '   o   o o   o  o  o o   o   o    ooo   o  o  o  o '
      echo -e "${NC}"
      echo -e "${G}  You have been Rick Rolled by VIKING.${NC}"
      echo -e "${D}  https://www.youtube.com/watch?v=dQw4w9WgXcQ${NC}"
    fi
    echo ""
    v_say "Ha! Even the greatest warriors fall for this raid. Skål."
    echo ""
    return 0
  fi

  # ── CODING ───────────────────────────────────────────────────
  if match "$INPUT" "python|write.*me|create.*script|make.*script|html|css|javascript|flask|django|bash.*script|code.*for|write.*a|powershell|golang"; then
    v_info "Scripting mode..."
    ai_response "Write complete working commented code. Full code block first, brief explanation after. Task: $INPUT"
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
  # Prompt shows active target if set
  if [[ -n "$CURRENT_TARGET" ]]; then
    echo -ne "${Y}You${NC}${D}[${NC}${G}${CURRENT_TARGET}${NC}${D}]${NC}${Y}:${NC} "
  else
    echo -ne "${Y}You: ${NC}"
  fi

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
  echo -e "  ${RB}[3]${NC}  ${RB}WAR MODE${NC} - install all ${#ARSENAL[@]} tools"
  echo -e "  ${Y}[4]${NC}  Skip\n"
  echo -ne "  Choice [1-4]: "
  read -r choice

  case "$choice" in
    1) log_ok "Standard install - CLI + AI ready." ;;
    2)
      display_arsenal_table
      echo -e "  Tool numbers space-separated (e.g. ${C}1 3 7 28${NC}):"
      echo -ne "  > "
      read -r picks
      mkdir -p "$ARSENAL_DIR"
      for n in $picks; do install_tool "$n" || true; done ;;
    3) war_mode_install ;;
    4) log_info "Skipping tool installation." ;;
    *) log_warn "Invalid choice - skipping." ;;
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
  echo "  ═════════════════════════════════════════════════"
  echo -e "${B}${Y}  [*]   VIKING AI - Installation Complete   [*]${NC}"
  echo "  ═════════════════════════════════════════════════"
  echo ""
  echo -e "  Launch:          ${C}viking${NC}"
  echo -e "  In tmux:         ${C}tmux new -s viking${NC}  then  ${C}viking${NC}"
  echo -e "  Detach tmux:     ${C}Ctrl+B then D${NC}"
  echo -e "  Reattach:        ${C}tmux attach -t viking${NC}"
  echo -e "  Browse tools:    inside viking -> ${C}arsenal${NC}"
  echo -e "  Switch model:    inside viking -> ${C}model${NC}"
  echo -e "  Lock target:     inside viking -> ${C}target 192.168.1.1${NC}"
  echo -e "  Scan results:    ${D}\$HOME/viking_scans/${NC}"
  echo -e "  Instagram:       ${D}@s.k.7.l.d${NC}"
  echo ""
  echo -e "  ${Y}The longship is ready. Type 'viking' to sail.${NC}"
  echo ""
}

# ════════════════════════════════════════════════════════════════
#  UPDATE FUNCTION — pull latest install.sh from GitHub and re-run
# ════════════════════════════════════════════════════════════════
self_update() {
  log_step "U" "Checking for updates..."
  local tmp_install="/tmp/viking_update_$$.sh"
  local remote_version=""

  log_info "Fetching latest version from GitHub..."
  if ! curl -fsSL "$GITHUB_RAW" -o "$tmp_install" 2>/dev/null; then
    log_err "Could not reach GitHub. Check internet connection."
    rm -f "$tmp_install"
    return 1
  fi

  # Extract remote version
  remote_version=$(grep 'readonly VIKING_VERSION=' "$tmp_install" 2>/dev/null |     grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  remote_version="${remote_version:-unknown}"

  echo ""
  echo -e "  Current version : ${Y}${VIKING_VERSION}${NC}"
  echo -e "  Remote version  : ${G}${remote_version}${NC}"
  echo ""

  if [[ "$remote_version" == "$VIKING_VERSION" ]]; then
    log_ok "VIKING AI is already up to date (v${VIKING_VERSION})"
    rm -f "$tmp_install"
    return 0
  fi

  echo -ne "  ${Y}Update to v${remote_version}? [Y/n]: ${NC}"
  read -r upd_choice
  if [[ "${upd_choice,,}" == "n" ]]; then
    log_info "Update cancelled."
    rm -f "$tmp_install"
    return 0
  fi

  log_info "Applying update..."
  chmod +x "$tmp_install"
  sudo bash "$tmp_install"
  rm -f "$tmp_install"
  log_ok "Update complete. Restart viking to use the new version."
}

# ════════════════════════════════════════════════════════════════
#  MAIN
# ════════════════════════════════════════════════════════════════
main() {
  show_installer_banner
  preflight

  mkdir -p "$VIKING_DIR" "$ARSENAL_DIR" "$LOG_DIR"

  install_dependencies   # step 1
  install_ollama         # step 2
  pull_model "$DEFAULT_MODEL"  # step 3
  write_arsenal_registry # step 4
  write_arsenal_menu     # step 4b
  write_viking_script    # step 5
  configure_tmux         # step 6

  printf 'VIKING_MODEL="%s"\n' "$DEFAULT_MODEL" > "$CONFIG_FILE"

  run_install_wizard     # step 7
  show_completion
}

main "$@"
