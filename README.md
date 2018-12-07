
# github_release_properties

## Reference

For example:

```puppet
$latest = github_release_properties(
  'latest',
  'takumakume/puppet-github-release-properties-test',
  'puppet-github-release-properties-test.tar.gz'
)
notify { "${latest[browser_download_url]}": }
#=> https://github.com/takumakume/puppet-github-release-properties-test/releases/download/v2.0.0/puppet-github-release-properties-test.tar.gz

$latest_for_tag = github_release_properties(
  'v1.0.0',
  'takumakume/puppet-github-release-properties-test',
  'puppet-github-release-properties-test.tar.gz'
)
notify { "${latest[browser_download_url]}": }
#=> https://github.com/takumakume/puppet-github-release-properties-test/releases/download/v1.0.0/puppet-github-release-properties-test.tar.gz

#
# with auth by access_token (supported Github Enterprise)
#
$latest_from_ghe = github_release_properties(
  'latest',
  'takumakume/puppet-github-release-properties-test',
  'puppet-github-release-properties-test.tar.gz',
  'https://[hostname]/api/v3',
  '***access_token***'
)

#
# Install latest application
#
$latest = github_release_properties(
  'latest',
  'takumakume/puppet-github-release-properties-test',
  'puppet-github-release-properties-test.tar.gz'
)
archive { "/usr/local/src/puppet-github-release-properties-test-${latest[tag_name]}.tar.gz":
  source => $latest[browser_download_url],
  cleanup => false,
  extract => true,
  extract_path => '/tmp',
}
```
