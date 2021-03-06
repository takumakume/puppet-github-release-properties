require 'spec_helper'

describe 'github_release_properties' do
  let(:repo) { 'takumakume/puppet-github-release-properties-test' }
  let(:asset) { 'puppet-github-release-properties-test.tar.gz' }

  it { VCR.use_cassette('latest_release') { is_expected.to run.with_params('latest', repo, asset) } }
  it { VCR.use_cassette('release_for_tag') { is_expected.to run.with_params('v1.0.0', repo, asset)} }
  it { VCR.use_cassette('release_for_tag_notfound') { is_expected.to run.with_params('notfound', repo, asset).and_raise_error(RuntimeError)} }

  let(:release) do
    {
      'tarball_url'          => 'https://api.github.com/repos/takumakume/puppet-github-release-properties-test/tarball/v1.0.0',
      'zipball_url'          => 'https://api.github.com/repos/takumakume/puppet-github-release-properties-test/zipball/v1.0.0',
      'tag_name'             => 'v1.0.0',
      'browser_download_url' => 'https://github.com/takumakume/puppet-github-release-properties-test/releases/download/v1.0.0/puppet-github-release-properties-test.tar.gz',
    }
  end

  it { VCR.use_cassette('release_for_tag') { is_expected.to run.with_params('v1.0.0', repo, asset).and_return(release)} }
end
