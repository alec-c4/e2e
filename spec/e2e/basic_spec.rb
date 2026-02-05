# frozen_string_literal: true

RSpec.describe "Basic", type: :e2e do
  it "can visit a page and check content using DSL" do
    visit("https://example.com")

    expect(current_url).to eq("https://example.com/")
    expect(page.body).to include("Example Domain")

    h1 = find("h1")
    expect(h1.text).to eq("Example Domain")

    # JavaScript execution check
    title = evaluate("document.title")
    expect(title).to eq("Example Domain")

    # Escape Hatch: access to native Playwright API
    # For example, get title directly via Playwright API instead of JS
    expect(page.native.title).to eq("Example Domain")

    # Screenshot check
    FileUtils.mkdir_p("tmp")
    screenshot_path = "tmp/screenshot.png"
    save_screenshot(screenshot_path) # rubocop:disable Lint/Debugger
    expect(File.exist?(screenshot_path)).to be true
    File.delete(screenshot_path)
  end
end
