require 'test_helper'

class BrowserifyProcessorTest < ActiveSupport::TestCase
  setup do
    @empty_module = fixture("empty_module.js")
  end

  test "should run command without options if none provided" do
    processor = BrowserifyRails::BrowserifyProcessor.new { |p| @empty_module }

    assert_equal "", processor.send(:options)
  end

  test "should run command without options if empty array provided" do
    engine_config.commandline_options = []
    processor = BrowserifyRails::BrowserifyProcessor.new { |p| @empty_module }

    assert_equal "", processor.send(:options)
  end

  test "should convert options provided as an array to string" do
    engine_config.commandline_options = ["-d", "-i test1.js"]

    processor = BrowserifyRails::BrowserifyProcessor.new { |p| @empty_module }
    assert_equal "-d -i test1.js", processor.send(:options)
  end

  test "should allow providing options as a string" do
    engine_config.commandline_options = "-d -i test2.js"
    processor = BrowserifyRails::BrowserifyProcessor.new { |p| @empty_module }

    assert_equal "-d -i test2.js", processor.send(:options)
  end

  test "should remove duplicate options when provided as an array" do
    engine_config.commandline_options = ["-d", "-i test3.js", "-d"]

    processor = BrowserifyRails::BrowserifyProcessor.new { |p| @empty_module }
    assert_equal "-d -i test3.js", processor.send(:options)
  end

  test "should add -d option if in development environment" do
    engine_config.commandline_options = ["-i test4.js"]
    Rails.env.stubs(:development?).returns(true)

    processor = BrowserifyRails::BrowserifyProcessor.new { |p| @empty_module }
    assert_equal "-d -i test4.js", processor.send(:options)
  end

  def engine_config
    BrowserifyRails::Railtie.config.browserify_rails
  end
end
