# frozen_string_literal: true

require "minitest/autorun"
require "e2e"
require "e2e/minitest"

class MinitestAssertionsTest < E2E::Minitest::TestCase
  def test_assert_text
    visit "data:text/html,<div>Hello World</div>"
    assert_text "Hello"
    assert_text "World"
    assert_text(/Hello/)
  end

  def test_refute_text
    visit "data:text/html,<div>Hello World</div>"
    refute_text "Goodbye"
    refute_text(/Goodbye/)
    assert_no_text "Goodbye"
  end

  def test_assert_selector
    visit "data:text/html,<div id='foo'>content</div>"
    assert_selector "#foo"
    assert_selector "div"
  end

  def test_refute_selector
    visit "data:text/html,<div id='foo'></div>"
    refute_selector "#bar"
    refute_selector ".baz"
    assert_no_selector "#bar"
  end

  def test_assert_current_path
    visit "data:text/html,<div></div>"
    # data: urls don't really have paths in the same way, but let's see how assert_current_path handles it.
    # The implementation:
    # actual_path = begin URI.parse(url).path rescue url end
    # For data:..., URI.parse might fail or return just the path.
    # Let's rely on what actual behavior is or mock it if needed.
    # Actually, let's use a standard page object if possible, or just expect the data url itself if path parsing fails.

    # Wait, the implementation of assert_current_path handles InvalidURIError by returning url.
    # For data:text/html,<div></div>, URI.parse might work but path is null or opaque?
    # Let's test with a real-ish url if we can, or just expect the data string.

    # Actually, RSpec tests use data urls.
    # Spec/e2e/matchers_spec.rb:
    # it "supports have_no_current_path matcher" do
    #   visit "data:text/html,<div></div>"
    #   expect(page).to have_no_current_path("/foo")
    # end

    # So I can test negative easily. Positive might be tricky with data uri.
    # I'll assert current path is the full data url.

    current = page.current_url
    assert_current_path current
  end

  def test_refute_current_path
    visit "data:text/html,<div></div>"
    refute_current_path "/foo"
    assert_no_current_path "/foo"
  end
end
