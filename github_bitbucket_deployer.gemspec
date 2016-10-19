# -*- encoding: utf-8 -*-
require File.expand_path('../lib/github_bitbucket_deployer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "github_bitbucket_deployer"
  gem.version       = GithubBitbucketDeployer::VERSION
  gem.authors       = ["Jessica Lynn Suttles", "Michael Mitchell"]
  gem.email         = ["jlsuttles@gmail.com", "michaelmitchell@gmail.com"]
  gem.description   = %q{Deploys Github repos to bitbucket}
  gem.summary       = %q{Deploys public and private Github repos to bitbucket}
  gem.homepage      = "https://github.com/G5/github_bitbucket_deployer"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "git", "~> 1.3"
  gem.add_dependency "git-ssh-wrapper", "~> 0.1"
  gem.add_dependency "retriable", "~> 2.1"

  gem.add_development_dependency "simplecov", "~> 0.7.1"
  gem.add_development_dependency "rspec", "~> 3.5"
  gem.add_development_dependency "fakefs", "~> 0.9.2"
  gem.add_development_dependency "pry-byebug", "~> 3.3"
end
