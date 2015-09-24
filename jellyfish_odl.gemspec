$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'jellyfish_odl/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'jellyfish-odl'
  s.version     = JellyfishOdl::VERSION
  s.authors     = ['Michael Fernando']
  s.email       = ['fernando_michael@bah.com']
  s.homepage    = 'http://github.com/projectjellyfish/jellyfish-odl'
  s.summary     = 'Jellyfish ODL Module'
  s.description = 'Adds ODL provider and product types to Jellyfish API'
  s.license     = 'APACHE'
  s.files = Dir['{app,config,db,lib,public}/**/*', 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']
  s.add_dependency 'rails', '~> 4.2'
  s.add_dependency 'bcrypt', '~> 3.1'
  s.add_development_dependency 'rspec-rails', '~> 3.3'
  s.add_development_dependency 'factory_girl_rails', '~> 4.5'
  s.add_development_dependency 'database_cleaner', '~> 1.4'
  s.add_development_dependency 'rubocop', '~> 0.34'
  s.add_development_dependency 'pry', '~> 0.10.1'
end
