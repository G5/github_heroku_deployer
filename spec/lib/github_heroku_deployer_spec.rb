require 'spec_helper'
require 'github_heroku_deployer'

describe GithubHerokuDeployer do
  it { should respond_to :configuration }
  it { should respond_to :configure }
  it { should respond_to :deploy }
  it { should respond_to :create }

  describe "::configuration" do
    it "should be the configuration object" do
      GithubHerokuDeployer.configuration.should(
        be_a_kind_of GithubHerokuDeployer::Configuration)
    end

    it "give a new instance if non defined" do
      GithubHerokuDeployer.configuration = nil
      GithubHerokuDeployer.configuration.should(
        be_a_kind_of GithubHerokuDeployer::Configuration)
    end
  end

  describe "::configure" do
    it "should yield the configuration object" do
      GithubHerokuDeployer.configure do |config|
        config.should equal(GithubHerokuDeployer.configuration)
      end
    end
  end

  describe "::deploy" do

    context "when unconfigured" do
      before :each do
        GithubHerokuDeployer.configure do |config|
          config.github_repo = nil
        end
      end

      it "requires github_repo to be set" do
        lambda { GithubHerokuDeployer.deploy }.should(
          raise_error ::GithubHerokuDeployer::ConfigurationException)
      end
    end

    # TODO: how can I test these better?
    context "when configured" do
      before :each do
        @deployer = mock("github_heroku_deployer")
        @deployer.stub!(:deploy).and_return(true)
      end

      context "when repo does not exist locally" do
        it "deploys public repos" do
          public_repo = ENV["PUBLIC_GITHUB_REPO"]
          public_repo_folder = Zlib.crc32(public_repo).to_s
          repos_dir = GithubHerokuDeployer.configuration[:repo_dir]
          full_path = File.join(repos_dir, public_repo_folder)
          FileUtils.rm_r(full_path) if File.exists?(full_path)
          GithubHerokuDeployer.configure do |config|
            config.github_repo = public_repo
          end
          # GithubHerokuDeployer.deploy.should be true
          @deployer.deploy.should be true
        end

        it "deploys private repos" do
          private_repo = ENV["PRIVATE_GITHUB_REPO"]
          private_repo_folder = Zlib.crc32(private_repo).to_s
          repos_dir = GithubHerokuDeployer.configuration[:repo_dir]
          full_path = File.join(repos_dir, private_repo_folder)
          FileUtils.rm_r(full_path) if File.exists?(full_path)
          GithubHerokuDeployer.configure do |config|
            config.github_repo = private_repo
          end
          # GithubHerokuDeployer.deploy.should be true
          @deployer.deploy.should be true
        end
      end

      context "when repo exists locally" do
        it "deploys public repos" do
          GithubHerokuDeployer.configure do |config|
            config.github_repo = ENV["PUBLIC_GITHUB_REPO"]
          end
          # GithubHerokuDeployer.deploy.should be true
          @deployer.deploy.should be true
        end

        it "deploys private repos" do
          GithubHerokuDeployer.configure do |config|
            config.github_repo = ENV["PRIVATE_GITHUB_REPO"]
          end
          # GithubHerokuDeployer.deploy.should be true
          @deployer.deploy.should be true
        end
      end

      it "overrides defaults" do
        GithubHerokuDeployer.configure do |config|
          config.github_repo = ""
        end

        override = ENV["PUBLIC_GITHUB_REPO"]
        override.should_not equal GithubHerokuDeployer.configuration[:github_repo]
        @deployer.deploy(github_repo: override).should be true
      end

      context "passing an organization" do
        before do
          GithubHerokuDeployer::Heroku.any_instance.stub(:new)
          GithubHerokuDeployer::Git.any_instance.stub(:push_app_to_heroku)
        end
        it "accepts organization option" do
          GithubHerokuDeployer.deploy({organization: "test-org"})
        end
      end
    end
  end

  describe "::create" do
    context "when unconfigured" do
      before :each do
        GithubHerokuDeployer.configure do |config|
          config.github_repo = nil
        end
      end

      it "requires github_repo to be set" do
        lambda { GithubHerokuDeployer.create }.should(
          raise_error ::GithubHerokuDeployer::ConfigurationException)
      end
    end

    context "when configured" do
      context "passing an organization" do
        before do
          GithubHerokuDeployer::Heroku.any_instance.stub(:new)
        end
        it "accepts organization option" do
          GithubHerokuDeployer.should_receive(:heroku_find_or_create_app).with(hash_including(organization: "test-org"))
          GithubHerokuDeployer.create({organization: "test-org", github_repo:"foo"})
        end
      end
    end
  end

  describe "::deploy_and_create" do
    subject { GithubHerokuDeployer.create_and_deploy }
    it "both creates and deploys" do
      GithubHerokuDeployer.should_receive(:create).exactly(1).times
      GithubHerokuDeployer.should_receive(:deploy).exactly(1).times
      subject
    end
  end
end

