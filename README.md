```
  ██╗   ██╗██╗██╗  ██╗██╗███╗   ██╗ ██████╗      █████╗ ██╗
  ██║   ██║██║██║ ██╔╝██║████╗  ██║██╔════╝     ██╔══██╗██║
  ██║   ██║██║█████╔╝ ██║██╔██╗ ██║██║  ███╗    ███████║██║
  ╚██╗ ██╔╝██║██╔═██╗ ██║██║╚██╗██║██║   ██║    ██╔══██║██║
   ╚████╔╝ ██║██║  ██╗██║██║ ╚████║╚██████╔╝    ██║  ██║██║
    ╚═══╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝  ╚═╝╚═╝
```

<div align="center">

**Digital Longship Intelligence System**

*A fully local, AI-powered CLI security assistant for Kali Linux.*
*113 hacking tools. War Mode. Zero cloud dependency.*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Kali%20Linux-blue.svg)]()
[![AI](https://img.shields.io/badge/AI-Ollama%20Local-green.svg)]()
[![Tools](https://img.shields.io/badge/Arsenal-103%20Tools-red.svg)]()
[![Shell](https://img.shields.io/badge/Shell-Bash-lightgrey.svg)]()

</div>

---

## What is VIKING AI?

VIKING AI is a local command-line assistant with the personality of a Norse cyber warrior. It runs entirely on your machine using [Ollama](https://ollama.com) — no internet connection required after install, no API keys, no data leaving your system.

You talk to it in plain English. It launches tools, runs scans, analyses output, writes code, and guides you through attacks. VIKING is chatty and in character — ask it how it is, what it can do, or name a target and it plans the raid.

```
You: hey viking
VIKING: Ha! A warrior enters the longship. I am VIKING - cyber raider and digital berserker.
        Who are we hunting today?

You: scan 192.168.1.1
[VIKING] Scouting: 192.168.1.1
... nmap runs ...
[VIKING] Raid report:
Port 22 open - SSH, potential brute force target. Port 80 open - run nikto next.
COMMAND: nikto -h 192.168.1.1
Want me to dig deeper once we have results?

You: launch xsstrike http://target.com
[VIKING] Launching: XSStrike http://target.com
...
```

---

## Features

- **Local AI brain** — tinyllama by default (600 MB, runs on 1 GB RAM), switchable to llama3.2:3b or qwen2.5:3b
- **113 security tools** — organized into 11 categories, installed via apt, pip, or git automatically
- **Smart install fallback** — if apt fails, Viking automatically falls back to git clone and builds from source
- **Wapens Arsenal** — numbered interactive menu to browse and install individual tools live from the CLI
- **War Mode** — deploy all 103 tools in parallel with a full red ASCII battle banner
- **Real tool execution** — nmap, nikto, sqlmap, wifite, gobuster, ffuf, and more launch directly from the prompt
- **AI output analysis** — scan results are fed back to the model for tactical interpretation
- **Chatty Viking personality** — engages in character, asks questions, plans the raid
- **Streaming responses** — tokens print as they are generated, no waiting for full output
- **Model warm-up** — model is pre-loaded on startup so the first question is instant
- **Live model switching** — swap between 3 light models without restarting
- **Persistent config** — model preference saved between sessions
- **tmux integration** — persistent background session, reconnect after SSH disconnect

---

## Requirements

| Requirement | Notes |
|---|---|
| Kali Linux or Debian-based OS | Ubuntu and Parrot also work |
| Root access | `sudo bash install.sh` |
| 1 GB RAM minimum | 2 GB+ recommended for llama3.2:3b or qwen2.5:3b |
| Internet connection | During install only — pulls Ollama and the AI model |
| 1-5 GB disk space | Depends on how many arsenal tools you install |

---

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/viking-ai.git
cd viking-ai
sudo bash install.sh
```

The installer walks through 7 steps automatically:

```
[STEP 1] Install system dependencies (git, python3, golang, nmap, etc.)
[STEP 2] Install and start Ollama
[STEP 3] Pull the default AI model (tinyllama)
[STEP 4] Generate the arsenal registry and menu scripts
[STEP 5] Install the viking command to /usr/local/bin/viking
[STEP 6] Configure tmux auto-session
[STEP 7] Arsenal setup wizard
```

At step 7 you choose how many tools to install:

```
[1]  VIKING CLI + AI only     (no extra tools)
[2]  Pick tools from arsenal  (enter numbers like: 1 3 7 28)
[3]  WAR MODE                 (install all 103 tools)
[4]  Skip
```

---

## Usage

```bash
viking
```

The ship banner and WELCOME WARRIOR message appear. Start typing.

### Built-in Commands

| Command | What happens |
|---|---|
| `scan <ip/url>` | nmap full scan then AI analyses the results |
| `masscan <ip>` | fast port scan across all 65535 ports |
| `naabu <ip>` | fast port discovery |
| `nikto <url>` | web vulnerability scan |
| `gobuster <url>` | directory brute force |
| `ffuf <url>` | fast fuzzer |
| `feroxbuster <url>` | recursive directory scan |
| `dirsearch <url>` | directory search |
| `katana <url>` | web crawler |
| `sqlmap <url>` | automated SQL injection |
| `commix <url>` | command injection |
| `wpscan <url>` | WordPress vulnerability scan |
| `xsstrike <url>` | XSS scanner |
| `dalfox <url>` | XSS fuzzer |
| `wifite` | wireless attack suite |
| `airgeddon` | full wifi audit menu |
| `oneshot` | WPS / PMKID attack |
| `wifiphisher` | evil twin access point |
| `fluxion` | WPA handshake capture |
| `bettercap` | MITM and wifi attacks |
| `airmon` | aircrack-ng step-by-step guidance |
| `theharvester <domain>` | email and host OSINT |
| `amass <domain>` | subdomain enumeration |
| `subfinder <domain>` | passive subdomain discovery |
| `sherlock <username>` | username hunt across platforms |
| `holehe <email>` | account existence checker |
| `maigret` | username OSINT |
| `netexec` | Active Directory Swiss Army knife |
| `responder` | LLMNR / NTLMv2 capture |
| `bloodhound` | AD attack path mapping |
| `certipy` | AD certificate services enumeration |
| `impacket` | full impacket suite guidance |
| `metasploit` | launch msfconsole or get guidance |
| `sliver` | Sliver C2 framework |
| `havoc` | Havoc C2 framework |
| `empire` | PowerShell Empire |
| `hydra` | brute force guidance |
| `hashcat` | hash cracking guidance |
| `netcat` | reverse / bind shell guidance |
| `tshark` | live packet capture on active interface |
| `ping <ip>` | probe a target |
| `whois <domain>` | WHOIS lookup |
| `anonsurf` | route traffic through Tor |
| `arsenal` | open the Wapens Arsenal menu |
| `model` | list and switch AI models |
| `model <name>` | switch directly |
| `history` | view session log |
| `banner` | redisplay the ship banner |
| `help` | full command reference |
| `quit` / `exit` | leave VIKING |

### Natural Language

VIKING understands plain English — you do not need to memorize exact commands:

```
You: how do i capture a wpa handshake
You: what can I do after getting a shell
You: write me a python reverse shell
You: explain what this nmap output means: [paste output]
You: set up a listener on port 4444
You: how do I find subdomains of example.com
You: what is impacket used for
```

### Generic Tool Launcher

Any tool can be launched with natural language:

```
You: open wireshark
You: launch msfconsole
You: run cupp
You: start bloodhound
You: open sqlmap
```

---

## Wapens Arsenal

Type `arsenal` at the prompt to open the interactive tool browser.

```
  [*] WAPENS ARSENAL

    -- Scanning & Recon --
  [01]  WebCheck
  [02]  DEATH_STAR
  [03]  Dracnmap
  ...

    -- Active Directory --
  [92]  netexec                          [installed]
  [93]  responder
  ...

  number -> install  |  WAR -> all tools  |  back -> return

arsenal> 93
[~] apt install: responder
[OK] responder installed via apt
```

If apt fails for any tool, Viking automatically falls back to git clone and builds from source.

### Tool Categories

| Category | Tools | Keys |
|---|---|---|
| Scanning & Recon | WebCheck, DEATH_STAR, Dracnmap, RED_HAWK, reconspider, ReconDog, Striker, SecretFinder, rang3r, Breacher, theHarvester, spiderfoot | 1-12 |
| Network Tools | nmap, masscan, RustScan, xerosploit, amass, httpx, subfinder, naabu | 13-19, 90 |
| XSS Tools | dalfox, XSS-LOADER, extended-xss-search, XSpear, XSSCon, XanXSS, XSStrike, RVuln | 20-27 |
| SQL Injection | sqlmap, NoSQLMap, DSSS, explo, Blisqy, leviathan, sqlscan | 28-34 |
| WiFi Tools | OneShot, wifipumpkin3, pixiewps, bluepot, fluxion, wifiphisher, wifite2, fakeap, airgeddon, aircrack-ng, bettercap | 35-42, 80-82 |
| Anonymity | kali-anonsurf, multitor | 43-44 |
| OSINT | holehe, maigret, trufflehog, gitleaks, SMWYG, sherlock | 45-49, 91 |
| Wordlist | cupp, wlcreator, GoblinWordGenerator | 50-52 |
| Phishing | autophisher, AdvPhishing, SET, SocialFish, evilginx2, I-See-You, saycheese, ohmyqr, Thanos, QRLJacking, maskphish, BlackPhish | 53-64 |
| Web Tools | dirb, takeover, checkURL, Sublist3r, web2attack | 65-69 |
| Web Scanning | commix, wpscan, ffuf, gobuster, dirsearch, feroxbuster, katana | 83-89 |
| Exploitation | Vegile, HeraKeylogger, bulk_extractor, TheFatRat, Brutal, msfpc, venom, spycam, Mob-Droid, Enigma | 70-79 |
| Active Directory | netexec, responder, impacket, bloodhound, certipy | 92-96 |
| Password Cracking | hashcat, john, hydra | 97-99 |
| C2 Frameworks | metasploit, sliver, havoc, empire | 100-103 |

---

## War Mode

Type `WAR` inside the arsenal menu, or choose option 3 during install.

```
  ██╗    ██╗ █████╗ ██████╗     ███╗   ███╗ ██████╗ ██████╗ ███████╗
  ██║    ██║██╔══██╗██╔══██╗    ████╗ ████║██╔═══██╗██╔══██╗██╔════╝
  ██║ █╗ ██║███████║██████╔╝    ██╔████╔██║██║   ██║██║  ██║█████╗
  ...

  ██╗  ██╗███████╗██╗     ██╗          ██╗███████╗
  ██║  ██║██╔════╝██║     ██║         ██╔╝██╔════╝
  ...

  [!]  DEPLOYING FULL WEAPON ARSENAL - ALL TOOLS INCOMING  [!]

[WAR 1/103] Deploying: WebCheck
[WAR 2/103] Deploying: DEATH_STAR
...
[####################################......] 89/103

WAR COMPLETE - 103 WEAPONS DEPLOYED
```

4 tools install in parallel. Each tool tries apt first, falls back to git clone on failure. A summary of any failed installs is shown at the end with log paths.

---

## AI Models

Three lightweight models are available. All run under 3 GB RAM.

| # | Model | RAM | Best for |
|---|---|---|---|
| 1 | `tinyllama` | ~1 GB | Default — fastest responses, runs on anything |
| 2 | `llama3.2:3b` | ~2 GB | Better reasoning and longer answers |
| 3 | `qwen2.5:3b` | ~2 GB | Strong code generation and security context |

Switch models live from inside Viking:

```
You: model

  [*] AVAILABLE MODELS

  [1]  tinyllama            <- active  [installed]
  [2]  llama3.2:3b
  [3]  qwen2.5:3b

model> 2
[VIKING] Pulling llama3.2:3b...
[VIKING] Active: llama3.2:3b
```

Or switch directly:

```
You: model llama3.2:3b
```

The choice is saved to `/opt/viking/config` and persists across sessions.

---

## How It Works

```
You type a message
        |
        v
  [ Input Router ]  -- case match for exact commands (O1, no fork)
        |                -- bash regex match() for tool keywords
        |                -- falls through to AI if nothing matches
        |
   +---------+---------------------------+
   |                                     |
   v                                     v
[ Direct Tool Execution ]        [ Ollama REST API ]
  nmap, nikto, sqlmap,             POST /api/chat
  wifite, gobuster, etc.           stream: true
  Runs immediately,                tokens print as generated,
  output streamed to terminal      model stays hot in memory
        |                                     |
        +------------------+------------------+
                           |
                    [ Your terminal ]
                    Output + session log
                    ~/.viking_history.log
```

**Why streaming is fast:** VIKING uses the Ollama REST API (`http://localhost:11434/api/chat`) with `stream: true`. Tokens print to your terminal as the model generates them — you see the first word in under a second. The model stays loaded between questions so there is no cold-start penalty after the first query.

**Why tinyllama works well:** `num_ctx: 512` keeps the KV cache tiny, cutting time-to-first-token dramatically. `temperature: 0.3` keeps the Viking persona consistent. The system prompt is one sentence. Personality and response format are taught through four few-shot example turns baked into every request — small models copy patterns far better than they follow abstract rules.

**Why tool handlers run before the AI:** Every recognized tool keyword (scan, sqlmap, wifite, gobuster, etc.) is caught by pattern matching in the main loop and executed directly. The AI is only called for analysis, guidance, and anything not matched — this means tool execution has zero AI latency.

---

## File Structure

```
/usr/local/bin/viking          <- the main command
/opt/viking/
  config                       <- saved model preference
  arsenal_registry.sh          <- auto-generated tool registry
  arsenal_menu.sh              <- interactive tool browser
  arsenal/                     <- all installed tools live here
    sqlmap/
    XSStrike/
    wifite2/
    ...
  logs/                        <- war mode install logs
~/.viking_history.log          <- session log
```

---

## Install Type System

Each tool in the arsenal has one of five install types:

| Type | Behaviour |
|---|---|
| `git_python` | git clone then `pip3 install -r requirements.txt` |
| `git_go` | git clone then `go build ./...` |
| `git_generic` | git clone then tries Makefile, setup.sh, or install.sh |
| `apt_install:pkg` | `apt-get install pkg`, falls back to git clone on failure |
| `pip_install:pkg` | `pip3 install pkg`, falls back to git clone on failure |

The fallback means no tool silently fails. If the Kali repo doesn't have a package, Viking clones the source and builds it.

---

## tmux Integration

Viking configures a persistent tmux session on install. Your session survives SSH disconnects.

```bash
# Start
tmux new -s viking
viking

# Detach (session keeps running)
Ctrl+B then D

# Reconnect later
tmux attach -t viking
```

---

## Adding a Tool

Add one line to the `ARSENAL` array in `install.sh`:

```bash
ARSENAL[104]="toolname|Category|https://github.com/user/repo.git|git_python"
```

Re-run `install.sh` and the registry and menu are regenerated automatically from the array. No other files need to be edited.

---

## Legal

VIKING AI is built for **authorized penetration testing, CTF competitions, security research, and educational use only.**

Only use these tools on systems you own or have explicit written permission to test. Many tools in the arsenal are powerful and can cause serious damage if misused. The authors take no responsibility for illegal or unauthorized use. Always comply with the laws of your jurisdiction.

---

## License

MIT — see [LICENSE](LICENSE) for details.

---

<div align="center">

*The longship is ready. Type* `viking` *to sail.*

</div><div align="center">

```
██╗   ██╗██╗██╗  ██╗██╗███╗   ██╗ ██████╗      █████╗ ██╗
██║   ██║██║██║ ██╔╝██║████╗  ██║██╔════╝     ██╔══██╗██║
██║   ██║██║█████╔╝ ██║██╔██╗ ██║██║  ███╗    ███████║██║
╚██╗ ██╔╝██║██╔═██╗ ██║██║╚██╗██║██║   ██║    ██╔══██║██║
 ╚████╔╝ ██║██║  ██╗██║██║ ╚████║╚██████╔╝    ██║  ██║██║
  ╚═══╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝  ╚═╝╚═╝
```

**Digital Longship Intelligence System**

*A fully local, AI-powered CLI security assistant for Kali Linux — armed with 79 hacking tools, War Mode, and zero cloud dependency.*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Kali%20Linux-blue.svg)]()
[![AI](https://img.shields.io/badge/AI-Ollama%20%7C%20Local-green.svg)]()
[![Tools](https://img.shields.io/badge/Arsenal-79%20Tools-red.svg)]()
[![Shell](https://img.shields.io/badge/Shell-Bash-lightgrey.svg)]()

</div>

---

## What is VIKING AI?

VIKING AI is a local command-line intelligence layer for penetration testers, security researchers, and Linux operators. It combines an offline AI assistant (powered by [Ollama](https://ollama.com)) with a curated arsenal of 79 security tools — all installable with a single command, all running 100% on your machine. No API keys. No cloud. No data leaving your system.

You talk to it in plain English. It runs scans, analyzes output, suggests next steps, writes code, and guides you through every phase of an engagement — from recon to exploitation.

---

## Features

- **Local AI brain** — runs on Ollama with `tinyllama` by default; switchable to different models
- **79 security tools** — organized into 9 categories, git-cloned and dependency-installed automatically
- **Wapens Arsenal** — interactive numbered menu to browse and install individual tools
- **War Mode** — installs the entire arsenal at once with a full-screen red ASCII battle banner
- **Real-time tool execution** — nmap, nikto, tshark, wifite, sqlmap, and more run directly from the prompt
- **AI output analysis** — scan results are fed back to the model for tactical interpretation
- **Model switcher** — switch between 13 Ollama models live from inside the CLI
- **Persistent config** — your model preference is saved between sessions
- **tmux integration** — auto-session management for persistent terminal workflows
- **Fully offline** — no internet required after installation

---

## Requirements

| Requirement | Notes |
|---|---|
| Kali Linux (or Debian-based) | Ubuntu/Parrot also work |
| Root access | `sudo bash install.sh` |
| 4 GB RAM minimum | 8 GB+ recommended for larger models |
| Internet connection | During install only — for cloning tools and pulling the AI model |
| ~3–10 GB disk space | Depends on how many arsenal tools you install |

---

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/viking-ai.git
cd viking-ai
sudo bash install.sh
```

The installer will walk you through 7 steps:

1. Install core system dependencies (`git`, `python3`, `go`, `nmap`, `curl`, etc.)
2. Install and start [Ollama](https://ollama.com)
3. Pull the default AI model (`tinyllama`)
4. Write the arsenal registry and interactive menu scripts to `/opt/viking/`
5. Install the `viking` command to `/usr/local/bin/viking`
6. Configure a persistent `tmux` session
7. **Arsenal setup wizard** — choose how many tools to install

### Arsenal Setup Options

When prompted during install, you choose one of four modes:

```
[1]  Standard install (VIKING CLI + AI only)
[2]  Install specific tools from the Wapens Arsenal
[3]  WAR MODE — Install ALL 79 arsenal tools
[4]  Skip tool installation
```

Option `[2]` lets you enter tool numbers separated by spaces, e.g. `1 3 7 28 45`.

You can always install more tools later from inside the VIKING prompt by typing `arsenal`.

---

## Usage

```bash
viking
```

You'll be greeted by the Viking ship ASCII banner and dropped into the interactive prompt.

```
You: scan 192.168.1.1
You: nikto http://target.com
You: sqlmap http://target.com/page?id=1
You: what is a SSRF vulnerability
You: write a python reverse shell
You: arsenal
You: model
```

### Built-in Commands

| Command | Description |
|---|---|
| `scan <ip/url>` | Run nmap + AI analysis on a target |
| `ping <ip/host>` | Probe a target |
| `whois <domain>` | Domain WHOIS lookup |
| `nikto <ip/url>` | Web vulnerability scan |
| `tshark` | Live packet capture on the active interface |
| `wifite` | Launch wifite wireless attack suite |
| `oneshot` | Launch OneShot WPS/PMKID attack |
| `airmon` | Step-by-step aircrack-ng guidance |
| `gobuster <url>` | Directory brute force guidance |
| `sqlmap <url>` | SQL injection commands and flags |
| `metasploit` | Msfconsole module and payload guidance |
| `hydra` | Brute force command construction |
| `hashcat` / `john` | Hash cracking guidance |
| `netcat` | Reverse/bind shell setup |
| `open chrome/firefox/wireshark/burp` | Launch GUI apps (requires display) |
| `arsenal` | Open the Wapens Arsenal tool browser |
| `model` | List and switch AI models |
| `model <name>` | Switch to a specific Ollama model |
| `history` | View session log |
| `banner` | Redisplay the ship banner |
| `help` | Show the full command reference |
| `quit` / `exit` | Exit VIKING |

### Natural Language

VIKING understands plain English. You don't need to memorize commands. Examples:

```
You: how do I crack WPA2 with aircrack-ng
You: analyze this nmap output: [paste output]
You: make me a python script that port scans a subnet
You: what ports should I check on a Windows machine
You: write a bash script to automate subdomain enumeration
```

---

## Wapens Arsenal

Type `arsenal` at the VIKING prompt to open the interactive tool browser.

```
⚔  WAPENS ARSENAL  ⚔
══════════════════════════════════════════════════

── Scanning & Recon ──
[01]  WebCheck
[02]  DEATH_STAR
[03]  Dracnmap
...

── WiFi Tools ──
[35]  OneShot
[36]  wifipumpkin3
...

══════════════════════════════════════════════════

Enter a number to install a single tool
Type   WAR    to install ALL tools (War Mode)
Type   back   to return to VIKING

arsenal> 3
```

Tools already installed are marked `[installed]` in the list. Entering a number clones the repo and installs dependencies automatically.

### Tool Categories

| Category | Tools | Numbers |
|---|---|---|
| Scanning & Recon | WebCheck, DEATH_STAR, Dracnmap, RED_HAWK, reconspider, ReconDog, Striker, SecretFinder, rang3r, Breacher, theHarvester, spiderfoot | 01–12 |
| Network Tools | nmap, masscan, RustScan, xerosploit, amass, httpx, subfinder | 13–19 |
| XSS Tools | dalfox, XSS-LOADER, extended-xss-search, XSpear, XSSCon, XanXSS, XSStrike, RVuln | 20–27 |
| SQL Injection | sqlmap, NoSQLMap, DSSS, explo, Blisqy, leviathan, sqlscan | 28–34 |
| WiFi Tools | OneShot, wifipumpkin3, pixiewps, bluepot, fluxion, wifiphisher, wifite2, fakeap | 35–42 |
| Anonymity | kali-anonsurf, multitor | 43–44 |
| OSINT | holehe, maigret, trufflehog, gitleaks, SMWYG | 45–49 |
| Wordlist | cupp, wlcreator, GoblinWordGenerator | 50–52 |
| Phishing | autophisher, AdvPhishing, SET, SocialFish, evilginx2, I-See-You, saycheese, ohmyqr, Thanos, QRLJacking, maskphish, BlackPhish | 53–64 |
| Web Tools | dirb, takeover, checkURL, Sublist3r, web2attack | 65–69 |
| Exploitation | Vegile, HeraKeylogger, bulk_extractor, TheFatRat, Brutal, msfpc, venom, spycam, Mob-Droid, Enigma | 70–79 |

---

## War Mode

Type `WAR` inside the arsenal menu (or choose option `[3]` during install) to activate War Mode.

```
██╗    ██╗ █████╗ ██████╗      ███╗   ███╗ ██████╗ ██████╗ ███████╗
██║    ██║██╔══██╗██╔══██╗     ████╗ ████║██╔═══██╗██╔══██╗██╔════╝
██║ █╗ ██║███████║██████╔╝     ██╔████╔██║██║   ██║██║  ██║█████╗
...

⚠  ALL WEAPONS DEPLOYING — STAND CLEAR  ⚠

[WAR 1/79] Deploying: WebCheck (Scanning & Recon)
[WAR 2/79] Deploying: DEATH_STAR (Scanning & Recon)
...
[WAR 79/79] Deploying: Enigma (Exploitation)

════════════════════════════════════════════
WAR COMPLETE — 79 WEAPONS DEPLOYED  ⚔
════════════════════════════════════════════
```

The entire terminal turns red. Every tool clones, builds, and installs automatically. A summary of any failures is printed at the end.

---

## AI Models

VIKING ships with `gemma3:1b` as the default — fast, lightweight, runs on 4 GB RAM. Switch to more powerful models anytime.

Type `model` at the VIKING prompt to open the model menu:

```
⚔ AVAILABLE MODELS ⚔
══════════════════════════════

  "tinyllama"    # default — fastest, ~600 MB
  "llama3.2:3b"  # better reasoning, ~2 GB
  "qwen2.5:3b"   # strong code + security context, ~2 GB


```

Selecting a model will pull it via Ollama if not already downloaded and save the choice to `/opt/viking/config`. The model persists across sessions.

You can also switch directly:

```
You: model tinyllama
```

## How It Works

```
┌─────────────────────────────────────────────────────┐
│                   You (terminal)                    │
│              types a command or question            │
└───────────────────────┬─────────────────────────────┘
                        │
          ┌─────────────▼──────────────┐
          │     VIKING Input Router    │
          │   (pattern matching in     │
          │    the main bash loop)     │
          └──┬───────────┬─────────────┘
             │           │
    ┌────────▼──┐   ┌────▼──────────────────┐
    │  Direct   │   │   Ollama AI Engine     │
    │  Tool     │   │  (local, no cloud)     │
    │  Exec     │   │                        │
    │  nmap     │   │  System prompt gives   │
    │  nikto    │   │  VIKING its identity,  │
    │  tshark   │   │  command format, and   │
    │  wifite   │   │  tactical behavior     │
    └────┬──────┘   └────────────┬───────────┘
         │                       │
         └──────────┬────────────┘
                    │
          ┌─────────▼──────────┐
          │   Output to        │
          │   terminal +       │
          │   ~/.viking_       │
          │   history.log      │
          └────────────────────┘
```

When you type something like `scan 192.168.1.1`, VIKING:

1. Detects the keyword `scan` via regex pattern matching
2. Extracts the IP/domain from your input
3. Runs `nmap -sV --open -T4` directly and streams the output
4. Passes the full nmap result to Ollama with a prompt asking for a tactical analysis
5. Prints the AI's assessment in green below the raw output

For anything not matched by a built-in handler, the input falls through to the general AI fallback, which answers using the VIKING system prompt.

---

## File Structure

```
/usr/local/bin/viking          ← the main CLI command
/opt/viking/
├── config                     ← saved model preference
├── arsenal_registry.sh        ← tool registry (sourced at runtime)
├── arsenal_menu.sh            ← interactive tool browser
├── arsenal/                   ← all installed tools live here
│   ├── WebCheck/
│   ├── sqlmap/
│   ├── XSStrike/
│   └── ...
└── logs/                      ← install logs
~/.viking_history.log          ← your session history
```

---

## tmux Integration

VIKING automatically configures a persistent `tmux` session. This means if you close your terminal, your VIKING session stays alive in the background.

```bash
# Start a new VIKING session
tmux new -s viking
viking

# Detach (session keeps running)
Ctrl+B then D

# Reattach later
tmux attach -t viking
```

This is especially useful when running long scans or waiting for tool output — close your SSH connection and come back later.

---

## Legal & Ethics

VIKING AI is built for **authorized penetration testing, CTF competitions, security research, and educational use only.**

- Only use these tools on systems you own or have explicit written permission to test
- Many of the tools in the arsenal are powerful and can cause serious damage if misused
- The authors take no responsibility for illegal or unauthorized use
- Always comply with the laws of your jurisdiction

---

## Contributing

Pull requests are welcome. To add a tool to the arsenal, add one line to the `ARSENAL` array in `install.sh`:

```bash
ARSENAL["80"]="ToolName|Category|https://github.com/user/repo.git|git_python"
```

Install types: `git_python` (auto-installs `requirements.txt`), `git_go` (runs `go build`), `git_generic` (tries Makefile / setup.sh / install.sh).

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">

*Built for the longship. Optimized for the raid.*

**⚔ Type `viking` to sail. ⚔**

</div>
