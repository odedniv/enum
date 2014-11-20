# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "enum/version"

Gem::Specification.new do |spec|
  spec.name          = "yinum"
  spec.version       = Enum::VERSION
  spec.authors       = ["Oded Niv"]
  spec.email         = ["oded.niv@gmail.com"]
  spec.summary       = %q{Enum implementation}
  spec.description   = %q{Yummy implementation of enum that gives integer values with a special wrapping.}
  spec.homepage      = "https://github.com/odedniv/enum"
  spec.license       = "UNLICENSE"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "generate_method", "~> 1.0"

  spec.add_development_dependency "rspec", "~> 2.0"
  spec.add_development_dependency "nil_or", "~> 2.0"
end
