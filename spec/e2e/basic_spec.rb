# frozen_string_literal: true

RSpec.describe "Basic", type: :e2e do
  let(:app) do
    proc do |_env|
      [
        200,
        {"content-type" => "text/html"},
        ["<!doctype html><html><head><title>Example Domain</title></head><body><h1>Example Domain</h1></body></html>"]
      ]
    end
  end

  around do |example|
    previous_app = E2E.config.app
    E2E.stop_server!
    E2E.config.app = app
    example.run
  ensure
    E2E.stop_server!
    E2E.config.app = previous_app
  end

  it "can visit a page and check content using DSL" do
    visit("/")

    expect(current_url).to eq("#{E2E.server.base_url}/")
    expect(page.body).to include("Example Domain")

    h1 = find("h1")
    expect(h1).to have_text("Example Domain")

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
