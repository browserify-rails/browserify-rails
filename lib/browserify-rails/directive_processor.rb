require 'open3'

module BrowserifyRails
  class DirectiveProcessor < Sprockets::DirectiveProcessor
    BROWSERIFY_CMD = './node_modules/.bin/browserify'.freeze
    COFFEEIFY_PATH = './node_modules/coffeeify'.freeze

    class BrowserifyError < ArgumentError
    end

    def evaluate(context, locals, &block)
      super

      if commonjs_module?(data)
        browserify_cmd = File.join(context.environment.root, BROWSERIFY_CMD)

        raise ArgumentError, "#{browserify_cmd} could not be found. Please run npm install." unless File.exist?(browserify_cmd)

        params = "-d"
        params += " -t coffeeify --extension='.coffee'" if File.directory?(COFFEEIFY_PATH)

        stdin, stdout, stderr = Open3.popen3("#{browserify_cmd} #{params} #{pathname}")
        begin
          result = stdout.read
          result_error = stderr.read.strip
          if result_error.empty?
            result
          else
            raise BrowserifyError, result_error
          end
        ensure
          stdin.close
          stdout.close
          stderr.close
        end
      else
        data
      end
    end

    def commonjs_module?(data)
      data.to_s.include?('module.exports') || data.to_s.include?('require')
    end
  end
end
