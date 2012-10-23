require 'spec_helper'
require 'github_heroku_deployer'

describe GithubHerokuDeployer do
  it { should respond_to :configuration }
  it { should respond_to :configure }
  it { should respond_to :deploy }
  
  describe "configuration" do
    it "should be the configuration object" do
      GithubHerokuDeployer.configuration.should(
        be_a_kind_of GithubHerokuDeployer::Configuration)
    end
  end

  describe "configure" do
    it "should yield the configuration object" do
      GithubHerokuDeployer.configure do |config|
        config.should equal(GithubHerokuDeployer.configuration)
      end
    end
  end

  describe "deploy" do

    context "unconfigured" do
      before :each do
        GithubHerokuDeployer.configure do |config|
          config.github_repo = nil
        end
      end

      it "should require github_repo to be set" do
        lambda { GithubHerokuDeployer.deploy }.should(
          raise_error ::GithubHerokuDeployer::ConfigurationException)
      end
    end

    context "configured" do
      before :each do
        GithubHerokuDeployer.configure do |config|
          config.ssh_enabled     = "false"
          config.github_repo     = ENV["GITHUB_REPO"]
          config.heroku_api_key  = ENV["HEROKU_API_KEY"]
          config.heroku_app_name = ENV["HEROKU_APP_NAME"]
          config.heroku_repo     = ENV["HEROKU_REPO"]
          config.heroku_username = ENV["HEROKU_USERNAME"]
        end
      end

      it "should deploy public repos" do
        GithubHerokuDeployer.configure do |config|
          config.github_repo = ENV["PUBLIC_GITHUB_REPO"]
        end
        GithubHerokuDeployer.deploy.should be true
      end

      it "should deploy private repos" do
        GithubHerokuDeployer.configure do |config|
          config.ssh_enabled = "true"
          config.github_repo = ENV["PRIVATE_GITHUB_REPO"]
        end
        GithubHerokuDeployer.deploy.should be true
      end
    end
  end
end
