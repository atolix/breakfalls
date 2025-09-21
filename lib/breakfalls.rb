# frozen_string_literal: true

require_relative 'breakfalls/version'
require 'breakfalls/railtie' if defined?(Rails)

module Breakfalls
  class << self
    def error_handlers
      @error_handlers ||= []
    end

    def controller_error_handlers
      @controller_error_handlers ||= Hash.new { |h, k| h[k] = [] }
    end

    def on_error(&block)
      error_handlers << block
    end

    def on_error_for(controller, &block)
      key = controller.to_s
      controller_error_handlers[key] << block
    end

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
