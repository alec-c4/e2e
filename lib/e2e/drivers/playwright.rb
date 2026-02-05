# frozen_string_literal: true

require "playwright"

module E2E
  module Drivers
    class Playwright < Driver
      def initialize
        @playwright_execution = ::Playwright.create(playwright_cli_executable_path: "npx playwright")
        @playwright = @playwright_execution.playwright
        @browser_type = @playwright.chromium
        @browser = @browser_type.launch(headless: E2E.config.headless)
        @context = @browser.new_context

        # Enable debug console to allow page.pause
        @context.enable_debug_console!

        @page = @context.new_page
      end

      def visit(url)
        @page.goto(url)
      end

      def current_url
        @page.url
      end

      def find(selector, **options)
        if options.key?(:text)
          text = options.delete(:text)
          selector = "#{selector}:has-text('#{text}')"
        end
        E2E::Element.new(@page.locator(selector, **options).first)
      end

      def all(selector, **options)
        if options.key?(:text)
          text = options.delete(:text)
          selector = "#{selector}:has-text('#{text}')"
        end
        @page.locator(selector, **options).all.map { |l| E2E::Element.new(l) }
      end

      def click(selector)
        @page.click(selector)
      end

      def click_button(value, **options)
        @page.get_by_role("button", name: value, **options).click
      end

      def click_link(value, **options)
        @page.get_by_role("link", name: value, **options).click
      end

      def fill_in(selector, with:)
        @page.fill(selector, with)
      end

      def check(selector)
        @page.check(selector)
      end

      def uncheck(selector)
        @page.uncheck(selector)
      end

      def attach_file(selector, path)
        @page.set_input_files(selector, path)
      end

      def body
        @page.content
      end

      def evaluate(script)
        @page.evaluate(script)
      end

      def save_screenshot(path, **options)
        @page.screenshot(path: path, **options)
      end

      def native
        @page
      end

      def pause
        @page.pause
      end

      def reset!
        @context.close
        @context = @browser.new_context
        @page = @context.new_page
      end

      def quit
        @browser.close
        @playwright_execution.stop
      end
    end
  end
end
