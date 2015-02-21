require 'rails/commands/server'

module BrowserifyRails
  class CacheFile
    def initialize(root)
      @rails_root = root
      @path = root.join(directory, "browserifyinc-cache-#{rails_port_number}.json").to_s
    end

    def path
      @path
    end

    def directory
      @directory ||= @rails_root.join("tmp", "browserify-rails").freeze
    end

    def reset_cache
      File.delete(@path) if File.exists?(@path)
    end

    private

    def rails_port_number
      Rails::Server.new.options[:Port]
    end
  end
end
