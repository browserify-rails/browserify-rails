module BrowserifyRails
  class Railtie < Rails::Engine
    initializer :setup_browserify do |app|
      app.assets.register_postprocessor "application/javascript", BrowserifyRails::BrowserifyProcessor
    end

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), "tasks/*.rake")].each { |f| load f }
    end
  end
end
