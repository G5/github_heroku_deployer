require "github_heroku_deployer"
require "github_heroku_deployer/deployer/provision"
require "github_heroku_deployer/deployer/config"
require "github_heroku_deployer/deployer/addons"
require "github_heroku_deployer/deployer/push"
require "github_heroku_deployer/deployer/tasks"

module GithubHerokuDeployer
  class Deployer
    def initialize(options={})
      @options = GithubHerokuDeployer.options(options)
    end

    def provision
      Provision.new(@options).run
    end

    def set_config(config)
      Config.new(@options).set(config)
    end

    def add_addons(addons)
      Addons.new(@options).add(addons)
    end

    def push(&block)
      Push.new(@options).run(&block)
    end

    def run_tasks(tasks)
      Tasks.new(@options).run(tasks)
    end
  end
end
