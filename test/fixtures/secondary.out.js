(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
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