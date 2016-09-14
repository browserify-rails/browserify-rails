require_relative 'test_helper'

class BrowserifyProcessorTest < ActiveSupport::TestCase
  def stub_engine_config(hash)
    @processor.config = (@processor.config || {}).merge(hash)
  end

  setup do
    @processor = BrowserifyRails::BrowserifyProcessor.new
    @processor.file = "empty_module.js"
  end

  test "should run command without options if none provided" do
    stub_engine_config({commandline_options: nil})
    assert_equal "", @processor.send(:options)
  end

  test "should run command without options if empty array provided" do
    stub_engine_config({commandline_options: []})
    assert_equal "", @processor.send(:options)
  end

  test "should convert options provided as an array to string" do
    stub_engine_config({commandline_options: ["-d", "-i test1.js"]})
    assert_equal "-d -i test1.js", @processor.send(:options)
  end

  test "should allow providing options as a string" do
    stub_engine_config({commandline_options: "-d -i test2.js"})

    assert_equal "-d -i test2.js", @processor.send(:options)
  end

  test "should remove duplicate options when provided as an array" do
    stub_engine_config({commandline_options: ["-d", "-i test3.js", "-d"]})

    assert_equal "-d -i test3.js", @processor.send(:options)
  end

  test "should allow command line options to be a function" do
    stub_engine_config({commandline_options: -> file { ["-d", "-i #{file}"] }})
    assert_equal "-d -i empty_module.js", @processor.send(:options)
  end

  test "should add -d option if current env is in source_maps_env list" do
    stub_engine_config({
      commandline_options: ["-i test4.js"],
      source_map_environments: [Rails.env]
    })

    assert_equal "-d -i test4.js", @processor.send(:options)
  end

  test "env should have NODE_ENV set to Rails.application.config.browserify_rails.node_env" do
    Rails.application.config.browserify_rails.node_env = "staging"

    assert_equal "staging", @processor.send(:env)["NODE_ENV"]
  end

  test "env should have NODE_ENV default to Rails.env" do
    Rails.application.config.browserify_rails.node_env = nil

    assert_equal Rails.env, @processor.send(:env)["NODE_ENV"]
  end

  test "env should have NODE_PATH set to Rails.application.config.assets.paths" do
    node_env = @processor.send(:env)["NODE_PATH"]

    Rails.application.config.assets.paths.each do |path|
      assert_equal true, node_env.include?(path)
    end
  end
end
