module BrowserifyRails
  class Railtie < Rails::Engine

    initializer :setup_browserify do |app|
      app.assets.register_preprocessor 'application/javascript', BrowserifyRails::DirectiveProcessor
    end

  end
end
