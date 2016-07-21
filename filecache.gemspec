Gem::Specification.new do |s|
  s.name              = 'filecache'
  s.version           = '1.0.1'
  s.authors           = ['Simon Whitaker', 'Leigh McCulloch']
  s.homepage          = 'https://github.com/leighmcculloch/filecache-ruby'
  s.summary           = 'A file-based caching library'
  s.files             = ['lib/filecache.rb']
  s.require_path      = 'lib'
  s.license           = 'MIT'
  s.test_file         = 'tests/filecache_test.rb'

  s.add_development_dependency 'rake', '~> 11', '> 11'
  s.add_development_dependency 'rdoc', '~> 4', '> 4'
  s.add_development_dependency 'test-unit', '~> 3', '> 3'
end
