# ⚔ VIKING AI

> *Digital Longship Intelligence System*
> Local AI-powered CLI security assistant for Kali Linux

![Kali Linux](https://img.shields.io/badge/Kali-Linux-557C94?style=flat&logo=kalilinux&logoColor=white)
![Ollama](https://img.shields.io/badge/Powered%20by-Ollama-black?style=flat)
![License](https://img.shields.io/badge/License-MIT-green?style=flat)
![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?style=flat&logo=gnubash&logoColor=white)
![Stars](https://img.shields.io/github/stars/YOUR_USERNAME/viking-ai?style=flat)

---

VIKING is a fully local, offline AI assistant that lives in your terminal. It understands natural language, runs Kali Linux tools automatically, analyzes scan results with AI, and helps you write code — all over SSH with no cloud, no API keys, and no internet required after setup.

Built for security researchers who SSH into their server from anywhere (mobile, laptop, VPN) and want an intelligent operator in the terminal.

---

## Features

- Runs 100% locally — privacy-first, no data leaves your machine
- Natural language → auto-executes the right Kali tool
- AI analysis of nmap scan results with risk assessment
- Supports: nmap, tshark, wifite, oneshot, nikto, sqlmap, hydra, metasploit, gobuster, hashcat, john, aircrack-ng, netcat, and more
- Coding assistant: Python, Bash, HTML, CSS, JavaScript
- Viking-themed identity with tactical CLI formatting
- tmux integration — sessions survive SSH disconnects
- Works from Termius on iPhone over Tailscale VPN
- Switch AI models on the fly

---

## Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 4-core x86_64 | 8-core (AMD FX / Ryzen) |
| RAM | 8 GB | 16 GB |
| VRAM | Not required | Not required |
| Storage | 5 GB free | 10 GB free |
| OS | Kali Linux / Debian | Kali Linux |

> Tested and working on: AMD FX-8350 (8-core) · 16GB DDR3 · AMD Radeon R7 370 2GB · Kali Linux

---

## One-Line Install

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/skuldexter-web/Viking-AI/main/install.sh)"
```

Or clone and run manually:

```bash
git clone https://github.com/skuldexter-web/Viking-AI.git
cd viking-ai
sudo bash install.sh
```

---

## Launch

```bash
viking
```

Inside tmux (recommended — survives disconnects):

```bash
tmux new -s viking
viking

# Detach:   Ctrl+B then D
# Reattach: tmux attach -t viking
```

---

## Usage Examples

```
You: scan 192.168.1.1
You: nmap 10.0.0.5
You: nikto http://192.168.1.100
You: run wifite
You: open tshark
You: sqlmap http://target.com/page?id=1
You: hydra ssh on 192.168.1.10
You: write a python port scanner
You: bash script to monitor active connections
You: what is a MITM attack
You: how do I set up a reverse shell with netcat
You: model phi3:mini
You: quit
```

---

## Supported Tools

| Category | Tools |
|----------|-------|
| Scanning & Recon | nmap, nikto, gobuster, dirb, whois |
| Wireless | wifite, oneshot, aircrack-ng, airmon-ng, airodump-ng |
| Web & Exploitation | sqlmap, metasploit, msfconsole, netcat |
| Password Attacks | hydra, hashcat, john the ripper |
| Network & Traffic | tshark, ping |
| GUI Apps | chrome, firefox, wireshark, burpsuite |
| Coding | Python, Bash, HTML, CSS, JavaScript |

---

## SSH + Mobile (Termius / Tailscale)

This tool is built for SSH-only terminal use. Everything works over a plain SSH connection.

**GUI apps** (Chrome, Wireshark, Burp Suite) need a display. Over SSH, VIKING will detect this and suggest CLI alternatives automatically. To enable GUI forwarding:

```bash
# X11 forwarding
ssh -X user@your-tailscale-ip

# Or install VNC
sudo apt install tigervnc-standalone-server
vncserver :1
```

---

## Switch AI Model

From inside VIKING:

```
You: model phi3:mini
```

Pull a new model first if needed:

```bash
ollama pull phi3:mini
ollama pull llama3.2:3b
```

| Model | Speed | Quality | VRAM |
|-------|-------|---------|------|
| gemma3:1b | Fastest | Good | CPU only |
| phi3:mini | Fast | Better | CPU only |
| llama3.2:3b | Moderate | Best | CPU only |

---

## File Structure

```
viking-ai/
├── install.sh     # One-command installer — installs everything
├── README.md      # This file
└── LICENSE        # MIT License
```

The installer writes the VIKING script to `/usr/local/bin/viking` so you can run `viking` from anywhere.

---

## Uninstall

```bash
sudo rm /usr/local/bin/viking
```

---

## Contributing

PRs welcome. Ideas:
- Add more tool integrations
- Improve AI prompt templates for specific tools
- Add a `report` command to save scan output as markdown
- Open WebUI integration for browser-based access

---

## License

MIT — free to use, fork, and share.

---

*Built for security operators who work from the terminal.*
*No cloud. No keys. No nonsense.*  ⚔
