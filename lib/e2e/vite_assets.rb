# frozen_string_literal: true

require "fileutils"
require "pathname"

module E2E
  # Ensures ViteRuby test assets are built before the e2e suite runs.
  #
  # ViteRuby::Builder skips compile when the watched-files digest is unchanged,
  # so calling this on every suite start is cheap when assets are fresh.
  #
  # A flock serializes builders across processes (e.g. accidental parallel e2e).
  module ViteAssets
    LOCK_NAME = "e2e-vite-test-build.lock"
    SKIP_ENV = "SKIP_VITE_TEST_BUILD"

    class << self
      def ensure_built!
        return if ENV[SKIP_ENV] == "1"
        return if done?

        mode = normalize_mode(E2E.config.ensure_vite_assets)
        return mark_done! if mode == :skip

        with_lock do
          return if done?

          case mode
          when :auto
            ensure_auto!
          when :build
            ensure_required!
          when :warn
            ensure_warn!
          end

          mark_done!
        end
      end

      def reset!
        @done = false
      end

      def project_root
        if defined?(Rails) && Rails.respond_to?(:root) && Rails.root
          Pathname(Rails.root)
        else
          Pathname.pwd
        end
      end

      private

      def done?
        @done
      end

      def mark_done!
        @done = true
      end

      def normalize_mode(value)
        case value
        when :auto, :build, :warn, :skip then value
        when true then :build
        when false, nil then :skip
        else
          raise E2E::Error, "Unknown ensure_vite_assets=#{value.inspect} (expected :auto, :build, :warn, :skip)"
        end
      end

      def vite_ruby_loaded?
        defined?(ViteRuby)
      end

      def ensure_auto!
        return unless vite_ruby_loaded?

        build_or_raise!
      end

      def ensure_required!
        unless vite_ruby_loaded?
          raise E2E::Error, <<~MSG.chomp
            ViteRuby is not loaded, but E2E.config.ensure_vite_assets = :build.
            Add vite_rails / vite_ruby, or set ensure_vite_assets to :skip / :auto.
          MSG
        end

        build_or_raise!
      end

      def ensure_warn!
        return warn_missing_vite_ruby unless vite_ruby_loaded?

        return if ViteRuby.commands.build

        warn <<~MSG
          [E2E] Vite test asset build failed.
          Run: bin/vite build --mode=test
          Or set #{SKIP_ENV}=1 / E2E.config.ensure_vite_assets = :skip
        MSG
      end

      def warn_missing_vite_ruby
        warn "[E2E] ensure_vite_assets=:warn but ViteRuby is not loaded; skipping."
      end

      def build_or_raise!
        return if ViteRuby.commands.build

        raise E2E::Error, <<~MSG.chomp
          Vite test asset build failed.
          Run: bin/vite build --mode=test
          Or set #{SKIP_ENV}=1 to skip (not recommended for Inertia/Vite apps).
        MSG
      end

      def with_lock
        lock_path = project_root.join("tmp", LOCK_NAME)
        FileUtils.mkdir_p(lock_path.dirname)

        File.open(lock_path, File::RDWR | File::CREAT, 0o644) do |lock|
          lock.flock(File::LOCK_EX)
          yield
        ensure
          lock.flock(File::LOCK_UN)
        end
      end
    end
  end
end
