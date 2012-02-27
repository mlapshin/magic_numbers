# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "magic_numbers/version"

Gem::Specification.new do |s|
  s.name        = "magic_numbers"
  s.version     = MagicNumbers::VERSION
  s.authors     = ["Mike Lapshin"]
  s.email       = ["sotakone@sotakone.com"]
  s.homepage    = "http://github.com/sotakone/magic_numbers"
  s.summary     = %q{Magic Numbers is a simple Rails plugin which brings transparent enums and sets (bitfields) to AR objects.}
  s.description = %q{Magic Numbers is a simple Rails plugin which brings transparent enums and sets (bitfields) to AR objects. It doesn’t require native database support for enums or sets, instead of this it stores values as plain integers.}

  s.rubyforge_project = "magic_numbers"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rake'
  s.add_development_dependency 'sqlite3'  
  s.add_dependency 'activerecord', '~> 3.0'
  s.add_dependency 'activesupport', '~> 3.0'
  s.add_dependency 'railties', '~> 3.0'
end
