# frozen_string_literal: true

require "minitest"
require "e2e"
require_relative "assertions"

module E2E
  module Minitest
    class TestCase < ::Minitest::Test
      include E2E::DSL
      include E2E::Assertions

      def teardown
        take_failed_screenshot if !passed? && !skipped?

        # Reset session but keep browser open for speed
        E2E.session.reset! if E2E.instance_variable_get(:@session)
        super
      end

      private

      def take_failed_screenshot
        screenshots_dir = File.expand_path("tmp/screenshots", Dir.pwd)
        FileUtils.mkdir_p(screenshots_dir)

        name = "#{self.class.name}_#{self.name}".gsub(/[^0-9A-Za-z]/, "_")
        path = File.join(screenshots_dir, "#{name}.png")

        begin
          # rubocop:disable Lint/Debugger
          save_screenshot(path)
          # rubocop:enable Lint/Debugger
          puts "
[E2E] Screenshot saved to #{path}"
        rescue => e
          puts "
[E2E] Failed to save screenshot: #{e.message}"
        end
      end
    end
  end
end

Minitest.after_run do
  E2E.session.quit if E2E.instance_variable_get(:@session)
end
