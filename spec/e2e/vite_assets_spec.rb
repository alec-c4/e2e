# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "tmpdir"

RSpec.describe E2E::ViteAssets do
  let(:root) { Dir.mktmpdir }
  let(:commands) { spy("ViteRuby::Commands") } # rubocop:disable RSpec/VerifiedDoubles

  before do
    vite_ruby = Class.new
    stub_const("ViteRuby", vite_ruby)
    allow(vite_ruby).to receive(:commands).and_return(commands)
    allow(commands).to receive(:build).and_return(true)
    allow(described_class).to receive(:project_root).and_return(Pathname.new(root))
    E2E.config.ensure_vite_assets = :auto
    described_class.reset!
  end

  after do
    FileUtils.remove_entry(root) if File.directory?(root)
    described_class.reset!
    E2E.config.ensure_vite_assets = :auto
    ENV.delete("SKIP_VITE_TEST_BUILD")
  end

  describe ".ensure_built!" do
    it "builds once when ViteRuby is present and mode is :auto" do
      described_class.ensure_built!
      described_class.ensure_built!

      expect(commands).to have_received(:build).once
    end

    it "skips when ensure_vite_assets is :skip" do
      E2E.config.ensure_vite_assets = :skip

      described_class.ensure_built!

      expect(commands).not_to have_received(:build)
    end

    it "skips when SKIP_VITE_TEST_BUILD=1" do
      ENV["SKIP_VITE_TEST_BUILD"] = "1"

      described_class.ensure_built!

      expect(commands).not_to have_received(:build)
    end

    it "raises when build fails and mode is :build" do
      E2E.config.ensure_vite_assets = :build
      allow(commands).to receive(:build).and_return(false)

      expect {
        described_class.ensure_built!
      }.to raise_error(E2E::Error, /Vite test asset build failed/)
    end

    it "warns when build fails and mode is :warn" do
      E2E.config.ensure_vite_assets = :warn
      allow(commands).to receive(:build).and_return(false)

      expect {
        described_class.ensure_built!
      }.to output(/Vite test asset build failed/).to_stderr
    end

    it "noops when ViteRuby is not defined" do
      hide_const("ViteRuby")
      E2E.config.ensure_vite_assets = :auto

      expect { described_class.ensure_built! }.not_to raise_error
    end

    it "raises when mode is :build and ViteRuby is missing" do
      hide_const("ViteRuby")
      E2E.config.ensure_vite_assets = :build

      expect {
        described_class.ensure_built!
      }.to raise_error(E2E::Error, /ViteRuby is not loaded/)
    end
  end
end
