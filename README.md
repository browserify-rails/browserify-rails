# browserify-rails

[![Build Status](https://travis-ci.org/hsume2/browserify-rails.png?branch=master)](https://travis-ci.org/hsume2/browserify-rails)

This library adds CommonJS module support to Sprockets (via Browserify).

It let's you mix and match  `//= require` directives and `require()` calls for including plain javascript files as well as modules.

1. Manage JS modules with `npm`
2. Serve assets with Sprockets
3. Require modules with `require()` (without separate `//= require` directives)
4. Only build required modules
5. Require *npm modules* in your Rails assets

## Getting Started

Add this line to your application's Gemfile:

    gem "hsume2-browserify-rails", "~> 0.2.0", :require => "browserify-rails"

Create `package.json` in your Rails root:

```js
{
  "name": "something",
  "devDependencies" : {
    "browserify": "~> 3.33"
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

Coffeescript is handled seamlessly, if you name your files `*.js.coffee`. That
way the coffeescript compiler will already have done it's work, when we are
putting the javascript tools to work.

## Browserify command line options

By default `browserify` is run with `-d` option (Enable source maps) in
development environment and without any options in all other environments.

You can easily extend the options which are used when running `browserify`, by
adding `config.browserify_rails.commandline_options` to your `config/application.rb`
or your environment file (`config/environments/*.rb`):

```ruby
# config/application.rb
Example::Application.config do

  # Browserify-rails supports options provided as an array:
  config.browserify_rails.commandline_options = ["-t browserify-shim", "--fast"]

  # or as a string:
  config.browserify_rails.commandline_options = "-t browserify-shim --fast"
end
```

## Contributing

Pull requests appreciated.

## Contributors

* [Henry Hsu](https://github.com/hsume2)
* [Cássio Souza](https://github.com/cassiozen)
* [Marten Lienen](https://github.com/CQQL)
* [Lukasz Sagol](https://github.com/zgryw)
