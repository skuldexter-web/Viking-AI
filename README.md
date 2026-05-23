<div align="center">

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

- **Local AI brain** — runs on Ollama with `gemma3:1b` by default; switchable to 13 different models
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
3. Pull the default AI model (`gemma3:1b`)
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

[ 1]  gemma3:1b          ← active  [installed]
[ 2]  gemma3:4b
[ 3]  llama3.2:1b
[ 4]  llama3.2:3b
[ 5]  llama3.1:8b
[ 6]  mistral:7b
[ 7]  phi3:mini
[ 8]  phi3:medium
[ 9]  qwen2.5:3b
[10]  qwen2.5:7b
[11]  deepseek-r1:7b
[12]  codellama:7b
[13]  neural-chat:7b

Enter a number or model name to switch.
```

Selecting a model will pull it via Ollama if not already downloaded and save the choice to `/opt/viking/config`. The model persists across sessions.

You can also switch directly:

```
You: model mistral:7b
```

### Model Recommendations

| Use Case | Recommended Model |
|---|---|
| Low RAM / fast responses | `gemma3:1b` (default) |
| Better reasoning | `llama3.1:8b` or `mistral:7b` |
| Code generation | `codellama:7b` |
| Deep research / analysis | `deepseek-r1:7b` |
| General security chat | `qwen2.5:7b` |

---

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
