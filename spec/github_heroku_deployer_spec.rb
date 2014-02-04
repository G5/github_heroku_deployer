require "spec_helper"
require "github_heroku_deployer"

describe GithubHerokuDeployer do
  it { should respond_to :configuration }
  it { should respond_to :configure }
  it { should respond_to :options }
  it { should respond_to :new }

  describe ".configuration" do
    subject { GithubHerokuDeployer.configuration }

    it "returns the configuration object" do
      expect(subject).to be_a_kind_of GithubHerokuDeployer::Configuration
    end

    it "returns a new instance if nil" do
      GithubHerokuDeployer.configuration = nil
      expect(subject).to be_a_kind_of GithubHerokuDeployer::Configuration
    end
  end

  describe ".configure" do
    it "yields the configuration object" do
      GithubHerokuDeployer.configure do |config|
        expect(config).to equal GithubHerokuDeployer.configuration
      end
    end
  end

  describe ".options" do
    it "merges custom options with configuration"
    it "validates custom options"
  end

  describe ".new" do
    subject { GithubHerokuDeployer.new }

    it "returns a deployer object" do
      expect(subject).to be_a_kind_of GithubHerokuDeployer::Deployer
    end
  end
end
