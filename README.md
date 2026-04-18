<div align="center">

```
███████╗██╗      █████╗ ███╗   ██╗██████╗ ██████╗ ███████╗██╗██╗██╗
██╔════╝██║     ██╔══██╗████╗  ██║██╔══██╗██╔══██╗██╔════╝██║██║██║
█████╗  ██║     ███████║██╔██╗ ██║██║  ██║██████╔╝█████╗  ██║██║██║
██╔══╝  ██║     ██╔══██║██║╚██╗██║██║  ██║██╔══██╗██╔══╝  ██║██║██║
██║     ███████╗██║  ██║██║ ╚████║██████╔╝██║  ██║███████╗██║██║██║
╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝╚═╝╚═╝
```

**Auto-install all your GitHub tools in one command.**

![GitHub](https://img.shields.io/badge/github-flandreiii-181717?style=flat-square&logo=github)
![Platform](https://img.shields.io/badge/platform-Termux%20%7C%20Arch%20Linux-blue?style=flat-square)
![Shell](https://img.shields.io/badge/shell-bash-4EAA25?style=flat-square&logo=gnubash)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

[![Buy Me A Coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=flandreiii&button_colour=FF5F5F&font_colour=ffffff&font_family=Poppins&outline_colour=000000&coffee_colour=FFDD00)](https://buymeacoffee.com/flandreiii)

</div>

---

## What is Autotool?

Autotool fetches all your public repositories from GitHub and presents an interactive TUI where you can select which ones to clone or update — all in one shot. It automatically detects project types and runs the appropriate setup command after cloning.

**Features:**
- Fetches all repos via paginated GitHub API (no missed repos)
- Interactive arrow-key selector with search, toggle all/none
- Auto-runs `npm install`, `pip install`, `make`, or `install.sh` after cloning
- Updates already-cloned repos with `git pull`
- Color-coded install summary

---

## Installation

### 🤖 Termux (Android)

> Requires: [Termux](https://termux.dev) on Android

```bash
git clone https://github.com/flandreiii/Autotool
cd Autotool
chmod +x autotool.sh
bash autotool.sh
```

### 🐧 Arch Linux

> Works with `pacman`, `yay`, or `paru`. Requires: Arch Linux or any Arch-based distro (Manjaro, EndeavourOS, Garuda, etc.)

```bash
git clone https://github.com/flandreiii/Autotool
cd Autotool
chmod +x autotool-arch.sh
bash autotool-arch.sh
```

---

## Controls

| Key | Action |
|-----|--------|
| `↑` / `↓` | Navigate repos |
| `Space` | Toggle selection |
| `a` | Select all |
| `n` | Deselect all |
| `Enter` | Confirm and install |
| `q` | Quit |

---

## Auto-Setup Detection

After cloning a repo, Autotool automatically runs the right setup command:

| File found | Command run |
|------------|-------------|
| `package.json` | `npm install` |
| `requirements.txt` | `pip install -r requirements.txt` |
| `Makefile` | `make` |
| `install.sh` | `bash install.sh` |

All repos are cloned into `~/tools/`.

---

## Files

| File | Platform |
|------|----------|
| `autotool.sh` | Termux (Android) |
| `autotool-arch.sh` | Arch Linux / Arch-based distros |

---

## Support

If you find this useful, consider buying me a coffee ☕

[![Buy Me A Coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=flandreiii&button_colour=FF5F5F&font_colour=ffffff&font_family=Poppins&outline_colour=000000&coffee_colour=FFDD00)](https://buymeacoffee.com/flandreiii)

---

#termux #arch #linux #github #automation #bash #tools #cybersecurity #webdevelopment
