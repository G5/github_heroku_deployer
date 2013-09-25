require "github_heroku_deployer"
require "github_heroku_deployer/heroku_client"
require "github_heroku_deployer/deployer/retry"

module GithubHerokuDeployer
  class Deployer
    class Provision
      RETRY_EXCEPTIONS = [::Heroku::API::Errors::ErrorWithResponse]

      def initialize(options={})
        @options = GithubHerokuDeployer.options(options)
        @heroku_client = HerokuClient.new(@options)
        @heroku_app_name = @options[:heroku_app_name]
      end

      def run
        Retry.new.run(log_message, RETRY_EXCEPTIONS, @options) do
          @heroku_client.post_app(name: @heroku_app_name)
        end
      end

      private

      def log_message
        @log_message = "Provisioning #{@heroku_app_name}"
      end
    end
  end
end
