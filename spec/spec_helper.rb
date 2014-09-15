require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'rspec'
require 'rspec/autorun'

RSpec.configure do |config|
  config.order = "random"
end

ENV['GITHUB_REPO']="git@github.com:G5/static-sinatra-prototype.git"
ENV['HEROKU_API_KEY']="heroku_api_key"
ENV['HEROKU_APP_NAME']="static-sinatra-prototype"
ENV['HEROKU_REPO']="git@heroku.com:static-sinatra-prototype.git"
ENV['HEROKU_USERNAME']="heroku_username"
ENV['ID_RSA']="id_rsa"
ENV['PRIVATE_GITHUB_REPO']="git@github.com:g5search/g5-client-location.git"
ENV['PUBLIC_GITHUB_REPO']="git@github.com:G5/static-sinatra-prototype.git"
ENV['REPO_DIR']="foo"

