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

    gem "browserify-rails", "~> 0.3"

Create `package.json` in your Rails root:

```js
{
  "name": "something",
  "devDependencies" : {
    "browserify": "~> 4.1"
  },
  "license": "MIT",
  "engines": {
    "node": ">= 0.10"
  }
}
```

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

## Configuration

You can configure different options of browserify-rails by adding one of lines
mentioned below into your `config/application.rb` or your environment file
(`config/environments/*.rb`):

```ruby
class My::Application < Rails::Application
  # Paths, that should be browserified. We browserify everything, that
  # matches (===) one of the paths. So you will most likely put lambdas
  # regexes in here.
  #
  # By default only files in /app and /node_modules are browserified,
  # vendor stuff is normally not made for browserification and may stop
  # working.
  config.browserify_rails.paths << /vendor\/assets\/javascripts\/module.js/

  # Environments, in which to generate source maps
  #
  # The default is `["development"]`.
  config.browserify_rails.source_map_environments << "production"

  # Command line options used when running browserify
  #
  # can be provided as an array:
  config.browserify_rails.commandline_options = ["-t browserify-shim", "--fast"]

  # or as a string:
  config.browserify_rails.commandline_options = "-t browserify-shim --fast"
```

## Contributing

Pull requests appreciated.

## Contributors

* [Henry Hsu](https://github.com/hsume2)
* [Cássio Souza](https://github.com/cassiozen)
* [Marten Lienen](https://github.com/CQQL)
* [Lukasz Sagol](https://github.com/zgryw)
