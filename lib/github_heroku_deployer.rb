require "github_heroku_deployer/exceptions"
require "github_heroku_deployer/configuration"
require "github_heroku_deployer/git"
require "github_heroku_deployer/heroku"
require "github_heroku_deployer/version"

module GithubHerokuDeployer
  class << self
    # A GithubHerokuDeployer configuration object. Must act like a hash and 
    # return sensible values for all GithubHerokuDeployer configuration options.
    #
    # @see GithubHerokuDeployer::Configuration.
    attr_writer :configuration

    # The configuration object.
    #
    # @see GithubHerokuDeployer.configure
    def configuration
      @configuration ||= Configuration.new
    end

    # Call this method to modify defaults in your initializers.
    #
    # @example
    #   GithubHerokuDeployer.configure do |config|
    #     config.github_repo     = ENV["GITHUB_REPO"]
    #     config.heroku_api_key  = ENV["HEROKU_API_KEY"]
    #     config.heroku_app_name = ENV["HEROKU_APP_NAME"]
    #     config.heroku_repo     = ENV["HEROKU_REPO"]
    #     config.heroku_username = ENV["HEROKU_USERNAME"]
    #   end
    def configure
      yield(configuration)
    end

    def deploy
      configuration.check_requirements
      heroku.find_or_create_app
      git.push_app_to_heroku
      true
    end

    def heroku
      Heroku.new(configuration)
    end

    def git
      Git.new(configuration)
    end

  end # class << self
end
