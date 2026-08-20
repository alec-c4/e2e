# frozen_string_literal: true

RSpec.describe E2E::Server do
  # Bare Rack app; the eager-load behavior under test doesn't touch it at all.
  let(:app) { proc { |_env| [200, {}, [""]] } }

  after { E2E.config.eager_load_app = true }

  describe "#eager_load_app!" do
    it "does nothing when Rails isn't loaded" do
      server = described_class.new(app)

      expect { server.send(:eager_load_app!) }.not_to raise_error
    end

    it "eager loads a Rails app that hasn't already eager loaded" do
      config = double(eager_load: false)
      application = double(config: config, eager_load!: nil) # rubocop:disable RSpec/VerifiedDoubles -- no real Rails::Application class loaded in this gem's suite
      stub_const("Rails", Module.new)
      allow(Rails).to receive_messages(respond_to?: true, application: application)

      described_class.new(app).send(:eager_load_app!)

      expect(application).to have_received(:eager_load!)
    end

    it "does not eager load again when the app is already eager loaded" do
      config = double(eager_load: true)
      application = double(config: config, eager_load!: nil) # rubocop:disable RSpec/VerifiedDoubles -- no real Rails::Application class loaded in this gem's suite
      stub_const("Rails", Module.new)
      allow(Rails).to receive_messages(respond_to?: true, application: application)

      described_class.new(app).send(:eager_load_app!)

      expect(application).not_to have_received(:eager_load!)
    end

    it "is skippable via E2E.config.eager_load_app" do
      E2E.config.eager_load_app = false
      stub_const("Rails", Module.new)
      allow(Rails).to receive(:respond_to?).and_raise("should not be reached")

      expect { described_class.new(app).send(:eager_load_app!) }.not_to raise_error
    end
  end
end
