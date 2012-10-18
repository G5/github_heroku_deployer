# Heroku App Deployer

Ruby gem to deploy repos to Heroku.


## Current Version

0.0.1


## Requirements

* ["heroku_api", "~> 0.3.5"](http://rubygems.org/gems/heroku-api)
* ["git", "~> 1.2.5"](http://rubygems.org/gems/git)
* ["git-ssh-wrapper", "~> 0.1.0"](http://rubygems.org/gems/git-ssh-wrapper)


## Installation

### Gemfile

Add this line to your application's Gemfile:

```ruby
gem 'heroku_app_deployer'
```

### Manual

Or install it yourself:

```bash
gem install heroku_app_deployer
```


## Usage

Set defaults in an initializer, defaults are shown:

```ruby
HerokuAppDeployer.configure do |config|
  config.github_repo     = ENV["GITHUB_REPO"]
  config.heroku_api_key  = ENV["HEROKU_API_KEY"]
  config.heroku_app_name = ENV["HEROKU_APP_NAME"]
  config.heroku_repo     = ENV["HEROKU_REPO"]
  config.heroku_username = ENV["HEROKU_USERNAME"]
end
```

Export you environment variables wherever you do that:

```bash
export HEROKU_USERNAME=heroku_username
export HEROKU_API_KEY=heroku_api_key
export HEROKU_APP_NAME=heroku_app_name
export HEROKU_REPO=git@heroku.com:repo.git
export GITHUB_REPO=git@github.com:your/repo.git
```

Deploy:

```ruby
  HerokuAppDeployer.deploy
```

TODO Override defaults:

```ruby
  HerokuAppDeployer.deploy(github_repo: github_repo)
```


## Authors

  * Jessica Lynn Suttles / [@jlsuttles](https://github.com/jlsuttles)


## Contributing

1. Fork it
2. Get it running
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Write your code and **specs**
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request

If you find bugs, have feature requests or questions, please
[file an issue](https://github.com/G5/heroku_app_deployer/issues).


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
