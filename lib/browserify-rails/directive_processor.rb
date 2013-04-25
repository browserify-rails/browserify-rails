require 'open3'

module BrowserifyRails
  class DirectiveProcessor < Sprockets::DirectiveProcessor
    BROWSERIFY_CMD = './node_modules/.bin/browserify'.freeze

    class BrowserifyError < ArgumentError
    end

    def evaluate(context, locals, &block)
      super

      browserify_cmd = File.join(context.environment.root, BROWSERIFY_CMD)

      raise ArgumentError, "#{browserify_cmd} could not be found. Please run npm install." unless File.exist?(browserify_cmd)

      stdin, stdout, stderr = Open3.popen3("#{browserify_cmd} #{pathname}")
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
    end
  end
end
