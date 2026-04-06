# Changelog

## [3.0.0] - 2026-04-06

### Breaking Changes
- **Requires bash 4+** — macOS ships bash 3.2 (2007, GPLv3 licensing). Install with `brew install bash`.
- Rewritten interactive selector with collapsible category trees (bash 4+ associative arrays)

### Added

#### Untouchable Category (NEW)
- Report-only section showing system-critical items that cannot be safely deleted
- Educational explanations for each item (why it exists, whose fault it is)
- Items: dyld shared cache, Rosetta 2 AOT cache, sleepimage, swap files, /Library/Updates, StagedFrameworks
- Triple-lock safety: separate U_* arrays, dedicated `scan_untouchable_target()`, auto mode guard
- `--test-untouchable-safety` flag to verify isolation
- Presented in report mode with `draw_box()` and lock icons

#### macOS Version Detection
- `detect_macos_version()` supporting Catalina (10.15) through Tahoe (26)
- Codename mapping (Mojave, Catalina, Big Sur, Monterey, Ventura, Sonoma, Sequoia, Tahoe)
- Mail database version mapping (V6-V10) based on macOS version
- Version-aware paths: Spotlight (pre-Big Sur vs Big Sur+), dyld cache (3 variants)

#### Tier 1 Scanners — Massive Impact (20-500+ GB)
- **Virtualization**: Parallels (all locations + App Store sandbox), VMware Fusion, UTM (direct + sandboxed), Lima, Colima, OrbStack (sparse-file aware with `du`), Tart (VMs + OCI cache), Vagrant, VirtualBox, Multipass
- **Docker.raw**: Sparse file detection with actual-on-disk reporting
- **Creative**: Adobe CC (media cache, After Effects per-version disk cache, support dirs), Lightroom (previews, smart previews, backups), DaVinci Resolve (cache DB + support)
- **Mail**: Versioned database scanning (V6-V10), active version detection, sync logs, downloads
- **/var/folders**: Per-user temp directories
- **Spotlight**: Version-aware index path scanning with `spotlight-rebuild` cleanup method
- **Google Drive**: DriveFS cache
- **Telegram**: App cache

#### Tier 2 Scanners — Medium Impact
- **Browsers**: Generic `scan_chromium_caches()` with multi-profile support, Safari (6 cache locations), Firefox (profiles + shared cache)
- **Browser Personal**: IndexedDB, File System, LocalStorage, History (PERSONAL risk)
- **Conda**: environments + packages
- **Cloud Storage**: Dropbox cache, OneDrive cache
- **Communication**: Signal, Zoom, Teams
- **Media**: Spotify cache, Steam
- **Game Dev**: Unity (Asset Store, cache, editor), Unreal Engine (engine + DerivedData), Bazel (new + legacy paths)
- **System**: Previously Relocated Items, Saved Application State
- **Pkg Manager**: Homebrew Caskroom .dmg/.pkg cleanup with `caskroom-clean` method

#### Tier 3 Scanners — Small Impact
- **Language ecosystems**: Julia, Haskell, OCaml, Perl, R, Elixir, Nim, Zig, Bun, Deno
- **Version managers**: nvm, volta, fnm, phpenv, luaenv
- **Build tools**: CMake, ccache, Buck, Pants, Meson, Ninja, sccache
- **Container tools**: Podman, nerdctl, Rancher Desktop, containerd
- **Creative tools**: Sketch, Figma (local), Blender
- **Gaming**: Epic Games Launcher, GOG Galaxy
- **Messaging**: WhatsApp, Line, Viber, WeChat, Messenger
- **Media downloads**: Apple TV downloads, Apple Music media, Podcasts, Books
- **Orphaned Group Containers**: Detects containers from uninstalled apps via Spotlight/Applications check
- **Minor directories**: HTTPStorages, Autosave Info, Metadata, Suggestions

#### Ghost Apps Detector
- Detects caches and containers from uninstalled applications
- Checks `/Applications`, `~/Applications`, `/System/Applications`, and Spotlight
- Scans both `~/Library/Caches` and `~/Library/Group Containers`

#### UI Redesign
- **16 ANSI semantic colors**: C_SUCCESS, C_WARNING, C_DANGER, C_INFO, C_MUTED, C_ACCENT
- **NO_COLOR support**: Respects no-color.org standard
- **Eighth-block proportional bars**: `draw_bar()` using ▏▎▍▌▋▊▉█░
- **Braille spinner**: `spinner_start()`/`spinner_stop()` with ⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏
- **Generic `draw_box()`**: Rounded Unicode box-drawing (╭╮╰╯), used across banner, doctor, report, untouchable
- **Collapsible category trees**: Bash 4+ associative arrays, ←/→ expand/collapse, space toggles category
- **Status bar**: Selected count + total at bottom
- **Detail panel**: Shows path, risk, method for highlighted item
- **Risk icons**: Emoji (🟢🟡🔴🔒) with ANSI fallback (●▲■) for non-emoji terminals

#### Risk Level System (Enhanced)
- SAFE / REBUILD / PERSONAL risk tags (from v2)
- **NEW: UNTOUCHABLE** — system-critical items, magenta color, lock icon, never deletable
- Color-coded: green (SAFE), yellow (REBUILD), red (PERSONAL), magenta (UNTOUCHABLE)
- PERSONAL and UNTOUCHABLE items auto-skipped in `--auto` mode

#### Profiles (Updated)
- `apps` profile now includes Virtualization, Browser, Creative, Mail categories
- `system` profile now includes System Temp (/var/folders)
- `personal` profile now includes Browser Personal data

#### Official Command Wrappers
- `tmutil thinlocalsnapshots` for APFS snapshot cleanup
- `xcrun simctl delete unavailable` for dead iOS simulators
- `docker system prune -a --volumes -f` for Docker cleanup
- `qlmanage -r cache` for QuickLook cache reset
- `sudo mdutil -E /` for Spotlight index rebuild
- `caskroom-clean` for Homebrew Caskroom installer cleanup

#### Structural
- All scanners wrapped in `run_all_scans()` function for proper variable scoping
- Per-VM individual reporting (not aggregated) for all virtualization platforms
- Sparse file handling — always `du`, never `ls` for Docker.raw and OrbStack
- Dynamic scanning of Group Containers with deduplication against known entries
- Scanner output with category headers and progress indicators

## [2.0.0] - 2026-04-05

### Added
- Interactive item selector with arrow key navigation, space to toggle, a/n for all/none
- Dry-run mode (`--dry-run`) showing exact deletion commands
- JSON output mode (`--json`) for piping into other tools
- Profile filtering (`--profile dev|system|apps`)
- Minimum size threshold (`--min-size N`)
- Exclusion file support (`~/.diskdocrc`)
- Doctor mode (`diskdoc doctor`) for disk diagnosis
- History tracking (`diskdoc history`) with logged cleanups
- Homebrew formula and install script

## [1.0.0] - 2026-04-04

### Added
- Initial release
- Scan mode (`--scan`) to preview without deleting
- Auto mode (`--auto`) for unattended cleanup
- Interactive mode with confirmation prompt
- Dynamic cache detection (scans all ~/Library/Caches entries)
- Apple idleassetsd screensaver cache detection (the #1 hidden space hog)
- Docker data cleanup
- Xcode DerivedData and iOS Simulator cleanup
- Android SDK detection
- node_modules scanning across code directories
- Package manager cache cleanup (npm, pnpm, yarn, Homebrew)
- AI tool cache cleanup (Claude, ChatGPT, Kiro, Windsurf, Cursor)
- Color-coded table with size-based highlighting
- Before/after progress bar visualization
- Detailed final report with recovered space stats
