# browserify-rails

[![Build Status](https://travis-ci.org/hsume2/browserify-rails.png?branch=master)](https://travis-ci.org/hsume2/browserify-rails)

This library adds CommonJS module support to Sprockets (via Browserify).

It let's you mix and match  `//= require` directives and `require()` calls for including plain javascript files as well as modules.

1. Manage JS modules with `npm`
2. Serve assets with Sprockets
3. Require modules with `require()` (without separate `//= require` directives)
4. Only build required modules
5. Require *npm modules* in your Rails assets
6. Require modules relative to asset paths (ie app/assets/javascript) with non-relative syntax (see below before using)
7. Configure browserify options for each JavaScript file so you can mark modules with `--require`, `--external`, etc

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

## CoffeeScript

For CoffeeScript support, make sure to follow the standard rails
`.js.coffee` naming convention.  You'll also need to do the following:

Add `coffeify` as a dependency within `package.json`:

```js
{
  // ...
  "devDependencies" : {
    // ...
    "coffeeify": "~> 0.6"
  }
}
```

Add the following command line options within `application.rb`:

```rb
config.browserify_rails.commandline_options = "-t coffeeify --extension=\".js.coffee\""
```

## Configuration

### Global configuration

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

### Per file configuration

Say you have three JavaScript files and one is a huge library you would like to
use in both. Browserify lets you mark that huge library with --require in one
file (to both bundle it and mark it with a special internal ID) and then
require it in the other file and mark it with --external (so it is not bundled
into the file but instead accessed via browserify internals using that special
ID). Note that this only works when the file that has the library bundled is
loaded before the file that uses the library with --external.

```yaml
javascript:
  main:
    require:
      - a_huge_library
  secondary:
    external:
      - a_huge_library
```

Note that any valid browserify option is allowed in the YAML file but not
use cases have been considered. If your use case does not work, please open
an issue with a runnable example of the problem including your
browserify.yml file.

## Support for rails asset directories as non-relative module sources

In the Rails asset pipeline, it is common to have files in
app/assets/javascripts and being able to do `//= require some_file` which
exists in one of the asset/javascript directories. In some cases, it is
useful to have similar functionality with browserify. This has been added
by putting the Rails asset paths into NODE_PATH environment variable when
running browserify.

But this comes at a large cost: right now, it breaks source maps. This might
be a bug or a fixable breakage but it hasn't been solved yet.

Why leave it in? Because some typical Rails components break without it.
For example, jasmine-rails expects to be able to move JavaScript to
different depths. So if you do a relative require from spec/javascript to
app/assets/javascripts, your tests will fail to run when RAILS_ENV=test.

So if you really need this, use it. But if you really need it for files that
are not tests, you should definitely figure out an alternative. Support
for this may go away if we cannot fix the issue(s) with source maps being
invalid.

## Contributing

Pull requests appreciated.

## Contributors

* [Henry Hsu](https://github.com/hsume2)
* [Cássio Souza](https://github.com/cassiozen)
* [Marten Lienen](https://github.com/CQQL)
* [Lukasz Sagol](https://github.com/zgryw)
