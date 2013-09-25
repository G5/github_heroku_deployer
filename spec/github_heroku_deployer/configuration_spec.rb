require "spec_helper"
require "github_heroku_deployer"
require "github_heroku_deployer/configuration"

describe GithubHerokuDeployer::Configuration do
  it { should respond_to :"[]" }
  it { should respond_to :to_hash }
  it { should respond_to :merge }

  it "provides default values" do
    assert_config_default :github_repo, ENV["GITHUB_REPO"]
    assert_config_default :heroku_api_key, ENV["HEROKU_API_KEY"]
    assert_config_default :heroku_app_name, ENV["HEROKU_APP_NAME"]
    assert_config_default :id_rsa, ENV["ID_RSA"]
    assert_config_default :repo_dir, ENV["REPO_DIR"]
  end

  it "allows values to be overwritten" do
    assert_config_overridable :github_repo
    assert_config_overridable :heroku_api_key
    assert_config_overridable :heroku_app_name
    assert_config_overridable :id_rsa
    assert_config_overridable :repo_dir
  end

  it "acts like a hash" do
    config = GithubHerokuDeployer::Configuration.new
    hash = config.to_hash
    GithubHerokuDeployer::Configuration::OPTIONS.each_pair do |key, value|
      config[key].should eq(hash[key])
    end
  end

  it "is mergable" do
    config = GithubHerokuDeployer::Configuration.new
    hash = config.to_hash
    config.merge(:key => 'value').should eq(hash.merge(:key => 'value'))
  end

  def assert_config_default(option, default_value, config = nil)
    config ||= GithubHerokuDeployer::Configuration.new
    config.send(option).should eq(default_value)
  end

  def assert_config_overridable(option, value = 'a value')
    config = GithubHerokuDeployer::Configuration.new
    config.send(:"#{option}=", value)
    config.send(option).should eq(value)
  end
end
