# frozen_string_literal: true

require "forwardable"
require "uri"

module E2E
  module DSL
    extend Forwardable

    def_delegators "E2E.session", :visit, :current_url, :find, :all, :click, :click_button, :click_link, :fill_in, :check, :uncheck, :attach_file, :body, :evaluate, :save_screenshot, :native, :pause, :reset!

    def page
      E2E.session
    end

    # Waits until the provided block returns a truthy value.
    # Raises E2E::Error on timeout for easier failure diagnostics.
    def wait_for(timeout: E2E.config.wait_timeout, interval: 0.05, message: "Timed out waiting for condition")
      result = nil
      found = E2E.wait_until(timeout: timeout, interval: interval) do
        result = yield
        result
      end

      raise E2E::Error, message unless found

      result
    end

    def wait_for_text(text, timeout: E2E.config.wait_timeout, interval: 0.05)
      wait_for(
        timeout: timeout,
        interval: interval,
        message: "Expected page to have text #{text.inspect} within #{timeout} seconds"
      ) do
        text_matches?(page.text, text)
      end
    end

    def wait_for_current_path(expected_path, timeout: E2E.config.wait_timeout, interval: 0.05)
      wait_for(
        timeout: timeout,
        interval: interval,
        message: "Expected current path to be #{expected_path.inspect} within #{timeout} seconds"
      ) do
        current_path_matches?(expected_path)
      end
    end

    def wait_for_flash(text = nil, type: nil, timeout: E2E.config.wait_timeout, interval: 0.05)
      wait_for(
        timeout: timeout,
        interval: interval,
        message: flash_timeout_message(text, type, timeout)
      ) do
        flashes = visible_flashes(type: type)
        next false if flashes.empty?
        next true if text.nil?

        flashes.any? { |flash_text| text_matches?(flash_text, text) }
      end
    end

    def click_button_and_wait_for_text(value, text, timeout: E2E.config.wait_timeout, interval: 0.05, **options)
      click_button(value, **options)
      wait_for_text(text, timeout: timeout, interval: interval)
    end

    def click_link_and_wait_for_text(value, text, timeout: E2E.config.wait_timeout, interval: 0.05, **options)
      click_link(value, **options)
      wait_for_text(text, timeout: timeout, interval: interval)
    end

    def click_button_and_wait_for_path(value, expected_path, timeout: E2E.config.wait_timeout, interval: 0.05, **options)
      click_button(value, **options)
      wait_for_current_path(expected_path, timeout: timeout, interval: interval)
    end

    def click_link_and_wait_for_path(value, expected_path, timeout: E2E.config.wait_timeout, interval: 0.05, **options)
      click_link(value, **options)
      wait_for_current_path(expected_path, timeout: timeout, interval: interval)
    end

    def click_button_and_wait_for_flash(value, text = nil, type: nil, timeout: E2E.config.wait_timeout, interval: 0.05, **options)
      click_button(value, **options)
      wait_for_flash(text, type: type, timeout: timeout, interval: interval)
    end

    def click_link_and_wait_for_flash(value, text = nil, type: nil, timeout: E2E.config.wait_timeout, interval: 0.05, **options)
      click_link(value, **options)
      wait_for_flash(text, type: type, timeout: timeout, interval: interval)
    end

    private

    def flash_timeout_message(text, type, timeout)
      scope = type ? "#{type} flash" : "flash"
      return "Expected #{scope} within #{timeout} seconds" if text.nil?

      "Expected #{scope} with text #{text.inspect} within #{timeout} seconds"
    end

    def visible_flashes(type: nil)
      selector = flash_selector_for(type)
      page.all(selector).select(&:visible?).map(&:text)
    rescue
      []
    end

    def flash_selector_for(type)
      selectors = E2E.config.flash_selectors || E2E::Config::DEFAULT_FLASH_SELECTORS
      key = normalize_flash_type(type)
      selectors.fetch(key) { selectors.fetch(:any, E2E::Config::DEFAULT_FLASH_SELECTORS[:any]) }
    end

    def normalize_flash_type(type)
      case type&.to_sym
      when :notice, :success
        :notice
      when :alert, :error
        :alert
      else
        :any
      end
    end

    def current_path_matches?(expected_path)
      actual_path = begin
        URI.parse(page.current_url).path
      rescue URI::InvalidURIError
        page.current_url
      end

      text_matches?(actual_path, expected_path, exact: true)
    end

    def text_matches?(actual_text, expected_text, exact: false)
      return actual_text.match?(expected_text) if expected_text.is_a?(Regexp)
      return actual_text == expected_text if exact

      actual_text.include?(expected_text)
    end
  end
end
