require "spec_helper"
require "github_heroku_deployer/deployer"

describe GithubHerokuDeployer::Deployer do
  it { should respond_to :new }

  describe ".new" do
    subject { GithubHerokuDeployer::Deployer.new }

    it "returns a GithubHerokuDeployer::Deployer object" do
      expect(subject).to be_a_kind_of GithubHerokuDeployer::Deployer
    end
  end
end
