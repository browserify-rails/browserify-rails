require "open3"
require "json"

module BrowserifyRails
  class DirectiveProcessor < Tilt::Template
    BROWSERIFY_CMD  = "./node_modules/.bin/browserify".freeze
    MODULE_DEPS_CMD = "./node_modules/.bin/module-deps".freeze
    COFFEEIFY_PATH  = "./node_modules/coffeeify".freeze

    class BrowserifyError < RuntimeError
    end

    class ModuleDepsError < RuntimeError
    end

    def prepare
    end

    def evaluate(context, locals, &block)
      if commonjs_module?
        dependencies.each do |dep|
          path = File.basename(dep["id"], context.environment.root)
          next if path == File.basename(file)

          if path =~ /<([^>]+)>/
            path = $1
          else
            path = "./#{path}" unless path.start_with?(".")
          end

          context.depend_on_asset(path)
        end

        browserify
      else
        data
      end
    end

    private

    def commonjs_module?
      data.to_s.include?("module.exports") || data.to_s.include?("require")
    end

    def dependencies
      stdout, stderr, status = Open3.capture3(module_deps_cmd, stdin_data: data)

      if !status.success?
        raise ModuleDepsError.new(stderr)
      end

      JSON.parse(stdout)
    end

    def browserify
      params = "-d"
      params += " -t coffeeify --extension='.coffee'" if File.directory?(COFFEEIFY_PATH)

      stdout, stderr, status = Open3.capture3("#{browserify_cmd} #{params}", stdin_data: data)

      if !status.success?
        raise BrowserifyError.new(stderr)
      end

      stdout
    end

    def browserify_cmd
      cmd = File.join(Rails.root, BROWSERIFY_CMD)

      if !File.exist?(cmd)
        raise ArgumentError, "#{cmd} could not be found. Please run npm install."
      end

      cmd
    end

    def module_deps_cmd
      cmd = File.join(Rails.root, MODULE_DEPS_CMD)

      if !File.exist?(cmd)
        raise ArgumentError, "#{cmd} could not be found. Please run npm install."
      end

      cmd
    end
  end
end
