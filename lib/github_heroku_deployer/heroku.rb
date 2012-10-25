require "heroku-api"

module GithubHerokuDeployer
  class Heroku

    def initialize(options)
      @heroku_api_key = options[:heroku_api_key]
      @heroku_app_name = options[:heroku_app_name]
    end

    def heroku
      @heroku ||= ::Heroku::API.new(api_key: @heroku_api_key)
    end

    def app
      @app ||= find_or_create_app
    end

    def find_or_create_app
      find_app || create_app
    end

    def find_app
      heroku.get_app(@heroku_app_name)
    end

    def create_app
      heroku.post_app(name: @heroku_app_name)
    end

    # def delete_app
    #   heroku.delete_app(@heroku_app_name)
    # end

    # def add_deployhooks_http(url)
    #   add_addon("deployhooks:http", url: url)
    # end

    # def add_addon(addon, options={})
    #   heroku.post_addon(@heroku_app_name, addon, options)
    # end

    # def delete_addon(addon)
    #   heroku.delete_addon(@heroku_app_name, addon)
    # end

    # def migrate
    #   heroku.post_ps(@heroku_app_name, "rake db:migrate")
    # end
  end
end
