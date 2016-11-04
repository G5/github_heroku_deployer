module GitHelpers
  def create_local_repo(working_dir)
    git_dir = "#{working_dir}/.git"
    FileUtils.mkdir_p(git_dir)
    Dir.chdir(git_dir) { FileUtils.touch('config') }
  end
end
