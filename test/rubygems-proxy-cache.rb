require 'rack/test'
require './lib/rubygems_proxy_cache'

include Rack::Test::Methods

`rm -rf #{RubygemsProxyCache.path}/*`

def app
  RubygemsProxyCache.new
end

test 'should not cache api calls' do
  head '/api/v1/dependencies'

  assert last_response.ok?
  assert !File.directory?( "#{ RubygemsProxyCache.path }/api/v1" )
end

test 'should cache static files' do
  spec_file_path = '/quick/Marshal.4.8/sinatra-1.4.5.gemspec.rz'
  assert !File.exists?( "#{ RubygemsProxyCache.path }#{ spec_file_path }" )

  get spec_file_path
  assert last_response.ok?
  assert File.exists?( "#{ RubygemsProxyCache.path }#{ spec_file_path }" )
end
