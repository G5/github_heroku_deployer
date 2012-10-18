require 'github_heroku_deployer/configuration'

describe GithubHerokuDeployer::Configuration do
  it { should respond_to :"[]" }
  it { should respond_to :to_hash }
  it { should respond_to :merge }

  it "provides default values" do
    assert_config_default :github_repo, ENV["GITHUB_REPO"]
  end

  it "allows values to be overwritten" do
    assert_config_overridable :github_repo
  end

  it "acts like a hash" do
    config = GithubHerokuDeployer::Configuration.new
    hash = config.to_hash
    GithubHerokuDeployer::Configuration::OPTIONS.each do |option|
      config[option].should eq(hash[option])
    end
  end

  it "is mergable" do
    config = GithubHerokuDeployer::Configuration.new
    hash = config.to_hash
    config.merge(:key => 'value').should eq(hash.merge(:key => 'value'))
  end

  it "gives a new instance if non defined" do
    GithubHerokuDeployer.configuration = nil
    GithubHerokuDeployer.configuration.should be_a_kind_of(GithubHerokuDeployer::Configuration)
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
