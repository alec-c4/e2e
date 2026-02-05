# frozen_string_literal: true

require "rack"
require "rackup"
require "webrick"
require "socket"

module E2E
  class Server
    attr_reader :app, :host, :port

    def initialize(app, port: nil)
      @app = app
      @host = "127.0.0.1"
      @port = port || find_available_port
    end

    def start
      @thread = Thread.new do
        # Use Rackup handler for Rack 3 compatibility
        Rackup::Handler::WEBrick.run(
          @app,
          Host: @host,
          Port: @port,
          AccessLog: [],
          Logger: WEBrick::Log.new(nil, 0) # Silence logs
        )
      end
      wait_for_boot
    end

    def base_url
      "http://#{@host}:#{@port}"
    end

    private

    def find_available_port
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]
      server.close
      port
    end

    def wait_for_boot
      start_time = Time.now
      loop do
        socket = TCPSocket.new("127.0.0.1", @port)
        socket.close
        break
      rescue Errno::ECONNREFUSED
        raise "Server failed to boot" if Time.now - start_time > 10
        sleep 0.1
      end
    end
  end
end
