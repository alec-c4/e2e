# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.0] - 2026-02-13

### Added

- DSL wait helpers: `wait_for`, `wait_for_text`, `wait_for_current_path`, and `wait_for_flash`
- Action helpers with built-in waiting: `click_button_and_wait_for_text`, `click_link_and_wait_for_text`, `click_button_and_wait_for_path`, `click_link_and_wait_for_path`, `click_button_and_wait_for_flash`, `click_link_and_wait_for_flash`
- Configurable flash selectors via `E2E.config.flash_selectors`

## [0.5.0] - 2026-02-09

### Added

- Minitest integration now includes auto-waiting assertions: `assert_text`, `refute_text`, `assert_selector`, `refute_selector`, `assert_current_path`, `refute_current_path`
- `E2E::Minitest::TestCase` now automatically quits the browser session after the test suite finishes

## [0.4.2] - 2026-02-07

### Fixed

- RuboCop configuration now correctly disables `Capybara/SpecificFinders` cop for E2E tests, preventing false positive suggestions to use `find_by_id` (which is not supported by this gem)

## [0.4.1] - 2026-02-07

### Added

- `have_no_content` / `have_no_text` matchers with auto-waiting support
- `have_no_current_path` matcher with auto-waiting support

### Fixed

- `have_current_path` (and its negation) no longer crashes on invalid URIs (e.g., `data:` URLs)

## [0.4.0] - 2026-02-06

### Added

- **Auto-waiting matchers:** `have_text`, `have_content`, and `have_current_path` now automatically retry until the expected condition is met or the timeout expires, eliminating flaky tests caused by page transitions and async rendering
- `have_current_path` matcher for asserting the current URL path with auto-waiting (supports exact strings and regexps)
- `E2E.wait_until` helper method for custom waiting logic in tests
- `wait_timeout` configuration option (default: 5 seconds) to control how long matchers wait before failing
- `text` method on page/session for reading visible text content of the page body

### Changed

- `fill_in` now matches fields by label, placeholder, id, and name (Capybara-like behavior) instead of only CSS selectors, with fallback to direct CSS selector

## [0.3.2] - 2026-02-05

### Fixed

- `Playwright::TargetClosedError` on CI environments without X-server by only enabling debug console in headed mode
- `pause` now raises a clear error when called in headless mode instead of failing silently

## [0.3.1] - 2026-02-05

### Fixed

- `uninitialized constant RSpec::Matchers` error when loading the gem in environments where RSpec is only partially initialized (e.g., via `Bundler.require`)
- Matchers are now only defined if `RSpec::Matchers` is actually present
- Matchers are no longer automatically loaded by `require "e2e"`; they are now explicitly loaded via `require "e2e/rspec"`

## [0.3.0] - 2026-02-05

### Added

- Custom RSpec matchers: `have_class`, `have_text`/`have_content`, `have_value`, `have_attribute`, `be_visible`, `be_checked`, `be_disabled`/`be_enabled`
- Element API methods: `classes`, `has_class?`, `visible?`, `[]`, `value`, `checked?`, `disabled?`, `enabled?`
- Improved debugging documentation and fixed `pause` helper

## [0.2.0] - 2026-02-05

### Added

- Browser switching support for Chromium, Firefox, and WebKit via `E2E.config.browser_type`
- `E2E.reset_session!` for dynamic session management
- `rails g e2e:install` generator with test framework detection (RSpec/Minitest) and RuboCop config injection
- `rails g e2e:test` generator for scaffolding test files
- Minitest support via `E2E::Minitest::TestCase`
- RuboCop integration with automatic `inherit_gem` injection
- `pause` helper for Playwright Inspector

## [0.1.0] - 2026-02-05

### Added

- Initial release of `e2e` gem, a unified testing framework wrapper around Playwright
- Playwright driver implementation using `playwright-ruby-client` (IPC/Pipes)
- Capybara-like DSL: `visit`, `click_button`, `click_link`, `fill_in`, `check`, `uncheck`, `attach_file`, `find`, `all`
- `E2E.enable_shared_connection!` for fast transactional tests in Rails
- Rack application booting via `E2E.config.app`
- Basic RSpec integration (`type: :e2e`)
