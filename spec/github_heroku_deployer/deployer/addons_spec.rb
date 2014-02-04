require "spec_helper"
require "github_heroku_deployer/deployer/addons"

describe GithubHerokuDeployer::Deployer::Addons do
  it { should respond_to :new }
  it { should respond_to :add }

  describe ".new" do
    subject { GithubHerokuDeployer::Deployer::Addons.new }

    it "returns a GithubHerokuDeployer::Deployer::Addons object" do
      expect(subject).to be_a_kind_of GithubHerokuDeployer::Deployer::Addons
    end
  end

  describe ".add" do
    subject { GithubHerokuDeployer::Deployer::Addons.new }

    it "does things"
  end
end
