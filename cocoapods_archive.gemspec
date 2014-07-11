# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods_archive.rb'

Gem::Specification.new do |spec|
  spec.name          = "cocoapods-archive"
  spec.version       = CocoapodsArchive::VERSION
  spec.authors       = ["Braintree"]
  spec.email         = ["code@getbraintree.com"]
  spec.description   = %q{A short description of cocoapods-archive.}
  spec.summary       = %q{A longer description of cocoapods-archive.}
  spec.homepage      = "https://github.com/EXAMPLE/cocoapods-archive"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
