# Change Log
All notable changes to this project will be documented in this file going forward.

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
