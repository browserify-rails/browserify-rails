require "open3"
require "fileutils"
require "tempfile"

module BrowserifyRails
  class BrowserifyProcessor < Tilt::Template
    NODE_BIN = "node_modules/.bin/"

    BROWSERIFY_CMD    = File.join(NODE_BIN, "browserify").freeze
    BROWSERIFYINC_CMD = File.join(NODE_BIN, "browserifyinc").freeze

    TMP_PATH = File.join("tmp/browserify-rails").freeze

    def prepare
      ensure_tmp_dir_exists!
      ensure_commands_exist!
    end

    def evaluate(context, locals, &block)
      # If there's nothing to do, we just return the data we received
      return data unless should_browserify?

      # Signal dependencies to sprockets to ensure we track changes
      evaluate_dependencies(context.environment.paths).each do |path|
        context.depend_on(path)
      end

      run_browserify(context.logical_path)
    end

  private

    def config
      Rails.application.config.browserify_rails
    end

    def ensure_tmp_dir_exists!
      FileUtils.mkdir_p(rails_path(TMP_PATH))
    end

    def ensure_commands_exist!
      error = ->(cmd) { "Unable to run #{cmd}. Ensure you have installed it with npm." }

      # Browserify has to be installed in any case
      if !File.exists?(rails_path(BROWSERIFY_CMD))
        raise BrowserifyRails::BrowserifyError.new(error.call(BROWSERIFY_CMD))
      end

      # If the user wants to use browserifyinc, we need to ensure it's there too
      if config.use_browserifyinc && !File.exists?(rails_path(BROWSERIFYINC_CMD))
        raise BrowserifyRails::BrowserifyError.new(error.call(BROWSERIFYINC_CMD))
      end
    end

    def should_browserify?
      in_path? && !browserified? && commonjs_module?
    end

    # Is this file in any of the configured paths?
    def in_path?
      config.paths.any? do |path_spec|
        path_spec === file
      end
    end

    # Is this file already packaged for the browser?
    def browserified?
      data.to_s.include?("define.amd") || data.to_s.include?("_dereq_")
    end

    # Is this a commonjs module?
    #
    # Be here as strict as possible, so that non-commonjs files are not
    # preprocessed.
    def commonjs_module?
      data.to_s.include?("module.exports") || data.present? && data.to_s.include?("require") && dependencies.length > 0
    end

    def asset_paths
      @asset_paths ||= Rails.application.config.assets.paths.collect { |p| p.to_s }.join(":") || ""
    end

    # This primarily filters out required files from node modules
    #
    # @return [<String>] Paths of dependencies to evaluate
    def evaluate_dependencies(asset_paths)
      return dependencies if config.evaluate_node_modules

      dependencies.select do |path|
        path.start_with?(*asset_paths)
      end
    end

    # @return [<String>] Paths of files, that this file depends on
    def dependencies
      @dependencies ||= begin
        # We forcefully run browserify (avoiding browserifyinc) with the --list
        # option to get a list of files.
        list = run_browserify(nil, "--list")

        list.lines.map(&:strip).select do |path|
          # Filter the temp file, where browserify caches the input stream
          File.exists?(path)
        end
      end
    end

    # Run the requested version of browserify (browserify or browserifyinc)
    # based on configuration or the use_browserifyinc parameter if present.
    #
    # We are passing the data via stdin, so that earlier preprocessing steps are
    # respected. If you had, say, an "application.js.coffee.erb", passing the
    # filename would fail, because browserify would read the original file with
    # ERB tags and fail. By passing the data via stdin, we get the expected
    # behavior of success, because everything has been compiled to plain
    # javascript at the time this processor is called.
    #
    # @raise [BrowserifyRails::BrowserifyError] if browserify does not succeed
    # @param logical_path [String] Sprockets's logical path for the file
    # @param extra_options [String] Options to be included in the command
    # @param force_browserifyinc [Boolean] Causes browserifyinc to be used if true
    # @return [String] Output of the command
    def run_browserify(logical_path=nil, extra_options=nil, force_browserifyinc=nil)
      command_options = "#{options} #{extra_options} #{granular_options(logical_path)}".strip

      # Browserifyinc uses a special cache file. We set up the path for it if
      # we're going to use browserifyinc.
      if uses_browserifyinc(force_browserifyinc)
        cache_file_path = rails_path(TMP_PATH, "browserifyinc-cache.json")
        command_options << " --cachefile=#{cache_file_path.inspect}"
      end

      # Create a temporary file for the output. Such file is necessary when
      # using browserifyinc, but we use it in all instances for consistency
      output_file = Tempfile.new("output", rails_path(TMP_PATH))
      command_options << " -o #{output_file.path.inspect}"

      # Compose the full command (using browserify or browserifyinc as necessary)
      command = "#{browserify_command(force_browserifyinc)} #{command_options} -"
      env = { "NODE_PATH" => asset_paths }

      # The directory the command will be executed from
      base_directory = File.dirname(file)

      Logger::log "Browserify: #{command}"
      stdout, stderr, status = Open3.capture3(env, command, stdin_data: data, chdir: base_directory)

      if !status.success?
        raise BrowserifyRails::BrowserifyError.new("Error while running `#{command}`:\n\n#{stderr}")
      end

      # Read the output that was stored in the temp file
      output = output_file.read

      # Destroy the temp file (good practice)
      output_file.close
      output_file.unlink

      # Some command flags (such as --list) make the output go to stdout,
      # ignoring -o. If this happens, we give out stdout instead.
      if stdout.present?
        stdout
      else
        output
      end
    end

    def uses_browserifyinc(force=nil)
      !force.nil? ? force : config.use_browserifyinc
    end

    def browserify_command(force=nil)
      rails_path(uses_browserifyinc(force) ? BROWSERIFYINC_CMD : BROWSERIFY_CMD)
    end

    def options
      options = []

      options.push("-d") if config.source_map_environments.include?(Rails.env)

      options += Array(config.commandline_options) if config.commandline_options.present?

      options.uniq.join(" ")
    end

    def get_granular_config(logical_path)
      granular_config = config.granular["javascript"]

      granular_config && granular_config[logical_path]
    end

    def granular_options(logical_path)
      granular_config = get_granular_config(logical_path)

      return nil if granular_config.blank?

      # We set separate options for each of the items in granular_config
      options = granular_config.keys.collect do |key|
        granular_config[key].collect { |value| "--#{key} #{value}" }
      end

      options.flatten.join(" ") if options
    end

    def rails_path(*paths)
      Rails.root.join(*paths).to_s
    end
  end
end
