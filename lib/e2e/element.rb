# frozen_string_literal: true

module E2E
  class Element
    def initialize(locator)
      @locator = locator
    end

    def click
      @locator.click
    end

    def fill(value)
      @locator.fill(value)
    end

    def text
      @locator.inner_text
    end

    def visible?
      @locator.visible?
    end

    def [](attribute)
      @locator.get_attribute(attribute)
    end

    def classes
      (self["class"] || "").split
    end

    def has_class?(class_name)
      classes.include?(class_name.to_s)
    end

    def value
      @locator.input_value
    end

    def checked?
      @locator.checked?
    end

    def disabled?
      @locator.disabled?
    end

    def enabled?
      @locator.enabled?
    end

    # Allows calling native playwright methods if needed
    def native
      @locator
    end
  end
end
