require 'net/http'
require 'uri'
require 'json'

Puppet::Functions.create_function(:github_release_properties) do
  dispatch :default_fetch do
    param 'String', :tag
    param 'String', :repo
    param 'String', :asset
  end

  dispatch :fetch_with_auth_by_token do
    param 'String', :tag
    param 'String', :repo
    param 'String', :asset
    param 'String', :api_endpoint
    param 'String', :access_token
  end

  def root_include_keys
    %w(
      tarball_url
      zipball_url
      tag_name
    )
  end

  def asset_include_keys
    %w(
      browser_download_url
    )
  end

  def default_fetch(tag, repo, asset)
    fetch(tag, repo, asset, 'https://api.github.com')
  end

  def fetch_with_auth_by_token(tag, repo, asset, api_endpoint, access_token)
    fetch(tag, repo, asset, api_endpoint, access_token)
  end

  def fetch(tag, repo, asset, api_endpoint=nil, access_token=nil)
    release_properties = fetch_release_properties(tag, repo, asset, api_endpoint, access_token)
    make_hash(asset, release_properties)
  end

  def fetch_release_properties(tag, repo, asset, api_endpoint=nil, access_token=nil)
    uri = if tag == 'latest'
      URI.parse("#{api_endpoint}/repos/#{repo}/releases/latest")
    else
      URI.parse("#{api_endpoint}/repos/#{repo}/releases/tags/#{tag}")
    end
  
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 10
    http.read_timeout = 15
    http.use_ssl = true if api_endpoint =~ /^https/
  
    request = Net::HTTP::Get.new(uri)
    request['Content-Type']    = 'application/json'
    request['Accept']          = 'application/vnd.github.v3+json'
    request['Accept-Encoding'] = 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
    request['Authorization']   = access_token if access_token
  
    response = http.request(request)
    raise "#{response.code} #{response.message}: #{uri}" unless response.class == Net::HTTPOK
    
    raw_body = if response.header['Content-Encoding'].eql?('gzip')
      Zlib::GzipReader.new(StringIO.new(response.body)).read
    else
      response.body
    end
    JSON.load(raw_body)
  end

  def make_hash(asset, release_properties)
    r = release_properties.select{|k,_| p k;root_include_keys.include?(k)}
    a = release_properties['assets'].select{|a| a['name'] == asset}.first.select{|k,v| asset_include_keys.include?(k)}
    Hash[r.merge(a).map{|k,v| [k.to_s, v]}]
  end
end

