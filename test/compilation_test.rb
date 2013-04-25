require 'test_helper'

class BrowserifyTest < ActionController::IntegrationTest

  test "asset pipeline should serve application.js" do
    get "/assets/application.js"
    assert_response :success
    assert @response.body == ";(function(e,t,n){function i(n,s){if(!t[n]){if(!e[n]){var o=typeof require==\"function\"&&require;if(!s&&o)return o(n,!0);if(r)return r(n,!0);throw new Error(\"Cannot find module '\"+n+\"'\")}var u=t[n]={exports:{}};e[n][0].call(u.exports,function(t){var r=e[n][1][t];return i(r?r:t)},u,u.exports)}return t[n].exports}var r=typeof require==\"function\"&&require;for(var s=0;s<n.length;s++)i(n[s]);return i})({1:[function(require,module,exports){\nvar foo = require('./foo');\n\n},{\"./foo\":2}],2:[function(require,module,exports){\nmodule.exports = function (n) { return n * 11 }\n\n},{}]},{},[1])\n;"
  end

  test "asset pipeline should serve foo.js" do
    get "/assets/foo.js"
    assert_response :success
    assert @response.body == ";(function(e,t,n){function i(n,s){if(!t[n]){if(!e[n]){var o=typeof require==\"function\"&&require;if(!s&&o)return o(n,!0);if(r)return r(n,!0);throw new Error(\"Cannot find module '\"+n+\"'\")}var u=t[n]={exports:{}};e[n][0].call(u.exports,function(t){var r=e[n][1][t];return i(r?r:t)},u,u.exports)}return t[n].exports}var r=typeof require==\"function\"&&require;for(var s=0;s<n.length;s++)i(n[s]);return i})({1:[function(require,module,exports){\nmodule.exports = function (n) { return n * 11 }\n\n},{}]},{},[1])\n;"
  end

end
