require 'spec_helper'
require 'github_bitbucket_deployer'

describe GithubBitbucketDeployer do
  it { should respond_to :configuration }
  it { should respond_to :configure }
  it { should respond_to :deploy }

  describe "::configuration" do
    it "should be the configuration object" do
      GithubBitbucketDeployer.configuration.should(
        be_a_kind_of GithubBitbucketDeployer::Configuration)
    end

    it "give a new instance if non defined" do
      GithubBitbucketDeployer.configuration = nil
      GithubBitbucketDeployer.configuration.should(
        be_a_kind_of GithubBitbucketDeployer::Configuration)
    end
  end

  describe "::configure" do
    it "should yield the configuration object" do
      GithubBitbucketDeployer.configure do |config|
        config.should equal(GithubBitbucketDeployer.configuration)
      end
    end
  end

  describe "::deploy" do

    context "when unconfigured" do
      before :each do
        GithubBitbucketDeployer.configure do |config|
          config.id_rsa = nil
        end
      end

      it "requires github_repo to be set" do
        lambda { GithubBitbucketDeployer.deploy }.should(
          raise_error ::GithubBitbucketDeployer::ConfigurationException)
      end
    end

    # TODO: how can I test these better?
    context "when configured" do
      before :each do
        @deployer = mock("github_bitbucket_deployer")
        @deployer.stub!(:deploy).and_return(true)
      end

      it "overrides defaults" do
        GithubBitbucketDeployer.configure do |config|
          config.id_rsa = ""
        end

        override = ENV["ID_RSA"]
        override.should_not equal GithubBitbucketDeployer.configuration[:id_rsa]
        @deployer.deploy(id_rsa: override).should be true
      end

    end
  end
end

