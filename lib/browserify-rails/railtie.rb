module BrowserifyRails
  class Railtie < Rails::Engine
    config.browserify_rails = ActiveSupport::OrderedOptions.new

    # Which paths should be browserified?
    config.browserify_rails.paths = [lambda { |p| p.start_with?(Rails.root.join("app").to_s) },
                                     lambda { |p| p.start_with?(Rails.root.join("node_modules").to_s) }]

    # Environments to generate source maps in
    config.browserify_rails.source_map_environments = ["development"]

    # Load granular configuration
    filename = File.join(Dir.pwd, 'config', 'browserify.yml')
    configuration = YAML::load(File.read(filename)) if File.exist? filename

    # TODO we don't have Rails.root yet so either figure out how to get that or if there is a cleaner way to do this
    filename_under_test = File.join(Dir.pwd, 'test', 'dummy', 'config', 'browserify.yml')
    configuration = YAML::load(File.read(filename_under_test)) if File.exist? filename_under_test

    config.browserify_rails_granular = configuration || {}

    initializer :setup_browserify do |app|
      app.assets.register_postprocessor "application/javascript", BrowserifyRails::BrowserifyProcessor
    end

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), "tasks/*.rake")].each { |f| load f }
    end
  end
end
