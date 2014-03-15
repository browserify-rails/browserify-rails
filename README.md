# browserify-rails

[![Build Status](https://travis-ci.org/hsume2/browserify-rails.png?branch=master)](https://travis-ci.org/hsume2/browserify-rails)

This library adds CommonJS module support to Sprockets (via Browserify).

It let's you mix and match  `//= require` directives and `require()` calls for including plain javascript files as well as modules.

1. Manage JS modules with `npm`
2. Serve assets with Sprockets
3. Require modules with `require()` (without separate `//= require` directives)
4. Only build required modules

## Getting Started

Add this line to your application's Gemfile:

    gem 'browserify-rails'

Create `package.json` in your Rails root:

```js
{
  "name": "something",
  "devDependencies" : {
    "browserify": "2.13.x",
    "module-deps": "1.7.x"
  },
  "license": "MIT",
  "engines": {
    "node": ">= 0.6"
  }
}
```
[TODO: Write a Rails generator for this]

Then run:

    npm install

Then start writing CommonJS, and everything will magically work!:

```js
// foo.js
module.exports = function (n) { return n * 11 }

// application.js
var foo = require('./foo');
console.log(foo(12));
```

## Coffeescript
If you want to use coffeescript files, add coffeeify as a dependency on `package.json`:
```js
{
  "name": "something",
  "devDependencies" : {
    "browserify": "2.13.x"
    "coffeeify": "0.6.x"
  },
  "license": "MIT",
  "engines": {
    "node": ">= 0.6"
  }
}
```

## Contributing

Pull requests appreciated.

## Contributors

* [Henry Hsu](https://github.com/hsume2)
* [Cássio Souza](https://github.com/cassiozen)
