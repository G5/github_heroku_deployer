# Github Heroku Deployer

[![Build Status](https://travis-ci.org/G5/github_heroku_deployer.png?branch=master)](https://travis-ci.org/G5/github_heroku_deployer)
[![Code Climate](https://codeclimate.com/github/G5/github_heroku_deployer.png)](https://codeclimate.com/github/G5/github_heroku_deployer)

Ruby gem to deploy public and private Github repos to Heroku


## Current Version

0.2.1


## Requirements

* ["heroku_api", "~> 0.3.5"](http://rubygems.org/gems/heroku-api)
* ["git", "~> 1.2.5"](http://rubygems.org/gems/git)
* ["git-ssh-wrapper", "~> 0.1.0"](http://rubygems.org/gems/git-ssh-wrapper)


## Installation

### Gemfile

Add this line to your application's Gemfile:

```ruby
gem 'github_heroku_deployer'
```

### Manual

Or install it yourself:

```bash
gem install github_heroku_deployer
```


## Usage

Set defaults in an initializer, defaults are shown:

```ruby
GithubHerokuDeployer.configure do |config|
  config.github_repo     = ENV["GITHUB_REPO"]
  config.heroku_api_key  = ENV["HEROKU_API_KEY"]
  config.heroku_app_name = ENV["HEROKU_APP_NAME"]
  config.heroku_repo     = ENV["HEROKU_REPO"]
  config.heroku_username = ENV["HEROKU_USERNAME"]
  config.id_rsa          = ENV["ID_RSA"]
  config.logger          = Logger.new(STDOUT)
end
```

Export you environment variables wherever you do that:

```bash
export GITHUB_REPO=git@github.com:your/repo.git
export HEROKU_API_KEY=heroku_api_key
export HEROKU_APP_NAME=heroku_app_name
export HEROKU_REPO=git@heroku.com:repo.git
export HEROKU_USERNAME=heroku_username
export ID_RSA=id_rsa
```

Deploy:

```ruby
  GithubHerokuDeployer.deploy
```

Override defaults:

```ruby
  GithubHerokuDeployer.deploy(github_repo: github_repo)
```

Manipulate Repo:

```ruby
  GithubHerokuDeployer.deploy(github_repo: github_repo) { |repo| repo.add "/path/to/file" }
```


## Authors

  * Jessica Lynn Suttles / [@jlsuttles](https://github.com/jlsuttles)
  * Bookis Smuin / [@bookis](https://github.com/bookis)


## Contributing

1. Fork it
2. Get it running
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Write your code and **specs**
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request

If you find bugs, have feature requests or questions, please
[file an issue](https://github.com/G5/github_heroku_deployer/issues).


## Specs

Export environment variables
```bash
export GITHUB_REPO=git@github.com:G5/static-sinatra-prototype.git
export HEROKU_API_KEY=heroku_api_key
export HEROKU_APP_NAME=static-sinatra-prototype
export HEROKU_REPO=git@heroku.com:static-sinatra-prototype.git
export HEROKU_USERNAME=heroku_username
export ID_RSA=id_rsa
export PRIVATE_GITHUB_REPO=git@github.com:g5search/g5-client-location.git
export PUBLIC_GITHUB_REPO=git@github.com:G5/static-sinatra-prototype.git
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
