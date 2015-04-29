Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  config.active_support.test_order = :sorted

  config.eager_load = false

  config.assets.debug = true
end
