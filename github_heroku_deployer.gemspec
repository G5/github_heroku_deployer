# -*- encoding: utf-8 -*-
require File.expand_path('../lib/github_heroku_deployer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "github_heroku_deployer"
  gem.version       = GithubHerokuDeployer::VERSION
  gem.authors       = ["Jessica Lynn Suttles", "Michael Mitchell"]
  gem.email         = ["jlsuttles@gmail.com"]
  gem.description   = %q{Deploys Github repos to Heroku}
  gem.summary       = %q{Deploys public and private Github repos to Heroku}
  gem.homepage      = "https://github.com/G5/github_heroku_deployer"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "heroku-api", ">= 0.3"
  gem.add_dependency "platform-api", ">= 0.2"
  gem.add_dependency "git", ">= 1.2"
  gem.add_dependency "git-ssh-wrapper", ">= 0.1"

  gem.add_development_dependency "simplecov", "~> 0.7.1"
  gem.add_development_dependency "rspec", "~> 2.11.0"
  gem.add_development_dependency "guard-rspec", "~> 2.1.0"
  gem.add_development_dependency "rb-fsevent", "~> 0.9.2"
end
