# frozen_string_literal: true

require 'rails/railtie'

module Breakfalls
  class Railtie < ::Rails::Railtie
    config.breakfalls = ActiveSupport::OrderedOptions.new

    config.to_prepare do
      Array(config.breakfalls.controllers)
      next if controllers.empty?

      controllers.each do |controller|
        klass = controller.safe_constantize
        next unless klass

        klass.class_eval do
          around_action :breakfalls_dispatch

          private

          def breakfalls_dispatch
            yield
          rescue StandardError => e
            Breakfalls.run_error_handlers(
              e,
              request,
              (respond_to?(current_user) ? current_user : nil),
              params
            )
            raise e
          end
        end
      end
    end
  end
end
