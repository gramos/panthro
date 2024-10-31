Gem::Specification.new do |s|
  s.name        = 'panthro'
  s.version     = '0.1.1'
  s.date        = '2024-10-31'
  s.summary     = "Panthro: the rubygems proxy cache"
  s.description = "!!! This project is a toy, is not usable for serious !!! " +
                  "The idea is to speed up the gem command caching gem" +
                  " and spec files. Rubygems proxy cache Is a rack app " +
                  "that cache static files into a local machine, where is " +
                  "runing. Is does not cache /api calls."
  s.authors     = ["Gaston Ramos"]
  s.email       = 'ramos.gaston@gmail.com'
  s.files       = ['lib/panthro.rb', 'config.ru']
  s.executables = ['panthro']
  s.homepage    = 'https://github.com/gramos/panthro'
  s.license     = 'GPLv3'
  s.post_install_message = "\n\e[1m<<< Panthro: The rubygems proxy cache >>>\e[0m\n" +
                           File.read('ascii-art.txt') + "\n"

  s.required_ruby_version = '>= 3.0'
  s.add_development_dependency "cutest", "~> 1.2"

  s.add_dependency "rack", "~> 3.1"
end
