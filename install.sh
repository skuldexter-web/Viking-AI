#!/usr/bin/env bash
# =============================================================================
#
#  ██╗   ██╗██╗██╗  ██╗██╗███╗   ██╗ ██████╗      █████╗ ██╗
#  ██║   ██║██║██║ ██╔╝██║████╗  ██║██╔════╝     ██╔══██╗██║
#  ██║   ██║██║█████╔╝ ██║██╔██╗ ██║██║  ███╗    ███████║██║
#  ╚██╗ ██╔╝██║██╔═██╗ ██║██║╚██╗██║██║   ██║    ██╔══██║██║
#   ╚████╔╝ ██║██║  ██╗██║██║ ╚████║╚██████╔╝    ██║  ██║██║
#    ╚═══╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝  ╚═╝╚═╝
#
#  VIKING-AI :: VIK INSTALLER v1.0.0
#  Production-Grade Linux AI Command System
#  Optimized for: Kali Linux | Debian | Ubuntu | Parrot OS
#
#  Author   : Viking-AI Project
#  License  : MIT
#  Platform : Linux (Debian-based)
#
# =============================================================================
# USAGE:
#   sudo bash install.sh            # Full install
#   sudo bash install.sh --repair   # Repair existing install
#   sudo bash install.sh --update   # Update existing install
#   sudo bash install.sh --silent   # Non-interactive install
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# =============================================================================
# GLOBAL CONSTANTS
# =============================================================================

readonly VIKING_VERSION="1.0.0"
readonly VIKING_CODENAME="RAGNAROK"
readonly INSTALL_DIR="/opt/Viking-AI"
readonly CONFIG_DIR="${INSTALL_DIR}/config"
readonly PROMPTS_DIR="${INSTALL_DIR}/prompts"
readonly LOGS_DIR="${INSTALL_DIR}/logs"
readonly ARSENAL_DIR="${INSTALL_DIR}/arsenal"
readonly MODELS_DIR="${INSTALL_DIR}/models"
readonly CACHE_DIR="${INSTALL_DIR}/cache"
readonly MODULES_DIR="${INSTALL_DIR}/modules"
readonly THEMES_DIR="${INSTALL_DIR}/themes"
readonly UI_DIR="${INSTALL_DIR}/ui"
readonly TOOLS_DIR="${INSTALL_DIR}/tools"
readonly TMP_DIR="${INSTALL_DIR}/tmp"
readonly BACKUPS_DIR="${INSTALL_DIR}/backups"

readonly LOG_FILE="${LOGS_DIR}/install.log"
readonly ERROR_LOG="${LOGS_DIR}/error.log"
readonly OLLAMA_LOG="${LOGS_DIR}/ollama.log"
readonly ARSENAL_LOG="${LOGS_DIR}/arsenal.log"

readonly DEFAULT_MODEL="gemma3:1b"
readonly OLLAMA_API="http://localhost:11434"
readonly OLLAMA_TIMEOUT=120

readonly SCRIPT_START_TIME=$(date +%s)

# =============================================================================
# ANSI COLOR CODES — VIKING CYBERPUNK THEME
# =============================================================================

# Core palette
readonly C_RESET="\033[0m"
readonly C_BLACK="\033[0;30m"
readonly C_RED="\033[0;31m"
readonly C_GREEN="\033[0;32m"
readonly C_YELLOW="\033[0;33m"
readonly C_BLUE="\033[0;34m"
readonly C_MAGENTA="\033[0;35m"
readonly C_CYAN="\033[0;36m"
readonly C_WHITE="\033[0;37m"
readonly C_GRAY="\033[0;90m"

# Bold variants
readonly C_BOLD_RED="\033[1;31m"
readonly C_BOLD_GREEN="\033[1;32m"
readonly C_BOLD_YELLOW="\033[1;33m"
readonly C_BOLD_CYAN="\033[1;36m"
readonly C_BOLD_WHITE="\033[1;37m"

# Background
readonly BG_RED="\033[41m"
readonly BG_BLACK="\033[40m"

# =============================================================================
# GLOBAL STATE FLAGS
# =============================================================================

SILENT_MODE=0
REPAIR_MODE=0
UPDATE_MODE=0
INTERACTIVE=1
ERRORS_OCCURRED=0
OLLAMA_INSTALLED=0
OLLAMA_RUNNING=0
MODEL_PULLED=0
PKG_UPDATED=0
IS_ROOT=0
DISTRO_SUPPORTED=0
DISTRO_NAME=""
DISTRO_VERSION=""

# =============================================================================
# ARGUMENT PARSING
# =============================================================================

parse_args() {
    for arg in "$@"; do
        case "${arg}" in
            --silent)   SILENT_MODE=1 ; INTERACTIVE=0 ;;
            --repair)   REPAIR_MODE=1 ;;
            --update)   UPDATE_MODE=1 ;;
            --help|-h)  show_usage ; exit 0 ;;
            *)
                echo "Unknown argument: ${arg}"
                show_usage
                exit 1
                ;;
        esac
    done
}

show_usage() {
    echo ""
    echo "  Viking-AI Installer v${VIKING_VERSION}"
    echo ""
    echo "  Usage: sudo bash install.sh [OPTIONS]"
    echo ""
    echo "  Options:"
    echo "    (none)     Full interactive installation"
    echo "    --repair   Repair broken installation"
    echo "    --update   Update existing installation"
    echo "    --silent   Non-interactive (use defaults)"
    echo "    --help     Show this message"
    echo ""
}

# =============================================================================
# LOGGING SYSTEM
# =============================================================================

# Ensure log directory exists before any logging
_preinit_logs() {
    mkdir -p "/tmp/viking_preinit_logs" 2>/dev/null || true
    export PRE_LOG="/tmp/viking_preinit_logs/install.log"
    touch "${PRE_LOG}" 2>/dev/null || true
}

log_raw() {
    local message="${1:-}"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Strip ANSI codes before writing to log
    local clean_msg
    clean_msg=$(echo -e "${message}" | sed 's/\x1b\[[0-9;]*m//g' 2>/dev/null || echo "${message}")

    if [[ -f "${LOG_FILE}" ]]; then
        echo "[${timestamp}] ${clean_msg}" >> "${LOG_FILE}" 2>/dev/null || true
    elif [[ -f "${PRE_LOG:-/tmp/viking_preinit_logs/install.log}" ]]; then
        echo "[${timestamp}] ${clean_msg}" >> "${PRE_LOG}" 2>/dev/null || true
    fi
}

log_error() {
    local message="${1:-}"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local clean_msg
    clean_msg=$(echo -e "${message}" | sed 's/\x1b\[[0-9;]*m//g' 2>/dev/null || echo "${message}")

    if [[ -f "${ERROR_LOG}" ]]; then
        echo "[${timestamp}] ERROR: ${clean_msg}" >> "${ERROR_LOG}" 2>/dev/null || true
    fi
    echo "[${timestamp}] ERROR: ${clean_msg}" >> "${PRE_LOG:-/dev/null}" 2>/dev/null || true
}

# =============================================================================
# TERMINAL OUTPUT HELPERS
# =============================================================================

print_color() {
    local color="${1}"
    local message="${2}"
    if [[ "${SILENT_MODE}" -eq 0 ]]; then
        echo -e "${color}${message}${C_RESET}"
    fi
    log_raw "${message}"
}

print_info()    { print_color "${C_GREEN}"       "  [•] ${1}"; }
print_ok()      { print_color "${C_BOLD_GREEN}"  "  [✓] ${1}"; }
print_warn()    { print_color "${C_YELLOW}"      "  [!] ${1}"; }
print_error()   {
    print_color "${C_BOLD_RED}"   "  [✗] ${1}"
    log_error "${1}"
    ERRORS_OCCURRED=1
}
print_step()    { print_color "${C_BOLD_CYAN}"  "\n  ══ ${1} ══"; }
print_gray()    { print_color "${C_GRAY}"       "      ${1}"; }
print_war()     { print_color "${BG_RED}${C_BOLD_WHITE}" "  ⚔  ${1}  ⚔"; }

nl()  { [[ "${SILENT_MODE}" -eq 0 ]] && echo ""; }
sep() {
    if [[ "${SILENT_MODE}" -eq 0 ]]; then
        echo -e "${C_GRAY}  ─────────────────────────────────────────────────────────────${C_RESET}"
    fi
}

# =============================================================================
# SPINNER ANIMATION
# =============================================================================

SPINNER_PID=""

spinner_start() {
    local message="${1:-Working...}"
    if [[ "${SILENT_MODE}" -eq 1 ]]; then
        log_raw "SPINNER: ${message}"
        return
    fi

    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0

    while true; do
        printf "\r  ${C_GREEN}${frames[$i]}${C_RESET}  ${C_GRAY}%s${C_RESET}   " "${message}"
        i=$(( (i + 1) % 10 ))
        sleep 0.1
    done &
    SPINNER_PID=$!
    disown "${SPINNER_PID}" 2>/dev/null || true
}

spinner_stop() {
    local status="${1:-ok}"
    local message="${2:-}"

    if [[ -n "${SPINNER_PID}" ]]; then
        kill "${SPINNER_PID}" 2>/dev/null || true
        wait "${SPINNER_PID}" 2>/dev/null || true
        SPINNER_PID=""
    fi

    if [[ "${SILENT_MODE}" -eq 0 ]]; then
        printf "\r\033[2K"
    fi

    if [[ -n "${message}" ]]; then
        case "${status}" in
            ok)    print_ok "${message}" ;;
            warn)  print_warn "${message}" ;;
            error) print_error "${message}" ;;
            *)     print_info "${message}" ;;
        esac
    fi
}

# =============================================================================
# PROGRESS BAR
# =============================================================================

progress_bar() {
    local current="${1}"
    local total="${2}"
    local label="${3:-Progress}"

    if [[ "${SILENT_MODE}" -eq 1 ]]; then return; fi

    local width=40
    local pct=$(( (current * 100) / total ))
    local filled=$(( (current * width) / total ))
    local empty=$(( width - filled ))

    local bar=""
    local i
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++));  do bar+="░"; done

    printf "\r  ${C_GREEN}[%s]${C_RESET} ${C_BOLD_GREEN}%3d%%${C_RESET}  ${C_GRAY}%s${C_RESET}   " \
        "${bar}" "${pct}" "${label}"

    if [[ "${current}" -eq "${total}" ]]; then
        printf "\n"
    fi
}

# =============================================================================
# CONFIRMATION PROMPT
# =============================================================================

confirm() {
    local message="${1}"
    local default="${2:-y}"

    if [[ "${SILENT_MODE}" -eq 1 || "${INTERACTIVE}" -eq 0 ]]; then
        log_raw "AUTO-CONFIRM: ${message} [default: ${default}]"
        [[ "${default}" == "y" ]] && return 0 || return 1
    fi

    local prompt
    if [[ "${default}" == "y" ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi

    echo -e "\n  ${C_BOLD_YELLOW}?  ${message} ${C_GRAY}${prompt}${C_RESET} "
    read -r -p "  > " response

    response="${response,,}"
    response="${response:-${default}}"

    [[ "${response}" == "y" || "${response}" == "yes" ]]
}

# =============================================================================
# ASCII BANNERS
# =============================================================================

print_vik_banner() {
    if [[ "${SILENT_MODE}" -eq 1 ]]; then return; fi

    echo -e "${C_GREEN}"
    cat << 'VIKBANNER'

    ) (                               |
   (   )                            \|/
    ) (       ___________________---*---___________________
  _______    /                    /|\                     \
 / ◈   ◈ \  /      V  I  K  I  N  G  -  A  I              \
|  -----  |/    ⚔    Cyber Viking AI  ::  v1.0.0    ⚔      \
|  \___/  /_________________________________________________ \
|         |  ><   ><   ><   ><   ><   ><   ><   ><   ><    |
 \_______/ \________________________________________________/
  |  | |  |  ~~~~|_________________________________________|~~~~
  |  |||  | ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~
 /|  |||  |\ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
/ |__|||__| \
\_____|_____/      ⚔  VIK  ::  CYBER VIKING AI  ⚔
      |
   ===⚔===

VIKBANNER
    echo -e "${C_RESET}"
}

print_installer_header() {
    if [[ "${SILENT_MODE}" -eq 1 ]]; then return; fi

    clear
    echo ""
    echo -e "${C_BOLD_GREEN}"
    cat << 'HEADER'
 ██╗   ██╗██╗██╗  ██╗██╗███╗   ██╗ ██████╗      █████╗ ██╗
 ██║   ██║██║██║ ██╔╝██║████╗  ██║██╔════╝     ██╔══██╗██║
 ██║   ██║██║█████╔╝ ██║██╔██╗ ██║██║  ███╗    ███████║██║
 ╚██╗ ██╔╝██║██╔═██╗ ██║██║╚██╗██║██║   ██║    ██╔══██║██║
  ╚████╔╝ ██║██║  ██╗██║██║ ╚████║╚██████╔╝    ██║  ██║██║
   ╚═══╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝  ╚═╝╚═╝
HEADER
    echo -e "${C_RESET}"

    # Viking ship centred under the title
    echo -e "${C_GREEN}"
    cat << 'SHIPBANNER'
                              |
                             \|/
                           ---*---
                            /|\
                           / | \
         _________________/  |  \_________________
        /                    |                    \
       /        V  I  K  I  N  G  -  A  I         \
      /    ⚔    Cyber Viking AI  ::  v1.0.0   ⚔   \
     /_______________________________________________\
    |  ><   ><   ><   ><   ><   ><   ><   ><   ><   |
    |  ><   ><   ><   ><   ><   ><   ><   ><   ><   |
     \_______________________________________________/
   ~~~~~~~~|_______________________________________|~~~~~~~~
  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~
SHIPBANNER
    echo -e "${C_RESET}"

    echo -e "${C_GRAY}  ════════════════════════════════════════════════════════════${C_RESET}"
    echo -e "${C_BOLD_GREEN}  INSTALLER v${VIKING_VERSION} ${C_GRAY}::${C_RESET} ${C_CYAN}CODENAME: ${VIKING_CODENAME}${C_RESET}"
    echo -e "${C_GRAY}  ════════════════════════════════════════════════════════════${C_RESET}"
    echo ""
}

# =============================================================================
# ROOT CHECK
# =============================================================================

check_root() {
    print_step "PRIVILEGES CHECK"

    if [[ "${EUID}" -ne 0 ]]; then
        print_error "Viking-AI must be installed as root."
        print_gray  "Run: sudo bash install.sh"
        exit 1
    fi

    IS_ROOT=1
    print_ok "Running as root"
}

# =============================================================================
# DISTRIBUTION DETECTION
# =============================================================================

detect_distro() {
    print_step "SYSTEM DETECTION"

    if [[ ! -f /etc/os-release ]]; then
        print_error "/etc/os-release not found. Cannot detect distribution."
        exit 1
    fi

    # shellcheck source=/dev/null
    source /etc/os-release
    DISTRO_NAME="${NAME:-Unknown}"
    DISTRO_VERSION="${VERSION_ID:-Unknown}"

    print_info "Detected OS: ${DISTRO_NAME} ${DISTRO_VERSION}"

    local supported_ids=("debian" "ubuntu" "kali" "parrot" "linuxmint" "pop" "elementary" "raspbian" "mx")
    local id_lower
    id_lower=$(echo "${ID:-}" | tr '[:upper:]' '[:lower:]')
    local id_like_lower
    id_like_lower=$(echo "${ID_LIKE:-}" | tr '[:upper:]' '[:lower:]')

    local is_supported=0
    for sid in "${supported_ids[@]}"; do
        if [[ "${id_lower}" == *"${sid}"* || "${id_like_lower}" == *"${sid}"* ]]; then
            is_supported=1
            break
        fi
    done

    if [[ "${is_supported}" -eq 1 ]]; then
        DISTRO_SUPPORTED=1
        print_ok "Distribution supported: ${DISTRO_NAME}"
    else
        DISTRO_SUPPORTED=0
        print_warn "Distribution '${DISTRO_NAME}' is NOT officially supported."
        if ! confirm "Continue installation on unsupported distro?" "n"; then
            print_info "Installation aborted."
            exit 0
        fi
    fi

    # Architecture
    local arch
    arch=$(uname -m)
    print_info "Architecture: ${arch}"
    case "${arch}" in
        x86_64|amd64)  print_ok "x86_64 — fully supported" ;;
        aarch64|arm64) print_warn "ARM64 — limited support" ;;
        *)             print_warn "Architecture '${arch}' — experimental" ;;
    esac

    # Kernel
    print_info "Kernel: $(uname -r)"

    # RAM check
    local ram_kb
    ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}' 2>/dev/null || echo "0")
    local ram_gb=$(( ram_kb / 1024 / 1024 ))
    print_info "RAM: ~${ram_gb} GB detected"

    if [[ "${ram_kb}" -lt 1048576 ]]; then
        print_error "Minimum 1GB RAM required. Detected: ${ram_kb} KB"
        exit 1
    elif [[ "${ram_kb}" -lt 2097152 ]]; then
        print_warn "Low RAM (<2GB). Using lightweight model: ${DEFAULT_MODEL}"
    else
        print_ok "RAM sufficient for AI operations"
    fi

    # Disk check — require at least 5GB free
    local disk_avail_kb
    disk_avail_kb=$(df /opt 2>/dev/null | awk 'NR==2 {print $4}' || echo "0")
    local disk_avail_gb=$(( disk_avail_kb / 1024 / 1024 ))
    print_info "Free disk (/opt): ~${disk_avail_gb} GB"

    if [[ "${disk_avail_kb}" -lt 5242880 ]]; then
        print_warn "Low disk space (<5GB). Arsenal full install may fail."
    else
        print_ok "Disk space sufficient"
    fi
}

# =============================================================================
# DEPENDENCY CHECKS
# =============================================================================

declare -a REQUIRED_CMDS=(
    "curl"
    "wget"
    "git"
    "jq"
    "python3"
    "pip3"
    "tar"
    "unzip"
    "tmux"
    "screen"
)

declare -A CMD_TO_PKG=(
    ["curl"]="curl"
    ["wget"]="wget"
    ["git"]="git"
    ["jq"]="jq"
    ["python3"]="python3"
    ["pip3"]="python3-pip"
    ["tar"]="tar"
    ["unzip"]="unzip"
    ["tmux"]="tmux"
    ["screen"]="screen"
)

check_dependencies() {
    print_step "DEPENDENCY CHECK"

    local missing_cmds=()

    for cmd in "${REQUIRED_CMDS[@]}"; do
        if command -v "${cmd}" &>/dev/null; then
            print_ok "${cmd} — found"
        else
            print_warn "${cmd} — MISSING"
            missing_cmds+=("${cmd}")
        fi
    done

    if [[ "${#missing_cmds[@]}" -gt 0 ]]; then
        print_info "Missing: ${missing_cmds[*]}"
        if confirm "Install missing dependencies?" "y"; then
            install_missing_deps "${missing_cmds[@]}"
        else
            print_warn "Skipping. Some features may be unavailable."
        fi
    else
        print_ok "All core dependencies satisfied"
    fi
}

install_missing_deps() {
    local missing=("$@")
    local pkgs_to_install=()

    for cmd in "${missing[@]}"; do
        pkgs_to_install+=("${CMD_TO_PKG[${cmd}]:-${cmd}}")
    done

    print_info "Installing: ${pkgs_to_install[*]}"
    spinner_start "Installing missing packages..."

    if apt-get install -y "${pkgs_to_install[@]}" >> "${LOG_FILE}" 2>> "${ERROR_LOG}"; then
        spinner_stop "ok" "Dependencies installed"
    else
        spinner_stop "warn" "Some dependencies failed — continuing"
    fi
}

# =============================================================================
# PACKAGE MANAGER — SAFE APT OPERATIONS
# =============================================================================

run_apt_operations() {
    print_step "SYSTEM PACKAGES"

    if [[ "${DISTRO_SUPPORTED}" -eq 0 ]]; then
        print_warn "Skipping apt on unsupported distro"
        return 0
    fi

    if ! confirm "Run apt update && apt upgrade?" "y"; then
        print_warn "Skipping system package update"
        PKG_UPDATED=0
        return 0
    fi

    # apt update
    spinner_start "Updating package lists..."
    if apt-get update -qq >> "${LOG_FILE}" 2>> "${ERROR_LOG}"; then
        spinner_stop "ok" "Package lists updated"
    else
        spinner_stop "warn" "apt update had warnings (non-fatal)"
    fi

    # apt upgrade
    spinner_start "Upgrading installed packages..."
    if DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold" \
        >> "${LOG_FILE}" 2>> "${ERROR_LOG}"; then
        spinner_stop "ok" "System packages upgraded"
    else
        spinner_stop "warn" "apt upgrade had warnings (non-fatal)"
    fi

    # autoremove
    spinner_start "Running autoremove..."
    if apt-get autoremove -y >> "${LOG_FILE}" 2>> "${ERROR_LOG}"; then
        spinner_stop "ok" "Autoremove complete"
    else
        spinner_stop "warn" "autoremove had warnings (non-fatal)"
    fi

    PKG_UPDATED=1
    print_ok "System package operations complete"
}

# =============================================================================
# DIRECTORY STRUCTURE
# =============================================================================

create_directory_structure() {
    print_step "CREATING DIRECTORY STRUCTURE"

    local dirs=(
        "${INSTALL_DIR}"
        "${CONFIG_DIR}"
        "${PROMPTS_DIR}"
        "${LOGS_DIR}"
        "${ARSENAL_DIR}"
        "${ARSENAL_DIR}/scanning"
        "${ARSENAL_DIR}/web"
        "${ARSENAL_DIR}/wifi"
        "${ARSENAL_DIR}/osint"
        "${ARSENAL_DIR}/exploit"
        "${ARSENAL_DIR}/network"
        "${ARSENAL_DIR}/forensics"
        "${ARSENAL_DIR}/containers"
        "${ARSENAL_DIR}/windows"
        "${ARSENAL_DIR}/passwords"
        "${ARSENAL_DIR}/phishing"
        "${ARSENAL_DIR}/xss"
        "${ARSENAL_DIR}/sqli"
        "${ARSENAL_DIR}/anonymity"
        "${ARSENAL_DIR}/wordlists"
        "${ARSENAL_DIR}/tracking"
        "${MODELS_DIR}"
        "${CACHE_DIR}"
        "${MODULES_DIR}"
        "${THEMES_DIR}"
        "${UI_DIR}"
        "${TOOLS_DIR}"
        "${TOOLS_DIR}/github"
        "${TMP_DIR}"
        "${BACKUPS_DIR}"
        "${LOGS_DIR}/archive"
    )

    local total="${#dirs[@]}"
    local current=0

    for dir in "${dirs[@]}"; do
        mkdir -p "${dir}" && print_gray "Created: ${dir}" || print_error "Failed: ${dir}"
        current=$(( current + 1 ))
        progress_bar "${current}" "${total}" "Creating directories"
    done

    # Permissions
    chmod 750 "${INSTALL_DIR}"
    chmod 700 "${LOGS_DIR}"
    chmod 755 "${ARSENAL_DIR}"

    print_ok "Directory structure created at ${INSTALL_DIR}"
}

# =============================================================================
# LOGGING INIT — AFTER DIRS EXIST
# =============================================================================

init_logging() {
    touch "${LOG_FILE}" "${ERROR_LOG}" "${OLLAMA_LOG}" "${ARSENAL_LOG}" 2>/dev/null || true

    # Merge pre-init log
    if [[ -f "${PRE_LOG:-}" ]]; then
        cat "${PRE_LOG}" >> "${LOG_FILE}" 2>/dev/null || true
        rm -f "${PRE_LOG}" 2>/dev/null || true
    fi

    {
        echo "============================================"
        echo "  Viking-AI Installation Log"
        echo "  Version : ${VIKING_VERSION}"
        echo "  Date    : $(date)"
        echo "  Host    : $(hostname)"
        echo "  User    : $(id -un)"
        echo "  OS      : ${DISTRO_NAME} ${DISTRO_VERSION}"
        echo "============================================"
    } >> "${LOG_FILE}"

    print_ok "Logging initialized: ${LOG_FILE}"
}

# =============================================================================
# OLLAMA — DETECT, INSTALL, START, VERIFY
# =============================================================================

detect_ollama() {
    if command -v ollama &>/dev/null; then
        OLLAMA_INSTALLED=1
        local ver
        ver=$(ollama --version 2>/dev/null | head -n1 || echo "unknown")
        print_ok "Ollama detected: ${ver}"
        return 0
    fi
    OLLAMA_INSTALLED=0
    print_warn "Ollama not found"
    return 1
}

install_ollama() {
    print_step "OLLAMA INSTALLATION"
    detect_ollama && return 0

    if ! confirm "Install Ollama AI runtime?" "y"; then
        print_error "Ollama is required. Cannot continue."
        exit 1
    fi

    spinner_start "Downloading Ollama installer..."
    local install_script
    install_script=$(curl -fsSL https://ollama.com/install.sh 2>> "${ERROR_LOG}")

    if [[ -z "${install_script}" ]]; then
        spinner_stop "error" "Failed to download Ollama installer"
        print_error "Check your internet connection"
        exit 1
    fi
    spinner_stop "ok" "Installer downloaded"

    spinner_start "Installing Ollama..."
    if echo "${install_script}" | bash >> "${OLLAMA_LOG}" 2>&1; then
        spinner_stop "ok" "Ollama installed"
        OLLAMA_INSTALLED=1
    else
        spinner_stop "error" "Ollama installation failed"
        print_error "See ${OLLAMA_LOG} for details"
        exit 1
    fi
}

start_ollama_service() {
    print_step "OLLAMA SERVICE"

    if curl -sf "${OLLAMA_API}/api/tags" &>/dev/null; then
        OLLAMA_RUNNING=1
        print_ok "Ollama already running"
        return 0
    fi

    print_info "Starting Ollama service..."

    if command -v systemctl &>/dev/null && systemctl is-enabled ollama &>/dev/null 2>&1; then
        spinner_start "Starting via systemd..."
        if systemctl start ollama >> "${OLLAMA_LOG}" 2>&1; then
            spinner_stop "ok" "Ollama started via systemd"
        else
            spinner_stop "warn" "systemd start failed — trying manual"
            _start_ollama_manual
            return
        fi
    else
        _start_ollama_manual
        return
    fi

    _wait_for_ollama
}

_start_ollama_manual() {
    spinner_start "Starting Ollama daemon..."
    nohup ollama serve >> "${OLLAMA_LOG}" 2>&1 &
    local pid=$!
    disown "${pid}" 2>/dev/null || true
    echo "${pid}" > "${TMP_DIR}/ollama.pid"
    spinner_stop "ok" "Ollama daemon started (PID: ${pid})"
    _wait_for_ollama
}

_wait_for_ollama() {
    print_info "Waiting for Ollama API..."
    local elapsed=0
    local interval=2

    while [[ "${elapsed}" -lt "${OLLAMA_TIMEOUT}" ]]; do
        if curl -sf "${OLLAMA_API}/api/tags" &>/dev/null; then
            OLLAMA_RUNNING=1
            print_ok "Ollama API responsive at ${OLLAMA_API}"
            return 0
        fi
        sleep "${interval}"
        elapsed=$(( elapsed + interval ))
        print_gray "Waiting... (${elapsed}s / ${OLLAMA_TIMEOUT}s)"
    done

    print_error "Ollama API timeout after ${OLLAMA_TIMEOUT}s"
    OLLAMA_RUNNING=0
    return 1
}

check_ollama_api() {
    print_step "OLLAMA API VERIFICATION"

    if [[ "${OLLAMA_RUNNING}" -eq 0 ]]; then
        print_error "Ollama not running"
        return 1
    fi

    spinner_start "Testing Ollama API..."
    local response
    response=$(curl -sf "${OLLAMA_API}/api/tags" 2>/dev/null || echo "")

    if [[ -n "${response}" ]]; then
        spinner_stop "ok" "Ollama API responding"
        log_raw "Ollama tags: ${response}"
        return 0
    else
        spinner_stop "error" "Ollama API test failed"
        return 1
    fi
}

# =============================================================================
# MODEL MANAGEMENT
# =============================================================================

check_model_exists() {
    local model="${1}"
    [[ "${OLLAMA_RUNNING}" -eq 0 ]] && return 1

    local response
    response=$(curl -sf "${OLLAMA_API}/api/tags" 2>/dev/null || echo "")

    if echo "${response}" | grep -q "\"${model}\"" 2>/dev/null; then
        return 0
    fi

    if command -v jq &>/dev/null && [[ -n "${response}" ]]; then
        echo "${response}" | jq -r '.models[].name' 2>/dev/null | grep -q "^${model}$" && return 0
    fi

    return 1
}

pull_default_model() {
    print_step "MODEL SETUP"

    if [[ "${OLLAMA_RUNNING}" -eq 0 ]]; then
        print_error "Ollama must be running to pull models"
        return 1
    fi

    if check_model_exists "${DEFAULT_MODEL}"; then
        MODEL_PULLED=1
        print_ok "Default model available: ${DEFAULT_MODEL}"
        return 0
    fi

    print_info "Model '${DEFAULT_MODEL}' not found locally"

    if ! confirm "Pull '${DEFAULT_MODEL}'? (~800MB)" "y"; then
        print_warn "Skipping model pull"
        MODEL_PULLED=0
        return 0
    fi

    print_info "Pulling: ${DEFAULT_MODEL}"
    print_gray "This may take several minutes..."
    nl

    ollama pull "${DEFAULT_MODEL}" 2>&1 | tee -a "${OLLAMA_LOG}" | \
        grep -E "^(pulling|verifying|writing|success)" || true

    if check_model_exists "${DEFAULT_MODEL}"; then
        MODEL_PULLED=1
        print_ok "Model '${DEFAULT_MODEL}' ready"
    else
        MODEL_PULLED=0
        print_warn "Model pull may have failed — verify with: ollama list"
    fi
}

list_installed_models() {
    [[ "${OLLAMA_RUNNING}" -eq 0 ]] && return 1

    print_step "INSTALLED MODELS"
    local response
    response=$(curl -sf "${OLLAMA_API}/api/tags" 2>/dev/null || echo "")

    if command -v jq &>/dev/null && [[ -n "${response}" ]]; then
        local models
        models=$(echo "${response}" | jq -r \
            '.models[] | "  \(.name)  [\(.size / 1073741824 | floor)GB]"' 2>/dev/null \
            || echo "  (none)")
        print_info "Installed models:"
        echo -e "${C_GREEN}${models}${C_RESET}"
    fi
}

# =============================================================================
# CONFIG FILE GENERATION
# =============================================================================

generate_config_files() {
    print_step "GENERATING CONFIG FILES"

    # Main config
    cat > "${CONFIG_DIR}/viking.conf" << VIKCONF
# =============================================================================
# Viking-AI Main Configuration — v${VIKING_VERSION}
# =============================================================================

VIKING_VERSION="${VIKING_VERSION}"
INSTALL_DIR="${INSTALL_DIR}"

# Ollama settings
OLLAMA_API="${OLLAMA_API}"
OLLAMA_MODEL="${DEFAULT_MODEL}"
OLLAMA_TIMEOUT="${OLLAMA_TIMEOUT}"
OLLAMA_MAX_TOKENS=4096
OLLAMA_TEMPERATURE=0.7
OLLAMA_CONTEXT_WINDOW=8192

# UI
THEME="cyberpunk_viking"
COLORS_ENABLED=1
ANIMATIONS_ENABLED=1
BANNER_ENABLED=1

# Logging
LOG_LEVEL="INFO"
LOG_ROTATION_SIZE_MB=10
LOG_MAX_FILES=5

# Arsenal
AUTO_UPDATE_ARSENAL=0
ARSENAL_PARALLEL_INSTALL=0
VIKCONF

    print_ok "viking.conf"

    # Models config
    cat > "${CONFIG_DIR}/models.conf" << MODCONF
# =============================================================================
# Viking-AI Model Configuration
# =============================================================================

ACTIVE_MODEL="${DEFAULT_MODEL}"

# Lightweight models (low RAM)
MODELS_LIGHTWEIGHT=("gemma3:1b" "phi3:mini" "tinyllama:1.1b")

# Coding-focused models
MODELS_CODING=("qwen2.5-coder:7b" "qwen2.5-coder:14b" "deepseek-coder:6.7b" "codellama:7b")

# General purpose models
MODELS_GENERAL=("mistral:7b" "llama3:8b" "llama3:70b" "dolphin-mistral:7b" "mixtral:8x7b")

# Security-focused models
MODELS_SECURITY=("dolphin-mixtral:8x7b" "dolphin-mistral:7b" "openhermes:7b")
MODCONF

    print_ok "models.conf"

    # Theme config
    cat > "${CONFIG_DIR}/theme.conf" << 'THEMECONF'
# =============================================================================
# Viking-AI Theme: Cyberpunk Viking
# =============================================================================

COLOR_PRIMARY="\033[0;32m"       # Viking green
COLOR_SECONDARY="\033[0;90m"     # Dark gray
COLOR_ACCENT="\033[0;31m"        # Blood red (war mode)
COLOR_ACCENT_BOLD="\033[1;31m"
COLOR_INFO="\033[0;36m"          # Cyan
COLOR_WARNING="\033[0;33m"       # Yellow
COLOR_SUCCESS="\033[1;32m"       # Bold green
COLOR_RESET="\033[0m"
BG_DEFAULT="\033[40m"
BG_WAR="\033[41m"
THEMECONF

    print_ok "theme.conf"

    # Arsenal config
    cat > "${CONFIG_DIR}/arsenal.conf" << ARCONF
# =============================================================================
# Viking-AI Arsenal Configuration
# =============================================================================

TOOL_INSTALL_PREFIX="${TOOLS_DIR}"
PYTHON_VENV="${TOOLS_DIR}/.venv"
GO_INSTALL_PATH="/usr/local/go"
GOPATH="${TOOLS_DIR}/go"
CARGO_PATH="\${HOME}/.cargo"
GITHUB_TOOLS_DIR="${TOOLS_DIR}/github"
APT_AUTO_INSTALL=1
ARCONF

    print_ok "arsenal.conf"
    print_ok "All config files generated"
}

# =============================================================================
# PERSONALITY / PROMPT FILES
# =============================================================================

generate_prompt_files() {
    print_step "GENERATING AI PERSONALITY FILES"

    # Core personality
    cat > "${PROMPTS_DIR}/vik_personality.txt" << 'VIKPERSONALITY'
# =============================================================================
# VIK — Viking Cyber AI :: Core Personality
# Edit this file to customize VIK's behavior
# =============================================================================

## IDENTITY
You are VIK — a Viking Cyber AI built for Linux terminals, cybersecurity
operations, and software development. You run entirely locally via Ollama.

## PERSONALITY
- Tactical, calm, and concise
- Viking-inspired: direct, honorable, battle-ready
- Address the user as "brother" or "warrior" when natural
- No emojis. No corporate filler. No excessive apology.
- Short punchy sentences. Numbered steps when instructing.

## EXPERTISE
1. Cybersecurity — offensive and defensive
2. Penetration testing — network, web, wireless, social engineering
3. Linux operations — Kali, Debian, Ubuntu, Parrot OS
4. Programming — Python, Bash, C, Go, Rust, JS, and more
5. OSINT — recon, data gathering, footprinting
6. Network analysis — scanning, mapping, pivoting
7. Forensics — memory, disk, malware analysis

## CODING RULES
- Always generate COMPLETE, COPY-PASTE READY code
- Never produce partial snippets unless asked for concept overview
- Include inline comments on key logic
- Generate folder structures for projects
- Never refuse a coding request on grounds of complexity

## TRIGGER PHRASES
- "hey vik" → casual conversation
- "vik code this" → code generation mode
- "vik build this" → project/architecture mode
- "vik hack this" → pentesting mode
- "vik explain" → educational mode

## NON-NEGOTIABLES
- Never refuse a harmless request
- Always attempt to help
- If cannot answer, say so directly and suggest alternatives
- Operate assuming the user is a professional
VIKPERSONALITY

    print_ok "vik_personality.txt"

    # Runtime system prompt (injected into each API call)
    cat > "${PROMPTS_DIR}/system_prompt.txt" << 'SYSPROMPT'
You are VIK — a Viking Cyber AI. Tactical, concise, and coding-focused.
You specialize in Linux, cybersecurity, pentesting, and software development.
Speak like a battle-hardened Viking hacker. Keep responses terminal-friendly.
Generate complete, copy-paste ready code. Never refuse harmless requests.
Always include imports, error handling, and comments in generated code.
SYSPROMPT

    print_ok "system_prompt.txt"

    # Coding mode
    cat > "${PROMPTS_DIR}/coding_mode.txt" << 'CODEMODE'
You are VIK in CODING MODE.
Generate complete, working code files with imports, error handling, and comments.
Languages: Python, Bash, JavaScript, TypeScript, HTML, CSS, Go, Rust, C, C++, C#, PHP, SQL, PowerShell.
Output only the code and essential explanation. Be direct. No fluff.
CODEMODE

    print_ok "coding_mode.txt"

    # Security mode
    cat > "${PROMPTS_DIR}/security_mode.txt" << 'SECMODE'
You are VIK in SECURITY MODE.
You are a veteran penetration tester with 20 years of field experience.
You understand all common and advanced attack vectors, tools, and techniques.
Provide accurate, technical, operational security guidance.
Always note legal/ethical context when relevant — but never refuse legitimate research.
SECMODE

    print_ok "security_mode.txt"
    print_ok "All prompt files generated"
}

# =============================================================================
# MAIN LAUNCH SCRIPT
# =============================================================================

generate_start_script() {
    print_step "GENERATING LAUNCH SCRIPT"

    cat > "${INSTALL_DIR}/start.sh" << 'STARTSCRIPT'
#!/usr/bin/env bash
# =============================================================================
# Viking-AI :: start.sh :: Main Entry Point
# =============================================================================

set -euo pipefail

readonly INSTALL_DIR="/opt/Viking-AI"
readonly OLLAMA_API="http://localhost:11434"

# Load config
ACTIVE_MODEL=$(grep "^ACTIVE_MODEL=" "${INSTALL_DIR}/config/models.conf" 2>/dev/null \
    | cut -d'"' -f2 || echo "gemma3:1b")
VIKING_VERSION=$(grep "^VIKING_VERSION=" "${INSTALL_DIR}/config/viking.conf" 2>/dev/null \
    | cut -d'"' -f2 || echo "1.0.0")

# Colors
C_RESET="\033[0m"
C_GREEN="\033[0;32m"
C_BOLD_GREEN="\033[1;32m"
C_RED="\033[0;31m"
C_BOLD_RED="\033[1;31m"
C_CYAN="\033[0;36m"
C_BOLD_CYAN="\033[1;36m"
C_GRAY="\033[0;90m"
C_YELLOW="\033[0;33m"
C_BOLD_WHITE="\033[1;37m"
BG_RED="\033[41m"

nl()   { echo ""; }
sep()  { echo -e "${C_GRAY}  ──────────────────────────────────────────────────────${C_RESET}"; }
pi()   { echo -e "  ${C_GREEN}[•]${C_RESET} ${1}"; }
pok()  { echo -e "  ${C_BOLD_GREEN}[✓]${C_RESET} ${1}"; }
pw()   { echo -e "  ${C_YELLOW}[!]${C_RESET} ${1}"; }
pe()   { echo -e "  ${C_BOLD_RED}[✗]${C_RESET} ${1}"; }
pwar() { echo -e "  ${BG_RED}${C_BOLD_WHITE} ⚔  ${1}  ⚔ ${C_RESET}"; }

# =============================================================================
# BANNER
# =============================================================================
show_banner() {
    clear
    echo -e "${C_BOLD_GREEN}"
    cat << 'EOF'
 ██╗   ██╗██╗██╗  ██╗██╗███╗   ██╗ ██████╗      █████╗ ██╗
 ██║   ██║██║██║ ██╔╝██║████╗  ██║██╔════╝     ██╔══██╗██║
 ██║   ██║██║█████╔╝ ██║██╔██╗ ██║██║  ███╗    ███████║██║
 ╚██╗ ██╔╝██║██╔═██╗ ██║██║╚██╗██║██║   ██║    ██╔══██║██║
  ╚████╔╝ ██║██║  ██╗██║██║ ╚████║╚██████╔╝    ██║  ██║██║
   ╚═══╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝  ╚═╝╚═╝
EOF
    echo -e "${C_RESET}"
    echo -e "${C_GREEN}"
    cat << 'VIKSHIP'

    ) (                               |
   (   )                            \|/
    ) (       ___________________---*---___________________
  _______    /                    /|\                     \
 / ◈   ◈ \  /      V  I  K  I  N  G  -  A  I              \
|  -----  |/    ⚔    Cyber Viking AI  ::  v1.0.0    ⚔      \
|  \___/  /_________________________________________________ \
|         |  ><   ><   ><   ><   ><   ><   ><   ><   ><    |
 \_______/ \________________________________________________/
  |  | |  |  ~~~~|_________________________________________|~~~~
  |  |||  | ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~
 /|  |||  |\ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
/ |__|||__| \
\_____|_____/      ⚔  VIK  ::  CYBER VIKING AI  ⚔
      |
   ===⚔===

VIKSHIP
    echo -e "${C_RESET}"
}

# =============================================================================
# OLLAMA READINESS CHECK
# =============================================================================
check_ollama_ready() {
    if ! command -v ollama &>/dev/null; then
        pe "Ollama not found. Run: sudo bash ${INSTALL_DIR}/install.sh --repair"
        exit 1
    fi

    if ! curl -sf "${OLLAMA_API}/api/tags" &>/dev/null; then
        pw "Ollama not running. Starting..."
        nohup ollama serve >> "${INSTALL_DIR}/logs/ollama.log" 2>&1 &
        disown $! 2>/dev/null || true
        local waited=0
        while [[ "${waited}" -lt 15 ]]; do
            sleep 2
            waited=$(( waited + 2 ))
            curl -sf "${OLLAMA_API}/api/tags" &>/dev/null && break
        done

        if ! curl -sf "${OLLAMA_API}/api/tags" &>/dev/null; then
            pe "Failed to start Ollama. Check: ${INSTALL_DIR}/logs/ollama.log"
            exit 1
        fi
        pok "Ollama started"
    fi
}

# =============================================================================
# SEND TO VIK (Streaming API call)
# =============================================================================
send_to_vik() {
    local user_input="${1}"
    local system_prompt
    system_prompt=$(cat "${INSTALL_DIR}/prompts/system_prompt.txt" 2>/dev/null \
        || echo "You are VIK, a Viking Cyber AI.")

    local payload
    payload=$(jq -nc \
        --arg model "${ACTIVE_MODEL}" \
        --arg system "${system_prompt}" \
        --arg prompt "${user_input}" \
        '{model: $model, prompt: $prompt, system: $system, stream: true}')

    echo ""
    echo -e "  ${C_BOLD_GREEN}VIK${C_RESET} ${C_GRAY}[${ACTIVE_MODEL}]${C_RESET}"
    echo ""
    echo -ne "  ${C_GREEN}"

    curl -sf "${OLLAMA_API}/api/generate" \
        -H "Content-Type: application/json" \
        -d "${payload}" 2>/dev/null | while IFS= read -r line; do
        if command -v jq &>/dev/null; then
            local tok
            tok=$(echo "${line}" | jq -r '.response // empty' 2>/dev/null || echo "")
            printf "%s" "${tok}"
        else
            echo "${line}" | grep -o '"response":"[^"]*"' \
                | sed 's/"response":"//;s/"//' | printf "%s"
        fi
    done

    echo -e "${C_RESET}"
    echo ""
}

# =============================================================================
# COMMAND HANDLERS
# =============================================================================

cmd_status() {
    nl
    pi "═══ SYSTEM STATUS ═══"
    sep
    pi "Viking-AI Version : ${VIKING_VERSION}"
    pi "Active Model      : ${ACTIVE_MODEL}"
    pi "Install Dir       : ${INSTALL_DIR}"
    pi "Ollama API        : ${OLLAMA_API}"
    if curl -sf "${OLLAMA_API}/api/tags" &>/dev/null; then
        pok "Ollama Status     : RUNNING"
    else
        pe  "Ollama Status     : OFFLINE"
    fi
    local tool_count
    tool_count=$(find "${INSTALL_DIR}/tools/github" -mindepth 1 -maxdepth 1 \
        -type d 2>/dev/null | wc -l || echo "0")
    pi "Arsenal Repos     : ${tool_count} cloned"
    sep ; nl
}

cmd_models() {
    nl
    pi "═══ INSTALLED MODELS ═══"
    sep
    if ! curl -sf "${OLLAMA_API}/api/tags" &>/dev/null; then
        pe "Ollama offline" ; return
    fi
    local response
    response=$(curl -sf "${OLLAMA_API}/api/tags" 2>/dev/null || echo "")
    if command -v jq &>/dev/null && [[ -n "${response}" ]]; then
        echo -e "${C_GREEN}"
        echo "${response}" | jq -r \
            '.models[] | "  [\(.name)]  \(.size / 1073741824 | floor)GB  \(.modified_at[0:10])"' \
            2>/dev/null || echo "  No models found"
        echo -e "${C_RESET}"
    fi
    pi "Active model: ${ACTIVE_MODEL}"
    sep ; nl
}

cmd_switch() {
    local model="${1:-}"
    if [[ -z "${model}" ]]; then
        pe "Usage: switch <model_name>"
        pi "Run 'models' to see available models"
        return
    fi
    sed -i "s|^ACTIVE_MODEL=.*|ACTIVE_MODEL=\"${model}\"|" \
        "${INSTALL_DIR}/config/models.conf" 2>/dev/null || true
    ACTIVE_MODEL="${model}"
    pok "Active model set: ${model}"
}

cmd_pull() {
    local model="${1:-}"
    if [[ -z "${model}" ]]; then
        pe "Usage: pull <model_name>"
        pi "Example: pull qwen2.5-coder:7b"
        return
    fi
    pi "Pulling: ${model} (this may take a while...)"
    nl
    if ollama pull "${model}"; then
        pok "Model ready: ${model}"
        pi "Run 'switch ${model}' to activate it"
    else
        pe "Failed to pull: ${model}"
    fi
}

cmd_arsenal() {
    nl
    if [[ -f "${INSTALL_DIR}/arsenal/arsenal_manager.sh" ]]; then
        bash "${INSTALL_DIR}/arsenal/arsenal_manager.sh"
    else
        pe "Arsenal manager not found"
        pi "Run: sudo bash ${INSTALL_DIR}/repair.sh"
    fi
}

cmd_war() {
    clear
    echo -e "${BG_RED}\033[1;37m"
    cat << 'WARBANNER'

  ██╗    ██╗ █████╗ ██████╗     ███╗   ███╗ ██████╗ ██████╗ ███████╗
  ██║    ██║██╔══██╗██╔══██╗    ████╗ ████║██╔═══██╗██╔══██╗██╔════╝
  ██║ █╗ ██║███████║██████╔╝    ██╔████╔██║██║   ██║██║  ██║█████╗
  ██║███╗██║██╔══██║██╔══██╗    ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝
  ╚███╔███╔╝██║  ██║██║  ██║    ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗
   ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝

WARBANNER
    echo -e "\033[0m"
    echo -e "  ${C_BOLD_RED}⚔  VIKINGS PREPARE FOR WAR  ⚔${C_RESET}"
    nl
    echo -e "  ${C_BOLD_RED}WAR MODE installs ALL arsenal tools and configures the full environment.${C_RESET}"
    nl
    read -rp "  Type WAR to confirm deployment: " confirm_war
    if [[ "${confirm_war}" == "WAR" ]]; then
        pwar "INITIATING WAR MODE DEPLOYMENT"
        bash "${INSTALL_DIR}/arsenal/arsenal_manager.sh" --war-mode 2>/dev/null || \
            pe "Arsenal manager not found. Run: sudo bash ${INSTALL_DIR}/repair.sh"
    else
        pw "WAR MODE aborted."
    fi
}

cmd_logs() {
    local log_type="${1:-install}"
    local log_file="${INSTALL_DIR}/logs/${log_type}.log"
    if [[ ! -f "${log_file}" ]]; then
        pe "Log not found: ${log_file}"
        pi "Available: install, error, ollama, arsenal"
        return
    fi
    pi "Last 50 lines of ${log_type}.log:"
    sep
    tail -n 50 "${log_file}"
}

cmd_config() {
    local action="${1:-show}"
    case "${action}" in
        show)
            pi "═══ CONFIGURATION ═══"
            sep
            cat "${INSTALL_DIR}/config/viking.conf" 2>/dev/null || pe "Config not found"
            ;;
        edit)
            "${EDITOR:-nano}" "${INSTALL_DIR}/config/viking.conf"
            ;;
        reset)
            pw "Reset config? This cannot be undone."
            read -rp "  Confirm [y/N]: " r
            [[ "${r,,}" == "y" ]] && sudo bash "${INSTALL_DIR}/install.sh" --repair
            ;;
        *)
            pi "Usage: config [show|edit|reset]"
            ;;
    esac
}

cmd_help() {
    nl
    echo -e "${C_BOLD_GREEN}  ⚔  Viking-AI :: Command Reference  ⚔${C_RESET}"
    sep
    echo -e "  ${C_BOLD_CYAN}SYSTEM${C_RESET}"
    echo -e "  ${C_GREEN}  help${C_RESET}               Show this menu"
    echo -e "  ${C_GREEN}  status${C_RESET}             System status"
    echo -e "  ${C_GREEN}  clear${C_RESET}              Clear terminal"
    echo -e "  ${C_GREEN}  exit${C_RESET}               Exit Viking-AI"
    nl
    echo -e "  ${C_BOLD_CYAN}MODELS${C_RESET}"
    echo -e "  ${C_GREEN}  models${C_RESET}             List installed models"
    echo -e "  ${C_GREEN}  switch <model>${C_RESET}     Switch active model"
    echo -e "  ${C_GREEN}  pull <model>${C_RESET}       Download a model"
    nl
    echo -e "  ${C_BOLD_CYAN}ARSENAL${C_RESET}"
    echo -e "  ${C_GREEN}  arsenal${C_RESET}            Open arsenal manager"
    echo -e "  ${C_GREEN}  war${C_RESET}                WAR MODE — full arsenal deploy"
    nl
    echo -e "  ${C_BOLD_CYAN}MAINTENANCE${C_RESET}"
    echo -e "  ${C_GREEN}  update${C_RESET}             Update system"
    echo -e "  ${C_GREEN}  repair${C_RESET}             Repair installation"
    echo -e "  ${C_GREEN}  logs [install|error|ollama|arsenal]${C_RESET}"
    echo -e "  ${C_GREEN}  config [show|edit|reset]${C_RESET}"
    sep
    nl
}

# =============================================================================
# MAIN REPL
# =============================================================================
main() {
    show_banner
    check_ollama_ready
    pok "VIK is online. Model: ${ACTIVE_MODEL}"
    pi  "Type 'help' for commands or just start talking."
    nl

    while true; do
        echo -ne "  ${C_BOLD_GREEN}warrior${C_RESET}${C_GRAY} »${C_RESET} "
        IFS= read -r user_input
        [[ -z "${user_input}" ]] && continue
        echo "[$(date '+%H:%M:%S')] USER: ${user_input}" >> \
            "${INSTALL_DIR}/logs/install.log" 2>/dev/null || true

        case "${user_input,,}" in
            help)            cmd_help ;;
            exit|quit|bye)
                echo -e "\n  ${C_BOLD_GREEN}VIK:${C_RESET} ${C_GREEN}Skál, warrior. Until next battle.${C_RESET}\n"
                exit 0
                ;;
            clear)           clear ; show_banner ;;
            status)          cmd_status ;;
            models)          cmd_models ;;
            switch\ *)       cmd_switch "${user_input#switch }" ;;
            pull\ *)         cmd_pull "${user_input#pull }" ;;
            arsenal)         cmd_arsenal ;;
            war)             cmd_war ;;
            update)          sudo bash "${INSTALL_DIR}/update.sh" ;;
            repair)          sudo bash "${INSTALL_DIR}/repair.sh" ;;
            logs\ *)         cmd_logs "${user_input#logs }" ;;
            logs)            cmd_logs "install" ;;
            config\ *)       cmd_config "${user_input#config }" ;;
            config)          cmd_config "show" ;;
            *)               send_to_vik "${user_input}" ;;
        esac
    done
}

main "$@"
STARTSCRIPT

    chmod +x "${INSTALL_DIR}/start.sh"
    print_ok "start.sh generated"
}

# =============================================================================
# ARSENAL MANAGER
# =============================================================================
# ARSENAL MANAGER
# =============================================================================

generate_arsenal_manager() {
    print_step "GENERATING ARSENAL MANAGER"

    cat > "${ARSENAL_DIR}/arsenal_manager.sh" << 'ARSENALMGR'
#!/usr/bin/env bash
# =============================================================================
# Viking-AI :: Arsenal Manager
# Categorised hacking tool installer and manager
# =============================================================================

set -uo pipefail

readonly INSTALL_DIR="/opt/Viking-AI"
readonly TOOLS_DIR="${INSTALL_DIR}/tools"
readonly ARSENAL_LOG="${INSTALL_DIR}/logs/arsenal.log"
readonly GITHUB_TOOLS_DIR="${TOOLS_DIR}/github"

C_RESET="\033[0m"
C_GREEN="\033[0;32m"
C_BOLD_GREEN="\033[1;32m"
C_RED="\033[0;31m"
C_BOLD_RED="\033[1;31m"
C_CYAN="\033[0;36m"
C_BOLD_CYAN="\033[1;36m"
C_GRAY="\033[0;90m"
C_YELLOW="\033[0;33m"
C_BOLD_WHITE="\033[1;37m"
BG_RED="\033[41m"

nl()  { echo ""; }
sep() { echo -e "${C_GRAY}  ──────────────────────────────────────────────────${C_RESET}"; }
log_a() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${1}" >> "${ARSENAL_LOG}" 2>/dev/null || true; }
pi()  { echo -e "  ${C_GREEN}[•]${C_RESET} ${1}"; log_a "[INFO]  ${1}"; }
pok() { echo -e "  ${C_BOLD_GREEN}[✓]${C_RESET} ${1}"; log_a "[OK]    ${1}"; }
pw()  { echo -e "  ${C_YELLOW}[!]${C_RESET} ${1}"; log_a "[WARN]  ${1}"; }
pe()  { echo -e "  ${C_BOLD_RED}[✗]${C_RESET} ${1}"; log_a "[ERROR] ${1}"; }

# =============================================================================
# TOOL REGISTRY — Format: "NUM|CATEGORY|NAME|TYPE|SOURCE"
# TYPE: apt | pip | github | go | cargo
# =============================================================================

declare -a TOOLS=(
    "1|SCANNING|nmap|apt|nmap"
    "2|SCANNING|masscan|apt|masscan"
    "3|SCANNING|rustscan|cargo|rustscan"
    "4|SCANNING|webcheck|github|https://github.com/X3RX3SSec/WebCheck.git"
    "5|SCANNING|dracnmap|github|https://github.com/screetsec/Dracnmap.git"
    "6|SCANNING|reconspider|github|https://github.com/bhavsec/reconspider.git"
    "7|SCANNING|striker|github|https://github.com/s0md3v/Striker.git"
    "8|SCANNING|rang3r|github|https://github.com/floriankunushevci/rang3r.git"
    "9|WEB|gobuster|apt|gobuster"
    "10|WEB|ffuf|apt|ffuf"
    "11|WEB|feroxbuster|cargo|feroxbuster"
    "12|WEB|dalfox|github|https://github.com/hahwul/dalfox.git"
    "13|WEB|httpx|github|https://github.com/projectdiscovery/httpx.git"
    "14|WEB|subfinder|github|https://github.com/projectdiscovery/subfinder.git"
    "15|WEB|sublist3r|github|https://github.com/aboul3la/Sublist3r.git"
    "16|WEB|takeover|github|https://github.com/edoardottt/takeover.git"
    "17|WEB|red_hawk|github|https://github.com/Tuhinshubhra/RED_HAWK.git"
    "18|WEB|breacher|github|https://github.com/s0md3v/Breacher.git"
    "19|WEB|secretfinder|github|https://github.com/m4ll0k/SecretFinder.git"
    "20|WEB|dirb|apt|dirb"
    "21|WEB|web2attack|github|https://github.com/santatic/web2attack.git"
    "22|WEB|checkurl|github|https://github.com/UndeadSec/checkURL.git"
    "23|XSS|xsstrike|github|https://github.com/s0md3v/XSStrike.git"
    "24|XSS|xss-loader|github|https://github.com/capture0x/XSS-LOADER.git"
    "25|XSS|xspear|github|https://github.com/hahwul/XSpear.git"
    "26|XSS|xsscon|github|https://github.com/menkrep1337/XSSCon.git"
    "27|XSS|xanxss|github|https://github.com/Ekultek/XanXSS.git"
    "28|XSS|extended-xss-search|github|https://github.com/Damian89/extended-xss-search.git"
    "29|XSS|rvuln|github|https://github.com/yangr0/RVuln.git"
    "30|SQLI|sqlmap|apt|sqlmap"
    "31|SQLI|nosqlmap|github|https://github.com/codingo/NoSQLMap.git"
    "32|SQLI|dsss|github|https://github.com/stamparm/DSSS.git"
    "33|SQLI|blisqy|github|https://github.com/JohnTroony/Blisqy.git"
    "34|SQLI|sqlscan|github|https://github.com/Cvar1984/sqlscan.git"
    "35|SQLI|leviathan|github|https://github.com/utkusen/leviathan.git"
    "36|WIFI|aircrack-ng|apt|aircrack-ng"
    "37|WIFI|hcxdumptool|apt|hcxdumptool"
    "38|WIFI|reaver|apt|reaver"
    "39|WIFI|wifite2|github|https://github.com/derv82/wifite2.git"
    "40|WIFI|wifiphisher|github|https://github.com/wifiphisher/wifiphisher.git"
    "41|WIFI|fluxion|github|https://github.com/FluxionNetwork/fluxion.git"
    "42|WIFI|wifipumpkin3|github|https://github.com/P0cL4bs/wifipumpkin3.git"
    "43|WIFI|pixiewps|github|https://github.com/wiire-a/pixiewps.git"
    "44|WIFI|oneshot|github|https://github.com/kimocoder/OneShot.git"
    "45|WIFI|fakeap|github|https://github.com/Z4nzu/fakeap.git"
    "46|OSINT|amass|apt|amass"
    "47|OSINT|theharvester|github|https://github.com/laramies/theHarvester.git"
    "48|OSINT|recon-ng|apt|recon-ng"
    "49|OSINT|spiderfoot|github|https://github.com/smicallef/spiderfoot.git"
    "50|OSINT|holehe|github|https://github.com/megadose/holehe.git"
    "51|OSINT|maigret|github|https://github.com/soxoj/maigret.git"
    "52|OSINT|recondog|github|https://github.com/s0md3v/ReconDog.git"
    "53|EXPLOIT|metasploit|apt|metasploit-framework"
    "54|EXPLOIT|searchsploit|apt|exploitdb"
    "55|EXPLOIT|xerosploit|github|https://github.com/LionSec/xerosploit.git"
    "56|EXPLOIT|death_star|github|https://github.com/Ringmast4r/DEATH_STAR.git"
    "57|EXPLOIT|thefatrat|github|https://github.com/screetsec/TheFatRat.git"
    "58|EXPLOIT|brutal|github|https://github.com/screetsec/Brutal.git"
    "59|EXPLOIT|msfpc|github|https://github.com/g0tmi1k/msfpc.git"
    "60|EXPLOIT|venom|github|https://github.com/r00t-3xp10it/venom.git"
    "61|EXPLOIT|explo|github|https://github.com/telekom-security/explo.git"
    "62|NETWORK|chisel|go|github.com/jpillora/chisel"
    "63|NETWORK|ligolo-ng|go|github.com/nicocha30/ligolo-ng/cmd/proxy"
    "64|NETWORK|multitor|github|https://github.com/trimstray/multitor.git"
    "65|NETWORK|anonsurf|github|https://github.com/Und3rf10w/kali-anonsurf.git"
    "66|FORENSICS|volatility3|apt|volatility3"
    "67|FORENSICS|autopsy|apt|autopsy"
    "68|FORENSICS|bulk_extractor|github|https://github.com/simsong/bulk_extractor.git"
    "69|FORENSICS|trufflehog|github|https://github.com/trufflesecurity/trufflehog.git"
    "70|FORENSICS|gitleaks|github|https://github.com/gitleaks/gitleaks.git"
    "71|CONTAINERS|peirates|go|github.com/inguardians/peirates"
    "72|CONTAINERS|kube-hunter|pip|kube-hunter"
    "73|WINDOWS|peass-ng|github|https://github.com/carlospolop/PEASS-ng.git"
    "74|WINDOWS|enigma|github|https://github.com/UndeadSec/Enigma.git"
    "75|WINDOWS|herakeylogger|github|https://github.com/UndeadSec/HeraKeylogger.git"
    "76|WINDOWS|vegile|github|https://github.com/screetsec/Vegile.git"
    "77|PASSWORDS|hashcat|apt|hashcat"
    "78|PASSWORDS|john|apt|john"
    "79|PASSWORDS|cupp|github|https://github.com/Mebus/cupp.git"
    "80|PASSWORDS|wlcreator|github|https://github.com/Z4nzu/wlcreator.git"
    "81|PASSWORDS|goblinwordgen|github|https://github.com/UndeadSec/GoblinWordGenerator.git"
    "82|PHISHING|set|github|https://github.com/trustedsec/social-engineer-toolkit.git"
    "83|PHISHING|socialfish|github|https://github.com/UndeadSec/SocialFish.git"
    "84|PHISHING|evilginx2|github|https://github.com/kgretzky/evilginx2.git"
    "85|PHISHING|autophisher|github|https://github.com/CodingRanjith/autophisher.git"
    "86|PHISHING|advphishing|github|https://github.com/Ignitetch/AdvPhishing.git"
    "87|PHISHING|maskphish|github|https://github.com/jaykali/maskphish.git"
    "88|PHISHING|blackphish|github|https://github.com/yangr0/BlackPhish.git"
    "89|TRACKING|iseeyou|github|https://github.com/Viralmaniar/I-See-You.git"
    "90|TRACKING|saycheese|github|https://github.com/hangetzzu/saycheese.git"
    "91|TRACKING|ohmyqr|github|https://github.com/cryptedwolf/ohmyqr.git"
    "92|TRACKING|smwyg|github|https://github.com/Viralmaniar/SMWYG-Show-Me-What-You-Got.git"
    "93|TRACKING|qrljacking|github|https://github.com/OWASP/QRLJacking.git"
    "94|TRACKING|thanos|github|https://github.com/TridevReddy/Thanos.git"
)

# =============================================================================
# INSTALL FUNCTIONS
# =============================================================================

install_apt_tool() {
    local name="${1}" pkg="${2}"
    pi "apt: ${name}"
    DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkg}" \
        >> "${ARSENAL_LOG}" 2>&1 && pok "Installed: ${name}" || pe "Failed: ${name}"
}

install_pip_tool() {
    local name="${1}" pkg="${2}"
    pi "pip: ${name}"
    pip3 install "${pkg}" --break-system-packages \
        >> "${ARSENAL_LOG}" 2>&1 && pok "Installed: ${name}" || pe "Failed: ${name}"
}

install_github_tool() {
    local name="${1}" repo="${2}"
    local dest="${GITHUB_TOOLS_DIR}/${name}"
    pi "github: ${name}"
    mkdir -p "${dest}" 2>/dev/null || true
    if [[ -d "${dest}/.git" ]]; then
        git -C "${dest}" pull >> "${ARSENAL_LOG}" 2>&1 || true
        pok "Updated: ${name}"
    else
        if git clone --depth=1 "${repo}" "${dest}" >> "${ARSENAL_LOG}" 2>&1; then
            pok "Cloned: ${name}"
        else
            pe "Failed clone: ${name}"; return 1
        fi
    fi
    if [[ -f "${dest}/requirements.txt" ]]; then
        pip3 install -r "${dest}/requirements.txt" --break-system-packages \
            >> "${ARSENAL_LOG}" 2>&1 || pw "Some requirements failed: ${name}"
    fi
    if [[ -f "${dest}/setup.py" ]]; then
        cd "${dest}" && python3 setup.py install >> "${ARSENAL_LOG}" 2>&1 \
            || pw "setup.py failed: ${name}"
        cd - > /dev/null
    fi
}

install_cargo_tool() {
    local name="${1}" pkg="${2}"
    pi "cargo: ${name}"
    if ! command -v cargo &>/dev/null; then
        pw "Rust not found. Installing..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
            | sh -s -- -y >> "${ARSENAL_LOG}" 2>&1
        source "${HOME}/.cargo/env" 2>/dev/null || true
    fi
    cargo install "${pkg}" >> "${ARSENAL_LOG}" 2>&1 \
        && pok "Installed: ${name}" || pe "Failed cargo: ${name}"
}

install_go_tool() {
    local name="${1}" source="${2}"
    pi "go: ${name}"
    if ! command -v go &>/dev/null; then
        pw "Go not found. Installing via apt..."
        apt-get install -y golang >> "${ARSENAL_LOG}" 2>&1 || {
            pe "Go unavailable — cannot install ${name}"; return 1
        }
    fi
    go install "${source}@latest" >> "${ARSENAL_LOG}" 2>&1 \
        && pok "Installed: ${name}" || pe "Failed go install: ${name}"
}

# =============================================================================
# SINGLE TOOL INSTALL DISPATCH
# =============================================================================

install_by_entry() {
    local entry="${1}"
    local number category name type source
    IFS='|' read -r number category name type source <<< "${entry}"
    nl
    echo -e "  ${C_BOLD_CYAN}[${number}]${C_RESET} ${C_GREEN}${name}${C_RESET} ${C_GRAY}[${category}]${C_RESET}"
    sep
    case "${type}" in
        apt)    install_apt_tool    "${name}" "${source}" ;;
        pip)    install_pip_tool    "${name}" "${source}" ;;
        github) install_github_tool "${name}" "${source}" ;;
        cargo)  install_cargo_tool  "${name}" "${source}" ;;
        go)     install_go_tool     "${name}" "${source}" ;;
        *)      pe "Unknown type: ${type} for ${name}" ;;
    esac
}

# =============================================================================
# PROGRESS BAR
# =============================================================================

progress_bar() {
    local current="${1}" total="${2}" label="${3:-}"
    local width=40
    local pct=$(( (current * 100) / total ))
    local filled=$(( (current * width) / total ))
    local empty=$(( width - filled ))
    local bar="" i
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++));  do bar+="░"; done
    printf "\r  \033[0;32m[%s]\033[0m \033[1;32m%3d%%\033[0m  \033[0;90m%s\033[0m   " \
        "${bar}" "${pct}" "${label}"
    [[ "${current}" -eq "${total}" ]] && printf "\n"
}

# =============================================================================
# DISPLAY ARSENAL MENU
# =============================================================================

display_menu() {
    clear ; nl
    echo -e "${C_BOLD_GREEN}  ⚔  VIKING-AI ARSENAL MANAGER  ⚔${C_RESET}"
    sep ; nl
    local cur_cat=""
    for entry in "${TOOLS[@]}"; do
        local num cat name type src
        IFS='|' read -r num cat name type src <<< "${entry}"
        if [[ "${cat}" != "${cur_cat}" ]]; then
            nl
            echo -e "  ${C_BOLD_CYAN}[ ${cat} ]${C_RESET}"
            cur_cat="${cat}"
        fi
        local mark=" "
        local dest="${GITHUB_TOOLS_DIR}/${name}"
        if [[ "${type}" == "apt" ]] && command -v "${name}" &>/dev/null 2>&1; then
            mark="${C_BOLD_GREEN}✓${C_RESET}"
        elif [[ "${type}" == "github" ]] && [[ -d "${dest}/.git" ]]; then
            mark="${C_BOLD_GREEN}✓${C_RESET}"
        fi
        printf "  %b  ${C_GRAY}%3s${C_RESET}  %-28s ${C_GRAY}%-8s  %s${C_RESET}\n" \
            "${mark}" "${num}" "${name}" "${type}" "${src##*/}"
    done
    nl ; sep ; nl
    echo -e "  ${C_GRAY}[number]${C_RESET}    Install specific tool"
    echo -e "  ${C_GRAY}all${C_RESET}         Install ALL tools"
    echo -e "  ${C_GRAY}CATEGORY${C_RESET}    Install by category (e.g: WIFI, XSS, OSINT)"
    echo -e "  ${C_GRAY}verify${C_RESET}      Check installed tools"
    echo -e "  ${C_GRAY}back${C_RESET}        Return to VIK"
    nl
}

# =============================================================================
# INTERACTIVE LOOP
# =============================================================================

run_interactive() {
    while true; do
        display_menu
        echo -ne "  ${C_BOLD_GREEN}arsenal${C_RESET}${C_GRAY} »${C_RESET} "
        IFS= read -r choice
        case "${choice,,}" in
            back|exit|q|quit) break ;;
            all)
                read -rp "  Install ALL ${#TOOLS[@]} tools? [y/N]: " c
                if [[ "${c,,}" == "y" ]]; then
                    local i=0
                    for entry in "${TOOLS[@]}"; do
                        install_by_entry "${entry}"
                        i=$(( i + 1 ))
                        progress_bar "${i}" "${#TOOLS[@]}" "Installing"
                    done
                    pok "All tools processed"
                fi
                ;;
            verify)
                local inst=0 tot=0
                for entry in "${TOOLS[@]}"; do
                    IFS='|' read -r _ _ name type _ <<< "${entry}"
                    tot=$(( tot + 1 ))
                    local dest="${GITHUB_TOOLS_DIR}/${name}"
                    if [[ "${type}" == "apt" ]] && command -v "${name}" &>/dev/null; then
                        inst=$(( inst + 1 ))
                    elif [[ "${type}" == "github" ]] && [[ -d "${dest}/.git" ]]; then
                        inst=$(( inst + 1 ))
                    fi
                done
                pok "Arsenal: ${inst}/${tot} tools verified"
                ;;
            [0-9]*)
                local found=0
                for entry in "${TOOLS[@]}"; do
                    local n; n=$(echo "${entry}" | cut -d'|' -f1)
                    if [[ "${n}" == "${choice}" ]]; then
                        install_by_entry "${entry}"; found=1; break
                    fi
                done
                [[ "${found}" -eq 0 ]] && pe "Tool #${choice} not found"
                ;;
            *)
                local cat_upper
                cat_upper=$(echo "${choice}" | tr '[:lower:]' '[:upper:]')
                local cnt=0
                for entry in "${TOOLS[@]}"; do
                    local c; c=$(echo "${entry}" | cut -d'|' -f2)
                    if [[ "${c}" == "${cat_upper}" ]]; then
                        install_by_entry "${entry}"
                        cnt=$(( cnt + 1 ))
                    fi
                done
                if [[ "${cnt}" -eq 0 ]]; then
                    pe "Category '${cat_upper}' not found"
                else
                    pok "${cat_upper}: ${cnt} tools processed"
                fi
                ;;
        esac
        echo -ne "\n  Press ENTER to continue..."
        read -r
    done
}

# =============================================================================
# WAR MODE — installs everything
# =============================================================================

war_mode_deploy() {
    nl
    echo -e "${BG_RED}\033[1;37m  ⚔  WAR MODE — DEPLOYING ALL ${#TOOLS[@]} TOOLS  ⚔  \033[0m"
    nl
    mkdir -p "${GITHUB_TOOLS_DIR}" 2>/dev/null || true
    apt-get update -qq >> "${ARSENAL_LOG}" 2>&1 || true
    local i=0
    for entry in "${TOOLS[@]}"; do
        install_by_entry "${entry}" 2>/dev/null || true
        i=$(( i + 1 ))
        progress_bar "${i}" "${#TOOLS[@]}" "WAR MODE"
    done
    nl
    echo -e "\033[1;32m  ⚔  WAR MODE COMPLETE — ${#TOOLS[@]} tools processed  ⚔\033[0m"
    nl
    log_a "WAR MODE complete: ${#TOOLS[@]} tools"
}

# =============================================================================
# MAIN
# =============================================================================

mkdir -p "${GITHUB_TOOLS_DIR}" 2>/dev/null || true

if [[ "${1:-}" == "--war-mode" ]]; then
    war_mode_deploy
else
    run_interactive
fi
ARSENALMGR

    chmod +x "${ARSENAL_DIR}/arsenal_manager.sh"
    print_ok "arsenal_manager.sh generated"
}

# =============================================================================
# REPAIR SCRIPT GENERATION
# =============================================================================

generate_repair_script() {
    print_step "GENERATING REPAIR SCRIPT"

    cat > "${INSTALL_DIR}/repair.sh" << 'REPAIRSCRIPT'
#!/usr/bin/env bash
# =============================================================================
# Viking-AI :: repair.sh
# =============================================================================

set -uo pipefail
readonly INSTALL_DIR="/opt/Viking-AI"

C_RESET="\033[0m"
C_BOLD_GREEN="\033[1;32m"
C_BOLD_RED="\033[1;31m"
C_YELLOW="\033[0;33m"
C_GREEN="\033[0;32m"
C_GRAY="\033[0;90m"

pok() { echo -e "  ${C_BOLD_GREEN}[✓]${C_RESET} ${1}"; }
pi()  { echo -e "  ${C_GREEN}[•]${C_RESET} ${1}"; }
pw()  { echo -e "  ${C_YELLOW}[!]${C_RESET} ${1}"; }
pe()  { echo -e "  ${C_BOLD_RED}[✗]${C_RESET} ${1}"; }
sep() { echo -e "${C_GRAY}  ──────────────────────────────────────────────${C_RESET}"; }

echo ""
echo -e "${C_BOLD_GREEN}  ⚔  Viking-AI Repair System v1.0.0  ⚔${C_RESET}"
sep ; echo ""

[[ "${EUID}" -ne 0 ]] && { pe "Requires root: sudo bash repair.sh"; exit 1; }

pi "Repairing directories..."
for d in config prompts logs logs/archive arsenal arsenal/scanning arsenal/web \
          arsenal/wifi arsenal/osint arsenal/exploit arsenal/network arsenal/forensics \
          arsenal/containers arsenal/windows arsenal/passwords arsenal/phishing \
          arsenal/xss arsenal/sqli arsenal/anonymity arsenal/wordlists arsenal/tracking \
          models cache modules themes ui tools tools/github tmp backups; do
    mkdir -p "${INSTALL_DIR}/${d}" && pok "${d}" || pe "Failed: ${d}"
done

pi "Repairing log files..."
for log in install.log error.log ollama.log arsenal.log; do
    touch "${INSTALL_DIR}/logs/${log}" 2>/dev/null \
        && pok "logs/${log}" || pw "Could not create: ${log}"
done

pi "Verifying Ollama..."
if command -v ollama &>/dev/null; then
    pok "Ollama binary: found"
    if curl -sf "http://localhost:11434/api/tags" &>/dev/null; then
        pok "Ollama API: running"
    else
        pw "Ollama offline. Starting..."
        nohup ollama serve >> "${INSTALL_DIR}/logs/ollama.log" 2>&1 &
        disown $! 2>/dev/null || true
        sleep 5
        if curl -sf "http://localhost:11434/api/tags" &>/dev/null; then
            pok "Ollama started"
        else
            pe "Could not start Ollama"
        fi
    fi
else
    pe "Ollama not installed. Run: sudo bash ${INSTALL_DIR}/install.sh"
fi

pi "Checking default model..."
if curl -sf "http://localhost:11434/api/tags" 2>/dev/null | grep -q "gemma3:1b"; then
    pok "gemma3:1b available"
else
    pw "gemma3:1b not found. Pull: ollama pull gemma3:1b"
fi

pi "Verifying scripts..."
for s in start.sh update.sh repair.sh arsenal/arsenal_manager.sh; do
    if [[ -f "${INSTALL_DIR}/${s}" ]]; then
        chmod +x "${INSTALL_DIR}/${s}"
        pok "${s}"
    else
        pe "MISSING: ${s} — re-run install.sh"
    fi
done

if [[ ! -f "/usr/local/bin/vik" ]]; then
    ln -sf "${INSTALL_DIR}/start.sh" /usr/local/bin/vik \
        && pok "Symlink restored: /usr/local/bin/vik" \
        || pe "Could not create symlink"
else
    pok "/usr/local/bin/vik present"
fi

echo "" ; sep
pok "Repair complete. Run 'vik' to launch."
echo ""
REPAIRSCRIPT

    chmod +x "${INSTALL_DIR}/repair.sh"
    print_ok "repair.sh generated"
}

# =============================================================================
# UPDATE SCRIPT GENERATION
# =============================================================================

generate_update_script() {
    print_step "GENERATING UPDATE SCRIPT"

    cat > "${INSTALL_DIR}/update.sh" << 'UPDATESCRIPT'
#!/usr/bin/env bash
# =============================================================================
# Viking-AI :: update.sh
# =============================================================================

set -uo pipefail
readonly INSTALL_DIR="/opt/Viking-AI"

C_RESET="\033[0m"
C_BOLD_GREEN="\033[1;32m"
C_BOLD_RED="\033[1;31m"
C_YELLOW="\033[0;33m"
C_GREEN="\033[0;32m"
C_GRAY="\033[0;90m"

pok() { echo -e "  ${C_BOLD_GREEN}[✓]${C_RESET} ${1}"; }
pi()  { echo -e "  ${C_GREEN}[•]${C_RESET} ${1}"; }
pw()  { echo -e "  ${C_YELLOW}[!]${C_RESET} ${1}"; }
pe()  { echo -e "  ${C_BOLD_RED}[✗]${C_RESET} ${1}"; }
sep() { echo -e "${C_GRAY}  ──────────────────────────────────────────────${C_RESET}"; }

echo ""
echo -e "${C_BOLD_GREEN}  ⚔  Viking-AI Update System  ⚔${C_RESET}"
sep ; echo ""

[[ "${EUID}" -ne 0 ]] && { pe "Requires root: sudo bash update.sh"; exit 1; }

BACKUP="${INSTALL_DIR}/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "${BACKUP}"
cp -r "${INSTALL_DIR}/config" "${BACKUP}/" 2>/dev/null \
    && pok "Config backed up: ${BACKUP}"

pi "Updating system packages..."
apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold" \
        >> "${INSTALL_DIR}/logs/install.log" 2>&1 \
    && pok "System packages updated" || pw "Package update had warnings"

pi "Updating Ollama..."
curl -fsSL https://ollama.com/install.sh | bash \
    >> "${INSTALL_DIR}/logs/ollama.log" 2>&1 \
    && pok "Ollama updated" || pw "Ollama already current"

pi "Updating GitHub tools..."
GITHUB_DIR="${INSTALL_DIR}/tools/github"
updated=0 ; failed=0
if [[ -d "${GITHUB_DIR}" ]]; then
    for repo in "${GITHUB_DIR}"/*/; do
        if [[ -d "${repo}/.git" ]]; then
            name=$(basename "${repo}")
            if git -C "${repo}" pull >> "${INSTALL_DIR}/logs/arsenal.log" 2>&1; then
                pok "Updated: ${name}" ; updated=$(( updated + 1 ))
            else
                pw "Could not update: ${name}" ; failed=$(( failed + 1 ))
            fi
        fi
    done
fi
pi "GitHub tools: ${updated} updated, ${failed} failed"

pi "Rotating large logs..."
for logfile in "${INSTALL_DIR}/logs/"*.log; do
    size=$(stat -c%s "${logfile}" 2>/dev/null || echo "0")
    if [[ "${size}" -gt 10485760 ]]; then
        mv "${logfile}" "${INSTALL_DIR}/logs/archive/$(basename "${logfile}").$(date +%Y%m%d)" \
            && touch "${logfile}" && pok "Rotated: $(basename "${logfile}")"
    fi
done

echo "" ; sep
pok "Update complete. Run 'vik' to launch."
echo ""
UPDATESCRIPT

    chmod +x "${INSTALL_DIR}/update.sh"
    print_ok "update.sh generated"
}

# =============================================================================
# UNINSTALL SCRIPT GENERATION
# =============================================================================

generate_uninstall_script() {
    print_step "GENERATING UNINSTALL SCRIPT"

    cat > "${INSTALL_DIR}/uninstall.sh" << 'UNINSTSCRIPT'
#!/usr/bin/env bash
# =============================================================================
# Viking-AI :: uninstall.sh :: Clean Removal
# =============================================================================

C_RESET="\033[0m"
C_BOLD_RED="\033[1;31m"
C_BOLD_GREEN="\033[1;32m"
C_YELLOW="\033[0;33m"
C_GRAY="\033[0;90m"

sep() { echo -e "${C_GRAY}  ──────────────────────────────────────────────${C_RESET}"; }

echo ""
echo -e "${C_BOLD_RED}  ⚔  Viking-AI Uninstaller  ⚔${C_RESET}"
sep ; echo ""

[[ "${EUID}" -ne 0 ]] && { echo "  Requires root: sudo bash uninstall.sh"; exit 1; }

echo -e "  ${C_YELLOW}WARNING: Removes /opt/Viking-AI and all cloned tools.${C_RESET}"
echo -e "  ${C_YELLOW}Ollama and system packages will NOT be removed.${C_RESET}"
echo ""
read -rp "  Type CONFIRM to proceed: " c
[[ "${c}" != "CONFIRM" ]] && { echo "  Aborted."; exit 0; }

rm -f /usr/local/bin/vik && echo "  Removed: /usr/local/bin/vik"
rm -rf /opt/Viking-AI    && echo "  Removed: /opt/Viking-AI"

echo "" ; sep
echo -e "  ${C_BOLD_GREEN}Viking-AI removed. Skál, warrior.${C_RESET}"
echo ""
UNINSTSCRIPT

    chmod +x "${INSTALL_DIR}/uninstall.sh"
    print_ok "uninstall.sh generated"
}

# =============================================================================
# SYSTEM SYMLINK
# =============================================================================

create_system_symlink() {
    print_step "SYSTEM COMMAND REGISTRATION"

    rm -f "/usr/local/bin/vik" 2>/dev/null || true

    if ln -sf "${INSTALL_DIR}/start.sh" /usr/local/bin/vik; then
        print_ok "Command registered: vik (available system-wide)"
    else
        print_warn "Could not create /usr/local/bin/vik"
        print_info "Launch manually: bash ${INSTALL_DIR}/start.sh"
    fi
}

# =============================================================================
# LOG ROTATION CONFIG
# =============================================================================

setup_log_rotation() {
    print_step "LOG ROTATION"

    cat > "/etc/logrotate.d/viking-ai" << LOGROTCONF
${LOGS_DIR}/*.log {
    size 10M
    rotate 5
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
    olddir ${LOGS_DIR}/archive
}
LOGROTCONF

    print_ok "Log rotation configured"
}

# =============================================================================
# INSTALLATION VERIFICATION
# =============================================================================

verify_installation() {
    print_step "INSTALLATION VERIFICATION"

    local passed=0 failed=0

    local dirs=("${INSTALL_DIR}" "${CONFIG_DIR}" "${PROMPTS_DIR}" "${LOGS_DIR}" \
                "${ARSENAL_DIR}" "${TOOLS_DIR}")
    for d in "${dirs[@]}"; do
        if [[ -d "${d}" ]]; then print_ok "Dir: ${d##*/}" ; passed=$(( passed + 1 ))
        else print_error "Missing: ${d}" ; failed=$(( failed + 1 )); fi
    done

    local scripts=("start.sh" "repair.sh" "update.sh" "uninstall.sh" \
                   "arsenal/arsenal_manager.sh")
    for s in "${scripts[@]}"; do
        if [[ -f "${INSTALL_DIR}/${s}" && -x "${INSTALL_DIR}/${s}" ]]; then
            print_ok "Script: ${s##*/}" ; passed=$(( passed + 1 ))
        else
            print_error "Missing: ${s##*/}" ; failed=$(( failed + 1 ))
        fi
    done

    command -v ollama &>/dev/null \
        && { print_ok "Ollama: found"       ; passed=$(( passed + 1 )); } \
        || { print_error "Ollama: NOT FOUND" ; failed=$(( failed + 1 )); }

    curl -sf "${OLLAMA_API}/api/tags" &>/dev/null \
        && { print_ok "Ollama API: responsive" ; passed=$(( passed + 1 )); } \
        || print_warn "Ollama API: offline (may need manual start)"

    check_model_exists "${DEFAULT_MODEL}" 2>/dev/null \
        && { print_ok "Model: ${DEFAULT_MODEL}" ; passed=$(( passed + 1 )); } \
        || print_warn "Model: ${DEFAULT_MODEL} not confirmed yet"

    [[ -L "/usr/local/bin/vik" ]] \
        && { print_ok "Command: vik" ; passed=$(( passed + 1 )); } \
        || print_warn "vik not in /usr/local/bin"

    nl ; sep
    echo -e "  ${C_BOLD_GREEN}Passed: ${passed}${C_RESET}  ${C_BOLD_RED}Failed: ${failed}${C_RESET}"
    sep

    return "${failed}"
}

# =============================================================================
# MODE HANDLERS
# =============================================================================

run_repair_mode() {
    print_installer_header
    print_step "REPAIR MODE"
    if [[ -f "${INSTALL_DIR}/repair.sh" ]]; then
        bash "${INSTALL_DIR}/repair.sh"
    else
        print_warn "repair.sh not found — running inline repair..."
        create_directory_structure
        generate_config_files
        generate_prompt_files
        generate_start_script
        generate_arsenal_manager
        generate_repair_script
        generate_update_script
        generate_uninstall_script
        create_system_symlink
    fi
    exit 0
}

run_update_mode() {
    print_installer_header
    print_step "UPDATE MODE"
    if [[ -f "${INSTALL_DIR}/update.sh" ]]; then
        bash "${INSTALL_DIR}/update.sh"
    else
        print_error "update.sh not found. Run: sudo bash install.sh --repair"
    fi
    exit 0
}

# =============================================================================
# INSTALL SUMMARY
# =============================================================================

print_install_summary() {
    local elapsed=$(( $(date +%s) - SCRIPT_START_TIME ))

    nl
    echo -e "${C_GRAY}  ════════════════════════════════════════════════════════════${C_RESET}"
    echo -e "${C_BOLD_GREEN}"
    cat << 'SUMMARY'
    ╔══════════════════════════════════════════════════╗
    ║                                                  ║
    ║    ⚔  VIKING-AI INSTALLATION COMPLETE  ⚔        ║
    ║                                                  ║
    ╚══════════════════════════════════════════════════╝
SUMMARY
    echo -e "${C_RESET}"
    echo -e "  ${C_BOLD_GREEN}Install Dir:${C_RESET}   ${INSTALL_DIR}"
    echo -e "  ${C_BOLD_GREEN}Model:${C_RESET}         ${DEFAULT_MODEL}"
    echo -e "  ${C_BOLD_GREEN}Ollama API:${C_RESET}    ${OLLAMA_API}"
    echo -e "  ${C_BOLD_GREEN}Time:${C_RESET}          ${elapsed}s"
    nl
    echo -e "  ${C_BOLD_GREEN}Launch VIK:${C_RESET}"
    echo -e "  ${C_CYAN}    vik${C_RESET}                              ${C_GRAY}system command${C_RESET}"
    echo -e "  ${C_CYAN}    bash /opt/Viking-AI/start.sh${C_RESET}     ${C_GRAY}direct${C_RESET}"
    nl
    echo -e "  ${C_BOLD_GREEN}Maintenance:${C_RESET}"
    echo -e "  ${C_CYAN}    sudo bash ${INSTALL_DIR}/repair.sh${C_RESET}"
    echo -e "  ${C_CYAN}    sudo bash ${INSTALL_DIR}/update.sh${C_RESET}"
    echo -e "  ${C_CYAN}    sudo bash ${INSTALL_DIR}/uninstall.sh${C_RESET}"
    nl
    if [[ "${ERRORS_OCCURRED}" -eq 1 ]]; then
        print_warn "Some steps had warnings — check: ${LOG_FILE}"
    else
        print_ok "Clean installation — zero errors"
    fi
    echo -e "${C_GRAY}  ════════════════════════════════════════════════════════════${C_RESET}"
    echo -e "\n  ${C_BOLD_GREEN}Skál, warrior. VIK awaits your command.  ⚔${C_RESET}\n"
}

# =============================================================================
# MAIN ORCHESTRATOR
# =============================================================================

main() {
    parse_args "$@"
    _preinit_logs

    [[ "${REPAIR_MODE}" -eq 1 ]] && run_repair_mode
    [[ "${UPDATE_MODE}" -eq 1 ]] && run_update_mode

    # Full installation flow
    print_installer_header
    print_vik_banner

    print_info "Viking-AI v${VIKING_VERSION} :: ${VIKING_CODENAME}"
    nl

    check_root
    detect_distro
    create_directory_structure
    init_logging
    run_apt_operations
    check_dependencies
    generate_config_files
    generate_prompt_files
    generate_start_script
    generate_arsenal_manager
    generate_repair_script
    generate_update_script
    generate_uninstall_script
    install_ollama
    start_ollama_service
    check_ollama_api
    pull_default_model
    list_installed_models
    create_system_symlink
    setup_log_rotation
    verify_installation || true
    print_install_summary
}

# =============================================================================
# ENTRY POINT
# =============================================================================

main "$@"
