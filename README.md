# diskdoc

Your Mac says the disk is full. You open Storage settings. It shows a colorful bar that explains nothing. You click "Manage" and it suggests deleting your photos or buying iCloud. You have 500GB and can't save a screenshot.

**This is by design.**

Apple doesn't want you to find what's eating your disk. They want you to buy a new Mac. Or pay for iCloud. Or "upgrade" to the model with more storage. The entire Storage UI is built to make you feel helpless — to make the problem feel unsolvable without opening your wallet.

`diskdoc` is the tool Apple will never build. One command. Full transparency. You choose what to delete.

<p align="center">
  <img src="demo/diskdoc.gif" alt="diskdoc demo" width="600">
</p>

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

### Risk Levels

Every item is tagged with a risk level:

| Tag | Meaning |
|-----|---------|
| **SAFE** | Caches and regenerable data. Delete without worry. |
| **REBUILD** | Costly to reconstruct — VM images, large downloads. Safe to delete but takes time to re-download. |
| **PERSONAL** | User data — Mail, Messages, Photos, browser history. Shown in `--report` but **never auto-deleted**. |
| **UNTOUCHABLE** | System-critical. Cannot be safely deleted. Shown for transparency. **Never deletable by any code path.** |

### Profiles

```bash
diskdoc --profile dev        # Dev tools + package managers + build artifacts
diskdoc --profile system     # System caches + logs + Trash + Spotlight
diskdoc --profile apps       # App data, media, virtualization, browsers
diskdoc --profile personal   # Personal data (Mail, Messages, iCloud, Photos)
```

### Exclusions

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
| **System** | Apple screensaver cache (idleassetsd), Trash, APFS snapshots, QuickLook, font caches, Preference Panes, Screen Savers | SAFE |
| **Apple Intelligence** | ML models, asset packs, translation models | SAFE |
| **Logs** | System logs, diagnostic reports, crash logs, /var/folders | SAFE |
| **Virtualization** | Parallels (.pvm, .macvm), VMware, UTM, Lima, Colima, OrbStack, Tart, Vagrant, VirtualBox, Multipass, Docker.raw | REBUILD |
| **Dev Tools** | Xcode, Android SDK, CocoaPods, Gradle, Go, Rust, Python, Ruby, Flutter, JetBrains, VS Code, Unity, Unreal, Bazel, Julia, Deno, R, vcpkg | SAFE |
| **Build Artifacts** | node_modules, Rust `target/`, build dirs (via `--dev-artifacts`) | SAFE |
| **App Data** | Docker, Claude, ChatGPT, Kiro, Windsurf, Cursor, Slack, Discord, Notion, OneDrive, Steam, Battle.net | SAFE |
| **Browsers** | Chromium browsers (multi-profile), Safari, Firefox | SAFE |
| **Browser Data** | IndexedDB, LocalStorage, History, bookmarks | PERSONAL |
| **Creative** | Adobe CC, Lightroom, DaVinci Resolve | SAFE/REBUILD |
| **Mail** | Mail database (V6-V10), downloads, sync logs | PERSONAL |
| **Media** | Apple TV, Music, Podcasts, Books, GarageBand, Logic, Final Cut Pro | REBUILD |
| **Package Managers** | npm, pnpm, yarn, pip, Homebrew, Conda, Poetry, Conan, opam, Bun, GHCup | SAFE |
| **Ghost Apps** | Caches and containers from uninstalled applications | SAFE |
| **Orphan Containers** | Group Containers from apps no longer installed | SAFE |
| **Daemon Containers** | macOS 15+ daemon app containers | SAFE |
| **Personal** | Messages attachments, iCloud Drive cache, Photos derivatives, Safari Tabs DB | PERSONAL |
| **Untouchable** | dyld cache, Rosetta 2, sleepimage, swap, macOS Updates, StagedFrameworks | UNTOUCHABLE |

## Interactive Selection

`diskdoc` uses a paginated flat list selector with keyboard navigation, toggling, and batch selection. Works with bash 3.2+ (macOS default).

```
  ▼ System (105.4 GB)                                              4 items
    > [x] ★ APFS Local Snapshots (3 snaps)            —      SAFE
      [x] Apple Screensavers (idleassetsd)        99.2 GB    SAFE
      [x] System Logs                              4.1 GB    SAFE
      [x] Trash                                    2.1 GB    SAFE
  ▼ Virtualization (82.3 GB)                                        3 items
      [x] Parallels: Windows 11.pvm               45.0 GB    REBUILD
      [x] Docker.raw (sparse)                      30.1 GB    SAFE
      [ ] UTM: Ubuntu.utm                           7.2 GB    REBUILD
  ► Dev Tools (25.0 GB)                                             8 items

  Selected: 6/15 items — 180.5 GB
  ↑↓ Navigate  ␣ Toggle  → Expand  ← Collapse  ⏎ Confirm  q Quit
```

## Report Mode

`diskdoc --report` gives a full audit with proportional bars and risk tags. Includes PERSONAL and UNTOUCHABLE sections. Nothing is deleted.

```
  System  (105.4 GB)
  ├── Apple Screensavers (idleassetsd)  99.2 GB  ████████░░  🟢 SAFE
  ├── System Logs                        4.1 GB  ░░░░░░░░░░  🟢 SAFE
  └── Trash                              2.1 GB  ░░░░░░░░░░  🟢 SAFE

  ╭─ 🔒 Untouchable — Apple's territory ─────────────────────╮
  │ Total: 34.8 GB — none of this can be safely removed      │
  ╰──────────────────────────────────────────────────────────╯
  🔒 dyld shared cache                6.2 GB
  🔒 sleepimage                       16.0 GB
```

## How It Works

1. Detects macOS version (Catalina through Tahoe) for version-aware scanning
2. Scans 250+ known space hogs with individual VM and browser profile enumeration
3. Dynamically scans `~/Library/Caches/*` for anything over the size threshold
4. Detects ghost app data and orphaned containers from uninstalled apps
5. Tags everything with risk levels — SAFE, REBUILD, PERSONAL, UNTOUCHABLE
6. Interactive selector to pick exactly what to delete
7. Uses official cleanup commands where available (`tmutil`, `xcrun simctl`, `docker system prune`)
8. Shows before/after report and saves to history

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

## Requirements

- macOS (Catalina through Tahoe)
- `sudo` access for scanning system directories
- Bash 4+ recommended (collapsible tree UI) — works on bash 3.2 with flat list fallback

## Contributing

Found another hidden space hog? Open an issue or PR.

## License

MIT — do whatever you want with it.
