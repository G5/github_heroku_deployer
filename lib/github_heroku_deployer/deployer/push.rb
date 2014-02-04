require "github_heroku_deployer"
require "github_heroku_deployer/git_wrapper"

module GithubHerokuDeployer
  class Deployer
    class Push
      RETRY_EXCEPTIONS = [::GithubHerokuDeployer::CommandException]

      def initialize(options={})
        @options = GithubHerokuDeployer.options(options)
        @heroku_app_name = @options[:heroku_app_name]
      end

      def run(&block)
        Retry.new.run(log_message, RETRY_EXCEPTIONS, @options) do
          GitWrapper.new(@options).deploy_to_heroku(&block)
        end
      end

      private

      def log_message
        @log_message = "Pushing #{@heroku_app_name}"
      end
    end
  end
end
