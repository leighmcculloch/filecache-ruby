require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rdoc/task'

Rake::TestTask.new do |t|
  t.libs << "tests"
  t.test_files = FileList["{tests}/*.rb"]
  t.verbose = true
end

RDoc::Task.new do |doc|
  doc.main = 'README.rdoc'
  doc.rdoc_dir = 'html'
  doc.rdoc_files = FileList.new %w[README COPYING lib/**/*.rb]
  doc.title = 'Ruby - filecache'
end

task :default => :test