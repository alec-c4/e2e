# frozen_string_literal: true

require "playwright"

module E2E
  module Drivers
    class Playwright < Driver
      def initialize
        @playwright_execution = ::Playwright.create(playwright_cli_executable_path: "npx playwright")
        @playwright = @playwright_execution.playwright

        browser_type_name = E2E.config.browser_type || :chromium
        @browser_type = @playwright.send(browser_type_name)

        @headless = E2E.config.headless
        @browser = @browser_type.launch(headless: @headless)
        @context = @browser.new_context

        # Enable debug console to allow page.pause (requires GUI, so only in headed mode)
        @context.enable_debug_console! unless @headless

        @page = build_page
      end

      def visit(url)
        with_released_connection do
          @page.goto(
            url,
            waitUntil: E2E.config.navigation_wait_until,
            timeout: navigation_timeout_ms
          )
        end
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
        with_released_connection { @page.click(selector) }
      end

      def click_button(value, **options)
        with_released_connection { @page.get_by_role("button", name: value, **options).click }
      end

      def click_link(value, **options)
        with_released_connection { @page.get_by_role("link", name: value, **options).click }
      end

      def fill_in(selector, with:)
        # Try to match Capybara's behavior: Label, Placeholder, ID, Name
        chain = @page.get_by_label(selector).or(@page.get_by_placeholder(selector))

        # Only add ID/Name matching if the selector doesn't contain spaces (valid CSS ID/Name assumption-ish)
        if selector.match?(/^[a-zA-Z0-9_-]+$/)
          chain = chain.or(@page.locator("##{selector}"))
            .or(@page.locator("[name='#{selector}']"))
        end

        with_released_connection do
          chain.first.fill(with)
        rescue
          # Fallback to treating it as a direct CSS selector if the above failed
          @page.fill(selector, with)
        end
      end

      def check(selector)
        with_released_connection { @page.check(selector) }
      end

      def uncheck(selector)
        with_released_connection { @page.uncheck(selector) }
      end

      def attach_file(selector, path)
        with_released_connection { @page.set_input_files(selector, path) }
      end

      def body
        @page.content
      end

      # Required for have_content matcher on page object
      def text
        @page.inner_text("body")
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
        raise E2E::Error, "pause is not available in headless mode" if @headless

        @page.pause
      end

      def reset!
        @context.close
        @context = @browser.new_context
        @context.enable_debug_console! unless @headless
        @page = build_page
      end

      def quit
        @browser.close
        @playwright_execution.stop
      end

      private

      def build_page
        page = @context.new_page
        page.set_default_timeout((E2E.config.wait_timeout * 1000).to_i)
        page.set_default_navigation_timeout(navigation_timeout_ms)
        page
      end

      def navigation_timeout_ms
        (E2E.config.navigation_timeout * 1000).to_i
      end

      def with_released_connection(&block)
        E2E::Rails.with_released_connection(&block)
      end
    end
  end
end
