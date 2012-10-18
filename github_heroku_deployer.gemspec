# -*- encoding: utf-8 -*-
require File.expand_path('../lib/github_heroku_deployer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "github_heroku_deployer"
  gem.version       = GithubHerokuDeployer::VERSION
  gem.authors       = ["Jessica Lynn Suttles"]
  gem.email         = ["jlsuttles@gmail.com"]
  gem.description   = %q{Deploys Github repos to Heroku}
  gem.summary       = %q{Deploys Github repos to Heroku}
  gem.homepage      = ""

  gem.add_runtime_dependency "heroku-api", "~> 0.3.5"
  gem.add_runtime_dependency "git", "~> 1.2.5"
  gem.add_runtime_dependency "git-ssh-wrapper", "~> 0.1.0"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
