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

    # Allows calling native playwright methods if needed
    def native
      @locator
    end
  end
end
