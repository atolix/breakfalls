# frozen_string_literal: true

require 'test_helper'

class TestBreakfalls < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Breakfalls::VERSION
  end

  def test_error_handler_called
    called = false
    Breakfalls.on_error { |_e, _req, _user, _params| called = true }
    Breakfalls.run_error_handlers(StandardError.new('error!'))
    assert called, 'error handler should be called'
  end
end
