# frozen_string_literal: true

require "forwardable"

module E2E
  class Session
    extend Forwardable

    attr_reader :driver

    def_delegators :@driver, :current_url, :click, :click_button, :click_link, :fill_in, :check, :uncheck, :attach_file, :body, :evaluate, :save_screenshot, :native, :pause, :reset!, :quit

    def initialize(driver_name = E2E.config.driver)
      @driver = initialize_driver(driver_name)
    end

    def find(...)
      @driver.find(...)
    end

    def all(...)
      @driver.all(...)
    end

    def visit(url)
      if url.start_with?("/") && E2E.server
        url = "#{E2E.server.base_url}#{url}"
      end
      @driver.visit(url)
    end

    private

    def initialize_driver(name)
      case name
      when :playwright
        Drivers::Playwright.new
      else
        raise ArgumentError, "Unknown driver: #{name}"
      end
    end
  end
end
