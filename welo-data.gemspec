# -*- encoding: utf-8 -*-
require File.expand_path('../lib/welo-data/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["crapooze"]
  gem.email         = ["crapooze@gmail.com"]
  gem.description   = %q{data persisters and fetchers for welo resources}
  gem.summary       = %q{easily expose or save welo resources}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "welo-data"
  gem.require_paths = ["lib"]
  gem.version       = Welo::Data::VERSION
end
