require "spec_helper"
require "github_heroku_deployer/heroku_client"

describe GithubHerokuDeployer::HerokuClient do
  it { should respond_to :new }

  describe ".new" do
    subject { GithubHerokuDeployer::HerokuClient.new }

    it "returns a Heroku::API object" do
      expect(subject).to be_a_kind_of ::Heroku::API
    end
  end
end
