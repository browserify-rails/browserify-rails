# Change Log
All notable changes to this project will be documented in this file going forward.

## [0.9.3] - 2015-04-28
- update dependency versions to be more open (sprockets >= 2.2, rails >= 3.2)

## [0.9.2] - 2015-04-29
- not released (yanked)

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
