# browserify-rails

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
    "browserify": "2.13.x"
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

## Contributing

Pull requests appreciated.
