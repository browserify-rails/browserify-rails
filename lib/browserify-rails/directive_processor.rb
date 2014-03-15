require 'open3'
require 'json'

module BrowserifyRails
  class DirectiveProcessor < Sprockets::DirectiveProcessor
    BROWSERIFY_CMD  = './node_modules/.bin/browserify'.freeze
    MODULE_DEPS_CMD = './node_modules/.bin/module-deps'.freeze
    COFFEEIFY_PATH  = './node_modules/coffeeify'.freeze

    class BrowserifyError < RuntimeError
    end

    class ModuleDepsError < RuntimeError
    end

    def evaluate(context, locals, &block)
      super

      if commonjs_module?(data)
        browserify_cmd = File.join(context.environment.root, BROWSERIFY_CMD)
        module_deps_cmd = File.join(context.environment.root, MODULE_DEPS_CMD)

        raise ArgumentError, "#{browserify_cmd} could not be found. Please run npm install." unless File.exist?(browserify_cmd)
        raise ArgumentError, "#{module_deps_cmd} could not be found. Please run npm install." unless File.exist?(module_deps_cmd)

        deps = JSON.parse(run_command("#{module_deps_cmd} #{pathname}"))
        deps.each do |dep|
          path = File.basename(dep['id'], context.environment.root)
          next if path == File.basename(pathname)

          if path =~ /<([^>]+)>/
            path = $1
          else
            path = "./#{path}" unless relative?(path)
          end

          context.depend_on_asset(path)
        end

        params = "-d"
        params += " -t coffeeify --extension='.coffee'" if File.directory?(COFFEEIFY_PATH)

        run_command("#{browserify_cmd} #{params} #{pathname}")
      else
        data
      end
    end

    def commonjs_module?(data)
      data.to_s.include?('module.exports') || data.to_s.include?('require')
    end

    def run_command(command)
      stdin, stdout, stderr = Open3.popen3("#{command}")
      begin
        result = stdout.read
        result_error = stderr.read.strip
        if result_error.empty?
          result
        else
          raise ModuleDepsError, result_error
        end
      ensure
        stdin.close
        stdout.close
        stderr.close
      end
    end
  end
end
