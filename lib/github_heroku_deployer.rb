require "github_heroku_deployer/version"
require "github_heroku_deployer/configuration"
require "github_heroku_deployer/deployer"

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
    #     config.id_rsa          = ENV["ID_RSA"]
    #     config.logger          = Logger.new(STDOUT)
    #     config.repo_dir        = ENV["REPO_DIR"]
    #   end
    def configure
      yield(configuration)
    end

    def options(custom_options)
      custom_options = configuration.merge(custom_options)
      configuration.validate_presence(custom_options)
      custom_options
    end

    def new(custom_options={})
      Deployer.new(custom_options)
    end
  end # class << self
end
