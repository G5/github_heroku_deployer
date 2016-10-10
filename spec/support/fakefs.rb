RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
  config.before(:each, fakefs: true) do
    FakeFS::FileSystem.clone(File.join(File.dirname(__FILE__), '..', '..'))
    FakeFS::FileSystem.clone('/Users/maeverevels/.rvm/gems/ruby-2.3.0/gems/git-1.3.0/lib')
    FakeFS::FileSystem.clone('/Users/maeverevels/.rvm/gems/ruby-2.3.0/gems/fakefs-0.9.1/lib')
    FakeFS::FileSystem.add(Dir.tmpdir)
    FakeFS::FileSystem.add('/tmp')
  end
end
