# frozen_string_literal: true

RSpec.describe "Rack", type: :e2e do
  # Simple Rack App
  let(:app) do
    proc do |env|
      case env["PATH_INFO"]
      when "/"
        [
          200,
          {"content-type" => "text/html"},
          [
            <<~HTML
              <h1>Hello Rack!</h1>
              <button id="save" onclick="setTimeout(() => { document.getElementById('status').textContent = 'Saved'; }, 50)">Save</button>
              <a href="#" onclick="setTimeout(() => { document.getElementById('status').textContent = 'Linked'; }, 50); return false;">Trigger Link</a>

              <button id="show-notice" onclick="setTimeout(() => { document.getElementById('notice').textContent = 'Profile updated'; }, 50)">Show Notice</button>
              <button id="show-alert" onclick="setTimeout(() => { document.getElementById('alert').textContent = 'Something went wrong'; }, 50)">Show Alert</button>

              <a href="/done">Go Done</a>
              <div id="status">Idle</div>
              <div id="notice" role="status"></div>
              <div id="alert" role="alert"></div>
            HTML
          ]
        ]
      when "/done"
        [200, {"content-type" => "text/html"}, ["<h1>Done Page</h1>"]]
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
    expect(find("h1")).to have_text("Hello Rack!")
  end

  it "waits for asynchronous text updates" do
    visit("/")

    click_button_and_wait_for_text("Save", "Saved")

    expect(page).to have_text("Saved")
  end

  it "waits for asynchronous text updates after link click" do
    visit("/")

    click_link_and_wait_for_text("Trigger Link", "Linked")

    expect(page).to have_text("Linked")
  end

  it "waits for path change after link click" do
    visit("/")

    click_link_and_wait_for_path("Go Done", "/done")

    expect(page).to have_current_path("/done")
    expect(page).to have_text("Done Page")
  end

  it "waits for notice flash" do
    visit("/")

    click_button_and_wait_for_flash("Show Notice", "Profile updated", type: :notice)

    expect(page).to have_text("Profile updated")
  end

  it "waits for alert flash" do
    visit("/")

    click_button_and_wait_for_flash("Show Alert", /went wrong/i, type: :alert)

    expect(page).to have_text("Something went wrong")
  end

  it "raises E2E::Error when wait_for times out" do
    visit("/")

    expect {
      wait_for(timeout: 0.05, interval: 0.01) { false }
    }.to raise_error(E2E::Error, /Timed out waiting for condition/)
  end

  it "raises E2E::Error when flash wait times out" do
    visit("/")

    expect {
      wait_for_flash("Missing flash", timeout: 0.05, interval: 0.01)
    }.to raise_error(E2E::Error, /Expected flash with text/)
  end
end
