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
    # @see HerokuAppDeployer.configure
    def configuration
      @configuration ||= Configuration.new
    end

    # Call this method to modify defaults in your initializers.
    #
    # @example
    #   HerokuAppDeployer.configure do |config|
    #     config.user_agent = "HerokuAppDeployer"
    #   end
    def configure
      yield(configuration)
    end
  end

end
