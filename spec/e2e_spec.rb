# frozen_string_literal: true

RSpec.describe E2e do
  it "has a version number" do
    expect(E2e::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
