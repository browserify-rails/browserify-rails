require "open3"
require "json"

module BrowserifyRails
  class DirectiveProcessor < Tilt::Template
    BROWSERIFY_CMD  = "./node_modules/.bin/browserify".freeze
    MODULE_DEPS_CMD = "./node_modules/.bin/module-deps".freeze
    COFFEEIFY_PATH  = "./node_modules/coffeeify".freeze

    class BrowserifyError < RuntimeError
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
      JSON.parse(run_with_data(module_deps_cmd))
    end

    def browserify
      params = "-d"
      params += " -t coffeeify --extension='.coffee'" if File.directory?(COFFEEIFY_PATH)

      run_with_data("#{browserify_cmd} #{params}")
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

    # Run `command` with `data` on standard input.
    #
    # We are passing the data via stdin, so that earlier preprocessing steps are
    # respected. If you had, say, an "application.js.coffee.erb", passing the
    # filename would fail, because browserify would read the original file with
    # ERB tags and fail. By passing the data via stdin, we get the expected
    # behavior of success, because everything has been compiled to plain
    # javascript at the time this processor is called.
    #
    # @raise [BrowserifyError] if `command` does not succeed
    # @param command [String]
    # @return [String] Output on standard out
    def run_with_data(command)
      stdout, stderr, status = Open3.capture3(command, stdin_data: data, chdir: File.dirname(file))

      if !status.success?
        raise BrowserifyError.new("Error while running `#{command}`:\n\n#{stderr}")
      end

      stdout
    end
  end
end
