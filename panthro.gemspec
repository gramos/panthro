Gem::Specification.new do |s|
  s.name        = 'panthro'
  s.version     = '0.0.2'
  s.date        = '2015-03-26'
  s.summary     = "Panthro: the rubygems proxy cache"
  s.description = "The idea is to speed up the gem command caching gem and spec files. Rubygems proxy cache Is a rack app that cache static files into a local machine, where is runing. Is does not cache /api calls."
  s.authors     = ["Gaston Ramos"]
  s.email       = 'ramos.gaston@gmail.com'
  s.files       = ['lib/panthro.rb', 'config.ru']
  s.executables = ['panthro']
  s.default_executable = 'panthro'
  s.homepage    = 'https://github.com/gramos/panthro'
  s.license     = 'GPLv3'

  s.add_development_dependency "cutest", "~> 1.2"

  s.add_dependency "rack", "~> 1.5"
end
