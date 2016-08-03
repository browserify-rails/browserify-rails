# browserify-rails

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
    "browserify": "~10.2.4",
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

#### Gotchas with `require` and `module.exports`

Do not put `module.exports` or `require()` in JavaScript comments or strings.
Doing so will certainly cause issues with compilation that are difficult to
track down.

This happens because browserify-rails works by parsing your JavaScript files for
these keywords that indicate whether it is a module, or is requiring a module.
If a file meets one of these criteria, browserify will compile the modules as
expected.

Because browserify-rails is working within the restraints of Ruby/Sprockets, the
parsing is done by Ruby and therefore does not know whether it is a JavaScript
string, comment, or function.

## CoffeeScript

For CoffeeScript support, make sure to follow the standard rails
`.js.coffee` naming convention.  You'll also need to add the npm
package `coffeeify` as a dependency:

```js
{
  // ...
  "dependencies" : {
    // ...
    "coffeeify": "~0.6"
  }
}
```

and configure `browserify_rails` accordingly:

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
  # Specify the file paths that should be browserified. We browserify everything that
  # matches (===) one of the paths. So you will most likely put lambdas
  # regexes in here.
  #
  # By default only files in /app and /node_modules are browserified,
  # vendor stuff is normally not made for browserification and may stop
  # working.
  config.browserify_rails.paths << /vendor\/assets\/javascripts\/module\.js/

  # Environments in which to generate source maps
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

#### Enabling browserify-incremental in production

To enable browserify-incremental in production, add the following line to `config/environments/production.rb`:

```ruby
config.browserify_rails.use_browserifyinc = true
```

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

Note that any valid browserify option is allowed in the YAML file but not all
use cases have been considered. If your use case does not work, please open
an issue with a runnable example of the problem including your browserify.yml file.

### Inside Isolated Engines

To make browserify-rails work inside an isolated engine, add the engine app directory to the browserify-rails paths (inside engine.rb):

```ruby
config.browserify_rails.paths << -> (p) { p.start_with?(Engine.root.join("app").to_s) }
```

If you wish to put the node_modules directory within the engine, you have some control over it with:

```ruby
config.browserify_rails.node_bin = "some/directory"
```

### Example setup

Refer to this repo for setting up this gem with ES6 and all front-end goodies like react and all - [github.com/gauravtiwari/browserify-rails](https://github.com/gauravtiwari/browserify-rails)

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

## Using Browserify Transforms

You can easily use a browserify transform by adding it to your `package.json`, then adding the transform flag to your `application.rb`, using `config.browserify_rails.commandline_options`. For example, here is how you can add ES6 support in your app:

1. Add `babelify` and `babel-preset-es2015` to your `package.json` in your app's root directory, then run `npm install`
2. Add this line to your config/application.rb:
   `config.browserify_rails.commandline_options = "-t [ babelify --presets [ es2015 ] --extensions .es6 ]"`
3. Create some `.es6` files and require them with `var m = require('./m.es6')` or `import m from './m.es6'`
4. Restart your server, and you now have ES6 support!


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

### Javascript Tests

If you want to use `browserify` to process test files as well, you will
need to configure `browserify-rails` to process files in your `spec` or `test`
directories.

```ruby
config.browserify_rails.paths << -> (p) { p.start_with?(Rails.root.join("spec/javascripts").to_s) }
```

## Acceptance Test Failures

If you have Sprockets precompile multiple JS files, each of which include
certain browserified files, your acceptance tests may timeout before some
of the assets have finished compiling.

To avoid this problem, run `rake assets:precompile` before running your
acceptance tests.

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

## Alternatives

### Use webpack or browserify directly instead of the asset pipeline

Use a tool like ProcMan to kick off a webpack or browserify process to rebuild your JavaScript on change. Reference the bundle in your Rails template and away you go. With webpack, you can even use the dev server and point to the dev server port in your Rails template to load JavaScript directly from webpack (it'll block on build so you'll always get your latest code). This does require configuring webpack hot middleware to have a port (see [__webpack_hmr goes to the wrong port and fails](http://stackoverflow.com/questions/35446109/webpack-hmr-goes-to-the-wrong-port-and-fails/35446292#35446292)).


### react_on_rails

[Webpack](http://webpack.github.io/) is a popular alternative to Browserify for JavaScript tooling. A quick [Google search](https://www.google.com/search?q=browserify+vs+webpack&gws_rd=ssl) yields many articles on this topic. If you wish to use Webpack with Rails, the most popular solution is the gem [github.com/shakacode/react_on_rails](https://github.com/shakacode/react_on_rails/). While this gem focuses on React integration, it offers a solid example of how to integrate Webpack into your Rails workflow, even supporting hot-module-reloading. It also provides useful helpers to ensure that your Webpack created files are ready before tests run. A live example of these techniques can be found at [github.com/shakacode/react-webpack-rails-tutorial](https://github.com/shakacode/react-webpack-rails-tutorial/).


## Contributors

* [Henry Hsu](https://github.com/hsume2)
* [Cássio Souza](https://github.com/cassiozen)
* [Marten Lienen](https://github.com/CQQL)
* [Lukasz Sagol](https://github.com/zgryw)
* [Cymen Vig](https://github.com/cymen)
