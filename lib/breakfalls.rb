# frozen_string_literal: true

require_relative 'breakfalls/version'

module Breakfalls
  class << self
    def error_handlers
      @error_handlers ||= []
    end

    def on_error(&block)
      error_handlers << block
    end

    def run_error_handlers(exception, request: nil, user: nil, params: nil)
      error_handlers.each do |eh|
        eh.call(exception, request, user, params)
      end
    end
  end
end
