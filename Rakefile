require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'spec'
  t.pattern = "spec/*_spec.rb"
end

desc "Run tests"
task :default => :test

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r acs/ldap"
end
