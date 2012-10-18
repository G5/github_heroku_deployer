require "heroku_app_deployer/configuration"
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
      find_or_create_remote_app
      deploy_remote_app
      add_deployhooks_http
    end

    def heroku
      @heroku ||= Heroku::API.new(api_key: configuration["heroku_api_key"])
    end

    def find_or_create_remote_app
      find_app || create_remote_app
    end

    def find_app
      heroku.get_app(name)
    end

    def create_remote_app
      heroku.post_app(name: configuration["heroku_app_name"])
    end

    def deploy_remote_app
      Typhoeus::Request.get(
        configuration["deployer_url"],
        params: {
          heroku_repo: configuration["heroku_repo"]
          github_repo: configuration["github_repo"]
        })
    end

    # def delete_remote_app
    #   heroku.delete_app(configuration["heroku_app_name"])
    # end

    def add_deployhooks_http
      add_addon("deployhooks:http", url: configuration["deployhooks_http_url"])
    end

    def add_addon(addon, options={})
      heroku.post_addon(configuration["heroku_app_name"], addon, options)
    end

    # def delete_addon(addon)
    #   heroku.delete_addon(configuration["heroku_app_name"], addon)
    # end

    # def migrate
    #   heroku.post_ps(configuration["heroku_app_name"], "rake db:migrate")
    # end

  end # class << self
end
