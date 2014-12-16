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
  head '/api/v1/dependencies'
  assert last_response.ok?
  assert !File.directory?( "#{ cache_path }/api/v1" )
end

test 'should cache static files' do |cache_path|
  spec_file_path = '/quick/Marshal.4.8/sinatra-1.4.5.gemspec.rz'
  get spec_file_path
  assert last_response.ok?
  assert File.exists?( "#{ cache_path }#{ spec_file_path }" )
end
