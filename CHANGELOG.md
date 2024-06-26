# Changelog

All notable changes to the `watchable` package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2024-06-26

- Static Analysis Fix

## [1.0.0] - 2024-06-26

### Added
- Initial release of the `watchable` package
- `Watchable<T>` class for wrapping values and notifying listeners of changes
- `WatchableBuilder` widget for efficiently rebuilding UI when state changes
- Static methods in `WatchableBuilder` for combining multiple `Watchable` instances:
  - `fromList`
  - `from2`
  - `from3`
  - `from4`
  - `from5`
- Basic documentation and examples