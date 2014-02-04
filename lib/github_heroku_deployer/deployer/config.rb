require "github_heroku_deployer"
require "github_heroku_deployer/heroku_client"
require "github_heroku_deployer/deployer/retry"

module GithubHerokuDeployer
  class Deployer
    class Config
      RETRY_EXCEPTIONS = [::Heroku::API::Errors::ErrorWithResponse]

      def initialize(options={})
        @options = GithubHerokuDeployer.options(options)
        @heroku_client = HerokuClient.new(@options)
        @heroku_app_name = @options[:heroku_app_name]
      end

      def set(config)
        Retry.new.run(log_message, RETRY_EXCEPTIONS, @options) do
          @heroku_client.put_config_vars(config)
        end
      end

      private

      def log_message
        @log_message = "Configuring #{@heroku_app_name}"
      end
    end
  end
end
