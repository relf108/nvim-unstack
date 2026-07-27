# Changelog

All notable changes to nvim-unstack will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.4.0] - 2026-07-27

### Added
- Pytest parser now handles `ERROR` collection summary lines (e.g. `ERROR tests/unit/test_utils.py`)
- Shared wrap-aware traceback parsing utility (`util/unwrap.lua`) used by all parsers
- Regression tests for wrapped and unwrapped traces across Python, Pytest, Node.js, Ruby, and Go

### Fixed
- Paths hard-wrapped by the terminal are correctly rejoined at any terminal width
- Quickfix entries no longer corrupted by caret/header lines being glued onto file paths during unwrapping
- Duplicate quickfix entries for the same file and line are removed
- Wrap-continuation segments that look like standalone locations no longer emit partial paths
- C# parser keeps Windows drive-letter colons (`C:\...`) in file paths
- Parser selection popup tests broken since their introduction

## [1.3.1] - 2026-03-02

### Fixed
- Improved line wrapping handling for stack traces across all parsers

## [1.3.0] - 2026-01-20

### Added
- Popup selection menu when multiple parsers match a stack trace
- `quickfix_list` layout option for opening traces in quickfix window
- `exclude_patterns` configuration option with sensible defaults to filter out common noise
- Line wrapping handling by concatenating tracebacks as single string

### Changed
- Documented new `use_first_parser` config option for parser selection behavior
- Updated license with contributor name

### Fixed
- `use_first_parser=true` no longer breaks filetype detection
- Pytest FAIL line now defaults to 1 when nil

## [1.2.0] - 2026-01-16

### Added
- Configuration tests to validate setup options
- Debug test script for interactive test debugging

### Changed
- Improved `mapkey` configuration handling - now accepts `false` to disable default mapping
- Moved keymap setup from plugin to init.lua for better lazy-loading support

### Fixed
- Fixed lazy loading on `:NvimUnstack` command - configuration now properly initializes
- Configuration now correctly respects `mapkey = false` to skip default key binding

## [1.1.0] - 2026-01-14

### Added
- Comprehensive test suite with 32 tests covering all parsers and features
- Tests for Python, Pytest, Node.js, Ruby, and Go parsers
- Configuration validation tests
- Error handling tests
- Parser edge case tests
- Multiple match extraction tests

### Changed
- Improved Makefile with better dependency management and help system
- Added `make help`, `make clean`, and improved CI targets
- Enhanced documentation generation workflow
- All internal parser functions now properly marked as `@private`
- Updated README with accurate configuration options

### Fixed
- Node.js parser now correctly extracts file paths (fixed parenthesis matching)
- Go parser now strips leading whitespace from file paths
- Removed non-functional `vertical_alignment` configuration option
- Documentation now only exposes public API (NvimUnstack.options and NvimUnstack.setup)
- Added missing `@param` and `@return` annotations to all parsers

## [1.0.1] - Previous Release

### Added
- Pytest traceback parsing support
- Comprehensive documentation with detailed configuration options
- API documentation for programmatic usage
- Examples for custom language parser creation
- Sign customization examples

### Changed  
- Updated README with complete feature overview and usage examples
- Enhanced Vim help documentation with proper sections and navigation
- Improved installation instructions for all major plugin managers

### Fixed
- Documentation consistency across README and help files

## [1.0.0] - Initial Release

### Added
- Multi-language stack trace parsing (Python, Node.js, Ruby, Go, C#, Perl, GDB/LLDB)
- Flexible layout options (tab, vsplit, split, floating)
- Visual signs for stack trace lines
- Multiple input methods (visual selection, clipboard, tmux)
- Configurable key mappings
- Plugin enable/disable functionality
- Debug logging capabilities
