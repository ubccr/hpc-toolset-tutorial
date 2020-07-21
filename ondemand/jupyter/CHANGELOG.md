# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Increased verbosity of output to make debugging easier.
- Does not launch template script as login shell anymore to speed up load time.

### Fixed
- Fix job not ending if forked processes still running.

### Removed
- Removed support for Anaconda Notebook extensions.

## [1.0.1] - 2018-01-03
### Changed
- Updated date in `LICENSE.txt`.

### Fixed
- Remove ERB from YAML comments to avoid possible crash.
  [#4](https://github.com/OSC/bc_example_jupyter/issues/4)

## 1.0.0 - 2017-11-15
### Added
- Initial release!

[Unreleased]: https://github.com/OSC/bc_example_jupyter/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/OSC/bc_example_jupyter/compare/v1.0.0...v1.0.1
