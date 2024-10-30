$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'rack/test'
require 'panthro'

include Rack::Test::Methods

Panthro.disable_logs = true
Panthro.path         = File.expand_path('../cache', __FILE__)
`rm -rf #{ Panthro.path }/*`

Panthro.mirror = 'https://index.rubygems.org'

def app
  Panthro.new
end

test 'should not cache api calls' do
  head '/versions'

  assert last_response.ok?
  assert !File.directory?( "#{ Panthro.path }/versions" )
end

test 'should redirect the query' do
  get '/info/sinatra'

  assert last_response.ok?
  assert !File.directory?( "#{ Panthro.path }/info/sinatra" )
end

test 'should return the same response code got it from rubygems' do
  get '/not-exists'

  assert last_response.status == 404
  assert !File.exist?( "#{ Panthro.path }/not-exists" )
end

test 'should cache static files' do
  spec_file_path = '/quick/Marshal.4.8/activerecord-7.2.1.2.gemspec.rz'
  assert !File.exist?( "#{ Panthro.path }#{ spec_file_path }" )

  get spec_file_path

  assert last_response.ok?
  assert File.exist?( "#{ Panthro.path }#{ spec_file_path }" )
end
