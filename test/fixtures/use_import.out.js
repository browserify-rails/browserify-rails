(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({"/Users/cvig/dev/browserify-rails/test/dummy/app/assets/javascripts/_stream_0.js":[function(require,module,exports){
'use strict';

var _simple_module = require('./simple_module');

var _simple_module2 = _interopRequireDefault(_simple_module);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

console.log((0, _simple_module2.default)());

},{"./simple_module":"__RAILS_ROOT__/app/assets/javascripts/simple_module.js"}],"__RAILS_ROOT__/app/assets/javascripts/simple_module.js":[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function () {
  return 42;
};

},{}]},{},["__RAILS_ROOT__/app/assets/javascripts/_stream_0.js"]);
