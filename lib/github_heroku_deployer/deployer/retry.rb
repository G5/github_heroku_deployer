require "github_heroku_deployer"

module GithubHerokuDeployer
  class Deployer
    class Retry
      attr_reader :retry_count

      def initialize(options={})
        @options = GithubHerokuDeployer.options(options)
        @logger = options[:logger]
      end

      def run(message, exceptions, retry_limit, &block)
        reset_retry_count
        run_with_retry(message, exceptions, retry_limit, &block)
      end

      private

      def run_with_retry(message, exceptions, retry_limit, &block)
        @logger.info "#{message}..."
        block.call
      rescue matching_exceptions(exceptions) => e
        if should_retry?(retry_limit)
          @logger.info "Retry: #{message}..."
          increment_retry_count
          retry
        else
          @logger.warn "Failure: #{message}"
          reset_retry_count
          raise e
        end
      end

      def matching_exceptions(exceptions)
        lambda do |exception|
          exceptions.each do |allowed_exception|
            return true if exception.instance_of? allowed_exception
          end
        end
      end

      def reset_retry_count
        @retry_count = 0
      end

      def should_retry?(retry_limit)
        @retry_count < retry_limit
      end

      def increment_retry_count
        @retry_count += 1
      end
    end
  end
end
