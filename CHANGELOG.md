# Changelog

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
