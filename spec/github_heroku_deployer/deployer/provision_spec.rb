require "spec_helper"
require "github_heroku_deployer/deployer/provision"

describe GithubHerokuDeployer::Deployer::Provision do
  it { should respond_to :new }
  it { should respond_to :run }

  describe ".new" do
    subject { GithubHerokuDeployer::Deployer::Provision.new }

    it "returns a GithubHerokuDeployer::Deployer::Provision object" do
      expect(subject).to be_a_kind_of GithubHerokuDeployer::Deployer::Provision
    end
  end

  describe ".run" do
    subject { GithubHerokuDeployer::Deployer::Provision.new }

    it "does things"
  end
end
