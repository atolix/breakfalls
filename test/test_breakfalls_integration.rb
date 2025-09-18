# frozen_string_literal: true

require 'test_helper'
require 'breakfalls/railtie'

class DummyController < ActionController::Base
  def index
    raise 'error!'
  end
end

class DummyRailsApp < Rails::Application
  config.secret_key_base = 'dummy'
  config.eager_load = false
  config.hosts.clear
  routes.append do
    get '/test' => 'dummy#index'
  end
end

class BreakfallsIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    Rails.application = DummyRailsApp.instance
    Rails.application.config.breakfalls.controllers = %w[DummyController]
    Rails.application.initialize!
    Rails.application.reloader.prepare!
  end

  def test_handler_called_on_exception
    called = false
    Breakfalls.on_error { |_e, _req, _user, _params| called = true }

    get '/test'
  rescue StandardError
    # skip execption
  ensure
    assert called, 'Breakfalls handler should be called when DummyController raises'
  end
end
