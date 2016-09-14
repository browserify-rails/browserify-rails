(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var foo = require('./foo');
var nodeTestPackage = require('node-test-package');

},{"./foo":2,"node-test-package":4}],2:[function(require,module,exports){
require('./nested');
module.exports = function (n) { return n * 11 }

},{"./nested":3}],3:[function(require,module,exports){
module.exports.NESTED = true;

},{}],4:[function(require,module,exports){
module.exports = console.log("hello friend");

},{}]},{},[1]);