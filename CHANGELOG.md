# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-02-05

### Added
- **Browser Switching:** Support for Chromium, Firefox, and WebKit via `E2E.config.browser_type`.
- **Dynamic Session Management:** `E2E.reset_session!` to handle browser switching mid-suite.
- **Generators:**
    - `rails g e2e:install` now detects test framework (RSpec/Minitest) and injects RuboCop config.
    - `rails g e2e:test` scaffolds test files based on the detected framework.
- **Minitest Support:** Full integration via `E2E::Minitest::TestCase`.
- **RuboCop Integration:** Automatic injection of `inherit_gem` to relax rules for E2E specs.
- **Debugging:** `pause` helper for calling Playwright Inspector.

## [0.1.0] - 2026-02-05

### Added
- **Core:** Initial release of `e2e` gem, a unified testing framework wrapper around Playwright.
- **Drivers:** Playwright driver implementation using `playwright-ruby-client` (IPC/Pipes).
- **DSL:** Capybara-like API including `visit`, `click_button`, `click_link`, `fill_in`, `check`, `uncheck`, `attach_file`, `find`, `all`.
- **Performance:** `E2E.enable_shared_connection!` for supporting fast transactional tests in Rails.
- **Rails Integration:** Rack application booting (`E2E.config.app`).
- **RSpec Support:** Basic RSpec integration (`type: :e2e`).
