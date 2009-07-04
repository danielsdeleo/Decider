# encoding: UTF-8
require "spec/rake/spectask"
require "cucumber"
require "cucumber/rake/task"

task :default => :spec

desc "Run Cucumber Features"
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = "-c -n"
end

desc "Run all of the specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.fail_on_error = false
end

namespace :spec do

  desc "Generate HTML report for failing examples"
  Spec::Rake::SpecTask.new('report') do |t|
    t.spec_files = FileList['failing_examples/**/*.rb']
    t.spec_opts = ["--format", "html:doc/tools/reports/failing_examples.html", "--diff", '--options', '"spec/spec.opts"']
    t.fail_on_error = false
  end

  desc "Run all spec with RCov" 
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.rcov = true
    t.rcov_dir = 'doc/tools/coverage/'
    t.rcov_opts = ['--exclude', 'spec']
  end

end
