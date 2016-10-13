RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
  config.before(:each, fakefs: true) do
    source_dir = File.join(File.dirname(__FILE__), '..', '..')
    FakeFS::FileSystem.clone(source_dir)
    FakeFS::FileSystem.add(Dir.tmpdir)
    FakeFS::FileSystem.add('/tmp')
  end
end
