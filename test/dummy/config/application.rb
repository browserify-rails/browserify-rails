require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)
require "browserify-rails"

module Dummy
  class Application < Rails::Application
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Enable the asset pipeline
    config.assets.enabled = true

    # Add CoffeeScript support
    config.browserify_rails.commandline_options = "-t coffeeify --extension=\".js.coffee\""

    config.secret_token = '717b5a4e715127fc72bb840a70685d6e'
    config.secret_key_base = 'blah_'
  end
end
