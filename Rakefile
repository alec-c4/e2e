# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rake/testtask"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)

Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.libs << "spec"
  t.test_files = FileList["spec/**/*_test.rb"]
  t.verbose = true
end

RuboCop::RakeTask.new

task default: %i[spec test rubocop]
