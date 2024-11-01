require 'net/http'

class Panthro
  class << self
    attr_accessor :path, :mirror, :disable_logs
  end

  def call env
    @env          = env
    @file_path    = "#{ self.class.path }#{ env['PATH_INFO'] }"
    @path         = @env['PATH_INFO']
    @method       = @env['REQUEST_METHOD']

    return get_from_mirror if (@path == '/' or @path =~ /\/info/)
    return get_from_cache if File.exist? @file_path
    get_from_mirror
  end

  private

  def uri_str
    uri  = "#{ Panthro.mirror }#{ @env['PATH_INFO'] }"
    uri += "?#{ @env['QUERY_STRING'] }" unless @env['QUERY_STRING'].empty?
    uri
  end

  def get uri
    http         = Net::HTTP.new( uri.host, uri.port )
    http.use_ssl = true
    request      = Net::HTTP::Get.new( uri.request_uri )
    resp         = http.request( request ) if @method == 'GET'
    resp         = http.head(@path) if @method == 'HEAD'
    resp         = get( URI resp['location']  ) if resp.code == '302'
    resp
  end

  def get_from_mirror
    @uri  = URI uri_str
    log(:get_mirror)
    @resp = get @uri
    write_cache! unless (@path == '/' or @path =~ /\/info/)
    headers = @resp.to_hash
    headers.delete 'transfer-encoding'
    headers.each{ |k,v| headers[k] = v.first }

    [ @resp.code.to_i, headers, [ @resp.body.to_s ] ]
  end

  def write_cache!
    return unless @resp.code =~ /20/

    log(:write_cache)
    dir = File.dirname @file_path
    FileUtils.mkdir_p dir unless File.directory? dir
    open( @file_path, "wb" ) do |file|
      file.write @resp.body
    end
  end

  def get_from_cache
    log(:get_cache)
    file    = File.open @file_path, "r"
    content = file.read
    file.close

    [ 200, {}, [ content ] ]
  end

  def log(action)
    actions = {
      :get_mirror  => "[ GET MIRROR ] #{@uri}",
      :get_cache   => "[ GET CACHE ] #{@file_path}",
      :write_cache => "[ WRITE CACHE ] #{@file_path}"
    }

    puts actions[action] unless Panthro.disable_logs
  end
end

Panthro.path   = "#{ ENV['HOME'] }/.panthro"
Panthro.mirror = 'https://index.rubygems.org'
