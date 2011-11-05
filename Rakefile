require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib' << 'test'
  t.test_files = Dir.glob("test/**/*_test.rb")
  t.verbose = true
end

task :default => :test

require 'bundler/gem_tasks'
