require 'spec_helper'
require 'github_bitbucket_deployer'
require 'github_bitbucket_deployer/configuration'

describe GithubBitbucketDeployer::Configuration do
  it { should respond_to :"[]" }
  it { should respond_to :to_hash }
  it { should respond_to :merge }

  it "provides default values" do
    assert_config_default :id_rsa, ENV["ID_RSA"]
  end

  it "allows values to be overwritten" do
    assert_config_overridable :id_rsa
  end

  it "acts like a hash" do
    config = GithubBitbucketDeployer::Configuration.new
    hash = config.to_hash
    GithubBitbucketDeployer::Configuration::OPTIONS.each_pair do |key, value|
      config[key].should eq(hash[key])
    end
  end

  it "is mergable" do
    config = GithubBitbucketDeployer::Configuration.new
    hash = config.to_hash
    config.merge(:key => 'value').should eq(hash.merge(:key => 'value'))
  end

  def assert_config_default(option, default_value, config = nil)
    config ||= GithubBitbucketDeployer::Configuration.new
    config.send(option).should eq(default_value)
  end

  def assert_config_overridable(option, value = 'a value')
    config = GithubBitbucketDeployer::Configuration.new
    config.send(:"#{option}=", value)
    config.send(option).should eq(value)
  end
end
