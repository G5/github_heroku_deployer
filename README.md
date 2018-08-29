# Github Bitbucket Deployer
[![Codefresh build status]( https://g.codefresh.io/api/badges/pipeline/g5dev/g5search%2Fgithub_bitbucket_deployer%2Fgithub_bitbucket_deployer?branch=master&key=eyJhbGciOiJIUzI1NiJ9.NWFjNjdhZDQzZmI2NmYwMDAxNTc4NDU0.tFs73TZYRDhdncaCsz-YDwgCsgwKVeQrKY3dygI0GCM&type=cf-1)]( https://g.codefresh.io/repositories/g5search/github_bitbucket_deployer/builds?filter=trigger:build;branch:master;service:5b7c82eeaedcd09cebccbed5~github_bitbucket_deployer)
[![Maintainability](https://api.codeclimate.com/v1/badges/433a307160a975b54a4f/maintainability)](https://codeclimate.com/repos/5762d216bb2a0c006d0019a1/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/433a307160a975b54a4f/test_coverage)](https://codeclimate.com/repos/5762d216bb2a0c006d0019a1/test_coverage)

Ruby gem to deploy public and private Github repos to Bitbucket


## Current Version

1.0.0

## Requirements

* [git](https://git-scm.com/) >= 1.6.0.0
* [ruby](https://www.ruby-lang.org/) >= 2.2

## Installation

### Gemfile

Add this line to your application's Gemfile:

```ruby
gem 'github_bitbucket_deployer'
```

### Manual

Or install it yourself:

```bash
gem install github_bitbucket_deployer
```


## Usage

Set defaults in an initializer, defaults are shown:

```ruby
GithubBitbucketDeployer.configure do |config|
  config.id_rsa          = ENV["ID_RSA"]
  config.logger          = Logger.new(STDOUT)
end
```

Export you environment variables wherever you do that:

```bash
export ID_RSA=id_rsa
```

Create Bitbucket App:

```ruby
  GithubBitbucketDeployer.create
```

Deploy:

```ruby
  GithubBitbucketDeployer.deploy
```

Override defaults:

```ruby
  GithubBitbucketDeployer.deploy(github_repo: github_repo)
```

Manipulate Repo:

```ruby
  GithubBitbucketDeployer.deploy(github_repo: github_repo) { |repo| repo.add "/path/to/file" }
```


## Authors

  * Jessica Lynn Suttles / [@jlsuttles](https://github.com/jlsuttles)
  * Bookis Smuin / [@bookis](https://github.com/bookis)
  * Michael Mitchell / [@variousred](https://github.com/variousred)


## Contributing

1. Fork it
2. Get it running
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Write your code and **specs**
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request

If you find bugs, have feature requests or questions, please
[file an issue](https://github.com/G5/github_bitbucket_deployer/issues).


## Specs

Export environment variables
```bash
export ID_RSA=id_rsa
```


## License

Copyright (c) 2012 G5

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
