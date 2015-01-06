module BrowserifyRails
  class Railtie < Rails::Engine
    config.browserify_rails = ActiveSupport::OrderedOptions.new

    # Which paths should be browserified?
    config.browserify_rails.paths = [lambda { |p| p.start_with?(Rails.root.join("app").to_s) },
                                     lambda { |p| p.start_with?(Rails.root.join("node_modules").to_s) }]

    # Environments to generate source maps in
    config.browserify_rails.source_map_environments = ["development"]

    # Use browserifyinc instead of browserify
    config.browserify_rails.use_browserifyinc = false

    initializer :setup_browserify do |app|
      # Load granular configuration
      filename = File.join(Rails.root, 'config', 'browserify.yml')
      configuration = YAML::load(File.read(filename)) if File.exist? filename
      config.browserify_rails.granular = configuration || {}

      app.assets.register_postprocessor "application/javascript", BrowserifyRails::BrowserifyProcessor
    end

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), "tasks/*.rake")].each { |f| load f }
    end
  end
end
