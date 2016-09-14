require "open3"
require "fileutils"
require "tempfile"
require "shellwords"
require "addressable"

module BrowserifyRails
  class BrowserifyProcessor
    attr_accessor :config, :data, :file

    def self.instance
      @instance ||= new
    end

    def self.call(input)
      instance.call(input)
    end

    def initialize
      self.config = Rails.application.config.browserify_rails
    end

    def call(input)
      self.data = input[:data]
      self.file = input[:filename]

      # Clear the cached dependencies because the source file changes
      @dependencies = nil

      ensure_tmp_dir_exists!
      ensure_commands_exist!

      # If there's nothing to do, we just return the data we received
      return data unless should_browserify?

      dependencies = Set.new(input[:metadata][:dependencies])

      # Signal dependencies to sprockets to ensure we track changes
      evaluate_dependencies(input[:environment].paths).each do |path|
        resolved = input[:environment].resolve(path)

        if resolved && resolved.is_a?(Array)
          resolved = resolved[0]
        elsif config.evaluate_node_modules && !resolved
          resolved = path
        end

        dependencies << "file-digest://#{Addressable::URI.escape resolved}" if resolved
      end

      new_data = run_browserify(input[:name])
      { data: new_data, dependencies: dependencies }
    end

  private

    def tmp_path
      @tmp_path ||= Rails.root.join("tmp", "cache", "browserify-rails").freeze
    end

    def browserify_cmd
      @browserify_cmd ||= File.join(config.node_bin, "browserify").freeze
    end

    def browserifyinc_cmd
      @browserifyinc_cmd ||= File.join(config.node_bin, "browserifyinc").freeze
    end

    def exorcist_cmd
      @exorcist_cmd ||= rails_path(File.join(config.node_bin, "exorcist").freeze)
    end

    def ensure_tmp_dir_exists!
      FileUtils.mkdir_p(rails_path(tmp_path))
    end

    def ensure_commands_exist!
      error = ->(cmd) { "Unable to run #{cmd}. Ensure you have installed it with npm." }

      # Browserify has to be installed in any case
      if !File.exist?(rails_path(browserify_cmd))
        raise BrowserifyRails::BrowserifyError.new(error.call(browserify_cmd))
      end

      # If the user wants to use browserifyinc, we need to ensure it's there too
      if config.use_browserifyinc && !File.exist?(rails_path(browserifyinc_cmd))
        raise BrowserifyRails::BrowserifyError.new(error.call(browserifyinc_cmd))
      end
    end

    def should_browserify?
      force_browserify? || (in_path? && !browserified? && commonjs_module?)
    end

    def force_browserify?
      if config.force.is_a? Proc
        config.force.call file
      else
        config.force
      end
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
      data.to_s.include?("module.exports") || data.present? && data.to_s.match(/(require\(.*\)|import)/) && dependencies.length > 0
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
          File.exist?(path)
        end
      end
    end

    # Environtment to run browserify in:
    #
    # NODE_PATH https://nodejs.org/api/all.html#all_loading_from_the_global_folders
    # but basically allows one to have multiple locations for non-relative requires
    # to be resolved to.
    #
    # NODE_ENV is set to the Rails.env. This is used by some modules to determine
    # how to build. Example: https://facebook.github.io/react/downloads.html#npm
    def env
      env_hash = {}
      env_hash["NODE_PATH"] = asset_paths unless uses_exorcist
      env_hash["NODE_ENV"] = config.node_env || Rails.env
      env_hash
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
        cache_file_path = rails_path(tmp_path, "browserifyinc-cache.json")
        command_options << " --cachefile=#{Shellwords.escape(cache_file_path)}"
      end

      # Create a temporary file for the output. Such file is necessary when
      # using browserifyinc, but we use it in all instances for consistency
      output_file = Tempfile.new("output", rails_path(tmp_path))
      command_options << " -o #{output_file.path.inspect}"

      # Compose the full command (using browserify or browserifyinc as necessary)
      command = "#{Shellwords.escape(browserify_command(force_browserifyinc))} #{command_options} -"

      # The directory the command will be executed from
      base_directory = File.dirname(file)

      Logger::log "Browserify: #{command}"

      # If we are on JRuby 1.x, capture3 does not support chdir option
      stdout, stderr, status = if RUBY_PLATFORM == "java" && JRUBY_VERSION =~ /^1/
        Dir.chdir(base_directory) {
          Open3.capture3(env, command, stdin_data: data)
        }
      else
        Open3.capture3(env, command, stdin_data: data, chdir: base_directory)
      end

      if !status.success?
        raise BrowserifyRails::BrowserifyError.new("Error while running `#{command}`:\n\n#{stderr}")
      end

      # If using exorcist, pipe output from browserify command into exorcist
      if uses_exorcist && logical_path
        if stdout.present?
          bfy_output = stdout
        else
          bfy_output = output_file.read
        end
        sourcemap_output_file = "#{File.dirname(file)}/#{logical_path.split('/')[-1]}.map"
        exorcist_command = "#{Shellwords.shellescape(exorcist_cmd)} #{Shellwords.shellescape(sourcemap_output_file)} #{exorcist_options}"
        Logger::log "Exorcist: #{exorcist_command}"
        exorcist_stdout, exorcist_stderr, exorcist_status = Open3.capture3(env,
                                                                           exorcist_command,
                                                                           stdin_data: bfy_output,
                                                                           chdir: base_directory)

        if !exorcist_status.success?
          raise BrowserifyRails::BrowserifyError.new("Error while running `#{exorcist_command}`:\n\n#{exorcist_stderr}")
        end
      end

      # Read the output that was stored in the temp file
      output = output_file.read

      # Destroy the temp file (good practice)
      output_file.close
      output_file.unlink

      # Some command flags (such as --list) make the output go to stdout,
      # ignoring -o. If this happens, we give out stdout instead.
      # If we're using exorcist, then we directly use its output
      if uses_exorcist && exorcist_stdout.present?
        exorcist_stdout
      elsif stdout.present?
        stdout
      else
        output
      end
    end

    def uses_browserifyinc(force=nil)
      !force.nil? ? force : config.use_browserifyinc
    end

    def uses_exorcist
      config.use_exorcist
    end

    def browserify_command(force=nil)
      rails_path(uses_browserifyinc(force) ? browserifyinc_cmd : browserify_cmd)
    end

    def options_to_array(options)
      if options.respond_to? :call
        options.call(file)
      else
        Array(options)
      end
    end

    def options
      options = []

      options.push("-d") if config.source_map_environments.include?(Rails.env)

      options += options_to_array(config.commandline_options) if config.commandline_options.present?

      options.uniq.join(" ")
    end

    def exorcist_options
      exorcist_options = []
      root_path = config.root || File.expand_path('../..', __FILE__)
      exorcist_base_path = config.exorcist_base_path || root_path
      exorcist_options.push("-b #{exorcist_base_path}")
      exorcist_options.join(" ")
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
