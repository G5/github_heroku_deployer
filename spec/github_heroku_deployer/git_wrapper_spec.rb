require "spec_helper"
require "github_heroku_deployer/git_wrapper"

describe GithubHerokuDeployer::GitWrapper do
  describe "::new" do
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
    end
  end
end
