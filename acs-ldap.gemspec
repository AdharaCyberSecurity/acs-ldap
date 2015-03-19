# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acs/ldap/version'

Gem::Specification.new do |s|
  s.name          = "acs-ldap"
  s.version       = Acs::Ldap::VERSION
  s.authors       = ["Terranova David"]
  s.email         = ["dterranova@adhara-cybersecurity.com"]
  s.summary       = %q{ActiveRecord to LDAP adapter}
  s.description   = %q{ActiveRecord to LDAP adapter}
  s.homepage      = ""
  s.license       = "MIT"

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.7"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec"
  s.add_development_dependency "debugger2"

  s.add_dependency 'net-ldap'
  s.add_dependency 'rails'
end
