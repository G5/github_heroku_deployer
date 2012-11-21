require "logger"
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
    #     config.id_rsa          = ENV["ID_RSA"]
    #     config.logger          = Logger.new(STDOUT)
    #   end
    def configure
      yield(configuration)
    end

    def deploy(options={})
      options = configuration.merge(options)
      validate_options(options)
      heroku_find_or_create_app(options)
      git_push_app_to_heroku(options)
      true
    end

    def heroku_destroy(options={})
      options = configuration.merge(options)
      validate_options(options)
      Heroku.new(options).destroy_app
    end

    def heroku_run(command, options={})
      options = configuration.merge(options)
      validate_options(options)
      Heroku.new(options).run(command)
    end

    def heroku_config_set(values, options={})
      options = configuration.merge(options)
      validate_options(options)
      Heroku.new(options).config_set(values)
    end

    def validate_options(options)
      configuration.validate_presence(options)
    end

    def heroku_find_or_create_app(options)
      Heroku.new(options).find_or_create_app
    end

    def git_push_app_to_heroku(options)
      Git.new(options).push_app_to_heroku
    end
  end # class << self
end
