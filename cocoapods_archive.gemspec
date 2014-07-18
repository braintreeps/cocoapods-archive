# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods_archive.rb'

Gem::Specification.new do |spec|
  spec.name          = "cocoapods-archive"
  spec.version       = CocoapodsArchive::VERSION
  spec.authors       = ["Mickey Reiss"]
  spec.email         = ["mickey@venmo.com"]
  spec.description   = %q{"A CocoaPods plugin that enables you to archive your Pod as a static library"}
  spec.summary       = <<-EOF

          Creates an archive containing everything one would need to integrate the CocoaPod in the current working directory without using CocoaPods:

          - A `.a` static library

          - A number of public `.h` headers

          - An `.xcconfig` file with the appropriate integration configuration settings

          - A README with integration instructions

          This tool is useful if your primary distribution mechanism is CocoaPods but a significat portion of your userbase does not yet use dependency management. Instead, they receive a closed-source version with manual integration instructions.
          EOF
  spec.homepage      = "https://github.com/braintreeps/cocoapods-archive"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
