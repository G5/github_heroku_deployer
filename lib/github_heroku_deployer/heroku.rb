require "heroku-api"
require "platform-api"

module GithubHerokuDeployer
  class Heroku

    def initialize(options)
      @heroku_api_key = options[:heroku_api_key]
      @heroku_app_name = options[:heroku_app_name]
      @heroku_organization_name = options[:heroku_organization_name]
      @logger = GithubHerokuDeployer.configuration.logger
    end

    def heroku
      @heroku ||= ::Heroku::API.new(api_key: @heroku_api_key)
    end


    def app
      @app ||= find_or_create_app
    end

    def find_or_create_app
      find_app
    rescue ::Heroku::API::Errors::NotFound
      create_app
    end

    def find_app
      heroku.get_app(@heroku_app_name)
    end

    def create_app
      @logger.info("Creating Heroku app with options: #{platform_api_options}")
      heroku_platform_api.organization_app.create(platform_api_options)
    end

    def restart_app
      heroku.post_ps_restart(@heroku_app_name)
    end

    def destroy_app
      heroku.delete_app(@heroku_app_name)
    end

    def run(command)
      heroku.post_ps(@heroku_app_name, command)
    end

    def config_set(config_vars)
      heroku.put_config_vars(@heroku_app_name, config_vars)
    end

    def addon_add(addon, addon_options={})
      heroku.post_addon(@heroku_app_name, addon, addon_options)
    end

    def addon_remove(addon)
      heroku.delete_addon(@heroku_app_name, addon)
    end

    def post_ps_scale(process, quantity)
      heroku.post_ps_scale(@heroku_app_name, process, quantity)
    end

    # def add_deployhooks_http(url)
    #   add_addon("deployhooks:http", url: url)
    # end

    private

    def platform_api_options
      options = {name: @heroku_app_name}
      unless @heroku_organization_name == "" || @heroku_organization_name == nil
        options.merge!(organization: @heroku_organization_name)
      end
      options
    end

    def heroku_platform_api
      @heroku_platform_api ||= ::PlatformAPI.connect_oauth(@heroku_api_key)
    end
  end
end

