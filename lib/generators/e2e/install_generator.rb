# frozen_string_literal: true

require "rails/generators"

module E2e
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      class_option :test_framework, type: :string, desc: "Test framework to be invoked"

      def create_helper_file
        case test_framework
        when :rspec
          create_rspec_helper
        when :minitest
          create_minitest_helper
        else
          say "Could not detect test framework. Please specify --test-framework=rspec or minitest.", :red
        end
      end

      def display_instructions
        case test_framework
        when :rspec
          say "E2E gem installed for RSpec! Use `require 'e2e_helper'` in specs.", :green
        when :minitest
          say "E2E gem installed for Minitest! Inherit from `E2E::Minitest::TestCase` in your tests.", :green
        end
      end

      def configure_rubocop
        return unless File.exist?(".rubocop.yml")

        config_content = File.read(".rubocop.yml")

        if config_content.include?("inherit_gem:")
          inject_into_file ".rubocop.yml", after: "inherit_gem:\n" do
            "  e2e: config/rubocop.yml\n"
          end
        else
          prepend_to_file ".rubocop.yml" do
            "inherit_gem:\n  e2e: config/rubocop.yml\n\n"
          end
        end
      end

      private

      def test_framework
        return options[:test_framework].to_sym if options[:test_framework]

        # Check Rails configuration
        rails_config = Rails.application.config.generators.options[:rails][:test_framework]
        return rails_config if rails_config

        # Fallback to directory detection
        return :rspec if File.directory?("spec")
        :minitest if File.directory?("test")
      end

      def create_rspec_helper
        create_file "spec/e2e_helper.rb", <<~RUBY
          # frozen_string_literal: true

          require "rails_helper"
          require "e2e/rspec"

          E2E.configure do |config|
            config.app = Rails.application
            config.headless = ENV.fetch("HEADLESS", "true") == "true"
          end

          # If you want to use transactional tests (faster), enable shared connection:
          # E2E.enable_shared_connection!

          RSpec.configure do |config|
            # Add additional configuration here
          end
        RUBY
      end

      def create_minitest_helper
        create_file "test/e2e_helper.rb", <<~RUBY
          # frozen_string_literal: true

          require "test_helper"
          require "e2e/minitest"

          E2E.configure do |config|
            config.app = Rails.application
            config.headless = ENV.fetch("HEADLESS", "true") == "true"
          end

          # If you want to use transactional tests (faster), enable shared connection:
          # E2E.enable_shared_connection!
        RUBY
      end
    end
  end
end
