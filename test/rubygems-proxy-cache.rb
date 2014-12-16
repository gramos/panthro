require 'rack/test'
require './lib/rubygems_proxy_cache'

include Rack::Test::Methods

setup do
  './cache'
end

def app
  RubygemsProxyCache.new
end

test 'should not cache api calls' do |cache_path|
  get '/api/v1/dependencies?gems=sinatra'
  assert !File.directory?( "#{ cache_path }/api/v1" )
end
