# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'factory/version'

Gem::Specification.new do |spec|
  spec.name          = "factory"
  spec.version       = Factory::VERSION
  spec.authors       = ["Ben Delsol"]
  spec.email         = ["ben.delsol@intel.com"]
	spec.summary       = "Provides a simple factory module for object construction."
	spec.description   = ""
  spec.homepage      = ""

  orig = $VERBOSE; $VERBOSE = nil
  spec.files         = `git ls-files`.split($/)
  $VERBOSE = orig
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "0.8.7"
  spec.add_development_dependency "rdoc"

	spec.extra_rdoc_files = Dir.glob("doc/*.rdoc")
	spec.has_rdoc = true
	spec.rdoc_options += ["--title=TestStats API",
			"--main=README.rdoc", "-f", "hanna"]
end

