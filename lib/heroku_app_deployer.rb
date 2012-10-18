require "heroku_app_deployer/configuration"
require "heroku_app_deployer/git"
require "heroku_app_deployer/heroku"
require "heroku_app_deployer/version"

module HerokuAppDeployer
  class << self
    # A HerokuAppDeployer configuration object. Must act like a hash and return sensible
    # values for all HerokuAppDeployer configuration options.
    #
    # @see HerokuAppDeployer::Configuration.
    attr_writer :configuration

    # The configuration object.
    #
    # @see HerokuAppDeployer.configure
    def configuration
      @configuration ||= Configuration.new
    end

    # Call this method to modify defaults in your initializers.
    #
    # @example
    #   HerokuAppDeployer.configure do |config|
    #     config.deployhooks_http_url = ENV["DEPLOYHOOKS_HTTP_URL"]
    #     config.heroku_username = ENV["HEROKU_USERNAME"]
    #     config.heroku_api_key = ENV["HEROKU_API_KEY"]
    #     config.github_repo = ENV["GITHUB_REPO"]
    #     config.heroku_repo = ENV["HEROKU_REPO"]
    #     config.heroku_app_name = ENV=["HEROKU_APP_NAME"]
    #   end
    def configure
      yield(configuration)
    end

    def deploy
      heroku.find_or_create_app
      git.push_app_to_heroku
      heroku.add_deployhooks_http
      # TODO: return useful stuff and things
    end

    # TODO: is this going to fly?
    def heroku
      @heroku ||= Heroku.new(configuration)
    end

    def git
      @git ||= Git.new(configuration)
    end

  end # class << self
end
