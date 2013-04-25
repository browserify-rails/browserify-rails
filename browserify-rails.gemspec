# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'browserify-rails/version'

Gem::Specification.new do |spec|
  spec.name          = "browserify-rails"
  spec.version       = BrowserifyRails::VERSION
  spec.authors       = ["Henry Hsu"]
  spec.email         = ["hhsu@zendesk.com"]
  spec.description   = %q{Browserify + Rails = CommonJS Heaven}
  spec.summary       = %q{Get the best of both worlds: Browserify + Rails = CommonJS Heaven}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sprockets", "~> 2.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rails", "~> 3.2"
end
