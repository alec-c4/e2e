# frozen_string_literal: true

module E2E
  module Assertions
    def assert_text(text)
      actual_text = nil
      found = E2E.wait_until do
        actual_text = page.text
        if text.is_a?(Regexp)
          actual_text.match?(text)
        else
          actual_text.include?(text)
        end
      end

      assert found, "Expected page to have text #{text.inspect}, but it had:
#{actual_text}"
    end

    def refute_text(text)
      actual_text = nil
      found = E2E.wait_until do
        actual_text = page.text
        if text.is_a?(Regexp)
          !actual_text.match?(text)
        else
          !actual_text.include?(text)
        end
      end

      assert found, "Expected page NOT to have text #{text.inspect}, but it did."
    end

    alias_method :assert_no_text, :refute_text

    def assert_selector(selector)
      found = E2E.wait_until do
        page.all(selector).any?(&:visible?)
      end
      assert found, "Expected to find visible selector #{selector.inspect}"
    end

    def refute_selector(selector)
      found = E2E.wait_until do
        page.all(selector).none?(&:visible?)
      end
      assert found, "Expected NOT to find visible selector #{selector.inspect}"
    end

    alias_method :assert_no_selector, :refute_selector

    def assert_current_path(expected_path)
      actual_path = nil
      found = E2E.wait_until do
        url = page.current_url
        actual_path = begin
          URI.parse(url).path
        rescue URI::InvalidURIError
          url
        end

        if expected_path.is_a?(Regexp)
          actual_path.match?(expected_path)
        else
          actual_path == expected_path
        end
      end

      assert found, "Expected current path to be #{expected_path.inspect}, but was #{actual_path.inspect}"
    end

    def refute_current_path(expected_path)
      actual_path = nil
      found = E2E.wait_until do
        url = page.current_url
        actual_path = begin
          URI.parse(url).path
        rescue URI::InvalidURIError
          url
        end

        if expected_path.is_a?(Regexp)
          !actual_path.match?(expected_path)
        else
          actual_path != expected_path
        end
      end

      assert found, "Expected current path NOT to be #{expected_path.inspect}, but it was"
    end

    alias_method :assert_no_current_path, :refute_current_path
  end
end
