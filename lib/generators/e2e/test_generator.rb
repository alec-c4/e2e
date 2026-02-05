# frozen_string_literal: true

require "rails/generators"

module E2e
  module Generators
    class TestGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)
      class_option :test_framework, type: :string, desc: "Test framework to be invoked"

      def create_test_file
        case test_framework
        when :rspec
          create_rspec_test
        when :minitest
          create_minitest_test
        else
          say "Could not detect test framework. Please specify --test-framework=rspec or minitest.", :red
        end
      end

      private

      def test_framework
        return options[:test_framework].to_sym if options[:test_framework]

        rails_config = Rails.application.config.generators.options[:rails][:test_framework]
        return rails_config if rails_config

        return :rspec if File.directory?("spec")
        :minitest if File.directory?("test")
      end

      def create_rspec_test
        template "rspec_test.rb.erb", "spec/e2e/#{file_name}_spec.rb"
      end

      def create_minitest_test
        template "minitest_test.rb.erb", "test/e2e/#{file_name}_test.rb"
      end
    end
  end
end
