# Changelog

All notable changes to diskdoc are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] — 2026-04-09

### Fixed
- **Interactive mode input lag**: eliminated ~120 process forks per keypress
  by pre-computing all display data (truncated names, formatted sizes, bar
  graphs, risk colors/icons) once before entering the input loop, replacing
  subshell calls with fast bash-builtin variants, tracking selection totals
  incrementally, and buffering the entire frame into a single write. Result:
  ~240-600ms/keypress → ~5-15ms.

## [1.0.1] — 2026-04-08

### Changed
- Updated README with real scan output examples and improved documentation

## [1.0.0] — 2026-04-08

**First public release.**

After extensive private development and iteration, diskdoc is ready for general use.
The codebase went through several major internal refactors before reaching this
stable baseline — that development history is preserved in git log for the curious.

### What's in 1.0.0

#### Scanner
- Comprehensive macOS scanner covering 250+ known space hogs
- Version-aware scanning for Catalina through Tahoe (macOS 10.15 – 26.x)
- Individual enumeration of VM bundles and browser profiles
- Dynamic scanning of `~/Library/Caches/*` above configurable threshold
- Ghost app detection with single-pass `mdfind` cache for performance
- Orphaned container detection for uninstalled apps

#### Safety & risk classification
- Four-tier risk model: SAFE, REBUILD, PERSONAL, UNTOUCHABLE
- SIP-aware UNTOUCHABLE detection — paths protected by System Integrity
  Protection are routed away from any delete code path
- PERSONAL items (Mail, Messages, browser history) are never auto-deleted
- UNTOUCHABLE items have no delete code path at all — dyld cache, sleepimage,
  Rosetta 2, ML Assets, Simulator Volumes, /var/folders daemon caches
- Exclusions via `~/.diskdocrc` honored absolutely
- Every action logged to `~/.diskdoc/history.log`

#### Interactive experience
- Flat-list paginated selector — works with bash 3.2 (macOS default)
- No pre-checked items; selection is always explicit
- Keyboard navigation, toggle, batch select/deselect
- Live progress indicator during scan
- Detail panel with path, size, category, and risk explanation

#### Reporting
- `--scan` for preview-only mode
- `--report` for full audit with proportional bars and risk tags
- `--dry-run` to see exact `rm` commands without executing
- `--json` for piping and automation
- `--auto` for hands-off cleanup (SAFE items only)
- `--profile` filter for dev, system, apps, or personal workflows

#### Error handling
- Real OS errors surfaced when cleanup fails — no silent failures
- Sudo credentials cached at scan start to prevent mid-scan timeout
- Consistent totals between interactive and report modes

### Requirements
- macOS Catalina (10.15) through Tahoe (26.x)
- bash 3.2 or newer (ships with macOS)
- sudo access for system-level directory scanning

### Known limitations
- Does not detect Spotlight Index issues beyond size reporting
- Does not integrate with Time Machine for protected snapshot management
- macOS only — paths are platform-specific

---

### Development history (pre-1.0.0)

Internal development versions between the first prototype and 1.0.0
are preserved in git history. Notable milestones along the way:

- First prototype: basic cache scanner, ~20 known paths
- Expanded scanner: 250+ paths across dev tools, apps, browsers, media
- Output simplification: removed verbose "nothing found" noise,
  reduced report output by ~70%
- Performance pass: ghost app detection from 97s to <5s via single-pass
  `mdfind` cache; overall scan time roughly halved
- SIP awareness: Tahoe endured `/System/Library/AssetsV2/` and
  `/Library/Developer/CoreSimulator/Volumes/` with SIP, so these moved
  to UNTOUCHABLE with educational messages instead of failing cleanup
- Cleanup error surfacing: replaced silent `2>/dev/null` with real OS
  error capture so users see why a delete actually failed
- Untouchable category: introduced a fourth risk tier with no delete
  code path, preventing any accidental destructive action on system
  paths that macOS protects

These changes are collapsed into 1.0.0 as the baseline public release.
