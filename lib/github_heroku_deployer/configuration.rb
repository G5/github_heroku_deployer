module GithubHerokuDeployer
  class Configuration
    OPTIONS = {
      github_repo: ENV["GITHUB_REPO"],
      heroku_api_key: ENV["HEROKU_API_KEY"],
      heroku_app_name: ENV["HEROKU_APP_NAME"],
      heroku_repo: ENV["HEROKU_REPO"],
      heroku_username: ENV["HEROKU_USERNAME"],
      id_rsa: ENV["ID_RSA"],
      logger: ::Logger.new(STDOUT),
    }

    # Defines accessors for all OPTIONS
    OPTIONS.each_pair do |key, value|
      attr_accessor key
    end

    # Initializes defaults to be the environment varibales of the same names
    def initialize
      OPTIONS.each_pair do |key, value|
        self.send("#{key}=", value)
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
        key = option.first
        hash[key] = self.send(key)
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

    def validate_presence(options)
      OPTIONS.each_pair do |key, value|
        if options[key].nil?
          raise GithubHerokuDeployer::ConfigurationException, "#{key} is missing"
        end
      end
    end
  end
end
