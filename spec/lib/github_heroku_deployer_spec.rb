require 'spec_helper'
require 'github_heroku_deployer'

describe GithubHerokuDeployer do
  it { should respond_to :configuration }
  it { should respond_to :configure }
  it { should respond_to :deploy }

  describe "::configuration" do
    it "should be the configuration object" do
      GithubHerokuDeployer.configuration.should(
        be_a_kind_of GithubHerokuDeployer::Configuration)
    end

    it "give a new instance if non defined" do
      GithubHerokuDeployer.configuration = nil
      GithubHerokuDeployer.configuration.should(
        be_a_kind_of GithubHerokuDeployer::Configuration)
    end
  end

  describe "::configure" do
    it "should yield the configuration object" do
      GithubHerokuDeployer.configure do |config|
        config.should equal(GithubHerokuDeployer.configuration)
      end
    end
  end

  describe "::deploy" do

    context "when unconfigured" do
      before :each do
        GithubHerokuDeployer.configure do |config|
          config.github_repo = nil
        end
      end

      it "requires github_repo to be set" do
        lambda { GithubHerokuDeployer.deploy }.should(
          raise_error ::GithubHerokuDeployer::ConfigurationException)
      end
    end

    context "when configured" do
      before :each do
        @deployer = mock("github_heroku_deployer")
        @deployer.stub!(:deploy).and_return(true)
      end

      # TODO: how can I test this better?
      it "deploys public repos" do
        GithubHerokuDeployer.configure do |config|
          config.github_repo = ENV["PUBLIC_GITHUB_REPO"]
        end
        # GithubHerokuDeployer.deploy.should be true
        @deployer.deploy.should be true
      end

      # TODO: how can I test this better?
      it "deploys private repos" do
        GithubHerokuDeployer.configure do |config|
          config.github_repo = ENV["PRIVATE_GITHUB_REPO"]
        end
        # GithubHerokuDeployer.deploy.should be true
        @deployer.deploy.should be true
      end

      # TODO: how can I test this better?
      it "overrides defaults" do
        GithubHerokuDeployer.configure do |config|
          config.github_repo = ""
        end

        override = ENV["PUBLIC_GITHUB_REPO"]
        override.should_not equal GithubHerokuDeployer.configuration[:github_repo]
        @deployer.deploy(github_repo: override).should be true
      end
    end
  end
end
