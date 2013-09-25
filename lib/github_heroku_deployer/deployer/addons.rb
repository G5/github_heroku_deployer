require "github_heroku_deployer"
require "github_heroku_deployer/heroku_client"
require "github_heroku_deployer/deployer/retry"

module GithubHerokuDeployer
  class Deployer
    class Addons
      RETRY_EXCEPTIONS = [::Heroku::API::Errors::ErrorWithResponse]

      def initialize(options={})
        @options = GithubHerokuDeployer.options(options)
        @heroku_client = HerokuClient.new(@options)
        @heroku_app_name = @options[:heroku_app_name]
      end

      def add(addons)
        addons.each { |addon| add_addon(addon) }
      end

      private

      def add_addon(addon)
        Retry.new.run(log_message(addon), RETRY_EXCEPTIONS, @options) do
          @heroku_client.post_addon(addon)
        end
      end

      def log_message(addon)
        @log_message = "Adding '#{addon}' addon to #{@heroku_app_name}"
      end
    end
  end
end
