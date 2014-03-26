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
    assert @response.body.include?("(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require==\"function\"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error(\"Cannot find module '\"+o+\"'\")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require==\"function\"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var foo = require('./foo');

},{\"./foo\":2}],2:[function(require,module,exports){
module.exports = function (n) { return n * 11 }

},{}]},{},[1])")
  end

  test "asset pipeline should serve foo.js" do
    get "/assets/foo.js"
    assert_response :success
    assert @response.body.include?("(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require==\"function\"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error(\"Cannot find module '\"+o+\"'\")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require==\"function\"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
module.exports = function (n) { return n * 11 }
;

},{}]},{},[1])")
  end

  test "asset pipeline should regenerate application.js when foo.js changes" do
    get "/assets/application.js"
    assert_response :success
    assert @response.body.include?("(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require==\"function\"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error(\"Cannot find module '\"+o+\"'\")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require==\"function\"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var foo = require('./foo');

},{\"./foo\":2}],2:[function(require,module,exports){
module.exports = function (n) { return n * 11 }

},{}]},{},[1])")

    File.open(File.join(Rails.root, 'app/assets/javascripts/foo.js'), 'w+') do |f|
      f.puts "module.exports = function (n) { return n * 12 }"
    end

    get "/assets/application.js"
    assert_response :success
    assert @response.body.include?("(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require==\"function\"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error(\"Cannot find module '\"+o+\"'\")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require==\"function\"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var foo = require('./foo');

},{\"./foo\":2}],2:[function(require,module,exports){
module.exports = function (n) { return n * 12 }

},{}]},{},[1])")
  end
end
