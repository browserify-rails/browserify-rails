module BrowserifyRails
  class Railtie < Rails::Engine

    initializer :setup_browserify do |app|
      app.assets.register_preprocessor 'application/javascript', BrowserifyRails::DirectiveProcessor
    end

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
    end

  end
end
