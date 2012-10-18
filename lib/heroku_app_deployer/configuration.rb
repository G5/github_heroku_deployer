module HerokuAppDeployer
  class Configuration
    OPTIONS = [
      :heroku_username,
      :heroku_api_key,
      :github_repo,
      :heroku_repo,
    ]

    OPTIONS.each do |option|
      attr_accessor option
    end

    def initialize
    end

    # Allows config options to be read like a hash
    #
    # @param [Symbol] option Key for a given attribute
    def [](option)
      send(option)
    end

    # Returns a hash of all configurable options
    def to_hash
      OPTIONS.inject({}) do |hash, option|
        hash[option.to_sym] = self.send(option)
        hash
      end
    end

    # Returns a hash of all configurable options merged with +hash+
    #
    # @param [Hash] hash A set of configuration options that will take 
    # precedence over the defaults
    def merge(hash)
      to_hash.merge(hash)
    end
  end
end
