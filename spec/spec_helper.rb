require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'rspec'
require 'pp' # See https://github.com/fakefs/fakefs/issues/99
require 'fakefs/spec_helpers'

RSpec.configure do |config|
  config.order = "random"

  config.include FakeFS::SpecHelpers, fakefs: true
end

ENV['ID_RSA']="id_rsa"
ENV['REPO_DIR']="foo"

