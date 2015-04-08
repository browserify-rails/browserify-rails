# Change Log
All notable changes to this project will be documented in this file going forward.

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
