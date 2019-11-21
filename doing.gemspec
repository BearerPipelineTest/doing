# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','doing','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'doing'
  s.version = Doing::VERSION
  s.author = 'Brett Terpstra'
  s.email = 'me@brettterpstra.com'
  s.homepage = 'http://brettterpstra.com/project/doing/'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A command line tool for managing What Was I Doing reminders'
  s.description = 'A tool for managing a TaskPaper-like file of recent activites. Perfect for the late-night hacker on too much caffeine to remember what they accomplished at 2 in the morning.'
  s.license = 'MIT'
# Add your other files here if you make them
  s.files = %w(
bin/doing
lib/doing/version.rb
lib/doing.rb
lib/doing/wwid.rb
  )
  s.require_paths << 'lib'

  s.extra_rdoc_files = ['README.md']
  s.rdoc_options << '--title' << 'doing' << '--main' << 'README.md' << '--markup' << 'markdown' << '-ri'
  s.bindir = 'bin'
  s.executables << 'doing'
  s.add_development_dependency 'rake', '~> 0'
  s.add_development_dependency 'rdoc', '~> 4.1', '>= 4.1.1'
  s.add_development_dependency 'aruba', '~> 0'
  s.add_development_dependency 'test-unit'
  s.add_runtime_dependency 'gli', '~> 2.17', '>= 2.17.1'
  s.add_runtime_dependency('haml','4.0.3')
  s.add_runtime_dependency('chronic','~> 0.10', '>= 0.10.2')
  s.add_runtime_dependency 'deep_merge', '~> 1.2', '>= 1.2.1'
  s.add_runtime_dependency 'json', '~> 2.2.0', '>= 1.8.1'
end
