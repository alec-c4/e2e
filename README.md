# E2E

**Unified, high-performance E2E testing framework for Ruby.**

`e2e` is a modern wrapper around **Playwright**, designed to bring the elegance of Capybara and the speed of raw browser automation together.

[![Gem Version](https://badge.fury.io/rb/e2e.svg)](https://badge.fury.io/rb/e2e)
[![Build Status](https://github.com/alec-c4/e2e/actions/workflows/main.yml/badge.svg)](https://github.com/alec-c4/e2e/actions)

## Why E2E?

- **⚡️ Blazing Fast:** Uses direct IPC (Pipes) to communicate with the browser, avoiding HTTP overhead.
- **🧩 Plug & Play:** Zero configuration for most Rails apps. Includes a generator.
- **💎 Clean DSL:** Idiomatic Ruby API (`click_button`, `find`, `visit`) that feels like home.
- **🚀 Modern Engine:** Powered by Microsoft Playwright (WebKit, Firefox, Chromium).
- **🛠 Escape Hatch:** Direct access to the `native` Playwright object for **any** complex scenario.
- **🔄 Shared Connection:** Built-in support for sharing DB connections between test and app threads (transactional tests support).
- **👮‍♀️ Lint Friendly:** Includes auto-configuration for RuboCop to respect E2E testing patterns.

## Installation

Add this line to your application's `Gemfile`:

```ruby
group :test do
  gem "e2e"
end
```

And then execute:

```bash
bundle install
npx playwright install # Install browser binaries
```

### Rails Setup

Run the generator to create the helper file:

```bash
rails g e2e:install
```

This will create `spec/e2e_helper.rb` (for RSpec) or `test/e2e_helper.rb` (for Minitest) and configure your `.rubocop.yml`.

## RuboCop Integration

`e2e` comes with a built-in RuboCop configuration that relaxes strict RSpec rules (like `DescribeClass` or `ExampleLength`) which are often not suitable for high-level E2E tests.

The generator adds this to your `.rubocop.yml` automatically:

```yaml
inherit_gem:
  e2e: config/rubocop.yml
```

This will apply the following changes to all files in `spec/e2e/` and `test/e2e/`:

- Disable `RSpec/DescribeClass` and `RSpec/DescribeMethod`.
- Disable `RSpec/ExampleLength` and `RSpec/MultipleExpectations`.
- Increase `RSpec/NestedGroups` allowance.

## Usage

You can generate a new test using:

```bash
rails g e2e:test UserLogin
```

### RSpec Example

Write your tests in `spec/e2e/`.

```ruby
# spec/e2e/login_spec.rb
require "e2e_helper"

RSpec.describe "User Login", type: :e2e do
  it "signs in successfully" do
    visit "/login"

    fill_in "Email", with: "user@example.com"
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page.body).to include("Welcome, User!")
  end
end
```

### Minitest Example

Write your tests in `test/e2e/`.

```ruby
# test/e2e/login_test.rb
require "e2e_helper"

class UserLoginTest < E2E::Minitest::TestCase
  def test_sign_in
    visit "/login"

    fill_in "Email", with: "user@example.com"
    fill_in "Password", with: "password"
    click_button "Sign In"

    assert_includes page.body, "Welcome, User!"
  end
end
```

## Debugging & UI Mode

By default, tests run in **headless** mode (no browser window). For debugging, you can run tests in **headful** mode to see what's happening.

### Running with a visible browser

Set the `HEADLESS` environment variable to `false`:

```bash
HEADLESS=false bundle exec rspec spec/e2e
```

### Pausing for Debugging

If the browser closes too fast, you can pause the execution to inspect the page or step through the test. This will open the **Playwright Inspector**.

Add this to your test:

```ruby
it "debugs something" do
  visit "/path"
  pause # The test will stop here, and a debugger UI will open
  click_button "Submit"
end
```

Alternatively, you can just use `sleep(10)` if you want the browser to stay open for a few seconds without opening the inspector.

### Automatic Screenshots

If a test fails in RSpec, a screenshot is automatically saved to `tmp/screenshots/` for quick investigation.

### API Reference

#### Navigation

```ruby
visit("/path")
current_url
```

#### Interaction

```ruby
click_button "Submit"
click_link "Read more"
click "#nav-menu" # CSS selector

fill_in "Email", with: "test@example.com"
check "I agree"
uncheck "Subscribe"
attach_file "#upload", "path/to/file.png"
```

#### Finding Elements

```ruby
find(".btn")          # Returns E2E::Element
all("li")             # Returns Array<E2E::Element>
find("button", text: "Save") # Filter by text
```

#### Assertions & Data

```ruby
page.body             # Full HTML
evaluate("document.title") # Execute JS
save_screenshot("tmp/screen.png")
```

### 🔓 Native Access (The Escape Hatch)

We believe you shouldn't be limited by the wrapper. You can access the underlying `Playwright::Page` object at any time using `.native`.

**This means you have access to 100% of Playwright's features.**

#### 1. Keyboard Shortcuts

```ruby
find("input").click
page.native.keyboard.press("Enter")
page.native.keyboard.press("Control+C")
```

#### 2. Network Interception (Mocking)

```ruby
page.native.route("**/api/users") do |route|
  route.fulfill(status: 200, body: '{"users": []}')
end
```

#### 3. Handling Dialogs (Alerts/Confirms)

```ruby
page.native.on("dialog") do |dialog|
  dialog.accept
end
click_button "Delete Account"
```

#### 4. Emulation (Mobile/Dark Mode)

```ruby
page.native.viewport_size = { width: 375, height: 667 }
page.native.emulate_media(color_scheme: 'dark')
```

## Performance: Transactional Tests

By default, Rails system tests run in a separate thread, meaning they can't see data created in a database transaction.
`e2e` solves this with **Shared Connection**.

Enable it in your `spec/e2e_helper.rb`:

```ruby
E2E.enable_shared_connection!
```

Now you can use fast transactional tests (standard RSpec behavior) instead of slow `DatabaseCleaner` truncation strategies.

## Configuration

```ruby
E2E.configure do |config|
  config.headless = ENV.fetch("HEADLESS", "true") == "true"
  config.app = Rails.application # Automatic Rack booting
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
