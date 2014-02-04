require "spec_helper"
require "github_heroku_deployer/deployer/tasks"

describe GithubHerokuDeployer::Deployer::Tasks do
  it { should respond_to :new }
  it { should respond_to :run }

  describe ".new" do
    subject { GithubHerokuDeployer::Deployer::Tasks.new }

    it "returns a GithubHerokuDeployer::Deployer::Tasks object" do
      expect(subject).to be_a_kind_of GithubHerokuDeployer::Deployer::Tasks
    end
  end

  describe ".run" do
    subject { GithubHerokuDeployer::Deployer::Tasks.new }

    it "does things"
  end
end
