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

  def test_error_handler_receives_execption
    received_message = false

    Breakfalls.on_error { |exception, _req, _user, _params| received_message = exception.message }
    Breakfalls.run_error_handlers(StandardError.new('This is exception message.'))

    assert_equal 'This is exception message.', received_message, 'handler should receive the exception with message'
  end
end
