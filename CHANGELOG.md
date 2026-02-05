# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-02-05

### Added
- **Core:** Initial release of `e2e` gem, a unified testing framework wrapper around Playwright.
- **Drivers:** Playwright driver implementation using `playwright-ruby-client` (IPC/Pipes).
- **DSL:** Capybara-like API including `visit`, `click_button`, `click_link`, `fill_in`, `check`, `uncheck`, `attach_file`, `find`, `all`.
- **Performance:** `E2E.enable_shared_connection!` for supporting fast transactional tests in Rails (avoids `DatabaseCleaner` truncation).
- **Rails Integration:**
    - `rails g e2e:install` generator for quick setup (RSpec/Minitest detection).
    - `rails g e2e:test` generator for scaffolding tests.
    - Automatic Rack application booting (`E2E.config.app`).
- **Test Frameworks:**
    - Full RSpec support (`type: :e2e`) with auto-screenshots on failure.
    - Full Minitest support (`E2E::Minitest::TestCase`).
- **Linting:** Built-in RuboCop configuration injection via `inherit_gem` to relax strict rules for E2E tests.
- **Debugging:**
    - `save_screenshot` helper.
    - `page.native` escape hatch for accessing raw Playwright objects (Network interception, Emulation, etc.).