# frozen_string_literal: true

module E2E
  module Rails
    class << self
      attr_accessor :shared_connection
      attr_reader :shared_connection_enabled

      def shared_connection_enabled?
        @shared_connection_enabled
      end

      def enable_shared_connection!
        return unless defined?(ActiveRecord::Base)
        return if @shared_connection_enabled

        ActiveRecord::Base.singleton_class.prepend(ActiveRecordSharedConnection)
        @shared_connection_enabled = true
        # #connection (unlike #lease_connection/#with_connection, added in
        # Rails 7.2) exists on every supported Rails version, so it's the only
        # safe way to bootstrap the very first shared connection.
        self.shared_connection = ActiveRecord::Base.connection
      end

      # Yields while the example thread is not holding a sticky AR lease.
      # Needed when the pool has a single connection and the server thread
      # must check it out during a blocking Playwright navigation/action.
      def with_released_connection
        return yield unless shared_connection_enabled?
        return yield unless defined?(ActiveRecord::Base)

        pool = ActiveRecord::Base.connection_pool
        pool.release_connection if pool.active_connection?
        yield
      ensure
        if shared_connection_enabled? && defined?(ActiveRecord::Base)
          # Keep the shared handle pointing at a live leased connection for
          # post-navigation assertions in the example thread.
          self.shared_connection = ActiveRecord::Base.connection
        end
      end
    end

    # Shares one ActiveRecord connection between the example thread and the
    # in-process server thread so transactional fixtures remain visible.
    #
    # Rails 7.2+/8 prefer +lease_connection+ / +with_connection+ over
    # +connection+. Overriding only +connection+ (pre-0.7.1) left those
    # APIs on the pool's thread-local lease and caused intermittent
    # deadlocks: the example thread blocked in Playwright while holding
    # the only connection, and the server sat idle in an open transaction.
    module ActiveRecordSharedConnection
      def connection
        E2E::Rails.shared_connection || super
      end

      # lease_connection/with_connection don't exist before Rails 7.2, so
      # `super` isn't always callable -- fall back to the always-available
      # #connection instead of blowing up with a NoMethodError.
      def lease_connection
        E2E::Rails.shared_connection || (defined?(super) ? super : connection)
      end

      def with_connection(prevent_permanent_checkout: false)
        if (conn = E2E::Rails.shared_connection)
          yield conn
        elsif defined?(super)
          super
        else
          yield connection
        end
      end

      def shared_connection=(connection)
        E2E::Rails.shared_connection = connection
      end

      def shared_connection
        E2E::Rails.shared_connection
      end
    end
  end
end

def E2E.enable_shared_connection!
  E2E::Rails.enable_shared_connection!
end
