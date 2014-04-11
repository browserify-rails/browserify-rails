require "open3"

module BrowserifyRails
  class BrowserifyProcessor < Tilt::Template
    BROWSERIFY_CMD = "./node_modules/.bin/browserify".freeze

    def prepare
      @config = Rails.application.config.browserify_rails_granular
    end

    def evaluate(context, locals, &block)
      if should_browserify?
        asset_dependencies(context.environment.paths).each do |path|
          context.depend_on(path)
        end

        browserify context.logical_path
      else
        data
      end
    end

    private

    def asset_paths
      @asset_paths ||= Rails.application.config.assets.paths.collect { |p| p.to_s }.join(':') || ''
    end

    def debug?
      @config.has_key?('debug') && @config['debug']
    end

    def has_config?(logical_path)
      @config.has_key?('javascript') && @config['javascript'].has_key?(logical_path)
    end

    def get_config(logical_path)
      if @config.has_key?('javascript')
        @config['javascript'][logical_path]
      end
    end

    def should_browserify?
      in_path? && commonjs_module?
    end

    # Is this file in any of the configured paths?
    def in_path?
      config.paths.any? do |path_spec|
        path_spec === file
      end
    end

    # Is this a commonjs module?
    #
    # Be here as strict as possible, so that non-commonjs files are not
    # preprocessed.
    def commonjs_module?
      data.to_s.include?("module.exports") || dependencies.length > 0
    end

    # This primarily filters out required files from node modules
    #
    # @return [<String>] Paths of dependencies, that are in asset directories
    def asset_dependencies(asset_paths)
      dependencies.select do |path|
        path.start_with?(*asset_paths)
      end
    end

    # @return [<String>] Paths of files, that this file depends on
    def dependencies
      @dependencies ||= run_browserify("#{options} --list").lines.map(&:strip).select do |path|
        # Filter the temp file, where browserify caches the input stream
        File.exists?(path)
      end
    end

    def browserify(logical_path)
      run_browserify(options, logical_path)
    end

    def browserify_cmd
      cmd = File.join(Rails.root, BROWSERIFY_CMD)

      if !File.exist?(cmd)
        raise BrowserifyRails::BrowserifyError.new("browserify could not be found at #{cmd}. Please run npm install.")
      end

      cmd
    end

    # Run browserify with `data` on standard input.
    #
    # We are passing the data via stdin, so that earlier preprocessing steps are
    # respected. If you had, say, an "application.js.coffee.erb", passing the
    # filename would fail, because browserify would read the original file with
    # ERB tags and fail. By passing the data via stdin, we get the expected
    # behavior of success, because everything has been compiled to plain
    # javascript at the time this processor is called.
    #
    # @raise [BrowserifyRails::BrowserifyError] if browserify does not succeed
    # @param options [String] Options for browserify
    # @return [String] Output on standard out
    def run_browserify(options, logical_path=nil)
      if has_config?(logical_path)
        config = get_config logical_path

        options += " " + config.keys.collect { |key|
          config[key].collect { |value|
            "--#{key} #{value}"
          }
        }.join(" ")
      end

      directory = File.dirname(file)
      # The dash tells browserify to read from STDIN
      command = "#{browserify_cmd} #{options} -"
      puts "Browserify: #{command}\n\n" if debug?
      env = {
        'NODE_PATH' => asset_paths
      }
      stdout, stderr, status = Open3.capture3(env, command, stdin_data: data, chdir: directory)

      if !status.success?
        raise BrowserifyRails::BrowserifyError.new("Error while running `#{command}`:\n\n#{stderr}")
      end

      stdout
    end

    def options
      options = []

      options.push("-d") if config.source_map_environments.include?(Rails.env)

      options += Array(config.commandline_options) if config.commandline_options.present?

      options.uniq.join(" ")
    end

    def config
      BrowserifyRails::Railtie.config.browserify_rails
    end
  end
end
