# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'breakfalls'
require 'minitest/autorun'

require 'action_controller/railtie'
require 'rails'
