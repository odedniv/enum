# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "enum/version"

Gem::Specification.new do |s|
  s.name        = "yinum"
  s.version     = Enum::VERSION
  s.authors     = ["Oded Niv"]
  s.email       = ["oded.niv@gmail.com"]
  s.homepage    = "https://github.com/odedniv/enum"
  s.summary     = %q{Enum implementation}
  s.description = %q{Yummy implementation of enum that gives integer values with a special wrapping.}
  s.license     = 'UNLICENSE'

  s.rubyforge_project = "yinum"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec', '~> 2.0'
  s.add_development_dependency 'nil_or', '~> 2.0'
end
