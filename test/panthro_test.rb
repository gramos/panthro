require 'rack/test'
require './lib/panthro'

include Rack::Test::Methods

`rm -rf #{ Panthro.path }/*`

def app
  Panthro.new
end

test 'should not cache api calls' do
  head '/api/v1/dependencies'

  assert last_response.ok?
  assert !File.directory?( "#{ Panthro.path }/api/v1" )
end

test 'should redirect the query' do
  get '/api/v1/dependencies?gems=sinatra'

  assert last_response.ok?
end

test 'should return the same response code got it from rubygems' do
  get '/not-exists'

  assert last_response.status == 404
  assert !File.exists?( "#{ Panthro.path }/not-exists" )
end

test 'should cache static files' do
  spec_file_path = '/quick/Marshal.4.8/sinatra-1.4.5.gemspec.rz'
  assert !File.exists?( "#{ Panthro.path }#{ spec_file_path }" )

  get spec_file_path

  assert last_response.ok?
  assert File.exists?( "#{ Panthro.path }#{ spec_file_path }" )
end
