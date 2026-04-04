# diskdoc

Your Mac says the disk is full. You open Storage settings. It shows a colorful bar that explains nothing. You click "Manage" and it suggests deleting your photos or buying iCloud. You have 500GB and can't save a screenshot.

**This is by design.**

Apple doesn't want you to find what's eating your disk. They want you to buy a new Mac. Or pay for iCloud. Or "upgrade" to the model with more storage. The entire Storage UI is built to make you feel helpless — to make the problem feel unsolvable without opening your wallet.

`diskdoc` is the tool Apple will never build. One command. Full transparency. You choose what to delete.

## What Apple Won't Tell You

macOS silently fills your disk with things you never asked for:

- **`com.apple.idleassetsd`** — Apple's screensaver daemon downloads aerial videos to a hidden system folder. It can grow to **100GB+** without any notification, any setting, any warning. There is no UI to see it. There is no UI to delete it. It just eats your disk until you can't work.
- **Docker, Xcode, Android Studio** — dev tools that accumulate build caches, simulators, and volumes until they consume more space than your actual projects.
- **App caches** — Spotify, Chrome, Slack, ChatGPT, Claude, Telegram — every app caches aggressively and none of them clean up after themselves.
- **node_modules** — if you're a developer, you have dozens of copies of the same packages scattered across forgotten projects.

None of this shows up in Finder. None of it shows up in "Storage Management." The space just disappears, and Apple's answer is: buy more.

**No.** The answer is `diskdoc`.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/javierjah/diskdoc/main/install.sh | bash
```

Or manually:
```bash
git clone https://github.com/javierjah/diskdoc.git
cd diskdoc
make install
```

## Usage

```bash
# Scan, select what to delete, clean
diskdoc

# Preview only — see what's eating your disk
diskdoc --scan

# Clean everything without asking (for scripts/cron)
diskdoc --auto
```

### Interactive Selection

`diskdoc` doesn't just dump a list and ask "delete all?" — it gives you full control:

```
  > [x] Apple Screensavers (idleassetsd)        99.2 GB
    [x] Docker Data                              30.1 GB
    [ ] Android SDK                              25.0 GB   ← deselected
    [x] iOS Simulators                           11.0 GB
    [x] Cache: com.spotify.client                 6.8 GB

  Selected: 4/5 items — 147.1 GB
  arrows=move  space=toggle  a=all  n=none  enter=confirm  q=cancel
```

Navigate with arrow keys. Toggle with space. You decide what stays and what goes.

## What It Cleans

| Category | Examples | Risk |
|----------|----------|------|
| **System** | Apple screensaver cache, Trash | Safe — regenerates |
| **Dev Tools** | Xcode DerivedData, iOS Simulators, Android SDK, node_modules | Safe — rebuild on demand |
| **App Data** | Docker, Claude, ChatGPT, Kiro, Windsurf, Cursor | Recreated on launch |
| **Caches** | Spotify, Chrome, Edge, Firefox, Slack, Telegram, Zoom | Safe — all regenerate |
| **Pkg Managers** | npm, pnpm, yarn, Homebrew | Safe — re-downloads |

Everything `diskdoc` targets is a cache, build artifact, or regenerable data. **Nothing personal is ever deleted.**

## How It Works

1. Scans known space hogs (idleassetsd, Docker, Xcode, etc.)
2. Dynamically scans `~/Library/Caches/*` for anything over 50MB
3. Finds `node_modules` across your code directories
4. Presents a sorted, color-coded table
5. Interactive selector — pick exactly what to delete
6. Cleans and shows a before/after report with progress bars

No dependencies. No runtime. Just a bash script that does what macOS refuses to.

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
- `sudo` access (for scanning system temp directories)

## Contributing

Found another hidden space hog? Open an issue or PR. The more eyes on this, the harder it is for Apple to hide.

## License

MIT — do whatever you want with it.
