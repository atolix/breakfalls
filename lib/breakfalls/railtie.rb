# frozen_string_literal: true

require 'rails/railtie'

module Breakfalls
  class Railtie < ::Rails::Railtie
    config.breakfalls = ActiveSupport::OrderedOptions.new

    config.to_prepare do
      controllers = Array(Rails.application.config.breakfalls.controllers)
      next if controllers.empty?

      controllers.each do |controller|
        ActiveSupport.on_load(:action_controller) do
          klass = controller.to_s.safe_constantize
          klass.class_eval do
            unless method_defined?(:breakfalls_dispatch)
              def dispatch_breakfalls
                yield
              rescue StandardError => e
                Breakfalls.run_error_handlers(
                  e,
                  request: request,
                  user: (respond_to?(:current_user) ? current_user : nil),
                  params: params
                )
                raise e
              end
            end
          end

          klass.send(:around_action, :dispatch_breakfalls)
        end
      end
    end
  end
end
