<div align="center">

```
██╗   ██╗██╗██╗  ██╗██╗███╗   ██╗ ██████╗      █████╗ ██╗
██║   ██║██║██║ ██╔╝██║████╗  ██║██╔════╝     ██╔══██╗██║
██║   ██║██║█████╔╝ ██║██╔██╗ ██║██║  ███╗    ███████║██║
╚██╗ ██╔╝██║██╔═██╗ ██║██║╚██╗██║██║   ██║    ██╔══██║██║
 ╚████╔╝ ██║██║  ██╗██║██║ ╚████║╚██████╔╝    ██║  ██║██║
  ╚═══╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝  ╚═╝╚═╝
```

# Viking-AI — Weapons Arsenal

**Automated deployment framework for security tooling, cyber reconnaissance, and penetration testing orchestration.**

[![Platform](https://img.shields.io/badge/Platform-Kali%20Linux-blue?style=flat-square&logo=linux)](https://www.kali.org/)
[![Shell](https://img.shields.io/badge/Shell-Bash%205%2B-lightgrey?style=flat-square&logo=gnubash)](https://www.gnu.org/software/bash/)
[![AI](https://img.shields.io/badge/AI-Ollama%20Local-green?style=flat-square)](https://ollama.com)
[![Arsenal](https://img.shields.io/badge/Arsenal-100%2B%20Tools-red?style=flat-square)](https://github.com/skuldexter-web/Viking-AI)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)
[![Use](https://img.shields.io/badge/Use-Authorized%20Testing%20Only-orange?style=flat-square)]()

*Questions? DM [@s.k.7.l.d](https://instagram.com/s.k.7.l.d) on Instagram*

</div>

-----

## Overview

**Viking-AI** is a fully local, AI-powered CLI security assistant built for Kali Linux. It combines a conversational Norse warrior AI personality with a modular tactical toolkit — the **Weapons Arsenal** — that automates the deployment of 100+ industry-standard security tools across 15 operational categories.

The system runs entirely offline after installation. No cloud dependency, no API keys, no telemetry. The AI brain runs on [Ollama](https://ollama.com) with models as small as 600 MB.

-----

## Architecture Highlights

|Feature              |Detail                                                 |
|---------------------|-------------------------------------------------------|
|**Local AI**         |Ollama-powered (tinyllama / llama3.2:3b / qwen2.5:3b)  |
|**Modular Arsenal**  |15 categories, each independently navigable            |
|**Dynamic Submenus** |Every category renders its tools numbered from `[1]`   |
|**WARMODE**          |Option `[16]` — deploys all 100+ tools sequentially    |
|**Smart Installer**  |apt → pip → git clone fallback chain per tool          |
|**Scan Depth Menus** |Quick / Medium / Full for every major scan type        |
|**AI Scan Analysis** |Feeds tool output to the AI for tactical interpretation|
|**Persistent Target**|Lock a target once — all tools use it automatically    |
|**Auto Update**      |`update` command pulls the latest version from GitHub  |
|**tmux Integration** |Persistent sessions survive SSH disconnects            |

-----

## Quick Start

```bash
# Clone the repository
git clone https://github.com/skuldexter-web/Viking-AI.git
cd Viking-AI

# Run the installer as root
chmod +x install.sh
sudo ./install.sh
```

The installer runs 7 automated steps:

```
[STEP 1]  Install system dependencies (git, python3, golang, nmap, etc.)
[STEP 2]  Install and start Ollama
[STEP 3]  Pull default AI model (tinyllama)
[STEP 4]  Generate the Arsenal registry and menu
[STEP 5]  Install the viking command to /usr/local/bin/viking
[STEP 6]  Configure tmux auto-session
[STEP 7]  Arsenal setup wizard
```

At step 7 you choose your deployment mode:

```
  [1]  VIKING CLI + AI only       (no extra tools)
  [2]  Pick tools from arsenal    (enter category and tool numbers)
  [3]  WAR MODE                   (install all 100+ tools in parallel)
  [4]  Skip
```

After install:

```bash
viking
```

-----

## Using the Arsenal

From inside VIKING, open the Arsenal at any time:

```
You: arsenal
```

The main menu renders:

```
  ══════════════════════════════════════════════════════
             VIKING AI -- WEAPONS ARSENAL
  ══════════════════════════════════════════════════════

  [ 1]  SCANNING & RECON
  [ 2]  NETWORK TOOLS
  [ 3]  WEB & VULNERABILITY SCANNING
  [ 4]  XSS TOOLS
  [ 5]  SQL INJECTION
  [ 6]  WIFI & BLUETOOTH TOOLS
  [ 7]  ANONYMITY
  [ 8]  OSINT (OPEN SOURCE INTELLIGENCE)
  [ 9]  EXPLOITATION & C2 FRAMEWORKS
  [10]  ACTIVE DIRECTORY
  [11]  PASSWORD CRACKING & WORDLISTS
  [12]  PHISHING
  [13]  POST EXPLOITATION
  [14]  RTL-SDR & RADIO TOOLS
  [15]  ADDITIONAL DEPENDENCIES & TRAINING LABS

  [16]  WARMODE  --  DEPLOY ALL WEAPONS

   [0]  Exit Arsenal
```

### Selecting a Category

Entering a category number opens its submenu:

```
  ══════════════════════════════════════════════════════
  VIKING AI ARSENAL  --  6. WIFI & BLUETOOTH TOOLS
  ══════════════════════════════════════════════════════

  [01]  OneShot
  [02]  wifipumpkin3
  [03]  pixiewps
  [04]  bluepot                    [installed]
  [05]  btlejack
  [06]  bluesnarfer
  [07]  fluxion
  [08]  wifiphisher
  [09]  wifite2
  [10]  aircrack-ng                [installed]
  [11]  bettercap
  [12]  hcxdumptool
  [13]  hcxtools
  [14]  eaphammer

  ────────────────────────────────────────────────────
  [A]  Install ALL tools in this category
  [B]  Back to main menu
  ────────────────────────────────────────────────────

  Select (1-14, A, or B):
```

- Enter a **number** to install a single tool standalone.
- Enter **A** to install every tool in the category at once.
- Enter **B** to return to the main menu.

### WARMODE

Selecting `[16]` from the main menu triggers WARMODE:

```
  ██╗    ██╗ █████╗ ██████╗     ███╗   ███╗ ██████╗ ██████╗ ███████╗
  ...

  WARNING: ENTERING WARMODE -- DEPLOYING ALL WEAPONS

  [WAR 1/100]  WebCheck
  [WAR 2/100]  RED_HAWK
  ...
  [#################################################.] 98/100

  WAR COMPLETE -- 100 / 100 WEAPONS DEPLOYED
```

WARMODE loops through all 15 categories sequentially without any further user input. Each tool uses the smart installer — apt first, pip second, git clone fallback. Failed installs are logged to `/opt/viking/logs/` and reported in the summary.

-----

## Arsenal — Complete Tool Registry

### [1] Scanning & Recon

|#|Tool        |Purpose                            |
|-|------------|-----------------------------------|
|1|WebCheck    |Web target information gathering   |
|2|RED_HAWK    |Multi-source recon and footprinting|
|3|theHarvester|Email, host, and URL harvesting    |
|4|spiderfoot  |Automated OSINT framework          |
|5|amass       |Subdomain and ASN mapping          |
|6|recon-ng    |Modular recon framework            |
|7|findomain   |Fast passive subdomain discovery   |

### [2] Network Tools

|#|Tool     |Purpose                            |
|-|---------|-----------------------------------|
|1|nmap     |Port scanning and service detection|
|2|masscan  |Ultra-fast mass port scanner       |
|3|RustScan |Rust-powered port scanner          |
|4|httpx    |Web probe and HTTP categorization  |
|5|subfinder|Passive subdomain discovery        |
|6|naabu    |Fast port discovery                |
|7|dnsx     |DNS resolution and brute force     |

### [3] Web & Vulnerability Scanning

|# |Tool        |Purpose                             |
|--|------------|------------------------------------|
|1 |SecretFinder|API keys and secrets in JS          |
|2 |waybackurls |Historical URL discovery            |
|3 |gau         |All URLs from multiple sources      |
|4 |hakrawler   |Fast web crawler                    |
|5 |takeover    |Subdomain takeover detection        |
|6 |commix      |Command injection automation        |
|7 |wpscan      |WordPress vulnerability scanner     |
|8 |ffuf        |Fast web fuzzer                     |
|9 |gobuster    |Directory and DNS brute force       |
|10|dirsearch   |Directory and file brute force      |
|11|feroxbuster |Recursive content discovery         |
|12|katana      |Next-gen web crawler                |
|13|jaeles      |Automated web testing framework     |
|14|arjun       |HTTP parameter discovery            |
|15|nuclei      |Template-based vulnerability scanner|

### [4] XSS Tools

|#|Tool    |Purpose                           |
|-|--------|----------------------------------|
|1|dalfox  |XSS parameter analysis and fuzzing|
|2|XSpear  |Reflected XSS scanner             |
|3|XSStrike|XSS detection suite               |

### [5] SQL Injection

|#|Tool    |Purpose                |
|-|--------|-----------------------|
|1|sqlmap  |Automated SQL injection|
|2|NoSQLMap|NoSQL injection attacks|
|3|DSSS    |Damn Small SQLi Scanner|

### [6] WiFi & Bluetooth Tools

|# |Tool        |Purpose                          |
|--|------------|---------------------------------|
|1 |OneShot     |WPS and PMKID attacks            |
|2 |wifipumpkin3|Evil twin and MitM framework     |
|3 |pixiewps    |Pixie Dust WPS attack            |
|4 |bluepot     |Bluetooth honeypot               |
|5 |btlejack    |BLE sniffing and hijacking       |
|6 |bluesnarfer |Bluetooth file access attacks    |
|7 |fluxion     |WPA handshake capture            |
|8 |wifiphisher |Evil twin phishing AP            |
|9 |wifite2     |Automated wireless attack suite  |
|10|aircrack-ng |WPA/WEP cracking suite           |
|11|bettercap   |Network MitM and wireless attacks|
|12|hcxdumptool |PMKID and EAPOL capture          |
|13|hcxtools    |Capture file conversion          |
|14|eaphammer   |WPA Enterprise EAP attacks       |

### [7] Anonymity

|#|Tool         |Purpose                      |
|-|-------------|-----------------------------|
|1|kali-anonsurf|Route all traffic through Tor|
|2|multitor     |Multiple Tor exit circuits   |

### [8] OSINT

|#|Tool       |Purpose                         |
|-|-----------|--------------------------------|
|1|holehe     |Email account existence checker |
|2|maigret    |Username OSINT and profiling    |
|3|trufflehog |Secrets in git repositories     |
|4|sherlock   |Username hunt across platforms  |
|5|phoneinfoga|Phone number OSINT              |
|6|GHunt      |Google account OSINT            |
|7|shodan     |Internet-connected device search|
|8|censys     |Internet scan data platform     |
|9|blackbird  |Social media account finder     |

### [9] Exploitation & C2 Frameworks

|#|Tool          |Purpose                            |
|-|--------------|-----------------------------------|
|1|bulk_extractor|Forensic artifact extraction       |
|2|TheFatRat     |Backdoor and payload generation    |
|3|msfpc         |MSFvenom payload creator           |
|4|venom         |Shellcode and payload generator    |
|5|metasploit    |Industry-standard exploit framework|
|6|sliver        |Modern cross-platform C2           |
|7|havoc         |Advanced post-exploitation C2      |
|8|empire        |PowerShell post-exploitation       |

### [10] Active Directory

|#|Tool         |Purpose                            |
|-|-------------|-----------------------------------|
|1|netexec      |AD Swiss Army knife                |
|2|responder    |LLMNR/NTLMv2 poisoning and capture |
|3|impacket     |AD attack protocol suite           |
|4|bloodhound   |AD attack path mapping             |
|5|certipy      |AD Certificate Services enumeration|
|6|BloodHound.py|Python AD data ingestor            |
|7|mitm6        |IPv6 and DHCPv6 MitM for AD        |

### [11] Password Cracking & Wordlists

|#|Tool          |Purpose                          |
|-|--------------|---------------------------------|
|1|hashcat       |GPU-accelerated hash cracking    |
|2|john          |John the Ripper CPU cracking     |
|3|hydra         |Online brute force tool          |
|4|name-that-hash|Hash type identification         |
|5|cupp          |Custom wordlist generation       |
|6|SecLists      |Comprehensive wordlist collection|

### [12] Phishing

|#|Tool      |Purpose                         |
|-|----------|--------------------------------|
|1|SET       |Social Engineer Toolkit         |
|2|SocialFish|Credential harvesting pages     |
|3|evilginx2 |Reverse proxy phishing framework|
|4|gophish   |Phishing campaign management    |
|5|zphisher  |Automated phishing page toolkit |

### [13] Post Exploitation

|#|Tool    |Purpose                           |
|-|--------|----------------------------------|
|1|PEASS-ng|Linux/Windows privilege escalation|
|2|pspy    |Process monitoring without root   |

### [14] RTL-SDR & Radio Tools

|#|Tool         |Purpose                        |
|-|-------------|-------------------------------|
|1|rtl-sdr      |RTL-SDR driver and utilities   |
|2|dump1090     |ADS-B flight radar             |
|3|rtl_433      |IoT and sensor signal decoder  |
|4|gqrx         |SDR receiver with spectrum view|
|5|gnuradio     |Signal processing toolkit      |
|6|multimon-ng  |Digital signal decoder         |
|7|kalibrate-rtl|GSM clock offset measurement   |
|8|urh          |Universal Radio Hacker         |

### [15] Additional Dependencies & Training Labs

|#|Tool       |Purpose                       |
|-|-----------|------------------------------|
|1|assetfinder|Subdomain and asset discovery |
|2|bombardier |HTTP benchmarking tool        |
|3|vulhub     |Vulnerable Docker environments|

### [16] WARMODE

> **Deploy all 100+ tools across all 15 categories sequentially — no further input required.**

-----

## Smart Installer Logic

Every tool in the Arsenal uses a three-tier installation chain:

```
1. apt-get install <package>          (fastest, system-managed)
         |
         v (if apt fails or package unavailable)
2. pip3 install <package>             (Python tools)
         |
         v (if pip fails)
3. git clone <url>                    (always available fallback)
   + pip install requirements.txt    (for Python tools)
   + go build ./...                   (for Go tools)
   + make / setup.sh / install.sh    (for generic tools)
```

All install output is logged to `/opt/viking/logs/install_<toolname>.log` for post-deployment audit.

-----

## Viking AI Commands

Once inside the interactive prompt, VIKING understands plain English:

```
You: scan 192.168.1.1          → nmap with depth menu + AI analysis
You: gobuster http://target    → directory brute force
You: sqlmap http://target      → SQL injection with risk levels
You: open bloodhound           → launches BloodHound
You: launch wifite             → launches wifite2
You: arsenal                   → opens the Weapons Arsenal
You: target 192.168.1.1        → locks the target for all tools
You: update                    → pulls latest version from GitHub
You: model llama3.2:3b         → switches AI model live
You: rick roll                 → you deserve what happens next
```

After every scan:

```
  Save output to .txt file? [y/N]:
  VIKING analyse output?    [Y/n]:
```

Results are saved to `~/viking_scans/` with timestamps.

-----

## File Structure

```
/usr/local/bin/viking              ← main command
/opt/viking/
  config                           ← saved model and target
  arsenal_menu.sh                  ← the Weapons Arsenal
  arsenal_registry.sh              ← tool registry (auto-generated)
  .current_target                  ← persistent target lock
  arsenal/                         ← all installed tools
    sqlmap/
    XSStrike/
    theHarvester/
    ...
  logs/                            ← install logs per tool
~/viking_scans/                    ← all saved scan output
~/.viking_history.log              ← session log
```

-----

## AI Models

|Model                  |RAM  |Best Use                        |
|-----------------------|-----|--------------------------------|
|`tinyllama` *(default)*|~1 GB|Fastest — works on any machine  |
|`llama3.2:3b`          |~2 GB|Better reasoning and detail     |
|`qwen2.5:3b`           |~2 GB|Strong code and security context|

Switch models live:

```
You: model 2
```

-----

## Requirements

|Requirement|Notes                                      |
|-----------|-------------------------------------------|
|OS         |Kali Linux (Debian/Ubuntu/Parrot also work)|
|Access     |Root — `sudo ./install.sh`                 |
|RAM        |1 GB minimum, 2 GB+ recommended            |
|Disk       |2–15 GB depending on tools installed       |
|Internet   |Required during install only               |

-----

## Legal

Viking-AI is built for **authorized penetration testing, CTF competitions, security research, and educational use only.**

Only use these tools against systems you own or have explicit written permission to test. The authors assume no liability for unauthorized or illegal use. You are solely responsible for complying with the laws of your jurisdiction.

-----

## Contributing

Adding a new tool to the Arsenal requires one line in `install.sh`:

```bash
# In the relevant CAT array inside write_arsenal_menu():
"toolname|https://github.com/user/repo.git|git_python"
```

Install type reference:

|Type         |Behaviour                               |
|-------------|----------------------------------------|
|`git_python` |clone → pip install requirements.txt    |
|`git_go`     |clone → go build ./…                    |
|`git_generic`|clone → Makefile / setup.sh / install.sh|
|`apt:pkg`    |apt-get install, falls back to git      |
|`pip:pkg`    |pip3 install, falls back to git         |

-----

## License

MIT — see <LICENSE> for full terms.

-----

<div align="center">

*The longship is ready. Type* `viking` *to sail.*

**[@s.k.7.l.d](https://instagram.com/s.k.7.l.d) — DM for questions**

</div>
