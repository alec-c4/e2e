# frozen_string_literal: true

require "e2e"

RSpec.configure do |config|
  config.include E2E::DSL, type: :e2e

  config.after(:each, type: :e2e) do |example|
    if example.exception
      # Create tmp/screenshots directory if it doesn't exist
      screenshots_dir = File.expand_path("tmp/screenshots", Dir.pwd)
      FileUtils.mkdir_p(screenshots_dir)

      # Generate filename based on example description
      filename = "#{example.full_description.gsub(/[^0-9A-Za-z]/, "_")}.png"
      path = File.join(screenshots_dir, filename)

      begin
        E2E.session.save_screenshot(path)
      rescue => e
        puts "Failed to save screenshot: #{e.message}"
      end
    end

    # Reset session (clear cookies/storage) but keep browser open
    E2E.session.reset! if E2E.instance_variable_get(:@session)
  end

  config.after(:suite) do
    E2E.session.quit if E2E.instance_variable_get(:@session)
  end
end
