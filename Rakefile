require 'rake'
require 'rake/testtask'
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "solid/version"

task default: [:test, :rubocop]

desc 'run test suite with default parser'
Rake::TestTask.new(:base_test) do |t|
  t.libs << '.' << 'lib' << 'test'
  t.test_files = FileList['test/{integration,unit}/**/*_test.rb']
  t.verbose = false
end

desc 'run test suite with warn error mode'
task :warn_test do
  ENV['LIQUID_PARSER_MODE'] = 'warn'
  Rake::Task['base_test'].invoke
end

task :rubocop do
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
end

desc 'runs test suite with both strict and lax parsers'
task :test do
  ENV['LIQUID_PARSER_MODE'] = 'lax'
  Rake::Task['base_test'].invoke

  ENV['LIQUID_PARSER_MODE'] = 'strict'
  Rake::Task['base_test'].reenable
  Rake::Task['base_test'].invoke

  if RUBY_ENGINE == 'ruby'
    ENV['LIQUID_PARSER_MODE'] = 'lax'
    Rake::Task['base_test'].reenable
    Rake::Task['base_test'].invoke

    ENV['LIQUID_PARSER_MODE'] = 'strict'
    Rake::Task['base_test'].reenable
    Rake::Task['base_test'].invoke
  end
end

task gem: :build
task :build do
  system "gem build solid.gemspec"
end

task install: :build do
  system "gem install solid-#{Solid::VERSION}.gem"
end

task release: :build do
  system "git tag -a v#{Solid::VERSION} -m 'Tagging #{Solid::VERSION}'"
  system "git push --tags"
  system "gem push solid-#{Solid::VERSION}.gem"
  system "rm solid-#{Solid::VERSION}.gem"
end

namespace :benchmark do
  desc "Run the solid benchmark with lax parsing"
  task :run do
    ruby "./performance/benchmark.rb lax"
  end

  desc "Run the solid benchmark with strict parsing"
  task :strict do
    ruby "./performance/benchmark.rb strict"
  end
end

namespace :profile do
  desc "Run the solid profile/performance coverage"
  task :run do
    ruby "./performance/profile.rb"
  end

  desc "Run the solid profile/performance coverage with strict parsing"
  task :strict do
    ruby "./performance/profile.rb strict"
  end
end

desc "Run example"
task :example do
  ruby "-w -d -Ilib example/server/server.rb"
end

task :console do
  exec 'irb -I lib -r solid'
end
