# frozen_string_literal: true

RSpec.describe "Matchers", type: :e2e do
  it "supports have_class matcher" do
    visit "data:text/html,<div class='foo bar'></div>"
    div = find("div")
    expect(div).to have_class("foo")
    expect(div).to have_class("bar")
    expect(div).not_to have_class("baz")
  end

  it "supports have_text/have_content matcher" do
    visit "data:text/html,<div>Hello World</div>"
    div = find("div")
    expect(div).to have_text("Hello")
    expect(div).to have_content("World")
    expect(div).not_to have_text("Goodbye")
  end

  it "supports have_value matcher" do
    visit "data:text/html,<input value='test'>"
    input = find("input")
    expect(input).to have_value("test")
    expect(input).not_to have_value("other")
  end

  it "supports have_attribute matcher" do
    visit "data:text/html,<div data-test='123'></div>"
    div = find("div")
    expect(div).to have_attribute("data-test", "123")
    expect(div).not_to have_attribute("data-test", "456")
  end

  it "supports be_checked matcher" do
    visit "data:text/html,<input type='checkbox' checked>"
    checkbox = find("input")
    expect(checkbox).to be_checked
  end

  it "supports be_disabled/be_enabled matchers" do
    visit "data:text/html,<button disabled>Disabled</button><button>Enabled</button>"
    disabled_btn = find("button", text: "Disabled")
    enabled_btn = find("button", text: "Enabled")

    expect(disabled_btn).to be_disabled
    expect(disabled_btn).not_to be_enabled

    expect(enabled_btn).to be_enabled
    expect(enabled_btn).not_to be_disabled
  end

  it "supports be_visible matcher" do
    visit "data:text/html,<div style='display:none'>Hidden</div><div>Visible</div>"
    hidden = find("div", text: "Hidden")
    visible = find("div", text: "Visible")

    expect(visible).to be_visible
    expect(hidden).not_to be_visible
  end

  it "supports have_no_text/have_no_content matcher" do
    visit "data:text/html,<div>Hello World</div>"
    expect(page).to have_no_text("Goodbye")
    expect(page).to have_no_content("Goodbye")

    expect {
      expect(page).to have_no_content("Hello")
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end

  it "supports have_no_current_path matcher" do
    visit "data:text/html,<div></div>"
    expect(page).to have_no_current_path("/foo")

    url = page.current_url
    path = begin
      URI.parse(url).path
    rescue URI::InvalidURIError
      url
    end

    expect {
      expect(page).to have_no_current_path(path)
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
  end
end
