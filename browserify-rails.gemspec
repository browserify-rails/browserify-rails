# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'browserify-rails/version'

Gem::Specification.new do |spec|
  spec.name          = "browserify-rails"
  spec.version       = BrowserifyRails::VERSION
  spec.authors       = ["Henry Hsu, Cymen Vig"]
  spec.email         = ["hhsu@zendesk.com, cymenvig@gmail.com"]
  spec.description   = %q{Browserify + Rails = CommonJS Heaven}
  spec.summary       = %q{Get the best of both worlds: Browserify + Rails = CommonJS Heaven}
  spec.homepage      = "https://github.com/browserify-rails/browserify-rails"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]


  spec.add_runtime_dependency "railties", ">= 4.0.0", "< 5.1"
  spec.add_runtime_dependency "sprockets", ">= 3.5.2"
  spec.add_runtime_dependency "addressable", ">= 2.4.0"

  spec.add_development_dependency "bundler", ">= 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "coffee-rails"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "test-unit"
end
