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
        webrick_handler.run(
          @app,
          Host: @host,
          Port: @port,
          AccessLog: [],
          Logger: WEBrick::Log.new(nil, 0) # Silence logs
        ) do |server|
          @webrick = server
        end
      end
      wait_for_boot
    end

    def stop
      @webrick&.shutdown
      @thread&.join(5)
      @thread = nil
      @webrick = nil
    end

    def base_url
      "http://#{@host}:#{@port}"
    end

    private

    # rackup 2.x (the version paired with Rack 3) exposes Rackup::Handler.
    # Older stacks that pin Rack 2.x (e.g. Rails 7.0/7.1 via this gem's own
    # Appraisal matrix) resolve `rackup` down to its 1.x line, which has no
    # Handler module at all -- there, the handler lives on Rack::Handler.
    def webrick_handler
      if defined?(Rackup::Handler)
        Rackup::Handler.get(:webrick)
      else
        Rack::Handler.get(:webrick)
      end
    end

    def find_available_port
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]
      server.close
      port
    end

    def wait_for_boot
      start_time = Time.now
      loop do
        if @thread && !@thread.alive?
          @thread.join # re-raises whatever exception killed the server thread
          raise "Server thread exited before boot completed"
        end

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
