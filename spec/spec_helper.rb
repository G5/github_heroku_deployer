require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'rspec'
require 'pp' # See https://github.com/fakefs/fakefs/issues/99
require 'pry-byebug'
require 'fakefs/spec_helpers'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }

ENV['ID_RSA']="id_rsa"
ENV['REPO_DIR']="foo"

require 'github_bitbucket_deployer'

RSpec.configure do |config|
  config.order = "random"
end
