require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/contrib/sshpublisher.rb'

Gem::manage_gems

html_dir  = 'doc/html'
library   = 'FileCache'

spec = Gem::Specification.new do |s|
  s.name              = "filecache"
  s.version           = "1.0"
  s.author            = "Simon Whitaker"
  s.email             = "sw@netcetera.org"
  s.homepage          = "http://netcetera.org"
  s.summary           = "A file-based caching library"
  s.files             = FileList["{lib,tests}/**/*"].exclude("rdoc").to_a
  s.require_path      = "lib"
  # s.autorequire       = "filecache"
  s.test_file         = "tests/test_filecache.rb"
  s.has_rdoc          = true
  s.extra_rdoc_files  = ["README", "COPYING"]
  s.rubyforge_project = "filecache"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar_gz = true
  pkg.package_files.include("README", "COPYING", "lib/**/*.rb")
end

task :gem     => ["pkg/#{spec.name}-#{spec.version}.gem"]
task :zip     => ["pkg/#{spec.name}-#{spec.version}.zip"]
task :gz      => ["pkg/#{spec.name}-#{spec.version}.tar.gz"]

Rake::TestTask.new do |t|
  t.libs << "tests"
  t.test_files = FileList["{tests}/*.rb"]
  t.verbose = true
end

Rake::RDocTask.new('rdoc') do |t|
  t.rdoc_files.include('README', 'COPYING', 'lib/**/*.rb')
  t.main = 'README'
  t.title = "#{library} API documentation"
  t.rdoc_dir = html_dir
end

rubyforge_user    = 'simonw'
rubyforge_project = 'filecache'
rubyforge_path    = "/var/www/gforge-projects/#{rubyforge_project}/"
desc 'Upload documentation to RubyForge.'
task 'upload-docs' => ['rdoc'] do
     sh "scp -r #{html_dir}/* #{rubyforge_user}@rubyforge.org:#{rubyforge_path}"
end
