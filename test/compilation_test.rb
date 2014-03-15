require 'test_helper'

class BrowserifyTest < ActionController::IntegrationTest

  setup do
    FileUtils.rm_rf(File.join(Rails.root, 'tmp/cache'))
    FileUtils.mkdir_p(File.join(Rails.root, 'tmp'))
    FileUtils.cp(File.join(Rails.root, 'app/assets/javascripts/application.js.example'), File.join(Rails.root, 'app/assets/javascripts/application.js'))
    FileUtils.cp(File.join(Rails.root, 'app/assets/javascripts/foo.js.example'), File.join(Rails.root, 'app/assets/javascripts/foo.js'))
  end

  test "asset pipeline should serve application.js" do
    get "/assets/application.js"
    assert_response :success
    assert @response.body.include? ";(function(e,t,n){function i(n,s){if(!t[n]){if(!e[n]){var o=typeof require==\"function\"&&require;if(!s&&o)return o(n,!0);if(r)return r(n,!0);throw new Error(\"Cannot find module '\"+n+\"'\")}var u=t[n]={exports:{}};e[n][0].call(u.exports,function(t){var r=e[n][1][t];return i(r?r:t)},u,u.exports)}return t[n].exports}var r=typeof require==\"function\"&&require;for(var s=0;s<n.length;s++)i(n[s]);return i})({1:[function(require,module,exports){\nvar foo = require('./foo');\n\n},{\"./foo\":2}],2:[function(require,module,exports){\nmodule.exports = function (n) { return n * 11 }\n\n},{}]},{},[1])\n"
  end

  test "asset pipeline should serve foo.js" do
    get "/assets/foo.js"
    assert_response :success
    assert @response.body.include? ";(function(e,t,n){function i(n,s){if(!t[n]){if(!e[n]){var o=typeof require==\"function\"&&require;if(!s&&o)return o(n,!0);if(r)return r(n,!0);throw new Error(\"Cannot find module '\"+n+\"'\")}var u=t[n]={exports:{}};e[n][0].call(u.exports,function(t){var r=e[n][1][t];return i(r?r:t)},u,u.exports)}return t[n].exports}var r=typeof require==\"function\"&&require;for(var s=0;s<n.length;s++)i(n[s]);return i})({1:[function(require,module,exports){\nmodule.exports = function (n) { return n * 11 }\n\n},{}]},{},[1])\n"
  end

  test "asset pipeline should regenerate application.js when foo.js changes" do
    get "/assets/application.js"
    assert_response :success
    assert @response.body.include? ";(function(e,t,n){function i(n,s){if(!t[n]){if(!e[n]){var o=typeof require==\"function\"&&require;if(!s&&o)return o(n,!0);if(r)return r(n,!0);throw new Error(\"Cannot find module '\"+n+\"'\")}var u=t[n]={exports:{}};e[n][0].call(u.exports,function(t){var r=e[n][1][t];return i(r?r:t)},u,u.exports)}return t[n].exports}var r=typeof require==\"function\"&&require;for(var s=0;s<n.length;s++)i(n[s]);return i})({1:[function(require,module,exports){\nvar foo = require('./foo');\n\n},{\"./foo\":2}],2:[function(require,module,exports){\nmodule.exports = function (n) { return n * 11 }\n\n},{}]},{},[1])\n"

    File.open(File.join(Rails.root, 'app/assets/javascripts/foo.js'), 'w+') do |f|
      f.puts "module.exports = function (n) { return n * 12 }"
    end

    get "/assets/application.js"
    assert_response :success
    assert @response.body.include? ";(function(e,t,n){function i(n,s){if(!t[n]){if(!e[n]){var o=typeof require==\"function\"&&require;if(!s&&o)return o(n,!0);if(r)return r(n,!0);throw new Error(\"Cannot find module '\"+n+\"'\")}var u=t[n]={exports:{}};e[n][0].call(u.exports,function(t){var r=e[n][1][t];return i(r?r:t)},u,u.exports)}return t[n].exports}var r=typeof require==\"function\"&&require;for(var s=0;s<n.length;s++)i(n[s]);return i})({1:[function(require,module,exports){\nvar foo = require('./foo');\n\n},{\"./foo\":2}],2:[function(require,module,exports){\nmodule.exports = function (n) { return n * 12 }\n\n},{}]},{},[1])\n"
  end

end
