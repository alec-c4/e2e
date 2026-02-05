# frozen_string_literal: true

RSpec.describe "Rack", type: :e2e do
  # Simple Rack App
  let(:app) do
    proc do |env|
      if env["PATH_INFO"] == "/"
        [200, {"content-type" => "text/html"}, ["<h1>Hello Rack!</h1>"]]
      else
        [404, {}, ["Not Found"]]
      end
    end
  end

  before do
    E2E.configure do |config|
      config.app = app
    end
  end

  it "visits a local rack app" do
    visit("/")
    expect(page.body).to include("Hello Rack!")
    expect(find("h1").text).to eq("Hello Rack!")
  end
end
