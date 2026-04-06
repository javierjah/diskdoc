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
- **Docker, Xcode, Android Studio** — dev tools that accumulate build caches, simulators, and volumes until they consume more space than your actual projects.
- **App caches** — Spotify, Chrome, Slack, ChatGPT, Claude, Telegram — every app caches aggressively and none of them clean up after themselves.
- **Ghost app data** — you uninstalled the app, but its caches and containers are still on your disk, invisible, taking up space for nothing.
- **node_modules / Rust targets** — if you're a developer, you have dozens of copies of the same packages and build artifacts scattered across forgotten projects.

None of this shows up in Finder. None of it shows up in "Storage Management." The space just disappears, and Apple's answer is: buy more.

**No.** The answer is `diskdoc`.

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
# Interactive: scan, select, clean
diskdoc

# Preview only — see what's eating your disk
diskdoc --scan

# Full audit report — includes personal data categories
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
| `--report` | Full audit tree with all categories including personal data |
| `--auto` | Clean without asking (skips PERSONAL items automatically) |
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
| **REBUILD** | Yellow | Costly to reconstruct — large downloads, sound libraries, ML models. Safe to delete but will take time to re-download. |
| **PERSONAL** | Magenta | User data — Mail, Messages, Photos, iCloud. Shown in `--report` mode but **never auto-deleted**. |

In `--auto` mode, PERSONAL items are automatically skipped. In interactive mode, they appear with a visible warning so you can make an informed choice.

### Profiles

Filter the scan to only what you care about:

- **`all`** — Everything (default)
- **`dev`** — Dev tools + package managers + node_modules + Rust targets
- **`system`** — System caches + logs + Trash
- **`apps`** — Application data (Docker, Claude, ChatGPT, etc.)
- **`personal`** — Personal data (Mail, Messages, Photos, iCloud)

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

`diskdoc` doesn't just dump a list and ask "delete all?" — it gives you full control:

```
  > [x] ★ APFS Local Snapshots (3 snaps)            —      SAFE
    [x] Apple Screensavers (idleassetsd)        99.2 GB    SAFE
    [x] Docker Data                              30.1 GB    SAFE
    [ ] Android SDK                              25.0 GB    REBUILD  <- deselected
    [x] iOS Simulators                           11.0 GB    SAFE
    [x] Cache: com.spotify.client                 6.8 GB    SAFE

  Selected: 4/6 items — 147.1 GB
  arrows=move  space=toggle  a=all  n=none  enter=confirm  q=cancel
```

Items with ★ are highlighted — they require special attention (like APFS snapshots or iOS backups that need `sudo`).

### Report Mode

`diskdoc --report` gives you a complete audit of everything on your disk, organized by category:

```
  System  (105.4 GB)
  ├── Apple Screensavers (idleassetsd)        99.2 GB  SAFE
  ├── System Logs                              4.1 GB  SAFE
  └── Trash                                    2.1 GB  SAFE

  Personal  (8.2 GB)
  ├── Mail Downloads                           3.1 GB  PERSONAL
  ├── Messages Attachments                     2.8 GB  PERSONAL
  └── iCloud Drive Cache                       2.3 GB  PERSONAL
```

Report mode includes PERSONAL categories for full visibility. Nothing is deleted — it's pure auditing.

### Ghost Apps

`diskdoc` detects **ghost app data** — caches and containers left behind by apps you already uninstalled. These invisible leftovers can waste gigabytes:

```
  Ghost: com.old.app                            2.1 GB    SAFE
  Ghost: com.another.removed                    1.3 GB    SAFE
```

It checks both `/Applications` and Spotlight to confirm the app is truly gone before flagging its data.

### APFS Snapshots

Time Machine creates local APFS snapshots that can silently consume significant disk space. `diskdoc` detects them and offers to thin them:

```
  ★ APFS Local Snapshots (7 snaps)              —        SAFE
```

Snapshot cleanup uses `tmutil thinlocalsnapshots` — the safe, Apple-sanctioned way to reclaim this space.

### Doctor Mode

`diskdoc doctor` gives you a full disk diagnosis without deleting anything:

- Disk health status (critical/warning/healthy)
- Top 15 space consumers in `~/Library`
- Top 10 space consumers in `~/`
- Time Machine local snapshot count

### History

Every cleanup is logged to `~/.diskdoc/history.log`. Run `diskdoc history` to see a table of past cleanups with date, recovered space, items cleaned, and elapsed time.

## What It Cleans

| Category | Examples | Risk |
|----------|----------|------|
| **System** | Apple screensaver cache, Trash, APFS snapshots | SAFE |
| **Apple Intelligence** | ML models, asset packs, translation models | SAFE |
| **Logs** | System logs, diagnostic reports, crash logs | SAFE |
| **Dev Tools** | Xcode DerivedData/Archives/Simulators, Android SDK, CocoaPods, Gradle | SAFE |
| **Dev Toolchains** | Rust (cargo/registry/target), Go modules, Java/Maven/Gradle, Flutter, Python (pip/conda), Ruby gems, Android NDK, JetBrains caches, VS Code extensions | SAFE |
| **Build Artifacts** | node_modules, Rust `target/`, build dirs (via `--dev-artifacts`) | SAFE |
| **App Data** | Docker, Claude, ChatGPT, Kiro, Windsurf, Cursor | SAFE |
| **Electron Apps** | Sandbox containers for Electron-based apps | SAFE |
| **Caches** | Any `~/Library/Caches/*` entry over the size threshold | SAFE |
| **Pkg Managers** | npm, pnpm, yarn, pip, Homebrew | SAFE |
| **Media** | GarageBand, Logic Pro, Final Cut Pro sound libraries and render files | REBUILD |
| **Personal** | Mail downloads, Messages attachments, iCloud Drive cache, Photos library faces/derivatives | PERSONAL |
| **Ghost Apps** | Caches and containers from uninstalled applications | SAFE |

Everything tagged SAFE or REBUILD is a cache, build artifact, or regenerable data. **PERSONAL items are never auto-deleted** — they only appear in `--report` mode and interactive mode with clear warnings.

## How It Works

1. Scans known space hogs (idleassetsd, Docker, Xcode, Android, ML models, etc.)
2. Detects APFS local snapshots and highlights them with ★
3. Dynamically scans `~/Library/Caches/*` for anything over the size threshold
4. Finds `node_modules` and Rust `target/` directories across your code directories
5. Scans Electron and sandbox containers, deduplicating already-known entries
6. Detects ghost app data — caches from apps you already uninstalled
7. Presents a sorted, color-coded table with categories, risk levels, and ★ highlights
8. Interactive selector — pick exactly what to delete
9. Uses official cleanup commands where available (`tmutil`, `xcrun simctl`, `docker system prune`, `qlmanage`)
10. Cleans and shows a before/after report with progress bars
11. Saves cleanup to history log

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
- Bash 3.2+ (ships with macOS)
- `sudo` access (for scanning system directories like idleassetsd and logs)

## Contributing

Found another hidden space hog? Open an issue or PR. The more eyes on this, the harder it is for Apple to hide.

## License

MIT — do whatever you want with it.
