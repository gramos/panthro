require 'net/http'

class Panthro
  def call env
    @env      = env
    @headers  = {}
    @dir      = File.dirname @env['PATH_INFO']
    @full_dir = "#{Panthro.path}#{@dir}"
    @basename = File.basename @env['PATH_INFO']

    return get_from_mirror if @env['PATH_INFO'] == '/'
    load_etag_from_file_system

    get_from_mirror
    return get_from_cache if File.exist? file_path
  end

  class << self
    attr_accessor :path, :mirror, :disable_logs, :meta
  end

  private

  def load_etag_from_file_system
    return (@etag = Panthro.meta[@env['PATH_INFO']]) if Panthro.meta[@env['PATH_INFO']]

    matched_file = Dir.glob(file_path("*"))
    return if matched_file.empty?

    @etag = File.basename(matched_file.first).split(".___").first
    @etag = "\"#{@etag}\""
    Panthro.meta[@env['PATH_INFO']] = @etag
  end

  def uri_str
    uri  = "#{ Panthro.mirror }#{ @env['PATH_INFO'] }"
    uri += "?#{ @env['QUERY_STRING'] }" unless @env['QUERY_STRING'].empty?
    uri
  end

  def get uri
    http         = Net::HTTP.new( uri.host, uri.port )
    http.use_ssl = true
    request      = Net::HTTP::Get.new( uri.request_uri, {'If-None-Match' => @etag} )

    resp         = http.request( request )
    resp         = get( URI resp['location']  ) if resp.code == '302'
    resp
  end

  def get_from_mirror
    @uri  = URI uri_str
    @resp = get @uri

    log(:get_mirror)

    @headers = @resp.to_hash
    @headers.delete 'transfer-encoding'
    @headers.each{ |k,v| @headers[k] = v.first }
    @etag = @headers['etag'] && @headers['etag'].tr('"','')

    write_cache! unless @env['PATH_INFO'] == '/' or @resp.code.to_i == 304

    [ @resp.code.to_i, @headers, [ @resp.body ] ]
  end

  def write_cache!
    return unless @resp.code =~ /20/

    log(:write_cache)
    FileUtils.mkdir_p @full_dir unless File.directory? @full_dir

    Panthro.meta[@env['PATH_INFO']] = "\"#{@etag}\""

    open( file_path, "wb" ) do |file|
      file.write @resp.body
    end
  end

  def get_from_cache
    log(:get_cache)
    file    = File.open file_path, "r"
    content = file.read
    file.close

    [ 200, {}, [ content ] ]
  end

  def file_path(prefix = nil)
    pre = prefix || @etag
    "#{ self.class.path }#{@dir}/#{pre}.___#{ @basename }"
  end

  def log(action)
    actions = {
      :get_mirror  => "[ MIRROR ] #{@uri} -- [ #{@resp.code} ]",
      :get_cache   => "[ CACHE ] #{file_path}",
      :write_cache => "[ WRITE CACHE ] #{file_path}"
    }

    puts actions[action] unless Panthro.disable_logs
  end
end

Panthro.path     = "#{ ENV['HOME'] }/.panthro"
Panthro.mirror   = 'https://index.rubygems.org'
