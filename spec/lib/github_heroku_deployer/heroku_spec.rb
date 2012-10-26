require 'spec_helper'
require 'github_heroku_deployer/heroku'

describe GithubHerokuDeployer::Heroku do
  context "#find_or_create" do
    it "creates app if it does not find it" do
      heroku = GithubHerokuDeployer::Heroku.new(
        heroku_api_key: "asdfghjkl",
        heroku_app_name: "asdfghjkl")
      heroku.stub("find_app").and_raise(::Heroku::API::Errors::NotFound.new("", ""))
      heroku.stub("create_app").and_return true
      heroku.find_or_create_app.should be true
    end
  end
end
