# frozen_string_literal: true

require 'test_helper'
require 'breakfalls/railtie'

class DummyController < ActionController::Base
  def unrescued_standard
    raise 'error!'
  end

  class RequestError < StandardError; end

  def rescued_custom
    raise RequestError
  rescue RequestError
    puts 'failed'
    head :ok
  end

  def rescued_standard
    raise StandardError, 'boom'
  rescue StandardError
    puts 'rescued standard'
    head :ok
  end
end

class DummyRailsApp < Rails::Application
  config.secret_key_base = 'dummy'
  config.active_support.to_time_preserves_timezone = :zone
  config.eager_load = false
  config.hosts.clear
  routes.append do
    get '/unrescued_standard' => 'dummy#unrescued_standard'
    get '/rescued_custom' => 'dummy#rescued_custom'
    get '/rescued_standard' => 'dummy#rescued_standard'
  end
end

class BreakfallsIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    Rails.application = DummyRailsApp.instance
    Rails.application.config.breakfalls.controllers = %w[DummyController]
    Rails.application.initialize! unless Rails.application.initialized?
    Rails.application.reloader.prepare!
  end

  def test_handler_called_on_unrescued_standard_error
    called = false
    Breakfalls.on_error { |_e, _req, _user, _params| called = true }

    get '/unrescued_standard'
  rescue StandardError
    # skip execption
  ensure
    assert called, 'Breakfalls handler should be called when DummyController raises'
  end

  def test_handler_skips_when_custom_exception_is_rescued
    called = false
    Breakfalls.on_error { |_e, _req, _user, _params| called = true }

    get '/rescued_custom'
  ensure
    assert !called, 'Breakfalls handler should not be called when the controller rescues the exception'
  end

  def test_handler_skips_when_standard_error_is_rescued
    called = false
    Breakfalls.on_error { |_e, _req, _user, _params| called = true }

    get '/rescued_standard'
  ensure
    assert !called, 'Breakfalls handler should not be called when StandardError is rescued in the controller'
  end
end
