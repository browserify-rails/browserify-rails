# browserify-rails

[![Join the chat at https://gitter.im/browserify-rails/browserify-rails](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/browserify-rails/browserify-rails?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Gem Version](https://badge.fury.io/rb/browserify-rails.svg)](http://badge.fury.io/rb/browserify-rails)

This library adds CommonJS module support to Sprockets (via Browserify).

It lets you mix and match  `//= require` directives and `require()` calls for including plain javascript files as well as modules. However, it is important to remember that once you are into code that is being browserified you can no longer use sprockets-style require (so no `//= require`). In many cases, it makes sense to put all your sprockets-required code in a separate file or at the very least at the top of your main JavaScript file. Then use `require()` to pull in the CommonJS code.

1. Manage JS modules with `npm`
2. Serve assets with Sprockets
3. Require modules with `require()` (without separate `//= require` directives)
4. Only build required modules
5. Require *npm modules* in your Rails assets
6. Require modules relative to asset paths (ie app/assets/javascript) with non-relative syntax (see below before using)
7. Configure browserify options for each JavaScript file so you can mark modules with `--require`, `--external`, etc

## Getting Started

Add this line to your application's Gemfile:

    gem "browserify-rails"

Create `package.json` in your Rails root:

```js
{
  "name": "something",
  "dependencies" : {
    "browserify": "~> 10.2.4",
    "browserify-incremental": "^3.0.1"
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

Add `coffeeify` as a dependency within `package.json`:

```js
{
  // ...
  "dependencies" : {
    // ...
    "coffeeify": "~> 0.6"
  }
}
```

Add the following command line options within `application.rb`:

```rb
config.browserify_rails.commandline_options = "-t coffeeify --extension=\".js.coffee\""
```

## Requirements

* node-browserify 4.x
* browserify-incremental

## Configuration

### Global configuration

You can configure different options of browserify-rails by adding one of the lines
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
  config.browserify_rails.paths << /vendor\/assets\/javascripts\/module\.js/

  # Environments, in which to generate source maps
  #
  # The default is none
  config.browserify_rails.source_map_environments << "development"

  # Should the node_modules directory be evaluated for changes on page load
  #
  # The default is `false`
  config.browserify_rails.evaluate_node_modules = true

  # Force browserify on every found JavaScript asset if true.
  # Can be a proc.
  #
  # The default is `false`
  config.browserify_rails.force = ->(file) { File.extname(file) == ".ts" }

  # Command line options used when running browserify
  #
  # can be provided as an array:
  config.browserify_rails.commandline_options = ["-t browserify-shim", "--fast"]

  # or as a string:
  config.browserify_rails.commandline_options = "-t browserify-shim --fast"

  # Define NODE_ENV to be used with envify
  #
  # defaults to Rails.env
  config.browserify_rails.node_env = "production"
```

### browserify-incremental

[browserify-incremental](https://github.com/jsdf/browserify-incremental) is used to cache browserification of CommonJS modules. One of the side effects is that the absolute module path is included in the emitted JavaScript. Most people do not want this for production code so browerify-incremental is current disabled for the `production` and `staging` environments. Note that counter-intuitively, browserify-incremental helps even with a single build pass of your code because typically the same modules are used multiple times. So it helps even for say asset compilation on a push to Heroku.

### Multiple bundles

node-browserify supports [multiple bundles](https://github.com/substack/node-browserify#multiple-bundles)
and so do does rails-browserify. It does this using `config/browserify.yml`.
Below is an example.

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

### Inside Isolated Engines

To make browserify-rails work inside an isolated engine, add the engine app directory to the browserify-rails paths (inside engine.rb):

```ruby
config.browserify_rails.paths << lambda { |p| p.start_with?(Engine.root.join("app").to_s) }
```

If you wish to put the node_modules directory within the engine, you have some control over it with:

```ruby
config.browserify_rails.node_bin = "some/directory"
```

## Support for rails asset directories as non-relative module sources

In the Rails asset pipeline, it is common to have files in
`app/assets/javascripts` and being able to do `//= require some_file` which
exists in one of the asset/javascript directories. In some cases, it is
useful to have similar functionality with browserify. This has been added
by putting the Rails asset paths into NODE_PATH environment variable when
running browserify.

But this comes at a large cost: right now, it appears to break source maps.
This might be a bug or a fixable breakage but it hasn't been solved yet. The
use of NODE_PATH is also contentious in the NodeJS community.

Why leave it in? Because some typical Rails components break without it.
For example, jasmine-rails expects to be able to move JavaScript to
different depths. So if you do a relative require from spec/javascript to
app/assets/javascripts, your tests will fail to run when RAILS_ENV=test.

So if you really need this, use it. But if you really need it for files that
are not tests, you should definitely figure out an alternative. Support
for this may go away if we cannot fix the issue(s) with source maps being
invalid.

## Deploying to Heroku

Heroku is a very common target for deploying. You'll have to add custom
buildpacks that run `bundle` and `npm install` on the target machine.

    $ heroku buildpacks:add https://github.com/heroku/heroku-buildpack-nodejs.git
    $ heroku buildpacks:add https://github.com/heroku/heroku-buildpack-ruby.git

## Troubleshooting

### Clear the asset pipeline cache

The Rails asset pipeline caches some files in the `tmp` directory inside
Rails root. It can happen that sometimes the cache does not get invalidated
correctly. You can manually clear the cache in at least two ways:

1. `rake tmp:cache:clear`
2. `rm -rf ./tmp` (when in the root directory of the Rails project)

The second method is definitely brute force but if you experience issues,
it is definitely worth trying before spending too much time debugging
why something that is browserified appears to not match the sources files.

## Contributing

Pull requests appreciated. Pull requests will not be rejected based on
ideological neurosis of either the NodeJS or the Ruby on Rails communities.
In other words, technical needs are respected.

## Potential areas of change (contributions welcome)

### Multiple modules

Often one has one main module (say a library module) and other modules that
consume the main module. It would be nice to be able to establish this
relationship in the YAML file to avoid having to manually manage the require
and external entries for the involved modules.

## Contributors

* [Henry Hsu](https://github.com/hsume2)
* [Cássio Souza](https://github.com/cassiozen)
* [Marten Lienen](https://github.com/CQQL)
* [Lukasz Sagol](https://github.com/zgryw)
* [Cymen Vig](https://github.com/cymen)
