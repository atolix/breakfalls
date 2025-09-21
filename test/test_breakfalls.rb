# frozen_string_literal: true

require 'test_helper'

class TestBreakfalls < Minitest::Test
  def setup
    Breakfalls.error_handlers.clear
    Breakfalls.controller_error_handlers.clear if Breakfalls.respond_to?(:controller_error_handlers)
  end

  def test_that_it_has_a_version_number
    refute_nil ::Breakfalls::VERSION
  end

  def test_error_handler_called
    called = false

    Breakfalls.on_error { |_e, _req, _user, _params| called = true }
    Breakfalls.run_error_handlers(StandardError.new('error!'))

    assert called, 'error handler should be called'
  end

  def test_error_handler_receives_exception
    received_message = false

    Breakfalls.on_error { |exception, _req, _user, _params| received_message = exception.message }
    Breakfalls.run_error_handlers(StandardError.new('This is exception message.'))

    assert_equal 'This is exception message.', received_message, 'handler should receive the exception with message'
  end

  def test_multiple_handlers_are_all_called
    called1 = false
    called2 = false

    Breakfalls.on_error { |_e, _req, _user, _params| called1 = true }
    Breakfalls.on_error { |_e, _req, _user, _params| called2 = true }

    Breakfalls.run_error_handlers(StandardError.new('oops'))

    assert called1 && called2, 'all registered handlers should be called'
  end

  def test_handler_receives_request
    captured = nil
    Breakfalls.on_error { |_e, req, _user, _params| captured = req }

    Breakfalls.run_error_handlers(StandardError.new('oops'), request: { path: '/foo' })

    assert_equal '/foo', captured[:path], 'request should be delivered to handler'
  end

  def test_handler_receives_params
    captured = nil
    Breakfalls.on_error { |_e, _req, _user, params| captured = params }

    Breakfalls.run_error_handlers(StandardError.new('oops'), params: { 'foo' => 'bar' })

    assert_equal 'bar', captured['foo'], 'params should be delivered to handler'
  end

  def test_handler_receives_user
    captured = nil
    Breakfalls.on_error { |_e, _req, user, _params| captured = user }

    Breakfalls.run_error_handlers(StandardError.new('oops'), user: { id: 1, name: 'alice' })

    assert_equal({ id: 1, name: 'alice' }, captured, 'user should be delivered to handler')
  end

  def test_no_handlers_registered_is_safe
    # should not raise and should return the handlers array (empty)
    result = Breakfalls.run_error_handlers(StandardError.new('no handlers'))
    assert_kind_of Array, result
    assert_empty result
  end

  def test_on_error_for_registers_handler_for_controller
    called = false
    Breakfalls.on_error_for('FooController') { |_e, _req, _user, _params| called = true }

    Breakfalls.run_error_handlers(StandardError.new('oops'), controller: 'FooController')

    assert called, 'controller-specific handler should be called for matching controller'
  end

  def test_controller_specific_handler_not_called_for_other_controller
    called = false
    Breakfalls.on_error_for('FooController') { |_e, _req, _user, _params| called = true }

    Breakfalls.run_error_handlers(StandardError.new('oops'), controller: 'BarController')

    assert !called, 'controller-specific handler should not be called for non-matching controller'
  end

  def test_controller_specific_and_global_handlers_both_called
    called_controller = false
    called_global = false

    Breakfalls.on_error_for('FooController') { |_e, _req, _user, _params| called_controller = true }
    Breakfalls.on_error { |_e, _req, _user, _params| called_global = true }

    result = Breakfalls.run_error_handlers(StandardError.new('oops'), controller: 'FooController')

    assert called_controller && called_global, 'both controller-specific and global handlers should be called'
    assert_equal 2, result.size, 'result should contain both handlers'
  end

  def test_only_global_handlers_called_when_no_controller_specific
    called_global = false
    Breakfalls.on_error { |_e, _req, _user, _params| called_global = true }

    result = Breakfalls.run_error_handlers(StandardError.new('oops'), controller: 'FooController')

    assert called_global, 'global handler should be called when no controller-specific handlers exist'
    assert_equal 1, result.size
  end
end
