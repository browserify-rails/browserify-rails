require "open3"

module BrowserifyRails
  class BrowserifyProcessor < Tilt::Template
    BROWSERIFY_CMD = "./node_modules/.bin/browserify".freeze

    def prepare
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

    def has_config?(logical_path)
      Rails.application.config.browserify_rails_granular.has_key? logical_path
    end

    def get_config(logical_path)
      Rails.application.config.browserify_rails_granular[logical_path]
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
      temp_file = nil
      begin
        if has_config?(logical_path)
          config = get_config logical_path

          options += " " + config.keys.collect { |key|
            value = config[key]
            # temporary work around for bug/diferent use case: https://github.com/substack/node-browserify/issues/724
            if key == "require"
              temp_file = Tempfile.new("data", File.dirname(self.file))
              temp_file.write(data)
              temp_file.close(false)
              value << temp_file.path
            end
            "--#{key} #{value.join(" ")}"
          }.join(" ")
        end

        command = "#{browserify_cmd} #{options}"
        # The dash tells browserify to read from STDIN
        command = "#{browserify_cmd} #{options} -"
        directory = File.dirname(file)
        stdout, stderr, status = Open3.capture3(command, stdin_data: data, chdir: directory)

        if !status.success?
          raise BrowserifyRails::BrowserifyError.new("Error while running `#{command}`:\n\n#{stderr}")
        end
      ensure
        temp_file.unlink if temp_file
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
