# diskdoc

Your Mac says the disk is full. You open Storage settings. It shows a colorful bar that explains nothing. You click "Manage" and it suggests deleting your photos or buying iCloud. You have 500GB and can't save a screenshot.

**This is by design.**

Apple doesn't want you to find what's eating your disk. They want you to buy a new Mac. Or pay for iCloud. Or "upgrade" to the model with more storage. The entire Storage UI is built to make you feel helpless — to make the problem feel unsolvable without opening your wallet.

`diskdoc` is the tool Apple will never build. One command. Full transparency. You choose what to delete.

## What Apple Won't Tell You

macOS silently fills your disk with things you never asked for:

- **`com.apple.idleassetsd`** — Apple's screensaver daemon downloads aerial videos to a hidden system folder. It can grow to **100GB+** without any notification, any setting, any warning. There is no UI to see it. There is no UI to delete it. It just eats your disk until you can't work.
- **Apple Intelligence & ML models** — macOS downloads large machine learning models for Siri, dictation, translation, and Apple Intelligence features. They sit in hidden system directories and grow over time.
- **APFS local snapshots** — Time Machine creates local snapshots that can consume tens of gigabytes. macOS never tells you they exist or how to reclaim the space.
- **Parallels, VMware, UTM** — virtual machines that silently grow their disk images to hundreds of gigabytes. Each VM is a single opaque file that Finder won't explain.
- **Docker, Xcode, Android Studio** — dev tools that accumulate build caches, simulators, and volumes until they consume more space than your actual projects.
- **App caches** — Spotify, Chrome, Slack, ChatGPT, Claude, Telegram — every app caches aggressively and none of them clean up after themselves.
- **Ghost app data** — you uninstalled the app, but its caches and containers are still on your disk, invisible, taking up space for nothing.
- **`dyld shared cache`** — 6-10 GB of "cache" that isn't a cache at all. It's part of the OS. You can't delete it. Apple named it "cache" anyway.
- **`sleepimage`** — a file the exact size of your RAM (8-96 GB) sitting in `/private/var/vm/`. Apple never mentions it exists.
- **node_modules / Rust targets** — if you're a developer, you have dozens of copies of the same packages and build artifacts scattered across forgotten projects.

None of this shows up in Finder. None of it shows up in "Storage Management." The space just disappears, and Apple's answer is: buy more.

**No.** The answer is `diskdoc`.

## Install

### Homebrew

```bash
brew tap javierjah/diskdoc
brew install diskdoc
```

> **Note:** diskdoc v3 requires bash 4+. macOS ships bash 3.2 from 2007 because Apple refuses to update it due to GPLv3 licensing. `brew install bash` fixes this.

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
# Interactive: scan, select, clean
diskdoc

# Preview only — see what's eating your disk
diskdoc --scan

# Full audit report — includes personal data and untouchable items
diskdoc --report

# Deep scan for dev build artifacts (node_modules, target/, build/)
diskdoc --dev-artifacts

# Show what would be deleted, with the exact commands
diskdoc --dry-run

# Clean everything without asking (for scripts/cron)
diskdoc --auto

# Output scan results as JSON (for piping/automation)
diskdoc --json

# Diagnose disk usage — top consumers in ~/Library and ~/
diskdoc doctor

# See your cleanup history
diskdoc history
```

### Flags

| Flag | Description |
|------|-------------|
| `--scan` | Scan only, don't delete anything |
| `--report` | Full audit tree with all categories including personal and untouchable |
| `--auto` | Clean without asking (skips PERSONAL and UNTOUCHABLE automatically) |
| `--dry-run` | Show what would be deleted (with commands) |
| `--dev-artifacts` | Deep scan for build artifacts across code directories |
| `--json` | Output scan results as JSON (implies `--scan`) |
| `--min-size N` | Minimum size in MB to include (default: 50) |
| `--profile PROFILE` | Filter by profile: `all`, `dev`, `system`, `apps`, `personal` |
| `--no-color` | Disable colored output |
| `--version` | Show version |
| `--help` | Show help |

### Risk Levels

Every item scanned by `diskdoc` is tagged with a risk level:

| Tag | Color | Meaning |
|-----|-------|---------|
| **SAFE** | Green | Caches and regenerable data. Delete without worry. |
| **REBUILD** | Yellow | Costly to reconstruct — large downloads, VM images, sound libraries. Safe to delete but will take time to re-download. |
| **PERSONAL** | Red | User data — Mail, Messages, Photos, browser history. Shown in `--report` mode but **never auto-deleted**. |
| **UNTOUCHABLE** | Magenta | System-critical. Cannot be safely deleted. Shown for transparency with educational explanations. **Never deletable by any code path.** |

In `--auto` mode, PERSONAL and UNTOUCHABLE items are automatically skipped. In interactive mode, PERSONAL items appear with a visible warning. UNTOUCHABLE items live in a separate section and cannot be selected.

### Profiles

Filter the scan to only what you care about:

- **`all`** — Everything (default)
- **`dev`** — Dev tools + package managers + build artifacts
- **`system`** — System caches + logs + Trash + /var/folders + Spotlight
- **`apps`** — Application data, media, virtualization, browsers, creative tools, mail
- **`personal`** — Personal data (Mail DB, Messages, iCloud, Photos, browser data)

```bash
# Only scan dev-related items
diskdoc --scan --profile dev

# Only clean app data, skip items under 100MB
diskdoc --profile apps --min-size 100

# Audit personal data usage without deleting anything
diskdoc --report --profile personal
```

### Exclusions

Create `~/.diskdocrc` to permanently exclude paths from cleanup:

```bash
# One path per line
~/Library/Android
~/Library/Developer/Xcode/DerivedData/MyProject
```

Excluded items show up as `⊘ excluded` during scans.

### Interactive Selection

`diskdoc` gives you full control with collapsible category trees:

```
  ▼ System (105.4 GB)                                              4 items
    > [x] ★ APFS Local Snapshots (3 snaps)            —      SAFE
      [x] Apple Screensavers (idleassetsd)        99.2 GB    SAFE
      [x] System Logs                              4.1 GB    SAFE
      [x] Trash                                    2.1 GB    SAFE
  ▼ Virtualization (82.3 GB)                                        3 items
      [x] Parallels: Windows 11.pvm               45.0 GB    REBUILD
      [x] Docker.raw (sparse)                      30.1 GB    SAFE
      [ ] UTM: Ubuntu.utm                           7.2 GB    REBUILD  <- deselected
  ► Dev Tools (25.0 GB)                                             8 items  [collapsed]

  Selected: 6/15 items — 180.5 GB
  ↑↓ Navigate  ␣ Toggle  → Expand  ← Collapse  ⏎ Confirm  q Quit
```

Navigate with arrow keys. Space toggles items. Left/right collapses/expands categories. Space on a category toggles all its items.

### Report Mode

`diskdoc --report` gives you a complete audit of everything on your disk, organized by category with proportional bars:

```
  System  (105.4 GB)
  ├── Apple Screensavers (idleassetsd)  99.2 GB  ████████░░  🟢 SAFE
  ├── System Logs                        4.1 GB  ░░░░░░░░░░  🟢 SAFE
  └── Trash                              2.1 GB  ░░░░░░░░░░  🟢 SAFE

  Virtualization  (82.3 GB)
  ├── Parallels: Windows 11.pvm         45.0 GB  █████░░░░░  🟡 REBUILD
  └── Docker.raw (sparse)               30.1 GB  ███░░░░░░░  🟢 SAFE

  Personal  (8.2 GB)
  ├── Mail Database (V10)                3.1 GB  ████░░░░░░  🔴 PERSONAL
  ├── Messages Attachments               2.8 GB  ███░░░░░░░  🔴 PERSONAL
  └── iCloud Drive (local)               2.3 GB  ██░░░░░░░░  🔴 PERSONAL

  ╭─ 🔒 Untouchable — Apple's territory ─────────────────────╮
  │ Total: 34.8 GB — none of this can be safely removed      │
  ╰──────────────────────────────────────────────────────────╯
  🔒 dyld shared cache                6.2 GB
  🔒 Rosetta 2 AOT cache              4.1 GB
  🔒 sleepimage                       16.0 GB
  🔒 Swap files                        4.0 GB
  🔒 macOS Update packages             4.3 GB
  🔒 StagedFrameworks                  0.2 GB

  These exist because of decisions Apple made about how
  macOS works. diskdoc shows them for transparency, but
  will never delete them.
```

Report mode includes PERSONAL and UNTOUCHABLE categories for full visibility. Nothing is deleted.

### Ghost Apps

`diskdoc` detects **ghost app data** — caches and containers left behind by apps you already uninstalled. These invisible leftovers can waste gigabytes:

```
  Ghost: com.old.app                            2.1 GB    SAFE
  Ghost: com.another.removed                    1.3 GB    SAFE
```

It checks `/Applications`, `~/Applications`, `/System/Applications`, and Spotlight to confirm the app is truly gone before flagging its data.

### Virtualization

`diskdoc` scans every major virtualization platform and reports each VM individually:

```
  Parallels: Windows 11.pvm             45.0 GB    REBUILD
  Parallels: macOS Ventura.macvm        22.1 GB    REBUILD
  VMware: Ubuntu Server.vmwarevm        18.5 GB    REBUILD
  UTM: Fedora 39.utm                     8.2 GB    REBUILD
  Docker.raw (sparse: 30.1 GB on disk)  60.0 GB    SAFE
  OrbStack data (sparse)                12.4 GB    SAFE
  Lima: default                          5.1 GB    REBUILD
  Tart VM: sonoma-vanilla                4.8 GB    REBUILD
```

Docker.raw and OrbStack use sparse files — `diskdoc` reports actual disk usage (via `du`), not the virtual size that Finder shows.

### APFS Snapshots

Time Machine creates local APFS snapshots that can silently consume significant disk space. `diskdoc` detects them and offers to thin them:

```
  ★ APFS Local Snapshots (7 snaps)              —        SAFE
```

Snapshot cleanup uses `tmutil thinlocalsnapshots` — the safe, Apple-sanctioned way to reclaim this space.

### Untouchable Items

`diskdoc` shows you everything — including the things you can't delete. The **Untouchable** section reports system-critical items with educational explanations:

- **dyld shared cache** (6-10 GB) — Not actually a cache. Contains all macOS dynamic libraries. Deleting it = system won't boot.
- **Rosetta 2 AOT cache** (2-7 GB) — Translated Intel binaries for Apple Silicon. Regenerates automatically.
- **sleepimage** (= your RAM) — Memory dump for deep hibernation. Can be disabled but you lose hibernate.
- **Swap files** (1-4+ GB) — Virtual memory. Deleting while running = kernel panic.
- **/Library/Updates** (0-13 GB) — Pending macOS updates. SIP-protected.
- **StagedFrameworks** — Rosetta framework translations. SIP-protected.

These exist because of decisions Apple made. `diskdoc` shows them for transparency but will never offer to delete them.

### Doctor Mode

`diskdoc doctor` gives you a full disk diagnosis without deleting anything:

- Disk health status (critical/warning/healthy)
- Top 15 space consumers in `~/Library`
- Top 10 space consumers in `~/`
- Time Machine local snapshot count

### History

Every cleanup is logged to `~/.diskdoc/history.log`. Run `diskdoc history` to see a table of past cleanups with date, recovered space, items cleaned, and elapsed time.

## What It Scans

| Category | Examples | Risk |
|----------|----------|------|
| **System** | Apple screensaver cache, Trash, APFS snapshots, QuickLook/font caches | SAFE |
| **Apple Intelligence** | ML models, asset packs, translation models | SAFE |
| **Logs** | System logs, diagnostic reports, crash logs, /var/folders temp | SAFE |
| **Virtualization** | Parallels, VMware, UTM, Lima, Colima, OrbStack, Tart, Vagrant, VirtualBox, Multipass, Docker.raw | REBUILD |
| **Dev Tools** | Xcode, Android SDK, CocoaPods, Gradle, Go, Rust, Python, Ruby, Flutter, JetBrains, VS Code, Unity, Unreal, Bazel | SAFE |
| **Build Artifacts** | node_modules, Rust `target/`, build dirs (via `--dev-artifacts`) | SAFE |
| **App Data** | Docker, Claude, ChatGPT, Kiro, Windsurf, Cursor, Slack, Discord, Notion | SAFE |
| **Browsers** | Chromium browsers (multi-profile), Safari, Firefox | SAFE |
| **Browser Data** | IndexedDB, LocalStorage, History, bookmarks | PERSONAL |
| **Creative** | Adobe CC, Lightroom, DaVinci Resolve | SAFE/REBUILD |
| **Mail** | Mail database (V6-V10), downloads, sync logs | PERSONAL |
| **Media** | Apple TV, Music, Podcasts, Books, GarageBand, Logic, Final Cut Pro | REBUILD |
| **Caches** | Any `~/Library/Caches/*` entry over the size threshold | SAFE |
| **Pkg Managers** | npm, pnpm, yarn, pip, Homebrew, Caskroom | SAFE |
| **Ghost Apps** | Caches and containers from uninstalled applications | SAFE |
| **Orphan Containers** | Group Containers from apps no longer installed | SAFE |
| **Personal** | Messages attachments, iCloud Drive cache, Photos derivatives | PERSONAL |
| **Untouchable** | dyld cache, Rosetta 2, sleepimage, swap, Updates, StagedFrameworks | UNTOUCHABLE |

Everything tagged SAFE or REBUILD is a cache, build artifact, or regenerable data. **PERSONAL items are never auto-deleted.** **UNTOUCHABLE items are never deletable by any code path** — they exist for transparency.

## How It Works

1. Detects macOS version (Catalina through Tahoe) for version-aware scanning
2. Scans known space hogs (idleassetsd, Docker, Xcode, VMs, ML models, etc.)
3. Scans every major virtualization platform, reporting each VM individually
4. Detects APFS local snapshots and highlights them with ★
5. Dynamically scans `~/Library/Caches/*` for anything over the size threshold
6. Finds `node_modules` and Rust `target/` directories across your code directories
7. Scans all browser profiles (Chromium multi-profile, Safari, Firefox)
8. Scans Electron and sandbox containers, deduplicating already-known entries
9. Detects ghost app data — caches from apps you already uninstalled
10. Reports untouchable system items with educational explanations
11. Presents a sorted, color-coded table with categories, risk levels, proportional bars, and ★ highlights
12. Interactive selector with collapsible category trees — pick exactly what to delete
13. Uses official cleanup commands where available (`tmutil`, `xcrun simctl`, `docker system prune`, `qlmanage`, `mdutil`)
14. Cleans and shows a before/after report with progress bars
15. Saves cleanup to history log

No dependencies. No runtime. Just a bash script that does what macOS refuses to.

## JSON Output

Pipe scan results into other tools:

```bash
# Get all items as JSON
diskdoc --json

# Filter with jq — items over 1GB
diskdoc --json | jq '.items[] | select(.size_bytes > 1073741824)'

# Total recoverable bytes
diskdoc --json | jq '.total_recoverable_bytes'

# Only PERSONAL items
diskdoc --json | jq '.items[] | select(.risk == "PERSONAL")'

# Untouchable items and why
diskdoc --json | jq '.untouchable[] | {name, size_human, description}'
```

## Origin Story

This tool was born from frustration.

A 500GB MacBook with only **6GB free**. No large files visible anywhere. The macOS Storage UI showing nothing useful — just a patronizing suggestion to "optimize storage" by paying Apple more money.

After hours of investigation, the culprit: `com.apple.idleassetsd` had silently eaten **99GB** caching screensaver videos that nobody asked for. Docker had 30GB of forgotten images. Xcode had 14GB of simulators for devices that don't exist anymore. App caches had piled up for years.

**216GB recovered.** From a disk that macOS said was "full" with no way to fix it.

The cleanup process was automated into `diskdoc` so nobody else has to go through that.

## Why This Exists

Planned obsolescence isn't just about hardware. It's about software that quietly makes your device worse until you give up and buy a new one.

When your Mac runs out of space, Apple's solution is never "here's what's using it." It's always "buy iCloud" or "upgrade your Mac." The Storage Management UI is deliberately unhelpful. Hidden system caches are never surfaced. There is no built-in tool to clean them.

This is not a bug. This is a business model.

`diskdoc` exists because your computer should work for **you**, not for Apple's revenue targets. You bought the hardware. You should be able to use all of it.

One person built this. No company. No funding. No agenda beyond: **your disk space belongs to you.**

## Requirements

- macOS (tested on Sonoma and Sequoia)
- Bash 4+ (`brew install bash` — macOS ships bash 3.2 from 2007 because Apple refuses to update due to GPLv3)
- `sudo` access (for scanning system directories like idleassetsd, logs, and untouchable items)

## Contributing

Found another hidden space hog? Open an issue or PR. The more eyes on this, the harder it is for Apple to hide.

## License

MIT — do whatever you want with it.
