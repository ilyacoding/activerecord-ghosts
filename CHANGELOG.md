# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.2] - 2025-08-26

- Minor fixes of dependencies

## [0.0.1] - 2025-08-25

### Added
- Initial release of ActiveRecord::Ghosts
- `has_ghosts` method to define ghost sequences on ActiveRecord models
- Support for range queries that return mix of real and ghost records
- Enumerator support for infinite sequences
- Ghost records that inherit `where` conditions from parent relation
- Performance warnings for unindexed ghost columns
- Support for Rails 7.0+ and Ruby 3.4+
- Comprehensive test suite covering Rails and Ruby compatibility

### Features
- Ghost records behave like AR objects but aren't persisted
- `ghost?` method to identify ghost records
- Works with ActiveRecord associations and scopes
- Efficient batching for large datasets via enumerators
- Custom inspect output for ghost records
