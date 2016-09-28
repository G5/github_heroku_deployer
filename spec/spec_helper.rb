require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'rspec'
require 'pp' # See https://github.com/fakefs/fakefs/issues/99
require 'pry-byebug'
require 'fakefs/spec_helpers'

ENV['ID_RSA']="id_rsa"
ENV['REPO_DIR']="foo"

require 'github_bitbucket_deployer'

RSpec.configure do |config|
  config.order = "random"

  config.include FakeFS::SpecHelpers, fakefs: true
  config.before(:each, fakefs: true) do
    FakeFS::FileSystem.clone(File.join(File.dirname(__FILE__), '..'))
    FakeFS::FileSystem.add(Dir.tmpdir)
    FakeFS::FileSystem.add('/tmp')
  end
end
