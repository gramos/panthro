#\ --port 4732

require File.expand_path( "lib/panthro", File.dirname(__FILE__) )

Panthro.path = "#{ ENV['HOME'] }/.panthro/"
run Panthro.new
