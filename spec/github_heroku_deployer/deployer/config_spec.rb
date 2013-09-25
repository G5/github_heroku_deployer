require "spec_helper"
require "github_heroku_deployer/deployer/config"

describe GithubHerokuDeployer::Deployer::Config do
  it { should respond_to :new }
  it { should respond_to :set }

  describe ".new" do
    subject { GithubHerokuDeployer::Deployer::Config.new }

    it "returns a GithubHerokuDeployer::Deployer::Config object" do
      expect(subject).to be_a_kind_of GithubHerokuDeployer::Deployer::Config
    end
  end

  describe ".set" do
    subject { GithubHerokuDeployer::Deployer::Config.new }

    it "does things"
  end
end
