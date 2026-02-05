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

  class Config
    attr_accessor :driver, :headless, :app

    def initialize
      @driver = :playwright
      @headless = ENV.fetch("HEADLESS", "true") == "true"
      @app = nil
    end
  end
end
