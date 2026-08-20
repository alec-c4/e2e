# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.3] - 2026-08-20

### Fixed

- `E2E::Server` eager loads a Rails app (once, before the in-process WEBrick thread starts) to close a rare full-process deadlock: Zeitwerk's per-loader autoload monitor and Ruby's own internal `require` lock can deadlock each other (a classic lock-ordering inversion) when the server thread and the caller's thread each reference a not-yet-loaded app constant for the first time at the same moment. The process idles at ~0% CPU forever with no exception raised. Only reproduces when `config.eager_load` is off (the common local-dev/test setting; CI setups that force eager loading were never affected). Opt out with `config.eager_load_app = false`.

## [0.7.2] - 2026-08-13

### Added

- `E2E.config.ensure_vite_assets` (`:auto` by default) builds ViteRuby test assets once before the e2e suite (RSpec `before(:suite)`, Minitest `before_setup`). Modes: `:auto` (build when ViteRuby is loaded), `:build` (require ViteRuby), `:warn`, `:skip`. Serialized with a flock so only one process compiles; ViteRuby skips compile when the watched-files digest is unchanged. Escape hatch: `SKIP_VITE_TEST_BUILD=1`.
- Install generator documents `ensure_vite_assets` in the helper template.

### Fixed

- Inertia / vite_rails apps no longer silently run e2e against a stale `public/vite-test` bundle when specs are started without a manual `bin/vite build --mode=test`.

## [0.7.1] - 2026-08-05

### Fixed

- Shared ActiveRecord connection now also overrides `lease_connection` and `with_connection` (Rails 7.2+/8), preventing intermittent deadlocks where the example thread held the only pool connection during Playwright navigation while the WEBrick thread sat `idle in transaction`
- `E2E::Rails.enable_shared_connection!` no longer crashes on Rails 7.0/7.1, where `lease_connection`/`with_connection` don't exist yet; it bootstraps and falls back through `connection` instead
- Playwright `visit` defaults to `waitUntil: "domcontentloaded"` with a configurable navigation timeout so pages with third-party iframes (YouTube/Vimeo) no longer hang on full `load`
- Blocking Playwright actions (`click`, `fill_in`, etc.) release the example thread's sticky AR lease while waiting for the browser when shared connection is enabled
- WEBrick test server is shut down after the RSpec/Minitest suite finishes
- `E2E::Server` resolves the WEBrick handler via `Rack::Handler` on Rack 2.x stacks (e.g. Rails 7.0/7.1, which pin `rack ~> 2.2`), where the `rackup` gem has no `Handler` module of its own

### Added

- `E2E.config.navigation_wait_until` (default: `"domcontentloaded"`)
- `E2E.config.navigation_timeout` (default: `30` seconds)
- `E2E.stop_server!`

## [0.7.0] - 2026-07-15

### Changed

- Minimum required Ruby version raised from 3.2 to 3.3

## [0.6.1] - 2026-04-15

### Removed

- `Capybara/SpecificFinders` RuboCop rule removed from `config/rubocop.yml` — the gem has no Capybara dependency

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
