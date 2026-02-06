# frozen_string_literal: true

require_relative "e2e/version"
require_relative "e2e/driver"
require_relative "e2e/server"
require_relative "e2e/session"
require_relative "e2e/dsl"
require_relative "e2e/element"
require_relative "e2e/rails"
require_relative "e2e/drivers/playwright"

module E2E
  class Error < StandardError; end

  class << self
    def session
      @session ||= Session.new
    end

    def reset_session!
      @session&.quit
      @session = nil
    end

    def configure
      yield(config)
    end

    def config
      @config ||= Config.new
    end

    def server
      @server ||= if config.app
        srv = Server.new(config.app)
        srv.start
        srv
      end
    end
  end

  # Retry a block until it returns truthy or timeout is reached
  def self.wait_until(timeout: config.wait_timeout, interval: 0.05)
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
    loop do
      result = yield
      return result if result

      if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
        return false
      end

      sleep interval
    end
  end

  class Config
    attr_accessor :driver, :headless, :app, :browser_type, :wait_timeout

    def initialize
      @driver = :playwright
      @browser_type = :chromium
      @headless = ENV.fetch("HEADLESS", "true") == "true"
      @app = nil
      @wait_timeout = 5
    end
  end
end
