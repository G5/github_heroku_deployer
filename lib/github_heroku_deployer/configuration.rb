module GithubHerokuDeployer
  class Configuration
    OPTIONS = [
      :github_repo,
      :heroku_api_key,
      :heroku_app_name,
      :heroku_repo,
      :heroku_username,
    ]

    # Defines accessors for all OPTIONS
    OPTIONS.each do |option|
      attr_accessor option
    end

    # Initializes defaults to be the environment varibales of the same names
    def initialize
      OPTIONS.each do |option|
        self.send("#{option}=", ENV[option.to_s.upcase])
      end
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

    def check_requirements
      OPTIONS.each do |option|
        if send(option).nil? || send(option).empty?
          raise GithubHerokuDeployer::ConfigurationException, "#{option} is missing"
        end
      end
    end
  end
end
