# frozen_string_literal: true

module E2E
  class Driver
    def visit(url)
      raise NotImplementedError
    end

    def current_url
      raise NotImplementedError
    end

    def find(selector, **options)
      raise NotImplementedError
    end

    def all(selector, **options)
      raise NotImplementedError
    end

    def click(selector)
      raise NotImplementedError
    end

    def click_button(value, **options)
      raise NotImplementedError
    end

    def click_link(value, **options)
      raise NotImplementedError
    end

    def fill_in(selector, with:)
      raise NotImplementedError
    end

    def check(selector)
      raise NotImplementedError
    end

    def uncheck(selector)
      raise NotImplementedError
    end

    def attach_file(selector, path)
      raise NotImplementedError
    end

    def body
      raise NotImplementedError
    end

    def evaluate(script)
      raise NotImplementedError
    end

    def save_screenshot(path, **options)
      raise NotImplementedError
    end

    def native
      raise NotImplementedError
    end

    def pause
      raise NotImplementedError
    end

    def reset!
      raise NotImplementedError
    end

    def quit
      raise NotImplementedError
    end
  end
end
