require 'spec_helper'
require 'github_bitbucket_deployer'

describe GithubBitbucketDeployer do
  it { is_expected.to respond_to(:configuration) }
  it { is_expected.to respond_to(:configure) }
  it { is_expected.to respond_to(:deploy) }

  describe ".configuration" do
    subject(:config) { GithubBitbucketDeployer.configuration }

    it "should be the configuration object" do
      expect(config).to be_a_kind_of(GithubBitbucketDeployer::Configuration)
    end

    it "give a new instance if non defined" do
      GithubBitbucketDeployer.configuration = nil
      expect(config).to be_a_kind_of(GithubBitbucketDeployer::Configuration)
    end
  end

  describe ".configure" do
    it "should yield the configuration object" do
      GithubBitbucketDeployer.configure do |config|
        expect(config).to equal(GithubBitbucketDeployer.configuration)
      end
    end
  end

  describe "::deploy" do
    subject(:deploy) { GithubBitbucketDeployer.deploy }

    context "when unconfigured" do
      before :each do
        GithubBitbucketDeployer.configure do |config|
          config.id_rsa = nil
        end
      end

      it "requires github_repo to be set" do
        expect { deploy }.to raise_error(GithubBitbucketDeployer::ConfigurationException)
      end
    end

    # TODO: how can I test these better?
    context "when configured" do
      before :each do
        @deployer = double("github_bitbucket_deployer")
        allow(@deployer).to receive(:deploy).and_return(true)
      end

      it "overrides defaults" do
        GithubBitbucketDeployer.configure do |config|
          config.id_rsa = ""
        end

        override = 'override-value'
        expect(@deployer.deploy(id_rsa: override)).to be true
      end

    end
  end
end

