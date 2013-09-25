require "heroku-api"
require "github_heroku_deployer"

module GithubHerokuDeployer
  class HerokuClient
    def initialize(options={})
      options = GithubHerokuDeployer.options(options)
      ::Heroku::API.new(api_key: options[:heroku_api_key])
    end
  end
end
