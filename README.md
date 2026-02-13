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

    expect(page).to have_current_path("/dashboard")
    expect(page).to have_content("Welcome, User!")
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

    assert_text "Welcome, User!"
    assert_current_path "/dashboard"
  end
end
```

## Debugging & UI Mode

By default, tests run in **headless** mode (no browser window). For debugging, you can run tests in **headful** mode to see what's happening.

### Running with a visible browser

Set the `HEADLESS` environment variable to `false`:

```bash
HEADLESS=false bundle exec rspec spec/e2e
# or for minitest
HEADLESS=false ruby test/e2e/login_test.rb
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

If a test fails, a screenshot is automatically saved to `tmp/screenshots/` for quick investigation.

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

fill_in "Email", with: "test@example.com"  # Matches by label, placeholder, id, or name
fill_in "#email", with: "test@example.com" # CSS selector fallback
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

#### RSpec Matchers

All text and path matchers **automatically wait** for the expected condition to be met (up to `wait_timeout` seconds), making your tests resilient to page transitions and async rendering.

```ruby
# Check for content (auto-waiting)
expect(page).to have_text("Success")
expect(page).to have_content("Success")         # Alias for have_text
expect(find(".alert")).to have_text("Success")   # Works on elements too
expect(page).to have_text(/welcome/i)            # Regexp support

# Check current path (auto-waiting)
expect(page).to have_current_path("/dashboard")
expect(page).to have_current_path(/\/users\/\d+/) # Regexp support

# Check for classes
expect(find(".alert")).to have_class("success")
expect(find(".alert")).not_to have_class("error")

# Check visibility
expect(find("#modal")).to be_visible

# Check attributes & value
expect(find("input")).to have_value("test")
expect(find("div")).to have_attribute("data-id", "123")

# Check states
expect(find("#checkbox")).to be_checked
expect(find("button")).to be_disabled
expect(find("input")).to be_enabled
```

#### Minitest Assertions

These assertions mimic the behavior of RSpec matchers, including **auto-waiting**.

```ruby
# Check for content (auto-waiting)
assert_text "Welcome"
refute_text "Error"
assert_text /welcome/i

# Check for specific elements (auto-waiting)
assert_selector ".user-profile"
refute_selector "#loading-spinner"

# Check current path (auto-waiting)
assert_current_path "/dashboard"
assert_current_path /\/users\/\d+/
refute_current_path "/login"
```

#### Assertions & Data

```ruby
page.body             # Full HTML
evaluate("document.title") # Execute JS
save_screenshot("tmp/screen.png")
```

### Auto-Waiting

The `have_text`, `have_content`, and `have_current_path` matchers automatically retry until the condition is met or the configured `wait_timeout` expires (default: 5 seconds). This eliminates flaky tests caused by page navigations, redirects, and async rendering.

```ruby
click_button "Submit"
# No need for sleep or manual waiting — the matcher will poll until
# the page transitions and the expected content appears
expect(page).to have_current_path("/success")
expect(page).to have_content("Your order has been placed")
```

For custom waiting logic, use `E2E.wait_until`:

```ruby
E2E.wait_until(timeout: 10) do
  page.current_url.include?("/ready")
end
```

Or use built-in DSL helpers that raise clear errors on timeout:

```ruby
wait_for { SomeModel.count > 0 }
wait_for_text("Saved")
wait_for_current_path("/dashboard")
wait_for_flash("Profile updated", type: :notice)

click_button_and_wait_for_text("Save", "Saved")
click_link_and_wait_for_text("Next", /done/i)
click_button_and_wait_for_path("Submit", "/dashboard")
click_link_and_wait_for_path("Continue", /checkout/)
click_button_and_wait_for_flash("Save", "Updated", type: :notice)
click_link_and_wait_for_flash("Delete", /failed/i, type: :alert)
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
  config.driver = :playwright
  config.browser_type = :chromium # Options: :chromium (default), :firefox, :webkit
  config.headless = ENV.fetch("HEADLESS", "true") == "true"
  config.app = Rails.application # Automatic Rack booting
  config.wait_timeout = 5 # Seconds to wait in auto-waiting matchers (default: 5)
  config.flash_selectors = {
    any: "[role='alert'], [role='status'], .flash",
    notice: "[role='status'], .flash.notice",
    alert: "[role='alert'], .flash.alert"
  }
end
```

### Multiple Browsers

One of the key advantages of Playwright is true cross-browser testing. You can easily switch engines:

- **Chromium:** Google Chrome, Microsoft Edge, etc.
- **Firefox:** Mozilla Firefox.
- **WebKit:** Safari, iOS browsers.

To test in Safari (WebKit):

```ruby
E2E.configure { |config| config.browser_type = :webkit }
```

Don't forget to install all browser binaries:

```bash
npx playwright install
```

### Switching Browsers per Test (RSpec)

You can run specific tests in different browsers using metadata (requires simple setup in your helper).

First, update your `spec/e2e_helper.rb` to respect metadata:

```ruby
RSpec.configure do |config|
  config.before(:each) do |example|
    browser = example.metadata[:browser]
    if browser
      E2E.config.browser_type = browser
      E2E.reset_session! # Force new browser launch
    end
  end

  config.after(:each) do
    if E2E.config.browser_type != :chromium
      E2E.config.browser_type = :chromium
      E2E.reset_session!
    end
  end
end
```

Then use it in your specs:

```ruby
it "works in Safari", browser: :webkit do
  visit "/"
  expect(page.body).to include("Safari specific feature")
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
