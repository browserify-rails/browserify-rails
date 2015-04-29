# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../test/dummy/config/environment.rb",  __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../test/dummy/db/migrate", __FILE__)]
require "rails/test_help"
require "fileutils"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
  ActiveSupport::TestCase.fixtures :all
end

# Remove tmp dir of dummy app
FileUtils.rm_rf "#{File.dirname(__FILE__)}/dummy/tmp"

ActiveSupport::TestCase.class_eval do
  def fixture(filename)
    File.open(File.join(File.dirname(__FILE__), "fixtures", filename)) do |f|
      contents = f.read.strip
      contents.gsub(/__RAILS_ROOT__/, Rails.root.to_s) if contents
    end
  end
end
