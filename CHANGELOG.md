# Change Log
All notable changes to this project will be documented in this file going forward.

## [3.2.0] - 2016-09-14
- make compatible with sprockets 4 (thanks marvwhere!)
- update dummy rails to use current browserify and browserify-incremental
- use Addressable gem for URI.escape instead of deprecated method
- replace uses of deprecated File.exists? with File.exist?
- make it easy to run each test file separately
- make it so the dummy rails is startable with Rails 5

## [3.1.0] - 2016-05-23
- relax railties requirement to < 5.1

## [3.0.1] - 2016-03-03
- detect import keyword and process as module if found

## [3.0.0] - 2016-02-17
- upgrade dependency on sprockets to >= 3.5.2

## [2.2.0] - 2016-01-01
- fix another dependency issue impacting cache invalidation (see PR #131)

## [2.1.0] - 2015-12-26
- fix some dependency issues (see PR #130)

## [2.0.3] - 2015-12-18
- detection of CommonJS (require(.*)) now more stringent
- update README about 2.x and react-rails

## [2.0.2] - 2015-11-23
- fix bug in dependencies passed to sprockets which broke change detection

## [2.0.1] - 2015-11-17
- remove tilt gem from gemspec and no longer require it in processor

## [2.0.0] - 2015-11-17
- remove dependency on tilt gem and use callable sprockets api (thanks to guiceolin)

## [1.5.0] - 2015-10-07
- add jruby support for file name resolution (thanks to jmagoon)
- make config.force more flexible by allowing it to be a proc (thanks to rosendi)
- fix browserify-rails to work with new sprockets 3 interface (thanks to hajpoj)
- fix broken test with current `npm install` in dummy test app

## [1.4.0] - 2015-08-12
- modify tilt allowed version to be ">= 1.1", "< 3" to be compatible with sass-rails

## [1.3.0] - 2015-08-12
- add tilt >= 2.0.1 as a runtime dependency (overlooked)

## [1.2.0] - 2015-07-19
- require sprockets > 3.0.2 (see browserify-rails issue 91)

## [1.1.0] - 2015-07-04
- fix major performance bug with browserify-incremental cachefile
- remove specific version in README

## [1.0.2] - 2015-06-29
- updates to README for versions

## [1.0.1] - 2015-06-08
- fix bug with exorcist and config.root being unset

## [1.0.0] - 2015-06-03
- fix bugs when path has a space in it

## [1.0.0b] - 2015-06-03
- update dependencies to be compatible with sass-rails and more...

## [0.9.3] - 2015-06-03
- allow parentheses in path names
- support for piping output through Exorcist to extract sourcemaps

## [0.9.1] - 2015-04-20
- options can be set to a proc

## [0.9.0] - 2015-04-16
- bumped a more significant version due to potential issues with Rails 4.x compatibility

## [0.8.4] - 2015-04-16
- make compatible with Rails 4.x and add missing testing gem

## [0.8.3] - 2015-03-17
- forgot to update CHANGELOG

## [0.8.2] - 2015-03-17
- allow setting NODE_ENV via configuration

## [0.8.1] - 2015-03-17
### Changed
- disable browserify-incremental in production and staging environments

## [0.8.0] - 2015-03-17
### Changed
- do not compile source maps for any environment by default (used to default to development-enabled)
- set NODE_ENV to Rails.env in environment that runs browserify command
- begin using changelog
