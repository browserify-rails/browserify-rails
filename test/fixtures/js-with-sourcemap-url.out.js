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

},{}]},{},[1])
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uL25vZGVfbW9kdWxlcy9icm93c2VyLXBhY2svX3ByZWx1ZGUuanMiLCJfc3RyZWFtXzAuanMiLCJmb28uanMiLCJuZXN0ZWQvaW5kZXguanMiLCIuLi8uLi8uLi9ub2RlX21vZHVsZXMvbm9kZS10ZXN0LXBhY2thZ2UvaW5kZXguanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBQUE7QUNBQTtBQUNBO0FBQ0E7O0FDRkE7QUFDQTtBQUNBOztBQ0ZBO0FBQ0E7O0FDREE7QUFDQSIsImZpbGUiOiJnZW5lcmF0ZWQuanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlc0NvbnRlbnQiOlsiKGZ1bmN0aW9uIGUodCxuLHIpe2Z1bmN0aW9uIHMobyx1KXtpZighbltvXSl7aWYoIXRbb10pe3ZhciBhPXR5cGVvZiByZXF1aXJlPT1cImZ1bmN0aW9uXCImJnJlcXVpcmU7aWYoIXUmJmEpcmV0dXJuIGEobywhMCk7aWYoaSlyZXR1cm4gaShvLCEwKTt2YXIgZj1uZXcgRXJyb3IoXCJDYW5ub3QgZmluZCBtb2R1bGUgJ1wiK28rXCInXCIpO3Rocm93IGYuY29kZT1cIk1PRFVMRV9OT1RfRk9VTkRcIixmfXZhciBsPW5bb109e2V4cG9ydHM6e319O3Rbb11bMF0uY2FsbChsLmV4cG9ydHMsZnVuY3Rpb24oZSl7dmFyIG49dFtvXVsxXVtlXTtyZXR1cm4gcyhuP246ZSl9LGwsbC5leHBvcnRzLGUsdCxuLHIpfXJldHVybiBuW29dLmV4cG9ydHN9dmFyIGk9dHlwZW9mIHJlcXVpcmU9PVwiZnVuY3Rpb25cIiYmcmVxdWlyZTtmb3IodmFyIG89MDtvPHIubGVuZ3RoO28rKylzKHJbb10pO3JldHVybiBzfSkiLCJ2YXIgZm9vID0gcmVxdWlyZSgnLi9mb28nKTtcbnZhciBub2RlVGVzdFBhY2thZ2UgPSByZXF1aXJlKCdub2RlLXRlc3QtcGFja2FnZScpO1xuIiwicmVxdWlyZSgnLi9uZXN0ZWQnKTtcbm1vZHVsZS5leHBvcnRzID0gZnVuY3Rpb24gKG4pIHsgcmV0dXJuIG4gKiAxMSB9XG4iLCJtb2R1bGUuZXhwb3J0cy5ORVNURUQgPSB0cnVlO1xuIiwibW9kdWxlLmV4cG9ydHMgPSBjb25zb2xlLmxvZyhcImhlbGxvIGZyaWVuZFwiKTtcbiJdfQ==
;