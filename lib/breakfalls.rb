# frozen_string_literal: true

require_relative 'breakfalls/version'
require 'breakfalls/railtie' if defined?(Rails)

module Breakfalls
  class << self
    def error_handlers
      @error_handlers ||= []
    end

    # Registry for controller-specific handlers.
    # Key: controller class name (String); Value: Array<Proc>.
    def controller_error_handlers
      @controller_error_handlers ||= Hash.new { |h, k| h[k] = [] }
    end

    # Register a global error handler (applies to all controllers).
    # Called in the order they were registered.
    # Example:
    #   Breakfalls.on_error do |exception, request, user, params|
    #     Rails.logger.error("[Global] #{exception.message} path=#{request&.path}")
    #   end
    def on_error(&block)
      error_handlers << block
    end

    # Register a controller-specific error handler.
    # The controller argument should be a class name (String or Symbol).
    # Invocation order at runtime is: controller-specific handlers first, then global handlers.
    # Example:
    #   Breakfalls.on_error_for('UsersController') do |exception, request, user, params|
    #     Rails.logger.warn("[UsersController] #{exception.class} at #{request&.path}")
    #   end
    def on_error_for(controller, &block)
      key = controller.to_s
      controller_error_handlers[key] << block
    end

    # Execute error handlers.
    # Call order: controller-specific (when controller matches) → global.
    # Returns: Array of invoked handler Procs.
    # Example (manual invocation):
    #   Breakfalls.run_error_handlers(
    #     RuntimeError.new('boom'),
    #     request: req,
    #     user: current_user,
    #     params: params,
    #     controller: 'UsersController'
    #   )
    def run_error_handlers(exception, request: nil, user: nil, params: nil, controller: nil)
      handlers = []
      controller && handlers.concat(controller_error_handlers[controller.to_s])
      handlers.concat(error_handlers)

      handlers.each do |eh|
        eh.call(exception, request, user, params)
      end

      handlers
    end
  end
end
