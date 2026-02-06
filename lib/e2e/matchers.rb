# frozen_string_literal: true

if defined?(RSpec::Matchers)
  RSpec::Matchers.define :have_class do |expected_class|
    match do |element|
      element.has_class?(expected_class)
    end

    failure_message do |element|
      "expected element to have class '#{expected_class}', but it had '#{element.classes.join(" ")}'"
    end

    failure_message_when_negated do |element|
      "expected element not to have class '#{expected_class}', but it did"
    end
  end

  RSpec::Matchers.define :have_text do |expected_text|
    match do |actual|
      @actual_text = nil

      E2E.wait_until do
        @actual_text = actual.text
        if expected_text.is_a?(Regexp)
          @actual_text.match?(expected_text)
        else
          @actual_text.include?(expected_text)
        end
      end
    end

    match_when_negated do |actual|
      E2E.wait_until do
        @actual_text = actual.text
        if expected_text.is_a?(Regexp)
          !@actual_text.match?(expected_text)
        else
          !@actual_text.include?(expected_text)
        end
      end
    end

    failure_message do
      "expected to find text #{expected_text.inspect} in #{@actual_text.inspect}"
    end

    failure_message_when_negated do
      "expected not to find text #{expected_text.inspect} in #{@actual_text.inspect}"
    end
  end

  RSpec::Matchers.alias_matcher :have_content, :have_text

  RSpec::Matchers.define :have_no_text do |expected_text|
    match do |actual|
      @actual_text = nil

      E2E.wait_until do
        @actual_text = actual.text
        if expected_text.is_a?(Regexp)
          !@actual_text.match?(expected_text)
        else
          !@actual_text.include?(expected_text)
        end
      end
    end

    match_when_negated do |actual|
      E2E.wait_until do
        @actual_text = actual.text
        if expected_text.is_a?(Regexp)
          @actual_text.match?(expected_text)
        else
          @actual_text.include?(expected_text)
        end
      end
    end

    failure_message do
      "expected not to find text #{expected_text.inspect} in #{@actual_text.inspect}"
    end

    failure_message_when_negated do
      "expected to find text #{expected_text.inspect} in #{@actual_text.inspect}"
    end
  end

  RSpec::Matchers.alias_matcher :have_no_content, :have_no_text

  RSpec::Matchers.define :have_current_path do |expected_path|
    match do |session|
      @actual_path = nil

      E2E.wait_until do
        url = session.current_url
        @actual_path = begin
          URI.parse(url).path
        rescue URI::InvalidURIError
          url
        end

        if expected_path.is_a?(Regexp)
          @actual_path.match?(expected_path)
        else
          @actual_path == expected_path
        end
      end
    end

    match_when_negated do |session|
      E2E.wait_until do
        url = session.current_url
        @actual_path = begin
          URI.parse(url).path
        rescue URI::InvalidURIError
          url
        end

        if expected_path.is_a?(Regexp)
          !@actual_path.match?(expected_path)
        else
          @actual_path != expected_path
        end
      end
    end

    failure_message do
      "expected current path to be #{expected_path.inspect}, but was #{@actual_path.inspect}"
    end

    failure_message_when_negated do
      "expected current path not to be #{expected_path.inspect}, but it was"
    end
  end

  RSpec::Matchers.define :have_no_current_path do |expected_path|
    match do |session|
      @actual_path = nil

      E2E.wait_until do
        url = session.current_url
        @actual_path = begin
          URI.parse(url).path
        rescue URI::InvalidURIError
          url
        end

        if expected_path.is_a?(Regexp)
          !@actual_path.match?(expected_path)
        else
          @actual_path != expected_path
        end
      end
    end

    match_when_negated do |session|
      E2E.wait_until do
        url = session.current_url
        @actual_path = begin
          URI.parse(url).path
        rescue URI::InvalidURIError
          url
        end

        if expected_path.is_a?(Regexp)
          @actual_path.match?(expected_path)
        else
          @actual_path == expected_path
        end
      end
    end

    failure_message do
      "expected current path not to be #{expected_path.inspect}, but was #{@actual_path.inspect}"
    end

    failure_message_when_negated do
      "expected current path to be #{expected_path.inspect}, but it was"
    end
  end

  RSpec::Matchers.define :have_value do |expected_value|
    match do |element|
      element.value == expected_value
    end

    failure_message do |element|
      "expected element to have value '#{expected_value}', but it had '#{element.value}'"
    end

    failure_message_when_negated do |element|
      "expected element not to have value '#{expected_value}', but it did"
    end
  end

  RSpec::Matchers.define :have_attribute do |attribute, expected_value|
    match do |element|
      element[attribute] == expected_value
    end

    failure_message do |element|
      "expected element to have attribute '#{attribute}' with value '#{expected_value}', but it had '#{element[attribute]}'"
    end

    failure_message_when_negated do |element|
      "expected element not to have attribute '#{attribute}' with value '#{expected_value}', but it did"
    end
  end

  RSpec::Matchers.define :be_checked do
    match do |element|
      element.checked?
    end

    failure_message do |element|
      "expected element to be checked, but it wasn't"
    end

    failure_message_when_negated do |element|
      "expected element not to be checked, but it was"
    end
  end

  RSpec::Matchers.define :be_disabled do
    match do |element|
      element.disabled?
    end

    failure_message do |element|
      "expected element to be disabled, but it was enabled"
    end

    failure_message_when_negated do |element|
      "expected element to be enabled, but it was disabled"
    end
  end

  RSpec::Matchers.define :be_enabled do
    match do |element|
      element.enabled?
    end

    failure_message do |element|
      "expected element to be enabled, but it was disabled"
    end

    failure_message_when_negated do |element|
      "expected element to be disabled, but it was enabled"
    end
  end
end
