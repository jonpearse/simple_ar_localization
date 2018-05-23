# encoding: UTF-8
require File.expand_path('../lib/simple_ar_localizer/version', __FILE__)

Gem::Specification.new do |gem|

  gem.name          = 'simple_ar_localizer'
  gem.summary       = 'Easier localisation for ActiveRecord models.'
  gem.description   = 'Provides a (hopefully) simpler way of localising the human name, attribute names, and error message for ActiveRecord models.'
  gem.version       = SimpleARLocalizer::VERSION

  gem.files         = `git ls-files`.split($\)
  gem.require_paths = [ 'lib' ]

  gem.authors       = 'Jon Pearse'
  gem.email         = 'hello@jonpearse.net'
  gem.license       = 'MIT'
  gem.homepage      = 'https://github.com/jonpearse/simple_ar_localizer'

  gem.add_dependency( 'activerecord', '~> 5.1' )

end
