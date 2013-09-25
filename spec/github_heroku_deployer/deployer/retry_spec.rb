require "spec_helper"
require "github_heroku_deployer/deployer/retry"

describe GithubHerokuDeployer::Deployer::Retry do
  it { should respond_to :new }
  it { should respond_to :run }

  describe ".new" do
    subject { GithubHerokuDeployer::Deployer::Retry.new }

    it "returns a GithubHerokuDeployer::Deployer::Retry object" do
      expect(subject).to be_a_kind_of GithubHerokuDeployer::Deployer::Retry
    end
  end

  describe ".run" do
    subject { GithubHerokuDeployer::Deployer::Retry.new }

    it "does things"
  end
end
