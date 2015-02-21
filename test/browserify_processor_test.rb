require 'test_helper'

class BrowserifyProcessorTest < ActiveSupport::TestCase
  setup do
    @empty_module = fixture("empty_module.js")
    @processor = BrowserifyRails::BrowserifyProcessor.new { |p| @empty_module }
    @processor.reset_cache
  end

  test "should run command without options if none provided" do
    stub_engine_config :commandline_options, nil
    assert_equal "", @processor.send(:options)
  end

  test "should run command without options if empty array provided" do
    stub_engine_config :commandline_options, []
    assert_equal "", @processor.send(:options)
  end

  test "should convert options provided as an array to string" do
    stub_engine_config :commandline_options, ["-d", "-i test1.js"]
    assert_equal "-d -i test1.js", @processor.send(:options)
  end

  test "should allow providing options as a string" do
    stub_engine_config :commandline_options, "-d -i test2.js"

    assert_equal "-d -i test2.js", @processor.send(:options)
  end

  test "should remove duplicate options when provided as an array" do
    stub_engine_config :commandline_options, ["-d", "-i test3.js", "-d"]

    assert_equal "-d -i test3.js", @processor.send(:options)
  end

  test "should add -d option if current env is in source_maps_env list" do
    stub_engine_config :commandline_options, ["-i test4.js"]
    stub_engine_config :source_map_environments, [Rails.env]

    assert_equal "-d -i test4.js", @processor.send(:options)
  end

  def stub_engine_config(key, value)
    @processor.send(:config).stubs(key).returns(value)
  end
end
