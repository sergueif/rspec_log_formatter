# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec_log_formatter/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec_log_formatter"
  spec.version       = RspecLogFormatter::VERSION
  spec.authors       = ["Serguei Filimonov"]
  spec.email         = ["sfilimonov@pivotallabs.com"]
  spec.summary       = "Logs the outcomes of the tests to a file"
  spec.description   = "Logs the outcomes of the tests to a file"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'chartkick'
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
