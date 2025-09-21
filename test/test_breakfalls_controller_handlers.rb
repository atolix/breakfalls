# frozen_string_literal: true

require 'test_helper'

class TestBreakfallsControllerHandlers < Minitest::Test
  def setup
    Breakfalls.error_handlers.clear
    Breakfalls.controller_error_handlers.clear if Breakfalls.respond_to?(:controller_error_handlers)
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
