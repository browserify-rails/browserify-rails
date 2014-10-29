(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var library = require('./a_huge_library');

module.exports = function() {
  console.log('some problem', library);
};

},{"./a_huge_library":"/a_huge_library"}],2:[function(require,module,exports){
// pretend this file is 1 MB
//
// app_main.js is going to require() it and browserify.yml is going to tell it to use --require on it
//
// app_secondary.js is going to require() it too but we know app_main.js is always going to be loaded
// so browserify.yml will be configured to mark it as --external so it is not bundled in
//
// this results in app_main.js taking the cost of loading app_a_huge_library.js
//
// and app_secondary.js saving the cost of loading app_a_huge_library.js (because again,
// we know a priori that something else has loaded it)


module.exports = "THIS IS A HUGE LIBRARY";

},{}]},{},[1]);