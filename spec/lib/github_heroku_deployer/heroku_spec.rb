require 'spec_helper'
require 'github_heroku_deployer/heroku'
require 'platform-api'

describe GithubHerokuDeployer::Heroku do
  context "#find_or_create" do
    before do
      PlatformAPI.stub(:connect_oauth)
    end

    it "creates app if it does not find it" do
      heroku = GithubHerokuDeployer::Heroku.new(
        heroku_organization_name: "test-org",
        heroku_api_key: "asdfghjkl",
        heroku_app_name: "asdfghjkl")
      response = mock(body: 'error')
      heroku.stub("find_app").and_raise(::Excon::Errors::NotFound.new('',response))

      organization_app = double(:organization_app, create: "created")
      platform_api = double(:mock, :organization_app => organization_app)
      PlatformAPI.stub(:connect_oauth).and_return(platform_api)
      organization_app.should_receive(:create).with(hash_including(organization: "test-org"))

      heroku.find_or_create_app
    end
  end
end

