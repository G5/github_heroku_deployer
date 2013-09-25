require "spec_helper"
require "github_heroku_deployer/deployer/push"

describe GithubHerokuDeployer::Deployer::Push do
  it { should respond_to :new }
  it { should respond_to :run }

  describe ".new" do
    subject { GithubHerokuDeployer::Deployer::Push.new }

    it "returns a GithubHerokuDeployer::Deployer::Push object" do
      expect(subject).to be_a_kind_of GithubHerokuDeployer::Deployer::Push
    end
  end

  describe ".run" do
    subject { GithubHerokuDeployer::Deployer::Push.new }

    it "does things"
  end
end
