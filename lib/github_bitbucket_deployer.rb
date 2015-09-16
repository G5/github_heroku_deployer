require "logger"
require "github_bitbucket_deployer/exceptions"
require "github_bitbucket_deployer/configuration"
require "github_bitbucket_deployer/git"
require "github_bitbucket_deployer/version"

module GithubBitbucketDeployer
  class << self
    # A GithubBitbucketDeployer configuration object. Must act like a hash and
    # return sensible values for all GithubBitbucketDeployer configuration options.
    #
    # @see GithubBitbucketDeployer::Configuration.
    attr_writer :configuration

    # The configuration object.
    #
    # @see GithubBitbucketDeployer.configure
    def configuration
      @configuration ||= Configuration.new
    end

    # Call this method to modify defaults in your initializers.
    #
    # @example
    #   GithubBitbucketDeployer.configure do |config|
    #     config.id_rsa          = ENV["ID_RSA"]
    #     config.logger          = Logger.new(STDOUT)
    #   end
    def configure
      yield(configuration)
    end

    def deploy(options={}, &block)
      options = configuration.merge(options)
      validate_options(options)
      git_push_app_to_bitbucket(options, &block)
      true
    end

    def validate_options(options)
      configuration.validate_presence(options)
    end

    def git_push_app_to_bitbucket(options, &block)
      repo = Git.new(options)
      repo.push_app_to_bitbucket(&block)
    end
  end # class << self
end
