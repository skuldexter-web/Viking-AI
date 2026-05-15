#!/bin/bash

# ================================================================
#   VIKING AI — Local CLI Security Assistant Installer
#   GitHub: https://github.com/skuldexter-web/Viking-AI
#   License: MIT
# ================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

INSTALL_PATH="/usr/local/bin/viking"
MODEL="gemma3:1b"

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

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!] Run as root: sudo bash install.sh${NC}"
  exit 1
fi

echo -e "${CYAN}[1/5] Installing dependencies...${NC}"
apt-get update -qq
apt-get install -y -qq tmux curl wget git python3 python3-pip nmap tshark whois nikto 2>/dev/null
echo -e "${GREEN}[✓] Dependencies ready${NC}"
echo ""

echo -e "${CYAN}[2/5] Checking Ollama...${NC}"
if command -v ollama &>/dev/null; then
  echo -e "${GREEN}[✓] Ollama already installed${NC}"
else
  echo -e "${YELLOW}[~] Installing Ollama...${NC}"
  curl -fsSL https://ollama.com/install.sh | sh
  echo -e "${GREEN}[✓] Ollama installed${NC}"
fi
systemctl enable ollama &>/dev/null
systemctl start ollama &>/dev/null
sleep 2
echo -e "${GREEN}[✓] Ollama service running${NC}"
echo ""

echo -e "${CYAN}[3/5] Checking AI model ($MODEL)...${NC}"
if ollama list 2>/dev/null | grep -q "gemma3:1b"; then
  echo -e "${GREEN}[✓] Model gemma3:1b already present${NC}"
else
  echo -e "${YELLOW}[~] Pulling $MODEL — this may take a few minutes...${NC}"
  ollama pull "$MODEL"
  echo -e "${GREEN}[✓] Model ready${NC}"
fi
echo ""

echo -e "${CYAN}[4/5] Installing VIKING to $INSTALL_PATH...${NC}"

cat > "$INSTALL_PATH" << 'VIKINGSCRIPT'
#!/bin/bash

# ================================================================
#  VIKING AI — Digital Longship Intelligence System
#  Local CLI Security Assistant for Kali Linux
#  License: MIT | https://github.com/YOUR_USERNAME/viking-ai
# ================================================================

MODEL="gemma3:1b"
LOGFILE="$HOME/.viking_history.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

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

# ── Viking ship ASCII art + banner ──────────────────────────
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
  echo "  ~~^~~^~~^~~^~~^~~^~~\________________________________________/~~~^~~^~~"
  echo "  ~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~^~~"
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

log()         { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"; }
viking_think(){ ollama run "$MODEL" "$SYSTEM_PROMPT

$1" 2>/dev/null; }
viking_say()  { echo -e "${YELLOW}⚔ VIKING:${NC} $1"; }
viking_info() { echo -e "${CYAN}[VIKING]${NC} $1"; }
viking_err()  { echo -e "${RED}[VIKING]${NC} $1"; }

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
  echo "    tshark                — live packet capture (CLI)"
  echo "    hashcat / john        — hash cracking guidance"
  echo ""
  echo -e "${CYAN}  GUI APPS (requires display)${NC}"
  echo "    open chrome           — launch Chrome"
  echo "    open firefox          — launch Firefox"
  echo "    open wireshark        — launch Wireshark"
  echo "    open burp             — launch Burp Suite"
  echo ""
  echo -e "${CYAN}  CODING & SCRIPTING${NC}"
  echo "    write a python ...    — Python code"
  echo "    make a html ...       — HTML / CSS / JS"
  echo "    bash script for ...   — Bash scripting"
  echo ""
  echo -e "${CYAN}  SYSTEM${NC}"
  echo "    help                  — show this menu"
  echo "    history               — view session log"
  echo "    banner                — redisplay the ship banner"
  echo "    model <name>          — switch AI model"
  echo "    quit / exit           — leave VIKING"
  echo ""
}

# ── Show banner on start ─────────────────────────────────────
show_banner

# ── Main loop ────────────────────────────────────────────────
while true; do
  echo -ne "${YELLOW}You: ${NC}"
  read -r INPUT

  [ -z "$INPUT" ] && continue
  log "USER: $INPUT"

  # Built-in commands
  if [[ "$INPUT" == "quit" || "$INPUT" == "exit" || "$INPUT" == "/bye" ]]; then
    echo ""
    viking_say "The longship returns to port. Skål. ⚔"
    echo ""
    break
  fi

  if [[ "$INPUT" == "help" ]];    then show_help;   continue; fi
  if [[ "$INPUT" == "banner" ]];  then show_banner; continue; fi

  if [[ "$INPUT" == "history" ]]; then
    echo ""; cat "$LOGFILE" 2>/dev/null || viking_err "No history yet."; echo ""; continue
  fi

  if echo "$INPUT" | grep -iq "^model "; then
    MODEL=$(echo "$INPUT" | awk '{print $2}')
    viking_say "Model switched to: $MODEL"; continue
  fi

  # ── NMAP ─────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "scan|nmap"; then
    TARGET=$(echo "$INPUT" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}|https?://[^ ]+|[a-zA-Z0-9._-]+\.[a-zA-Z]{2,}" | head -1)
    if [ -n "$TARGET" ]; then
      viking_info "Scouting target: $TARGET"; echo ""
      RESULT=$(sudo nmap -sV --open -T4 "$TARGET" 2>&1)
      echo "$RESULT"; echo ""
      viking_info "Compiling raid report..."; echo ""
      ANALYSIS=$(viking_think "Produce a VIKING Scouting Report for this nmap scan. List: open ports, services, risk level, vulnerabilities, and recommended follow-up commands. Be tactical and concise. Scan: $RESULT")
      echo -e "${GREEN}$ANALYSIS${NC}"; log "SCAN: $TARGET"
    else
      viking_err "No valid target found. Usage: scan 192.168.1.1"
    fi
    continue
  fi

  # ── TSHARK ───────────────────────────────────────
  if echo "$INPUT" | grep -iEq "tshark|packet capture|sniff|capture traffic"; then
    IFACE=$(ip link show | awk -F': ' '/^[0-9]+:/ && !/lo/{print $2; exit}' | tr -d ' ')
    viking_info "Intercepting traffic on: $IFACE  (Ctrl+C to stop)"
    sudo tshark -i "$IFACE" 2>&1 | head -50
    continue
  fi

  # ── WIFITE ───────────────────────────────────────
  if echo "$INPUT" | grep -iEq "wifite|wifi attack|wireless attack"; then
    viking_info "Launching wireless raid via Wifite..."
    sudo wifite; continue
  fi

  # ── ONESHOT ──────────────────────────────────────
  if echo "$INPUT" | grep -iEq "oneshot|wps attack|pmkid"; then
    viking_info "Launching OneShot WPS attack..."
    IFACE=$(ip link show | awk -F': ' '/wlan/{print $2; exit}' | tr -d ' ')
    sudo python3 /usr/share/oneshot/oneshot.py -i "$IFACE" 2>/dev/null \
      || sudo python3 ~/OneShot/oneshot.py -i "$IFACE" 2>/dev/null \
      || viking_err "OneShot not found. Install: git clone https://github.com/drygdryg/OneShot ~/OneShot"
    continue
  fi

  # ── AIRCRACK ─────────────────────────────────────
  if echo "$INPUT" | grep -iEq "aircrack|airmon|airodump|monitor mode"; then
    viking_info "Wireless warfare guidance:"; echo ""
    viking_think "Give exact step-by-step aircrack-ng terminal commands with explanations for: $INPUT"
    continue
  fi

  # ── NIKTO ────────────────────────────────────────
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

  # ── GOBUSTER ─────────────────────────────────────
  if echo "$INPUT" | grep -iEq "gobuster|dirb|directory scan|directory brute"; then
    viking_info "Directory assault guidance:"; echo ""
    viking_think "Give exact gobuster or dirb commands with wordlist paths and flag explanations for: $INPUT"
    continue
  fi

  # ── SQLMAP ───────────────────────────────────────
  if echo "$INPUT" | grep -iEq "sqlmap|sql injection|sqli"; then
    viking_info "SQL injection raid:"; echo ""
    viking_think "Give exact sqlmap commands with all flags explained. Include --risk, --level, and tamper options for: $INPUT"
    continue
  fi

  # ── METASPLOIT ───────────────────────────────────
  if echo "$INPUT" | grep -iEq "metasploit|msfconsole|exploit|payload|meterpreter"; then
    viking_info "Metasploit siege guidance:"; echo ""
    viking_think "Give exact msfconsole commands, module search, use, set options, and run steps for: $INPUT"
    continue
  fi

  # ── HYDRA ────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "hydra|brute.?force|crack password|password attack"; then
    viking_info "Brute force assault guidance:"; echo ""
    viking_think "Give the exact hydra command with all flags explained including wordlist options for: $INPUT"
    continue
  fi

  # ── HASHCAT / JOHN ───────────────────────────────
  if echo "$INPUT" | grep -iEq "hashcat|john the ripper|crack hash|hash crack"; then
    viking_info "Hash cracking guidance:"; echo ""
    viking_think "Give exact hashcat or john commands including hash type detection and attack mode flags for: $INPUT"
    continue
  fi

  # ── NETCAT ───────────────────────────────────────
  if echo "$INPUT" | grep -iEq "netcat|reverse shell|bind shell| nc "; then
    viking_info "Netcat battle guidance:"; echo ""
    viking_think "Give exact netcat commands showing both the listener side and connect side for: $INPUT"
    continue
  fi

  # ── PING ─────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "^ping |ping "; then
    TARGET=$(echo "$INPUT" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}|[a-zA-Z0-9._-]+\.[a-zA-Z]{2,}" | head -1)
    if [ -n "$TARGET" ]; then
      viking_info "Probing $TARGET..."
      ping -c 4 "$TARGET"
    fi
    continue
  fi

  # ── WHOIS ────────────────────────────────────────
  if echo "$INPUT" | grep -iEq "whois|domain info|domain lookup"; then
    TARGET=$(echo "$INPUT" | grep -oE "[a-zA-Z0-9._-]+\.[a-zA-Z]{2,}" | head -1)
    if [ -n "$TARGET" ]; then
      viking_info "Domain reconnaissance: $TARGET"
      whois "$TARGET" 2>&1 | head -40
    fi
    continue
  fi

  # ── GUI APPS ─────────────────────────────────────
  for APP in chrome firefox wireshark burpsuite burp; do
    if echo "$INPUT" | grep -iEq "open $APP|launch $APP|start $APP"; then
      CMD=""
      case "$APP" in
        chrome)         CMD="google-chrome" ;;
        firefox)        CMD="firefox" ;;
        wireshark)      CMD="wireshark" ;;
        burpsuite|burp) CMD="burpsuite" ;;
      esac
      if [ -n "$DISPLAY" ]; then
        viking_info "Launching $CMD..."
        $CMD &>/dev/null &
      else
        viking_err "No display available over SSH."
        echo "  → X11 forwarding:  ssh -X user@$(hostname -I | awk '{print $1}')"
        echo "  → Install VNC:     sudo apt install tigervnc-standalone-server"
        [[ "$APP" == "wireshark" ]]                       && echo "  → CLI alternative: sudo tshark -i eth0"
        [[ "$APP" == "chrome" || "$APP" == "firefox" ]]   && echo "  → CLI alternative: curl -s <url>"
      fi
      continue 2
    fi
  done

  # ── CODING ───────────────────────────────────────
  if echo "$INPUT" | grep -iEq "python|write me|create a script|make a script|function|class|html|css|javascript| js |flask|django|bash script|code for|write a"; then
    viking_info "Scripting mode engaged..."; echo ""
    viking_think "Write clean, working, commented code. Show the full code block first, then a brief explanation. Task: $INPUT"
    continue
  fi

  # ── GENERAL FALLBACK ─────────────────────────────
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
echo -e "${GREEN}[✓] VIKING installed at $INSTALL_PATH${NC}"
echo ""

echo -e "${CYAN}[5/5] Configuring tmux session...${NC}"
BASHRC="/root/.bashrc"
MARKER="# VIKING AI auto-session"
if ! grep -q "$MARKER" "$BASHRC" 2>/dev/null; then
  cat >> "$BASHRC" << 'EOF'

# VIKING AI auto-session
if command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
  tmux has-session -t viking 2>/dev/null || tmux new-session -d -s viking
fi
EOF
fi
echo -e "${GREEN}[✓] tmux session configured${NC}"
echo ""

echo "  ═══════════════════════════════════════════════"
echo -e "${BOLD}${YELLOW}   ⚔  VIKING AI — Installation Complete  ⚔${NC}"
echo "  ═══════════════════════════════════════════════"
echo ""
echo -e "  Launch:          ${CYAN}viking${NC}"
echo -e "  In tmux:         ${CYAN}tmux new -s viking${NC}  then  ${CYAN}viking${NC}"
echo -e "  Detach tmux:     ${CYAN}Ctrl+B then D${NC}"
echo -e "  Reattach:        ${CYAN}tmux attach -t viking${NC}"
echo ""
echo -e "  ${YELLOW}The longship is ready. Type 'viking' to sail.  ⚔${NC}"
echo ""
