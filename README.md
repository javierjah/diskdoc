# diskdoc

> The disk cleanup tool Apple will never build. One command. Full transparency. You choose what to delete.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell: bash](https://img.shields.io/badge/shell-bash-1f425f.svg)](https://www.gnu.org/software/bash/)
[![Platform: macOS](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](CHANGELOG.md)
[![Tested: Catalina–Tahoe](https://img.shields.io/badge/tested-Catalina%E2%80%93Tahoe-success.svg)](#tested-on)

---

Your Mac says the disk is full. You open Storage settings. It shows a colorful bar that explains nothing. You click "Manage" and it suggests deleting your photos or buying iCloud. You have 500GB and can't save a screenshot.

**This is by design.**

Apple doesn't want you to find what's eating your disk. They want you to buy a new Mac. Or pay for iCloud. Or "upgrade" to the model with more storage. The entire Storage UI is built to make you feel helpless — to make the problem feel unsolvable without opening your wallet.

`diskdoc` is the tool Apple will never build. One command. Full transparency. You choose what to delete.

<p align="center">
  <img src="demo/diskdoc.gif" alt="diskdoc demo" width="600">
</p>

## Table of Contents

- [Install](#install)
- [Usage](#usage)
- [Safety](#safety)
- [Risk Levels](#risk-levels)
- [Profiles](#profiles)
- [Exclusions](#exclusions)
- [What It Scans](#what-it-scans)
- [Interactive Selection](#interactive-selection)
- [Report Mode](#report-mode)
- [How It Works](#how-it-works)
- [JSON Output](#json-output)
- [Why This Exists](#why-this-exists)
- [Tested On](#tested-on)
- [Troubleshooting / FAQ](#troubleshooting--faq)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [Changelog](#changelog)
- [License](#license)

## Install

### Homebrew

```bash
brew tap javierjah/diskdoc
brew install diskdoc
```

### Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/javierjah/diskdoc/main/install.sh | bash
```

### Manual

```bash
git clone https://github.com/javierjah/diskdoc.git
cd diskdoc
make install
```

## Usage

```bash
diskdoc                    # Interactive: scan, select, clean
diskdoc --scan             # Preview only — see what's eating your disk
diskdoc --report           # Full audit including personal and untouchable items
diskdoc --auto             # Clean without asking (only SAFE items)
diskdoc --dry-run          # Show what would be deleted, with exact commands
diskdoc --dev-artifacts    # Deep scan for node_modules, target/, build/
diskdoc --json             # Scan results as JSON (for piping/automation)
diskdoc doctor             # Diagnose disk usage — top consumers
diskdoc history            # See your cleanup history
```

### Flags

| Flag | Description |
|------|-------------|
| `--scan` | Scan only, don't delete anything |
| `--report` | Full audit with all categories including personal and untouchable |
| `--auto` | Clean without asking — only deletes SAFE items, skips everything else |
| `--dry-run` | Show what would be deleted (with commands) |
| `--dev-artifacts` | Deep scan for build artifacts across code directories |
| `--json` | Output scan results as JSON (implies `--scan`) |
| `--min-size N` | Minimum size in MB to include (default: 50) |
| `--profile PROFILE` | Filter: `all`, `dev`, `system`, `apps`, `personal` |
| `--no-color` | Disable colored output |
| `--version` | Show version |
| `--help` | Show help |

## Safety

diskdoc is built around one principle: **you decide**. Nothing gets deleted without your explicit confirmation. Specifically:

- **Interactive mode requires explicit selection.**. You manually pick what to delete with the spacebar, then confirm with Enter.
- **`--auto` only touches SAFE items.** It will never auto-delete REBUILD, PERSONAL, or UNTOUCHABLE items, regardless of how you invoke it.
- **PERSONAL items are never auto-deleted.** Mail, Messages, browser history, iCloud cache — these only show up in `--report` for awareness. Cleaning them requires manual interactive selection.
- **UNTOUCHABLE items have no delete code path at all.** dyld cache, sleepimage, ML Assets, Simulator Volumes, /var/folders, Rosetta — diskdoc detects and shows them, but no command in the codebase can remove them. They're protected by SIP at the OS level too — even `sudo rm -rf` fails.
- **Exclusions are honored absolutely.** Anything in `~/.diskdocrc` is skipped during scans and shown as `⊘ excluded`.
- **Every action is logged.** `~/.diskdoc/history.log` records what was removed, when, and how much space was reclaimed. Audit anytime.
- **`--dry-run` shows exact commands.** When unsure, run `--dry-run` first to see the literal `rm -rf` commands that would execute. Nothing happens until you re-run without the flag.

If diskdoc ever fails to delete something, it shows the real error from the OS — not a generic "failed". Most failures are SIP protections you couldn't have bypassed anyway.

## Risk Levels

Every item is tagged with a risk level:

| Tag | Meaning |
|-----|---------|
| 🟢 **SAFE** | Caches and regenerable data. Delete without worry. |
| 🟡 **REBUILD** | Costly to reconstruct — VM images, Spotlight index, large downloads. Safe to delete but takes hours of CPU or re-download time. |
| 🔴 **PERSONAL** | User data — Mail, Messages, Photos, browser history. Shown in `--report` but **never auto-deleted**. |
| 🔒 **UNTOUCHABLE** | System-critical or SIP-protected. Cannot be safely deleted. Shown for transparency. **Never deletable by any code path.** |

## Profiles

```bash
diskdoc --profile dev        # Dev tools + package managers + build artifacts
diskdoc --profile system     # System caches + logs + Trash + Spotlight
diskdoc --profile apps       # App data, media, virtualization, browsers
diskdoc --profile personal   # Personal data (Mail, Messages, iCloud, Photos)
```

## Exclusions

Create `~/.diskdocrc` to permanently exclude paths:

```bash
# One path per line
~/Library/Android
~/Library/Developer/Xcode/DerivedData/MyProject
```

Excluded items show up as `⊘ excluded` during scans.

## What It Scans

| Category | Examples | Risk |
|----------|----------|------|
| **System** | Apple screensaver cache (idleassetsd), Trash, APFS snapshots, QuickLook, font caches, Preference Panes, Screen Savers | 🟢 SAFE |
| **Apple Intelligence** | ML models, asset packs, translation models (SIP-protected on Tahoe) | 🔒 UNTOUCHABLE |
| **Logs** | System logs, diagnostic reports, crash logs | 🟢 SAFE |
| **Virtualization** | Parallels (.pvm, .macvm), VMware, UTM, Lima, Colima, OrbStack, Tart, Vagrant, VirtualBox, Multipass, Docker.raw | 🟡 REBUILD |
| **Dev Tools** | Xcode, Android SDK, CocoaPods, Gradle, Go, Rust, Python, Ruby, Flutter, JetBrains, VS Code, Unity, Unreal, Bazel, Julia, Deno, R, vcpkg | 🟢 SAFE |
| **Simulator Volumes** | `/Library/Developer/CoreSimulator/Volumes/` (SIP-protected on Tahoe) | 🔒 UNTOUCHABLE |
| **Build Artifacts** | node_modules, Rust `target/`, build dirs (via `--dev-artifacts`) | 🟢 SAFE |
| **App Data** | Docker, Claude, ChatGPT, Kiro, Windsurf, Cursor, Slack, Discord, Notion, OneDrive, Steam, Battle.net | 🟢 SAFE |
| **Browsers** | Chromium browsers (multi-profile), Safari, Firefox | 🟢 SAFE |
| **Browser Data** | IndexedDB, LocalStorage, History, bookmarks | 🔴 PERSONAL |
| **Creative** | Adobe CC, Lightroom, DaVinci Resolve | 🟢/🟡 SAFE/REBUILD |
| **Mail** | Mail database (V6-V10), downloads, sync logs | 🔴 PERSONAL |
| **Media** | Apple TV, Music, Podcasts, Books, GarageBand, Logic, Final Cut Pro | 🟡 REBUILD |
| **Package Managers** | npm, pnpm, yarn, pip, Homebrew, Conda, Poetry, Conan, opam, Bun, GHCup | 🟢 SAFE |
| **Spotlight Index** | `/System/Volumes/Data/.Spotlight-V100` — re-indexing takes hours | 🟡 REBUILD |
| **Ghost Apps** | Caches and containers from uninstalled applications | 🟢 SAFE |
| **Orphan Containers** | Group Containers from apps no longer installed | 🟢 SAFE |
| **Daemon Containers** | macOS 15+ daemon app containers | 🟢 SAFE |
| **Personal** | Messages attachments, iCloud Drive cache, Photos derivatives, Safari Tabs DB | 🔴 PERSONAL |
| **Untouchable** | dyld cache, Rosetta 2, sleepimage, /var/folders daemon caches, macOS Updates | 🔒 UNTOUCHABLE |

## Interactive Selection

`diskdoc` uses a paginated flat list selector with keyboard navigation, toggling, and batch selection. Works with the bash that ships with macOS — no upgrades needed.

```
  Found 13 items — 12.0 GB recoverable  (scanned in 112s)

  Select items to delete:

    [x] Spotlight Index                       3.9 GB  ██████████  🟡 REBUILD
    [x] Homebrew Cache                        2.5 GB  ██████▏░░░  🟢 SAFE
    [x] System Diagnostics                    923 MB  ██▎░░░░░░░  🟢 SAFE
    [x] node_modules (~/code)                 895 MB  ██▏░░░░░░░  🟢 SAFE
    [x] UUID Text Logs                        865 MB  ██▏░░░░░░░  🟢 SAFE
    [x] Cache: Google                         826 MB  ██░░░░░░░░  🟢 SAFE
    [x] Slack Cache                           787 MB  █▉░░░░░░░░  🟢 SAFE
    [x] Firefox storage                       457 MB  █▏░░░░░░░░  🔴 PERSONAL
  > [x] pyenv Versions                        378 MB  ▉░░░░░░░░░  🟢 SAFE
    [x] Gradle Caches                         287 MB  ▋░░░░░░░░░  🟢 SAFE
    [x] Windsurf Data                         196 MB  ▍░░░░░░░░░  🟢 SAFE
    [x] Container: com.apple.wallpaper.agent   56 MB  ▏░░░░░░░░░  🟢 SAFE
    [x] Metadata                               54 MB  ▏░░░░░░░░░  🟢 SAFE

  Selected: 13/13 items — 12.0 GB
  ↑↓ move  ␣ toggle  A all  N none  ⏎ confirm  q quit
```

## Report Mode

`diskdoc --report` gives a full audit with proportional bars and risk tags. Includes PERSONAL and UNTOUCHABLE sections. Nothing is deleted.

```
  Dev Tools  (1.6 GB)
  ├── node_modules (~/code)                 895 MB  ██████████  🟢 SAFE
  ├── pyenv Versions                        378 MB  ████▎░░░░░  🟢 SAFE
  └── Gradle Caches                         287 MB  ███▎░░░░░░  🟢 SAFE

  System  (3.9 GB)
  └── Spotlight Index                       3.9 GB  ██████████  🟡 REBUILD

  ╭─ 🔒 Untouchable — Apple's territory ──────────────────────╮
  │ Total: 26.5 GB — none of this can be safely removed       │
  │                                                           │
  │  🔒 ML Asset: LinguisticData              1.7 GB          │
  │  🔒 Simulator Volumes (CoreSimulator)    15.5 GB          │
  │  🔒 dyld shared cache                     5.8 GB          │
  │  🔒 Rosetta 2 cache (/var/db/oah)             —           │
  │  🔒 sleepimage                            2.0 GB          │
  │  🔒 /var/folders (daemon caches)         171 MB           │
  ╰───────────────────────────────────────────────────────────╯
```

## How It Works

1. Detects macOS version (Catalina through Tahoe) for version-aware scanning
2. Scans 250+ known space hogs with individual VM and browser profile enumeration
3. Dynamically scans `~/Library/Caches/*` for anything over the size threshold
4. Detects ghost app data and orphaned containers from uninstalled apps
5. Tags everything with risk levels — SAFE, REBUILD, PERSONAL, UNTOUCHABLE
6. Detects SIP-protected paths and routes them to UNTOUCHABLE so cleanup never fails on them
7. Interactive selector to pick exactly what to delete
8. Uses official cleanup commands where available (`tmutil`, `xcrun simctl`, `docker system prune`)
9. Captures real OS errors and surfaces them — no silent failures
10. Shows before/after report and saves to history

No dependencies. No runtime. One bash script.

## JSON Output

```bash
diskdoc --json | jq '.items[] | select(.size_bytes > 1073741824)'
diskdoc --json | jq '.total_recoverable_bytes'
diskdoc --json | jq '.untouchable[] | {name, size_human, description}'
```

## Why This Exists

A 500GB MacBook with **6GB free**. No large files visible. The macOS Storage UI showing nothing useful — just a patronizing suggestion to "optimize storage" by paying Apple more money.

After hours of investigation: `com.apple.idleassetsd` had silently eaten **99GB** caching screensaver videos. Docker had 30GB of forgotten images. Xcode had 14GB of dead simulators. **216GB recovered** from a disk macOS said was "full" with no way to fix it.

Your computer should work for **you**, not for Apple's revenue targets. You bought the hardware. You should be able to use all of it.

## Tested On

- **macOS Tahoe 26.3** (Apple Silicon) — primary development
- **macOS Sequoia 15.7**
- **macOS Sonoma 14.x**
- **bash 3.2** (macOS default)
- **bash 5.x** (Homebrew)

Older macOS versions (Catalina, Big Sur, Monterey, Ventura) should work but receive less testing. Issues and PRs welcome.

## Troubleshooting / FAQ

### Why does diskdoc need sudo?

To accurately measure system-level paths that the regular user can't read: `sleepimage`, `/private/var/folders/`, `/Library/Developer/CoreSimulator/`, dyld cache, and others. Without sudo, those items would silently report as 0 bytes and you'd miss real cleanup opportunities. diskdoc only uses sudo for read operations during scanning and write operations when you explicitly select something to delete.

### Why are some items marked UNTOUCHABLE?

macOS protects certain paths with **System Integrity Protection (SIP)**. These include `/System/Library/AssetsV2/*` (Apple Intelligence models), `/Library/Developer/CoreSimulator/Volumes/*` (Simulator runtimes), `/var/db/oah/` (Rosetta 2 cache), and others. Even `sudo rm -rf` returns "Operation not permitted" on these paths. diskdoc shows them so you know where your space is going, but never tries to delete them — that would just produce errors and waste your time.

### Is it safe to delete the Spotlight Index?

Technically yes, but diskdoc tags it 🟡 **REBUILD** for a reason. Removing the index forces macOS to re-index your entire disk, which can take **several hours** with CPU at 100%. During that time, file searches won't work and your Mac will feel slow. Only do it if Spotlight is genuinely broken (corrupt results, missing files).

### Does it work on Intel Macs?

Yes. The scanners are based on file paths, not architecture. Tested on both Apple Silicon and Intel Macs running Catalina through Tahoe.

### Why not Linux?

The paths diskdoc looks at (`~/Library/Caches`, `/Library/Developer/CoreSimulator`, `/private/var/folders`, etc.) are macOS-specific. A Linux equivalent would essentially be a different tool — `bleachbit` and `ncdu` already cover that ground well.

### diskdoc said "failed" on something. What now?

diskdoc shows the real OS error next to "failed". Most common reasons:

- **"Operation not permitted"** → SIP-protected path. Nothing you can do; it should have been UNTOUCHABLE. Open an issue with the path so it can be reclassified.
- **"No space left on device"** → Your disk is genuinely full mid-cleanup. Free up some space manually first.
- **"Resource busy"** → A running app is holding the file. Quit the app and retry.

### How do I undo a cleanup?

You can't, mostly — diskdoc uses `rm -rf`, not the Trash. **For SAFE items this doesn't matter**: caches regenerate themselves the next time the app runs. For REBUILD items (VM images, Spotlight index), regeneration takes time but is automatic. Use `--dry-run` first if you're nervous about a particular cleanup.

### Can I trust this with my data?

Read the [Safety](#safety) section. The short version: PERSONAL data is never auto-deleted, UNTOUCHABLE has no delete code path at all, every action is logged, and `--dry-run` exists for a reason. The tool is more conservative than its tone suggests.

## Requirements

- **macOS** Catalina (10.15) through Tahoe (26.x)
- **bash 3.2** or newer (the version shipped with macOS works fine — no upgrade needed)
- **`sudo` access** for scanning system-level directories (sleepimage, /var/folders, Simulator Volumes)

No other dependencies. Doesn't install anything globally except the script itself.

## Contributing

Found a hidden space hog diskdoc doesn't detect? Open an issue with:

- The path
- Approximate size
- Which app/tool creates it
- Your macOS version

PRs welcome. New scanners should follow the existing pattern: add a `scan_*()` function, call it from `run_all_scans()`, tag items with the appropriate risk level. **When in doubt, prefer UNTOUCHABLE over SAFE** — it's easier to reclassify later than to apologize for a destructive bug.

For changes that touch the cleanup logic or risk classification, please run the cleanup against a real Mac and paste the before/after output in the PR.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for full release history.

## License

MIT — do whatever you want with it.