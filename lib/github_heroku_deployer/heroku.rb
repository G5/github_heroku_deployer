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
      #platform-api
      @heroku ||= ::PlatformAPI.connect_oauth(@heroku_api_key)
    end

    def app
      @app ||= find_or_create_app
    end

    def find_or_create_app
      find_app
    rescue ::Excon::Errors::NotFound
      create_app
    end

    def find_app
      #platform-api
      heroku.app.info(@heroku_app_name)
    end

    def create_app
      #platform-api
      @logger.info("Creating Heroku app with options: #{platform_api_options}")
      heroku_platform_api.organization_app.create(platform_api_options)
    end

    def set_buildpack(buildpack)
      #platform-api
      @logger.info("Setting buildpack on Heroku app: #{}")
      heroku.buildpack_installation.update(@heroku_app_name, buildpack)
    end

    def restart_app
      #platform-api
      heroku.dyno.restart_all(@heroku_app_name)
    end

    def destroy_app
      #platform-api
      heroku.app.delete(@heroku_app_name)
    end

    def run(command)
      #platform-api
      run_dyno = {attach: false,
                            command: command,
                            size: "Hobby",
                            type: "run",
                            time_to_live: 1800}
      heroku.dyno.create(@heroku_app_name, run_dyno)
    end

    def config_set(config_vars)
      #platform-api
      heroku.config_var.update(@heroku_app_name, config_vars)
    end

    def addon_add(addon, addon_options={})
      #platform-api
      heroku.addon.create(@heroku_app_name, {"plan" => {name: addon}, "config" => addon_options})
    end

    def addon_remove(addon)
      #platform-api
      heroku.addon.delete(@heroku_app_name, addon)
    end

    def post_ps_scale(process, quantity)
      #platform-api
      heroku.formation.update(@heroku_app_name, process, {"quantity" => quantity})
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

