# Changelog

## [3.0.0] - 2026-04-06

### Added

#### Risk Level System
- SAFE / REBUILD / PERSONAL risk tags on every scan item
- Color-coded display: green (SAFE), yellow (REBUILD), magenta (PERSONAL)
- PERSONAL items auto-skipped in `--auto` mode

#### New Scan Categories
- **Apple Intelligence & ML**: Siri models, translation assets, asset packs, intelligent suggestions
- **APFS Snapshots**: Time Machine local snapshots with ★ highlight and `tmutil thinlocalsnapshots` cleanup
- **iOS Backups (enhanced)**: Highlighted with ★, tagged PERSONAL
- **Xcode Extended**: Old archives, unavailable simulators (`xcrun simctl delete unavailable`), documentation cache
- **Mail & Messages**: Mail downloads and Messages attachments (PERSONAL)
- **Logs & Diagnostics**: System logs, diagnostic reports, crash reporter data
- **Dev Toolchains**: Rust (cargo/registry), Go modules, Java/Maven/Gradle, Flutter, Python (pip/conda/venv), Ruby gems, Android NDK, JetBrains IDE caches, VS Code extensions
- **Electron & Sandbox Containers**: Dynamic scanning of Group Containers with deduplication
- **Apple Media**: GarageBand, Logic Pro, Final Cut Pro sound libraries and render files (REBUILD)
- **iCloud Drive**: Local cache (PERSONAL)
- **QuickLook & Font Caches**: QuickLook thumbnails (with `qlmanage -r cache` cleanup), font caches
- **Photos Library**: Faces metadata and derivatives (PERSONAL)

#### Ghost Apps Detector
- Detects caches and containers from uninstalled applications
- Checks `/Applications`, `~/Applications`, `/System/Applications`, and Spotlight
- Scans both `~/Library/Caches` and `~/Library/Group Containers`

#### New Flags & Modes
- `--report` — Full audit tree organized by category, includes PERSONAL items, no deletion
- `--dev-artifacts` — Deep scan for `node_modules`, Rust `target/`, and `build/` directories across code directories
- `--profile personal` — Filter to personal data categories only

#### Official Command Wrappers
- `tmutil thinlocalsnapshots` for APFS snapshot cleanup
- `xcrun simctl delete unavailable` for dead iOS simulators
- `docker system prune -a --volumes -f` for Docker cleanup
- `qlmanage -r cache` for QuickLook cache reset

#### Structural Improvements
- ★ highlighted sections: APFS snapshots and iOS backups sort to top regardless of size
- Dynamic asset pack scanning in `~/Library/Assets/`
- Priority sorting: star items always appear first in the table

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
