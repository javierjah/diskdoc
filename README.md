# diskdoc

A fast, opinionated disk cleanup CLI for macOS developers.

Your Mac says the disk is full but you can't find what's eating it? `diskdoc` knows where to look.

## The Problem

macOS hides space in places Finder and "Storage" settings won't show you:

- **Apple's screensaver cache** (`idleassetsd`) can silently grow to **100GB+**
- **Docker** accumulates images and volumes without bounds
- **Xcode** leaves behind simulators and build artifacts worth tens of GBs
- **node_modules** multiply across dozens of projects
- **App caches** (Spotify, Chrome, Slack, AI tools) pile up indefinitely

`diskdoc` finds all of it, shows you exactly what it'll delete, and cleans it in one shot.

## Install

**curl (quickest):**
```bash
curl -fsSL https://raw.githubusercontent.com/javierjah/diskdoc/main/install.sh | bash
```

**Homebrew:**
```bash
brew install javierjah/tap/diskdoc
```

**Manual:**
```bash
git clone https://github.com/javierjah/diskdoc.git
cd diskdoc
make install
```

## Usage

```bash
# Scan, review, confirm, clean
diskdoc

# Preview only — see what would be cleaned
diskdoc --scan

# Clean without asking (for scripts/cron)
diskdoc --auto
```

## What It Cleans

| Category | Examples | Risk |
|----------|----------|------|
| **System** | Apple screensaver cache, Trash | Safe — regenerates |
| **Dev Tools** | Xcode DerivedData, iOS Simulators, Android SDK, node_modules | Safe — rebuild on demand |
| **App Data** | Docker volumes, Claude/ChatGPT/Kiro/Windsurf/Cursor caches | Recreated on launch |
| **Caches** | Spotify, Chrome, Edge, Firefox, Slack, Telegram, Zoom, etc. | Safe — all regenerate |
| **Pkg Managers** | npm, pnpm, yarn, Homebrew caches | Safe — re-downloads |

Everything `diskdoc` targets is either a cache, build artifact, or regenerable data. **Nothing personal is ever deleted.**

## How It Works

1. Scans known space hogs (idleassetsd, Docker, Xcode, etc.)
2. Dynamically scans `~/Library/Caches/*` for anything over 50MB
3. Finds `node_modules` across your code directories
4. Presents a sorted, color-coded table
5. Asks for confirmation (unless `--auto`)
6. Cleans everything and shows before/after stats

## Origin Story

Born from a real debugging session where a 500GB Mac had only 6GB free with no visible large files. The culprit? `com.apple.idleassetsd` had silently eaten **99GB** caching screensaver videos. After recovering 216GB by investigating every hidden corner of macOS, the cleanup process was automated into `diskdoc`.

## Requirements

- macOS (tested on Sonoma and Sequoia)
- Bash 3.2+ (ships with macOS)
- `sudo` access (for scanning system temp directories)

## License

MIT
