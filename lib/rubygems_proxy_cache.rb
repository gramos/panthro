require 'net/http'

class RubygemsProxyCache

  def call( env )
    @env = env

    if File.exists? "#{ self.class.path }#{ env['PATH_INFO'] }"
      get_from_local_file "#{ self.class.path }#{ env['PATH_INFO'] }"
    else
      get_from_mirror uri_str
    end
  end

  def uri_str
    uri  = "http://rubygems.org#{ @env['PATH_INFO'] }"
    uri += "?#{ @env['QUERY_STRING'] }" unless @env['QUERY_STRING'].empty?
    uri
  end

  def get( uri )
    resp = Net::HTTP.start( uri.host ) do |http|
      http.get( uri.path )
    end

    if resp.code == '302'
      resp = get( URI( resp['location'] ) )
    end

    resp
  end

  def get_from_mirror(uri_str)
    uri  = URI( uri_str )
    resp = get( uri )
    write_cache!( resp, uri.path )

    [ resp.code, resp.header, [ resp.body ] ]
  end

  def write_cache!(resp, path)
    return if path =~ /\/api\//
    return unless resp.code =~ /20/

    dir = File.dirname( "#{ self.class.path }#{ path }" )
    FileUtils.mkdir_p( dir ) unless File.directory?( dir )

    open( "#{ self.class.path }#{ path }", "wb" ) do |file|
      file.write( resp.body )
    end
  end

  def get_from_local_file(file_path)
    file    = File.open(file_path, "r")
    content = file.read
    file.close

    [ 200, {}, [ content ] ]
  end

  def self.path
    '/home/gramos/srcs/rubygems-proxy-cache/cache'
  end
end
