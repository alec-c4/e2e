# frozen_string_literal: true

module E2E
  module Rails
    # This module allows the test thread and the server thread to share the same
    # ActiveRecord connection. This is crucial for running tests in transactions
    # which is much faster than using truncation.
    module ActiveRecordSharedConnection
      def connection
        @shared_connection || retrieve_connection
      end

      def shared_connection=(connection)
        @shared_connection = connection
      end
    end
  end
end

# We only want to apply this when Rails is present and we want to enable it.
def E2E.enable_shared_connection!
  return unless defined?(ActiveRecord::Base)

  ActiveRecord::Base.extend(E2E::Rails::ActiveRecordSharedConnection)
  ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
end
