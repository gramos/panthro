require 'net/http'

class RubygemsProxyCache

  def call( env )
    if File.exists? "#{ cache_path }#{ env['PATH_INFO'] }"
      get_from_local_file env['PATH_INFO']
    else
      get_from_mirror "http://rubygems.org#{ env['PATH_INFO'] }"
    end
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

    write_cache!( resp, uri.path ) unless uri.path =~ /\/api\//
    [ resp.code, resp.header, resp.body ]
  end

  def write_cache!(resp, path)
    dir = File.dirname( "#{ cache_path }#{ path }" )
    FileUtils.mkdir_p( dir ) unless File.directory?( dir )

    open( "#{ cache_path }#{ path }", "wb" ) do |file|
      file.write( resp.body )
    end
  end

  def get_from_local_file(file_path)
    file    = File.open(file_path, "r")
    content = file.read
    file.close

    [ 200, {}, content ]
  end

  def cache_path
    '/home/gramos/srcs/rubygems-proxy-cache/cache'
  end
end
