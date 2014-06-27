require "test_helper"

class BrowserifyTest < ActionController::IntegrationTest
  def copy_example_file(filename)
    example_file = File.join(Rails.root, "app/assets/javascripts/#{filename}")
    new_file = File.join(Rails.root, "app/assets/javascripts/#{filename.gsub(/\.example$/, '')}")

    FileUtils.cp(example_file, new_file)
  end

  setup do
    Rails.application.assets.cache = nil

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
  end

  test "asset pipeline should serve application.js" do
    expected_output = fixture("application.out.js")

    get "/assets/application.js"
    assert_response :success
    assert_equal expected_output, @response.body.strip
  end

  test "asset pipeline should serve foo.js" do
    expected_output = fixture("foo.out.js")

    get "/assets/foo.js"
    assert_response :success
    assert_equal expected_output, @response.body.strip
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

  test "uses config/browserify.yml to mark a module as globally available via --require" do
    expected_output = fixture("main.out.js")

    get "/assets/main.js"

    assert_response :success
    assert_equal expected_output, @response.body.strip
    assert_equal true, @response.body.include?("ReMerY")     # browserify internal global id for a_huge_library.js module
  end

  test "uses config/browserify.yml for browserification options" do
    expected_output = fixture("secondary.out.js")

    get "/assets/secondary.js"

    assert_response :success
    assert_equal expected_output, @response.body.strip
    assert_equal true, @response.body.include?("ReMerY")     # browserify internal global id for a_huge_library.js module
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
