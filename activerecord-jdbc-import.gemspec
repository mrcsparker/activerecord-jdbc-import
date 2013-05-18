# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record/jdbc/import/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-jdbc-import"
  spec.version       = Activerecord::Jdbc::Import::VERSION
  spec.authors       = ["Chris Parker"]
  spec.email         = ["mrcsparker@gmail.com"]
  spec.description   = %q{Import items quickly with activerecord-jdbc}
  spec.summary       = %q{Uses jdbc stored procedures to quickly import data}
  spec.homepage      = "https://github.com/mrcsparker/activerecord-jdbc-import"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport'
  spec.add_dependency 'actionpack'
  spec.add_dependency 'activerecord'
  spec.add_dependency 'activerecord-jdbc-adapter'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'activerecord-jdbcsqlite3-adapter'
  spec.add_development_dependency 'jdbc-sqlite3'
  spec.add_development_dependency 'ffaker'
end
