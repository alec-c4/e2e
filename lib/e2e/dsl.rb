# frozen_string_literal: true

require "forwardable"

module E2E
  module DSL
    extend Forwardable

    def_delegators "E2E.session", :visit, :current_url, :find, :all, :click, :click_button, :click_link, :fill_in, :check, :uncheck, :attach_file, :body, :evaluate, :save_screenshot, :native, :pause, :reset!

    def page
      E2E.session
    end
  end
end
