require 'spec_helper'

describe GithubBitbucketDeployer::Configuration do
  it { is_expected.to respond_to :"[]" }
  it { is_expected.to respond_to :to_hash }
  it { is_expected.to respond_to :merge }

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
      expect(config[key]).to eq(hash[key])
    end
  end

  it "is mergable" do
    config = GithubBitbucketDeployer::Configuration.new
    hash = config.to_hash
    expect(config.merge(:key => 'value')).to eq(hash.merge(:key => 'value'))
  end

  def assert_config_default(option, default_value, config = nil)
    config ||= GithubBitbucketDeployer::Configuration.new
    expect(config.send(option)).to eq(default_value)
  end

  def assert_config_overridable(option, value = 'a value')
    config = GithubBitbucketDeployer::Configuration.new
    config.send(:"#{option}=", value)
    expect(config.send(option)).to eq(value)
  end
end
