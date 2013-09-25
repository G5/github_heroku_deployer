require "github_heroku_deployer"
require "github_heroku_deployer/heroku_client"
require "github_heroku_deployer/deployer/retry"

module GithubHerokuDeployer
  class Deployer
    class Tasks
      RETRY_EXCEPTIONS = [::Heroku::API::Errors::ErrorWithResponse]

      def initialize(options={})
        @options = GithubHerokuDeployer.options(options)
        @heroku_client = HerokuClient.new(@options)
        @heroku_app_name = @options[:heroku_app_name]
      end

      def run(tasks)
        tasks.each { |task| add_task(task) }
      end

      private

      def run_task(task)
        Retry.new.run(log_message(task), RETRY_EXCEPTIONS, @options) do
          @heroku_client.post_ps(task)
        end
      end

      def log_message(task)
        @log_message = "Running task '#{task}' on #{@heroku_app_name}"
      end
    end
  end
end
