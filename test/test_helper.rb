# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails"
require "rails/test_help"
require "fileutils"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Remove tmp dir of dummy app
FileUtils.rm_rf "#{File.dirname(__FILE__)}/dummy/tmp"

ActiveSupport::TestCase.class_eval do
  def fixture(filename)
    File.open(File.join(File.dirname(__FILE__), "fixtures", filename)) do |f|
      contents = f.read.strip
      contents.gsub(/__RAILS_ROOT__/, Rails.root.to_s) if contents
    end
  end

  def fix(filename, contents)
    File.open(File.join(File.dirname(__FILE__), "fixtures", filename), "w") do |f|
      f.write(contents)
    end
  end
end
