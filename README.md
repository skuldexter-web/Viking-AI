```
  ██╗   ██╗██╗██╗  ██╗██╗███╗   ██╗  ██████╗      █████╗ ██╗
  ██║   ██║██║██║ ██╔╝██║████╗  ██║ ██╔════╝     ██╔══██╗██║
  ██║   ██║██║█████╔╝ ██║██╔██╗ ██║ ██║  ███╗    ███████║██║
  ╚██╗ ██╔╝██║██╔═██╗ ██║██║╚██╗██║ ██║   ██║    ██╔══██║██║
   ╚████╔╝ ██║██║  ██╗██║██║ ╚████║ ╚██████╔╝    ██║  ██║██║
    ╚═══╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝  ╚═════╝     ╚═╝  ╚═╝╚═╝
```

<div align="center">

**Digital Longship Intelligence System**

*A fully local, AI-powered CLI security assistant for Kali Linux.*
*97 curated tools. War Mode. Zero cloud. 100% offline after install.*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Kali%20Linux-blue.svg)]()
[![AI](https://img.shields.io/badge/AI-Ollama%20Local-green.svg)]()
[![Tools](https://img.shields.io/badge/Arsenal-97%20Tools-red.svg)]()
[![Shell](https://img.shields.io/badge/Shell-Bash-lightgrey.svg)]()

*Questions? DM [@s.k.7.l.d](https://instagram.com/s.k.7.l.d) on Instagram*

</div>

-----

## What is VIKING AI?

VIKING AI is a local command-line intelligence system for penetration testers, security researchers, and red teamers running Kali Linux. It wraps a curated arsenal of 97 security tools inside a chatty AI assistant with a Norse warrior personality — powered entirely by [Ollama](https://ollama.com) with no cloud, no API keys, and no data leaving your machine.

You talk to it in plain English. It launches tools, runs scans with depth options, analyses output, and guides you through every phase of an engagement.

```
You: hey viking
VIKING: Ha! A warrior enters the longship. I am VIKING — cyber raider and
        digital berserker. Who are we hunting today?

You: scan 192.168.1.1

  Scan depth:
  [1]  Quick  — top 1000 ports  (fast)
  [2]  Medium — top 1000 + versions  (default)
  [3]  Full   — all 65535 ports + scripts  (slow)
  [1-3]: 2

[VIKING] Scouting: 192.168.1.1
... nmap output ...

  Save output to .txt file? [y/N]: y
  [OK] Saved: /root/viking_scans/nmap_192.168.1.1_20241201_143022.txt

  VIKING analyse output? [Y/n]: y
[VIKING] Analysing...
Port 22 open — SSH, try default creds with hydra.
Port 80 open — run nikto or gobuster next.
Recommend: gobuster dir -u http://192.168.1.1 -w /usr/share/wordlists/dirb/common.txt
```

-----

## Features

|Feature          |Detail                                                                         |
|-----------------|-------------------------------------------------------------------------------|
|Local AI brain   |tinyllama (default, ~600 MB), llama3.2:3b, or qwen2.5:3b                       |
|97 security tools|20 categories, curated — no redundant duplicates                               |
|Scan depth menus |Quick / Medium / Full for nmap, masscan, nikto, sqlmap, gobuster, wpscan, amass|
|Save output      |Every scan asks if you want results saved to `~/viking_scans/`                 |
|AI scan analysis |Every scan asks if VIKING should analyse and suggest next steps                |
|Persistent target|`target 192.168.1.1` — all tools use it automatically                          |
|War Mode         |Deploys all 97 tools in parallel with full red ASCII battle banner             |
|Tool auto-install|If a tool is missing, VIKING offers 3 install options                          |
|Tool dependencies|Tools auto-install their own pip/apt requirements                              |
|Update command   |`update` pulls the latest version from GitHub                                  |
|RTL-SDR support  |Flight radar (dump1090), sensor decode (rtl_433), FM radio, ham radio          |
|Streaming AI     |Tokens print as generated — no waiting for full responses                      |
|Model warm-up    |Model pre-loads on startup so first answer is instant                          |
|tmux integration |Persistent session — reconnect after SSH disconnect                            |
|Rick Roll        |Type `rick roll` and find out                                                  |

-----

## Requirements

|Requirement     |Notes                                        |
|----------------|---------------------------------------------|
|Kali Linux      |Debian/Ubuntu/Parrot also work               |
|Root access     |`sudo bash install.sh`                       |
|1 GB RAM minimum|2 GB+ recommended for llama3.2:3b            |
|Internet        |During install only — fully offline after    |
|~2-10 GB disk   |Depends on how many arsenal tools you install|

-----

## Installation

```bash
git clone https://github.com/skuldexter-web/Viking-AI.git
cd Viking-AI
sudo bash install.sh
```

The installer runs 7 steps automatically:

```
[STEP 1]  Install system dependencies
[STEP 2]  Install and start Ollama
[STEP 3]  Pull default AI model (tinyllama)
[STEP 4]  Generate arsenal registry and menu
[STEP 5]  Install the viking command
[STEP 6]  Configure tmux auto-session
[STEP 7]  Arsenal setup wizard
```

At step 7, choose your install mode:

```
  [1]  VIKING CLI + AI only     (no extra tools)
  [2]  Pick tools from arsenal  (enter numbers like: 1 4 11 28)
  [3]  WAR MODE                 (install all 97 tools in parallel)
  [4]  Skip
```

-----

## Starting VIKING

```bash
viking
```

The Viking ship banner and WELCOME WARRIOR message appear. The AI model warms up in the background while you read it.

```
    o==========o==========||==========o==========o
  (O) (O) (O) (O)~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~(O) (O) (O) (O)
         ___ ______________________________________________________ ___
        /  ooo  ooo  ooo  ooo  ooo  ooo  ooo  ooo  ooo  ooo  ooo  \
       /______________________________________________________\

  ██╗   ██╗██╗██╗  ██╗██╗███╗   ██╗  ██████╗      █████╗ ██╗
  ...

  WELCOME WARRIOR
  WARRIOR
  The longship is crewed. What is the target?
```

-----

## Commands

### Target Memory

Lock a target once — every tool uses it automatically without retyping.

```
You: target 192.168.1.1
[OK] Target locked: 192.168.1.1

You: scan
[VIKING] Scouting: 192.168.1.1   <-- uses locked target automatically

You: target clear
[OK] Target cleared
```

The prompt also shows your active target:

```
You[192.168.1.1]:
```

### Scanning

|Command         |What it does                      |
|----------------|----------------------------------|
|`scan <ip/url>` |nmap with depth menu + AI analysis|
|`masscan <ip>`  |fast port scan (rate options)     |
|`rustscan <ip>` |ultra-fast Rust port scanner      |
|`naabu <ip>`    |fast port discovery               |
|`nuclei <url>`  |CVE template scan                 |
|`nikto <url>`   |web vulnerability scan            |
|`ping <ip>`     |basic connectivity probe          |
|`whois <domain>`|WHOIS lookup                      |

### Web Attacks

|Command               |What it does                             |
|----------------------|-----------------------------------------|
|`gobuster <url>`      |directory brute force (3 wordlist depths)|
|`ffuf <url>`          |fast fuzzer                              |
|`feroxbuster <url>`   |recursive directory scan                 |
|`dirsearch <url>`     |directory search                         |
|`sqlmap <url>`        |SQL injection (3 risk levels)            |
|`commix <url>`        |command injection                        |
|`wpscan <url>`        |WordPress scan (basic or full)           |
|`xsstrike <url>`      |XSS scanner                              |
|`dalfox <url>`        |XSS fuzzer                               |
|`katana <url>`        |web crawler                              |
|`waybackurls <domain>`|historical URL discovery                 |
|`gau <domain>`        |all URLs (multi-source)                  |
|`hakrawler <url>`     |fast web crawler                         |
|`arjun <url>`         |HTTP parameter discovery                 |

### OSINT

|Command                |What it does                         |
|-----------------------|-------------------------------------|
|`theharvester <domain>`|email, host, and URL recon           |
|`amass <domain>`       |subdomain mapping (passive or active)|
|`subfinder <domain>`   |passive subdomain discovery          |
|`recon-ng`             |modular recon framework              |
|`spiderfoot`           |automated OSINT (web UI on port 5001)|
|`sherlock <username>`  |username hunt across platforms       |
|`holehe <email>`       |email account existence checker      |
|`maigret <username>`   |username + full profile OSINT        |
|`blackbird <username>` |social media account finder          |
|`phoneinfoga`          |phone number OSINT                   |
|`ghunt`                |Google account OSINT                 |
|`shodan`               |internet-connected device search     |
|`trufflehog`           |find secrets in git repositories     |

### Wireless

|Command      |What it does                   |
|-------------|-------------------------------|
|`wifite`     |automated wireless attack suite|
|`oneshot`    |WPS and PMKID attacks          |
|`wifiphisher`|evil twin access point         |
|`fluxion`    |WPA handshake capture          |
|`bettercap`  |MITM + wireless attacks        |
|`aircrack-ng`|WPA/WEP cracking suite         |
|`hcxdumptool`|PMKID/EAPOL capture            |
|`eaphammer`  |WPA Enterprise EAP attacks     |

### Bluetooth

|Command      |What it does                 |
|-------------|-----------------------------|
|`bluepot`    |Bluetooth honeypot           |
|`btlejack`   |BLE sniffing and hijacking   |
|`bluesnarfer`|Bluetooth file access attacks|

### Active Directory

|Command        |What it does                |
|---------------|----------------------------|
|`netexec`      |AD Swiss Army knife         |
|`responder`    |LLMNR/NTLMv2 capture        |
|`bloodhound`   |AD attack path mapping      |
|`bloodhound.py`|Python AD data ingestor     |
|`certipy`      |AD Certificate Services enum|
|`mitm6`        |IPv6/AD MITM attacks        |
|`impacket`     |Full impacket suite guidance|

### Exploitation

|Command         |What it does                   |
|----------------|-------------------------------|
|`metasploit`    |launch msfconsole              |
|`sliver`        |Sliver C2 framework            |
|`havoc`         |Havoc C2 framework             |
|`empire`        |PowerShell Empire              |
|`msfpc`         |MSFvenom payload creator       |
|`venom`         |shellcode generator            |
|`thefatrat`     |automated payload generation   |
|`netcat`        |reverse and bind shell guidance|
|`hydra`         |online brute force guidance    |
|`hashcat`       |GPU hash cracking guidance     |
|`john`          |John the Ripper guidance       |
|`name-that-hash`|identify unknown hash types    |

### Post Exploitation

|Command  |What it does                      |
|---------|----------------------------------|
|`linpeas`|Linux privilege escalation checker|
|`pspy`   |monitor processes without root    |

### Phishing

|Command     |What it does                     |
|------------|---------------------------------|
|`setoolkit` |Social Engineer Toolkit          |
|`evilginx`  |reverse proxy credential phishing|
|`gophish`   |phishing campaign management     |
|`socialfish`|credential harvesting pages      |
|`zphisher`  |automated phishing page toolkit  |

### RTL-SDR Radio

|Command   |What it does                             |
|----------|-----------------------------------------|
|`dump1090`|ADS-B flight radar (needs RTL-SDR dongle)|
|`rtl_433` |decode IoT / weather / sensor signals    |
|`hamradio`|FM radio, multimon-ng, kalibrate menu    |
|`rtl-sdr` |dongle setup guide and tool overview     |

### Anonymity

|Command   |What it does                 |
|----------|-----------------------------|
|`anonsurf`|route all traffic through Tor|
|`multitor`|multiple Tor circuits        |

### System & Tool Management

|Command          |What it does                             |
|-----------------|-----------------------------------------|
|`open <tool>`    |open any tool by name                    |
|`launch <tool>`  |same as open                             |
|`run <tool>`     |same as open                             |
|`start <tool>`   |same as open                             |
|`arsenal`        |browse and install tools                 |
|`model`          |list and switch AI models                |
|`model <name>`   |quick switch                             |
|`target <ip/url>`|lock active target                       |
|`target clear`   |clear locked target                      |
|`status`         |show model, target, Ollama status        |
|`update`         |pull latest Viking AI version from GitHub|
|`history`        |view session log                         |
|`banner`         |redraw the ship banner                   |
|`help`           |full command reference                   |
|`quit` / `exit`  |leave VIKING                             |

-----

## Open / Launch / Run Any Tool

VIKING understands any tool name regardless of how you type it:

```
You: open xsstrike
You: launch theHarvester
You: run bloodhound
You: start sqlmap
You: open wifite
```

If the tool is installed, it launches immediately. If not:

```
  [!] Could not launch: xsstrike

  [1]  Install via arsenal
  [2]  Quick install: sudo apt install ...
  [3]  Show me how to install it manually
  [4]  Skip
```

Over 120 name variants are recognized — `theharvester`, `the-harvester`, `harvester`, `theHarvester` all resolve to the same tool.

-----

## Scan Output — Save and Analyse

Every scan offers two questions at the end:

```
  Save output to .txt file? [y/N]: y
  [OK] Saved: /root/viking_scans/nmap_192.168.1.1_20241201_143022.txt

  VIKING analyse output? [Y/n]: y
  Port 22 open — SSH. Try: hydra -l root -P rockyou.txt ssh://192.168.1.1
  Port 443 open — HTTPS. Try: nikto -h https://192.168.1.1
```

All scan results are saved to `~/viking_scans/` with timestamps.

-----

## Wapens Arsenal

Type `arsenal` to browse the interactive tool menu.

```
  [*]  WEAPONS ARSENAL

    -- Active Directory --
  [092]  netexec                          [installed]
  [093]  responder

    -- Bluetooth --
  [038]  bluepot
  [140]  btlejack
  [141]  bluesnarfer

    -- Web Scanning --
  [083]  commix
  [084]  wpscan                           [installed]
  ...

  number -> install  |  war -> all tools  |  back -> return

arsenal> 93
[~] apt install: responder
[OK] responder installed via apt
```

If apt fails, VIKING automatically falls back to git clone and builds from source.

-----

## Arsenal Categories

|Category              |Tools                                                                                                                   |
|----------------------|------------------------------------------------------------------------------------------------------------------------|
|Active Directory      |netexec, responder, impacket, bloodhound, certipy, BloodHound.py, mitm6                                                 |
|Anonymity             |kali-anonsurf, multitor                                                                                                 |
|Bluetooth             |bluepot, btlejack, bluesnarfer                                                                                          |
|C2 Frameworks         |metasploit, sliver, havoc, empire                                                                                       |
|Exploitation          |bulk_extractor, TheFatRat, msfpc, venom                                                                                 |
|Lab & Training        |vulhub                                                                                                                  |
|Network Tools         |nmap, masscan, RustScan, httpx, subfinder, naabu, dnsx                                                                  |
|OSINT                 |holehe, maigret, trufflehog, sherlock, phoneinfoga, GHunt, shodan, censys, blackbird                                    |
|Password Cracking     |hashcat, john, hydra, name-that-hash                                                                                    |
|Phishing              |SET, SocialFish, evilginx2, gophish, zphisher                                                                           |
|Post Exploitation     |PEASS-ng, pspy                                                                                                          |
|RTL-SDR Radio         |rtl-sdr, dump1090, rtl_433, gqrx, gnuradio, multimon-ng, kalibrate-rtl, urh                                             |
|SQL Injection         |sqlmap, NoSQLMap, DSSS                                                                                                  |
|Scanning & Recon      |WebCheck, RED_HAWK, theHarvester, spiderfoot, amass, recon-ng, findomain                                                |
|Vulnerability Scanning|nuclei                                                                                                                  |
|Web Scanning          |commix, wpscan, ffuf, gobuster, dirsearch, feroxbuster, katana, waybackurls, gau, hakrawler, jaeles, arjun              |
|Web Tools             |SecretFinder, takeover                                                                                                  |
|WiFi Tools            |OneShot, wifipumpkin3, pixiewps, fluxion, wifiphisher, wifite2, aircrack-ng, bettercap, hcxdumptool, hcxtools, eaphammer|
|Wordlist              |cupp, SecLists                                                                                                          |
|XSS Tools             |dalfox, XSpear, XSStrike                                                                                                |

**97 tools total — no duplicates, no redundant entries.**

-----

## War Mode

Type `war` inside the arsenal menu or choose option 3 during install:

```
  ██╗    ██╗ █████╗ ██████╗     ███╗   ███╗ ██████╗ ██████╗ ███████╗
  ...

  [!]  DEPLOYING FULL WEAPON ARSENAL - ALL TOOLS INCOMING  [!]

[WAR  1/97] Deploying: WebCheck
[WAR  2/97] Deploying: RED_HAWK
...
[###################################.......] 82/97

  WAR COMPLETE - 97 WEAPONS DEPLOYED
```

4 tools install in parallel. Each tool tries apt first, falls back to git clone on failure. Failed installs are logged to `/opt/viking/logs/`.

-----

## AI Models

All 3 models run under 3 GB RAM.

|#|Model        |RAM  |Best for                          |
|-|-------------|-----|----------------------------------|
|1|`tinyllama`  |~1 GB|Default — instant responses       |
|2|`llama3.2:3b`|~2 GB|Better reasoning                  |
|3|`qwen2.5:3b` |~2 GB|Stronger code and security context|

Switch live from inside VIKING:

```
You: model

  [*]  AVAILABLE MODELS

  [1]  tinyllama       <- active  [installed]
  [2]  llama3.2:3b
  [3]  qwen2.5:3b

model> 2
[VIKING] Pulling llama3.2:3b...
[VIKING] Active: llama3.2:3b
```

Your choice is saved and persists between sessions.

-----

## Updating

```
You: update
```

VIKING checks GitHub for a newer version, shows the version diff, and asks before applying:

```
  Current : 2.1.0
  Remote  : 2.2.0

  Update to v2.2.0? [Y/n]: y
```

-----

## tmux Integration

VIKING auto-configures a persistent tmux session on install.

```bash
# Start
tmux new -s viking
viking

# Detach — session keeps running in background
Ctrl+B then D

# Reconnect later
tmux attach -t viking
```

Your session survives SSH disconnects.

-----

## File Structure

```
/usr/local/bin/viking            <- the viking command
/opt/viking/
  config                         <- saved model and target
  arsenal_registry.sh            <- auto-generated tool registry
  arsenal_menu.sh                <- interactive tool browser
  .current_target                <- locked target persistence
  arsenal/                       <- all cloned tools
    sqlmap/
    XSStrike/
    theHarvester/
    ...
  logs/                          <- war mode install logs
~/viking_scans/                  <- all saved scan output
~/.viking_history.log            <- session log
```

-----

## How It Works

```
You type a message
        |
  [ Built-in exact match ]  -->  help, banner, status, quit
        |
  [ Tool keyword match ]    -->  Direct execution (nmap, sqlmap, wifite...)
        |                        No AI latency — runs immediately
  [ open/launch/run ]       -->  Name resolution -> launch_tool()
        |
  [ Ollama REST API ]       -->  stream:true, num_ctx:512
        |                        Tokens print as generated
  [ ~/viking_scans/ ]       -->  Save output if user says yes
```

**Why it is fast:** The Ollama REST API (`localhost:11434/api/chat`) keeps the model resident in memory between questions. `stream:true` means you see the first word in under a second. `num_ctx:512` cuts KV cache size to minimize time-to-first-token on small models. The model pre-warms in the background while the banner displays.

**Why tool handlers run before AI:** Every recognized tool keyword is caught by pattern matching and executed directly. The AI is only called for output analysis, guidance questions, and fallback — meaning tool execution has zero AI latency.

-----

## Legal

VIKING AI is built for **authorized penetration testing, CTF competitions, security research, and educational use only.**

Only use these tools on systems you own or have explicit written permission to test. The authors take no responsibility for illegal or unauthorized use. Always comply with the laws of your jurisdiction.

-----

## Contributing

To add a tool to the arsenal, add one line to the `ARSENAL` array in `install.sh`:

```bash
ARSENAL[142]="toolname|Category|https://github.com/user/repo.git|git_python"
```

Install types:

|Type             |Behaviour                                         |
|-----------------|--------------------------------------------------|
|`git_python`     |git clone + pip install requirements.txt          |
|`git_go`         |git clone + go build                              |
|`git_generic`    |git clone + tries Makefile / setup.sh / install.sh|
|`apt_install:pkg`|apt install, falls back to git clone on failure   |
|`pip_install:pkg`|pip3 install, falls back to git clone on failure  |

The registry and menu are auto-generated from the array — no other files need editing.

-----

## License

MIT — see <LICENSE> for details.

-----

<div align="center">

*The longship is ready. Type* `viking` *to sail.*

**DM [@s.k.7.l.d](https://instagram.com/s.k.7.l.d) on Instagram for questions.**

</div>
