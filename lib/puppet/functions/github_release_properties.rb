require 'octokit'

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
    %i(
      tarball_url
      zipball_url
      tag_name
    )
  end

  def asset_include_keys
    %i(
      browser_download_url
    )
  end

  def default_fetch(tag, repo, asset)
    fetch(tag, repo, asset)
  end

  def fetch_with_auth_by_token(tag, repo, asset, api_endpoint, access_token)
    fetch(tag, repo, asset, api_endpoint, access_token)
  end

  def fetch(tag, repo, asset, api_endpoint=nil, access_token=nil)
    release_properties = fetch_release_properties(tag, repo, asset, api_endpoint, access_token)
    make_hash(asset, release_properties)
  end

  def fetch_release_properties(tag, repo, asset, api_endpoint=nil, access_token=nil)
    client = Octokit::Client.new(
      :api_endpoint => api_endpoint,
      :access_token => access_token
    )
    release = if tag == 'latest'
      client.latest_release(repo)
    else
      client.release_for_tag(repo, tag)
    end
  end

  def make_hash(asset, release_properties)
    r = Hash[release_properties.select{|k,v| root_include_keys.include?(k)}]
    a = Hash[release_properties['assets'].select{|a| a['name'] == asset}.first.select{|k,v| asset_include_keys.include?(k)}]
    Hash[r.merge(a).map{|k,v| [k.to_s, v]}]
  end
end

