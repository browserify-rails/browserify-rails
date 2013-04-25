require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

namespace :dummy do
  namespace :npm do
    desc "Run npm install for dummy app"
    task :install do
      dummy_dir = Bundler.root.join 'test/dummy'

      sh "cd #{dummy_dir} && npm install" do |ok, res|
        fail "Error running npm install in #{dummy_dir}." unless ok
      end
    end
  end
end

task :test => ['dummy:npm:install']

task :default => :test
