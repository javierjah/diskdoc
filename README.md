# diskdoc

> Find what Apple hid on the disk you already paid for. One bash script. You decide what stays.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell: bash](https://img.shields.io/badge/shell-bash-1f425f.svg)](https://www.gnu.org/software/bash/)
[![Platform: macOS](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)
[![Version](https://img.shields.io/badge/version-1.0.2-blue.svg)](CHANGELOG.md)
[![Tested: Catalina–Tahoe](https://img.shields.io/badge/tested-Catalina%E2%80%93Tahoe-success.svg)](#tested-on)

---

Apple sold you a half-terabyte disk and built an operating system that hides where the bytes go. You open Storage settings: a colored bar that explains nothing. You click "Manage": a polite suggestion to delete your photos or pay for iCloud. You have 500GB and can't save a screenshot.

This is not a UX failure. It is the UX working as intended. Manufactured opacity is how a trillion-dollar company turns hardware you already own into a recurring revenue stream — iCloud subscriptions, premature upgrades, the steady drip of "your disk is almost full." The confusion is the product. You are not supposed to find the 99GB of cached screensaver videos. You are supposed to feel helpless and reach for your wallet.

`diskdoc` refuses the premise. One bash script. It walks 250+ known hiding places on macOS, tags every byte by what it actually is, and hands you the list. No telemetry. No account. No upsell. The tool has no opinion about what you should delete, because the tool is not trying to sell you anything.

You bought the hardware. The hardware is yours. This just shows you what's on it.

<p align="center">
  <img src="demo/diskdoc.gif" alt="diskdoc demo" width="600">
</p>

## Table of Contents

- [Install](#install)
- [Use it](#use-it)
- [What it won't do](#what-it-wont-do)
- [Risk Levels](#risk-levels)
- [Profiles](#profiles)
- [Exclusions](#exclusions)
- [Where Apple hides things](#where-apple-hides-things)
- [Interactive selection](#interactive-selection)
- [Report mode](#report-mode)
- [How it works](#how-it-works)
- [JSON output](#json-output)
- [Where this came from](#where-this-came-from)
- [Tested on](#tested-on)
- [Troubleshooting / FAQ](#troubleshooting--faq)
- [Requirements](#requirements)
- [Add to the map](#add-to-the-map)
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

## Use it

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

## What it won't do

The whole script is built on one rule: nothing happens without you. Specifically:

- **Interactive mode requires explicit selection.** You manually pick what to delete with the spacebar, then confirm with Enter. No "select all and pray."
- **`--auto` only touches SAFE items.** It will never auto-delete REBUILD, PERSONAL, or UNTOUCHABLE items, regardless of how you invoke it. There is no flag, no env var, no override.
- **PERSONAL items are never auto-deleted.** Mail, Messages, browser history, iCloud cache — these only show up in `--report` for awareness. Cleaning them requires manual interactive selection. Your data stays your data until you say otherwise.
- **UNTOUCHABLE items have no delete code path at all.** dyld cache, sleepimage, ML Assets, Simulator Volumes, /var/folders, Rosetta — diskdoc detects and shows them, but no command in the codebase can remove them. They're protected by SIP at the OS level too — even `sudo rm -rf` fails. We show them anyway, because you deserve to know where the space went even when you can't reclaim it.
- **Exclusions are honored absolutely.** Anything in `~/.diskdocrc` is skipped during scans and shown as `⊘ excluded`.
- **Every action is logged.** `~/.diskdoc/history.log` records what was removed, when, and how much space was reclaimed. Audit anytime. The script keeps receipts on itself.
- **`--dry-run` shows exact commands.** When unsure, run `--dry-run` first to see the literal `rm -rf` commands that would execute. Nothing happens until you re-run without the flag.

If diskdoc ever fails to delete something, it shows the real error from the OS — not a generic "failed". Most failures are SIP protections you couldn't have bypassed anyway. The tool will not lie to you to look competent.

## Risk Levels

Every item is tagged with a risk level. The point of the tags is not to tell you what to do — it's to give you the context you need to decide:

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

## Where Apple hides things

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

## Interactive selection

`diskdoc` uses a paginated flat list selector with keyboard navigation, toggling, and batch selection. Works with the bash that ships with macOS — no upgrades needed, no Homebrew, no runtime.

Here's a real scan from a working developer's Mac — the kind of disk state diskdoc is built for:

```
  Found 38 items — 71.8 GB recoverable  (scanned in 190s)

  Select items to delete:

  > [x] Android AVDs                           23.4 GB  ██████████  🟢 SAFE
    [x] Simulator Volumes                      15.5 GB  ██████▋░░░  🟢 SAFE
    [x] Claude VM Bundles                      12.0 GB  █████▏░░░░  🟢 SAFE
    [x] ML Asset: com_apple…MacSoftwareUpdate   3.3 GB  █▍░░░░░░░░  🟢 SAFE
    [x] ML Asset: com_apple…SFRSoftwareUpdate   3.1 GB  █▎░░░░░░░░  🟢 SAFE
    [x] iOS Simulators                          3.1 GB  █▎░░░░░░░░  🟢 SAFE
    [x] Windsurf Data                           1.6 GB  ▋░░░░░░░░░  🟢 SAFE
    [x] System Diagnostics                      1.1 GB  ▍░░░░░░░░░  🟢 SAFE
    [x] VS Code Workspaces                      1.0 GB  ▍░░░░░░░░░  🟢 SAFE
    [x] node_modules (~/code)                   895 MB  ▍░░░░░░░░░  🟢 SAFE
    [x] ML Asset: com_apple…LinguisticData      864 MB  ▍░░░░░░░░░  🟢 SAFE
    [x] Slack Cache                             859 MB  ▍░░░░░░░░░  🟢 SAFE
    [x] Maven Repository                        749 MB  ▎░░░░░░░░░  🟢 SAFE
    [x] ML Asset: com_apple…UAF_Siri            565 MB  ▎░░░░░░░░░  🟢 SAFE
    [x] pyenv Versions                          521 MB  ▎░░░░░░░░░  🟢 SAFE
    [x] UUID Text Logs                          512 MB  ▎░░░░░░░░░  🟢 SAFE
    [x] Gradle Caches                           338 MB  ▏░░░░░░░░░  🟢 SAFE
    [x] Ghost: zoom.us                          327 MB  ▏░░░░░░░░░  🟢 SAFE
    [x] Cache: com.nordvpn.macos                299 MB  ▏░░░░░░░░░  🟢 SAFE
    [x] Cache: vscode-cpptools                  208 MB  ▏░░░░░░░░░  🟢 SAFE
    ▼ 18 more below

  Selected: 38/38 items — 71.8 GB
  ↑↓ move  ␣ toggle  A all  N none  ⏎ confirm  q quit
```

**71.8 GB hiding in plain sight.** Android AVDs you forgot about. Simulator runtimes from an old Xcode. Claude VM bundles. ML models Apple silently downloaded onto a disk you bought. A zoom.us install you uninstalled months ago whose caches never left. None of this shows up in macOS Storage settings. All of it is yours to reclaim.

## Report mode

`diskdoc --report` gives you a full audit with proportional bars and risk tags. Includes PERSONAL and UNTOUCHABLE sections. Nothing is deleted — this mode exists so you can see the whole picture without making any decision yet.

```
  diskdoc report — Full Disk Audit

  Dev Tools  (45.8 GB)
  ├── Android AVDs                    23.4 GB  ██████████  🟢 SAFE
  ├── Simulator Volumes               15.5 GB  ██████▋░░░  🟢 SAFE
  ├── iOS Simulators                   3.1 GB  █▎░░░░░░░░  🟢 SAFE
  ├── VS Code Workspaces               1.0 GB  ▍░░░░░░░░░  🟢 SAFE
  ├── node_modules (~/code)            895 MB  ▍░░░░░░░░░  🟢 SAFE
  ├── Maven Repository                 749 MB  ▎░░░░░░░░░  🟢 SAFE
  ├── pyenv Versions                   521 MB  ▎░░░░░░░░░  🟢 SAFE
  ├── Gradle Caches                    338 MB  ▏░░░░░░░░░  🟢 SAFE
  └── rbenv Versions                    98 MB  ░░░░░░░░░░  🟢 SAFE

  App  (15.0 GB)
  ├── Claude VM Bundles               12.0 GB  ██████████  🟢 SAFE
  ├── Windsurf Data                    1.6 GB  █▎░░░░░░░░  🟢 SAFE
  ├── Slack Cache                      859 MB  ▋░░░░░░░░░  🟢 SAFE
  └── Ghost: zoom.us                   327 MB  ▎░░░░░░░░░  🟢 SAFE

  System  (8.0 GB)
  ├── ML Asset: MacSoftwareUpdate      3.3 GB  ██████████  🟢 SAFE
  ├── ML Asset: SFRSoftwareUpdate      3.1 GB  █████████▌  🟢 SAFE
  ├── ML Asset: LinguisticData         864 MB  ██▋░░░░░░░  🟢 SAFE
  └── ML Asset: UAF_Siri               565 MB  █▊░░░░░░░░  🟢 SAFE

  Cache  (1.1 GB)
  ├── Cache: com.nordvpn.macos         299 MB  ██████████  🟢 SAFE
  ├── Cache: vscode-cpptools           208 MB  ██████▉░░░  🟢 SAFE
  ├── Cache: com.apple.python          167 MB  █████▌░░░░  🟢 SAFE
  └── Cache: Homebrew                   88 MB  ██▉░░░░░░░  🟢 SAFE

  Total: 71.8 GB  (38 items across 6 categories)

  ╭─ 🔒 Untouchable — Apple's territory ──────────────────────╮
  │ Total: 26.5 GB — none of this can be safely removed       │
  │                                                           │
  │  🔒 dyld shared cache                     5.8 GB          │
  │  🔒 sleepimage                            2.0 GB          │
  │  🔒 Rosetta 2 cache (/var/db/oah)             —           │
  │  🔒 /var/folders (daemon caches)         171 MB           │
  ╰───────────────────────────────────────────────────────────╯

  Report mode: nothing was deleted.
  Items tagged PERSONAL are included for audit only.
```

## How it works

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

No dependencies. No runtime. No background daemon. One bash script you can read end to end before running it. That's the whole point — a tool you can audit yourself in an afternoon, instead of trusting another opaque binary to fix the problems caused by the first opaque binary.

## JSON output

```bash
diskdoc --json | jq '.items[] | select(.size_bytes > 1073741824)'
diskdoc --json | jq '.total_recoverable_bytes'
diskdoc --json | jq '.untouchable[] | {name, size_human, description}'
```

## Where this came from

A 500GB MacBook with **6GB free**. No large files visible. The macOS Storage UI showing nothing useful — just a patronizing nudge to "optimize storage" by paying Apple more money.

Hours of digging later: `com.apple.idleassetsd` had silently cached **99GB** of screensaver videos onto a disk I owned. Docker had 30GB of forgotten images. Xcode had 14GB of dead simulators. **216GB recovered** from a disk macOS swore was full with no way to fix it.

The expected next step was: buy a new Mac. The actual next step was: write this script. It's been growing ever since, because every developer who runs it finds another hiding place and sends it back.

Your computer should answer to you, not to a quarterly earnings target. You bought the hardware. Use all of it.

## Tested on

- **macOS Tahoe 26.3** (Apple Silicon) — primary development
- **macOS Sequoia 15.7**
- **macOS Sonoma 14.x**
- **bash 3.2** (macOS default)
- **bash 5.x** (Homebrew)

Older macOS versions (Catalina, Big Sur, Monterey, Ventura) should work but receive less testing. Issues and PRs welcome.

## Troubleshooting / FAQ

### Why does diskdoc need sudo?

To accurately measure system-level paths that the regular user can't read: `sleepimage`, `/private/var/folders/`, `/Library/Developer/CoreSimulator/`, dyld cache, and others. Without sudo, those items would silently report as 0 bytes and you'd miss real cleanup opportunities. diskdoc only uses sudo for read operations during scanning and write operations when you explicitly select something to delete. The script is short enough to read first if you don't trust it.

### Why are some items marked UNTOUCHABLE?

macOS protects certain paths with **System Integrity Protection (SIP)**. These include `/System/Library/AssetsV2/*` (Apple Intelligence models pushed to your disk whether you asked or not), `/Library/Developer/CoreSimulator/Volumes/*` (Simulator runtimes), `/var/db/oah/` (Rosetta 2 cache), and others. Even `sudo rm -rf` returns "Operation not permitted" on these paths. diskdoc shows them so you know where your space is going, but never tries to delete them — that would just produce errors and waste your time. The point isn't only to clean; it's to make Apple's claim on your disk visible.

### Is it safe to delete the Spotlight Index?

Technically yes, but diskdoc tags it 🟡 **REBUILD** for a reason. Removing the index forces macOS to re-index your entire disk, which can take **several hours** with CPU at 100%. During that time, file searches won't work and your Mac will feel slow. Only do it if Spotlight is genuinely broken (corrupt results, missing files).

### Does it work on Intel Macs?

Yes. The scanners are based on file paths, not architecture. Tested on both Apple Silicon and Intel Macs running Catalina through Tahoe.

### Why not Linux?

The paths diskdoc looks at (`~/Library/Caches`, `/Library/Developer/CoreSimulator`, `/private/var/folders`, etc.) are macOS-specific. A Linux equivalent would essentially be a different tool — `bleachbit` and `ncdu` already cover that ground well. Linux users tend not to need this script for the same reason: the OS isn't actively hiding things from them.

### diskdoc said "failed" on something. What now?

diskdoc shows the real OS error next to "failed". Most common reasons:

- **"Operation not permitted"** → SIP-protected path. Nothing you can do; it should have been UNTOUCHABLE. Open an issue with the path so it can be reclassified.
- **"No space left on device"** → Your disk is genuinely full mid-cleanup. Free up some space manually first.
- **"Resource busy"** → A running app is holding the file. Quit the app and retry.

### How do I undo a cleanup?

You can't, mostly — diskdoc uses `rm -rf`, not the Trash. **For SAFE items this doesn't matter**: caches regenerate themselves the next time the app runs. For REBUILD items (VM images, Spotlight index), regeneration takes time but is automatic. Use `--dry-run` first if you're nervous about a particular cleanup. The script trusts you to make adult decisions about your own machine.

### Can I trust this with my data?

Read the [What it won't do](#what-it-wont-do) section. The short version: PERSONAL data is never auto-deleted, UNTOUCHABLE has no delete code path at all, every action is logged, and `--dry-run` exists for a reason. The script is more conservative than its tone suggests — but more importantly, it's short enough to read end to end before you run it. Don't take my word for it; take the code's.

## Requirements

- **macOS** Catalina (10.15) through Tahoe (26.x)
- **bash 3.2** or newer (the version shipped with macOS works fine — no upgrade needed)
- **`sudo` access** for scanning system-level directories (sleepimage, /var/folders, Simulator Volumes)

No other dependencies. Doesn't install anything globally except the script itself. Doesn't phone home. Doesn't have a "pro version."

## Add to the map

This script is a map of where macOS hides things, and maps get better when more people walk the territory. Found a hiding place diskdoc doesn't know about yet? Open an issue with:

- The path
- Approximate size
- Which app or tool puts it there
- Your macOS version

PRs welcome. New scanners follow the existing pattern: add a `scan_*()` function, call it from `run_all_scans()`, tag items with the right risk level. **When in doubt, prefer UNTOUCHABLE over SAFE** — it's easier to reclassify later than to apologize for a destructive bug.

For changes that touch cleanup logic or risk classification, run it against a real Mac and paste before/after output in the PR. Nothing ships to anyone's disk based on theory.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for full release history.

## License

MIT. Take it, fork it, rename it, paste it on Pastebin, teach it to a friend, run it on every machine in the office. The script is yours the moment you read it. If you find a hiding place I missed, send it back — so the next person staring at "Manage Storage" at midnight, three weeks from a deadline, doesn't have to find it alone.