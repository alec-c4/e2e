# frozen_string_literal: true

require "active_record"

class RailsSharedConnectionSpecWidget < ActiveRecord::Base
  self.table_name = "widgets"
end

RSpec.describe "RailsSharedConnection", type: :e2e do
  # Establishing the sqlite3 connection and enabling the shared-connection prepend
  # is expensive-ish and globally scoped (ActiveRecord::Base-wide) anyway, so it's
  # done once for the file rather than re-done per example.
  # rubocop:disable RSpec/BeforeAfterAll
  before(:all) do
    # A pool size of 1 is what makes the original bug reproducible: the example
    # thread and the in-process WEBrick server thread have exactly one physical
    # connection to fight over.
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:", pool: 1)
    ActiveRecord::Base.connection.execute("CREATE TABLE widgets (id INTEGER PRIMARY KEY, name TEXT)")
    E2E::Rails.enable_shared_connection!
  end

  after(:all) do
    ActiveRecord::Base.remove_connection
  end
  # rubocop:enable RSpec/BeforeAfterAll

  after { RailsSharedConnectionSpecWidget.delete_all }

  let(:app) do
    proc do |env|
      case env["PATH_INFO"]
      when "/widgets"
        # Route the query through lease_connection/with_connection when available
        # (Rails 7.2+) since those are exactly the APIs that were NOT overridden
        # pre-0.7.1 and could deadlock a single-connection pool.
        count = if ActiveRecord::Base.respond_to?(:with_connection)
          ActiveRecord::Base.with_connection { RailsSharedConnectionSpecWidget.count }
        else
          RailsSharedConnectionSpecWidget.count
        end
        [200, {"content-type" => "text/plain"}, ["widgets:#{count}"]]
      else
        [404, {}, ["Not Found"]]
      end
    end
  end

  before do
    # E2E.server is memoized on first access, so a server booted by an earlier
    # spec file (with a different Rack app) would otherwise stick around and
    # this app's routes would never be reachable.
    E2E.stop_server!
    E2E.configure { |config| config.app = app }
  end

  it "lets the WEBrick thread query the shared connection without deadlocking the pool" do
    RailsSharedConnectionSpecWidget.create!(name: "a")

    # The example thread is still holding the shared connection's lease here.
    # `visit` blocks the example thread on Playwright while the WEBrick thread
    # services the request on that very same connection.
    visit("/widgets")

    expect(page.body).to include("widgets:1")
  end

  describe "E2E::Rails.with_released_connection" do
    it "releases the pool's real lease for the duration of the block" do
      pool = ActiveRecord::Base.connection_pool
      # Force a real, pool-tracked lease for this thread regardless of what
      # earlier examples left behind (a prior `visit` already released it once).
      # ConnectionPool#lease_connection only exists from Rails 7.2 on; older
      # pools only expose #connection for the same effect.
      pool.respond_to?(:lease_connection) ? pool.lease_connection : pool.connection
      expect(pool).to be_active_connection

      active_during_block = nil
      E2E::Rails.with_released_connection do
        active_during_block = pool.active_connection?
      end
      expect(active_during_block).to be_falsy

      # NB: pool.active_connection? stays false after the block -- the `ensure`
      # re-lease calls the overridden ActiveRecord::Base.lease_connection, which
      # short-circuits to the cached E2E::Rails.shared_connection instead of
      # calling pool.lease_connection for real. That's harmless here because
      # every AR call in this setup goes through that same override and never
      # touches the pool directly, so callers keep working regardless:
      expect(RailsSharedConnectionSpecWidget.count).to eq(0)
    end
  end
end
