require 'net/http'

class Panthro

  def call( env )
    @env          = env
    @file_path    = "#{ self.class.path }#{ env['PATH_INFO'] }"
    @query_string = @env['QUERY_STRING']

    return get_from_cache if File.exists? @file_path
    get_from_mirror
  end

  class << self
    attr_accessor :path
  end

  def uri_str
    uri  = "http://rubygems.org#{ @env['PATH_INFO'] }"
    uri += "?#{ @query_string }" unless @query_string.empty?
    uri
  end

  def get( uri )
    http    = Net::HTTP.new( uri.host, uri.port )
    request = Net::HTTP::Get.new( uri.request_uri )
    resp    = http.request( request )
    resp    = get( URI( resp['location'] ) ) if resp.code == '302'
    resp
  end

  def get_from_mirror
    @uri  = URI( uri_str )
    @resp = get( @uri )
    write_cache!

    headers = @resp.to_hash
    headers.delete 'transfer-encoding'
    headers.each{ |k,v| headers[k] = v.first }

    [ @resp.code, headers, [ @resp.body ] ]
  end

  def write_cache!
    return if @uri.path =~ /\/api\//
    return unless @resp.code =~ /20/

    dir = File.dirname( @file_path )
    FileUtils.mkdir_p( dir ) unless File.directory?( dir )

    open( @file_path, "wb" ) do |file|
      file.write( @resp.body )
    end
  end

  def get_from_cache
    file    = File.open( @file_path, "r" )
    content = file.read
    file.close

    [ 200, {}, [ content ] ]
  end
end
