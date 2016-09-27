require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'rspec'
require 'fakefs/spec_helpers'

RSpec.configure do |config|
  config.order = "random"
end

ENV['ID_RSA']="id_rsa"
ENV['REPO_DIR']="foo"

