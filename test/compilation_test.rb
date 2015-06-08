require "test_helper"

class BrowserifyTest < ActionDispatch::IntegrationTest
  def copy_example_file(filename, path = nil)
    path ||= "app/assets/javascripts"
    example_file = File.join(Rails.root, path, filename)
    new_file = File.join(Rails.root, path, filename.gsub(/\.example$/, ''))

    FileUtils.cp(example_file, new_file)
  end

  setup do
    Rails.application.assets.cache = nil

    # Reset config on each run
    Dummy::Application.config.browserify_rails.force = false

    cache_file = File.join(Rails.root, "tmp/cache/browserify-rails/browserifyinc-cache.json")
    File.delete(cache_file) if File.exists?(cache_file)

    copy_example_file "application.js.example"
    copy_example_file "foo.js.example"
    copy_example_file "nested/index.js.example"
    copy_example_file "mocha.js.coffee.example"
    copy_example_file "coffee.js.coffee.example"
    copy_example_file "node_path_based_require.js.example"
    copy_example_file "main.js.example"
    copy_example_file "secondary.js.example"
    copy_example_file "a_huge_library.js.example"
    copy_example_file "some_folder/answer.js.example"
    copy_example_file "browserified.js.example"
    copy_example_file "index.js.example", "node_modules/node-test-package"
  end

  test "asset pipeline should serve application.js" do
    expected_output = fixture("application.out.js")

    get "/assets/application.js"

    assert_response :success
    assert_equal expected_output, @response.body.strip
  end

  test "asset pipeline should serve foo.js" do
    expected_output = fixture("application.out.js")

    get "/assets/application.js"

    assert_response :success
    assert_equal expected_output, @response.body.strip
  end

  test "asset pipeline should regenerate application.js when node_modules changes" do
    Dummy::Application.config.browserify_rails.evaluate_node_modules = true
    expected_output = fixture("application.out.js")

    begin
      get "/assets/application.js"

      assert_response :success
      assert_equal expected_output, @response.body.strip

      # Ensure that Sprockets can detect the change to the file modification time
      sleep 1

      File.open(File.join(Rails.root, "node_modules/node-test-package/index.js"), "w+") do |f|
        f.puts 'module.exports = console.log("goodbye friend");'
      end

      expected_output = fixture("application.node_test_package_changed.out.js")

      get "/assets/application.js"

      assert_response :success
      assert_equal expected_output, @response.body.strip
    ensure
      Dummy::Application.config.browserify_rails.evaluate_node_modules = false
    end
  end

  test "asset pipeline should regenerate application.js when foo.js changes" do
    expected_output = fixture("application.out.js")

    get "/assets/application.js"

    assert_response :success
    assert_equal expected_output, @response.body.strip

    # Ensure that Sprockets can detect the change to the file modification time
    sleep 1

    File.open(File.join(Rails.root, "app/assets/javascripts/foo.js"), "w+") do |f|
      f.puts "require('./nested');"
      f.puts "module.exports = function (n) { return n * 12 }"
    end

    expected_output = fixture("application.foo_changed.out.js")

    get "/assets/application.js"

    assert_response :success
    assert_equal expected_output, @response.body.strip
  end

  test "asset pipeline should regenerate application.js when application.js changes" do
    expected_output = fixture("application.out.js")

    get "/assets/application.js"

    assert_response :success
    assert_equal expected_output, @response.body.strip

    # Ensure that Sprockets can detect the change to the file modification time
    sleep 1

    File.open(File.join(Rails.root, "app/assets/javascripts/application.js"), "w+") do |f|
      f.puts "var foo = require('./foo');"
      f.puts "console.log(foo(11));"
    end

    expected_output = fixture("application.changed.out.js")

    get "/assets/application.js"

    assert_response :success
    assert_equal expected_output, @response.body.strip
  end

  test "browserifies coffee files after they have been compiled to JS" do
    expected_output = fixture("mocha.js")

    get "/assets/mocha.js"

    assert_response :success
    assert_equal expected_output, @response.body.strip
  end

  test "browserifies files with coffee requires" do
    get "/assets/coffee.js"

    assert_no_match /BrowserifyRails::BrowserifyError/, @response.body
  end

  test "uses NODE_PATH so files can be required non-relatively" do
    expected_output = fixture("node_path_based_require.out.js")

    get "/assets/node_path_based_require.js"

    assert_response :success
    assert_equal expected_output, @response.body.strip
    assert_equal false, @response.body.include?("Error: Cannot find module 'some_folder/answer'")
  end

  test "skips files that are already browserified" do
    get "/assets/browserified.js"

    assert_equal fixture("browserified.out.js"), @response.body.strip
  end

  test "skip files that should not be browserified" do
    get "/assets/plain.js"

    assert_equal fixture("plain.js"), @response.body.strip
  end

  test "browserify even plain files if force == true" do
    Dummy::Application.config.browserify_rails.force = true

    get "/assets/plain.js"

    begin
      assert_equal fixture("plain.out.js"), @response.body.strip
    ensure
      Dummy::Application.config.browserify_rails.force = false
    end
  end

  test "uses config/browserify.yml to mark a module as globally available via --require" do
    expected_output = fixture("main.out.js")

    get "/assets/main.js"

    assert_response :success
    assert_equal expected_output, @response.body.strip
  end

  test "uses config/browserify.yml for browserification options" do
    expected_output = fixture("secondary.out.js")

    get "/assets/secondary.js"

    assert_response :success
    assert_equal expected_output, @response.body.strip
  end

  test "generates sourcemap and writes to file if --use-exorcist and set_base_path" do
    Dummy::Application.config.browserify_rails.commandline_options = "-d"
    Dummy::Application.config.browserify_rails.use_exorcist = true
    Dummy::Application.config.browserify_rails.exorcist_base_path = File.join(File.dirname(File.expand_path(__FILE__))).to_s

    begin
      expected_output = fixture("js-with-sourcemap-url.out.js")

      get "/assets/application.js"

      assert_response :success
      assert_equal expected_output, @response.body.strip
    ensure
      Dummy::Application.config.browserify_rails.use_exorcist = false
      Dummy::Application.config.browserify_rails.commandline_options = ""
    end
  end

  test "generates sourcemap and writes to file if --use-exorcist and default_base_path" do
    Dummy::Application.config.browserify_rails.commandline_options = "-d"
    Dummy::Application.config.browserify_rails.use_exorcist = true
    Dummy::Application.config.browserify_rails.exorcist_base_path = nil

    begin
      expected_output = fixture("js-with-sourcemap-url.out.js")

      get "/assets/application.js"

      assert_response :success
      assert_equal expected_output, @response.body.strip
    ensure
      Dummy::Application.config.browserify_rails.use_exorcist = false
      Dummy::Application.config.browserify_rails.commandline_options = ""
    end
  end

  test "throws BrowserifyError if something went wrong while executing browserify" do
    File.open(File.join(Rails.root, "app/assets/javascripts/application.js"), "w+") do |f|
      f.puts "var foo = require('./foo');"
      f.puts "var bar = require('./bar');"
    end

    get "/assets/application.js"

    assert_match /BrowserifyRails::BrowserifyError/, @response.body
  end
end
