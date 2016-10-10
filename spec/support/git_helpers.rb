module GitHelpers
  def create_local_repo(repo_name, working_dir)
    git_dir = "#{working_dir}/.git"
    FileUtils.mkdir_p(git_dir)

    Dir.chdir(git_dir) do
      File.open('config', 'w') do |file|
        file.puts("[core]")
        file.puts("\trepositoryformatversion = 0")
        file.puts("\tfilemode = true")
        file.puts("\tbare = false")
        file.puts("\tlogallrefupdates = true")
        file.puts("\tignorecase = true")
        file.puts("\tprecomposeunicode = true")
      end

      ['objects/info', 'objects/pack',
       'refs/heads', 'refs/tags'].each { |dir| FileUtils.mkdir_p(dir) }

      File.open('HEAD', 'w') do |file|
        file.puts('ref: refs/heads/master')
      end
    end
  end

  def add_git_remote(remote, working_dir)
    File.open("#{working_dir}/.git/config", 'a') do |file|
      file.puts("[remote \"#{remote}\"]")
      file.puts("\turl = git@#{remote}.com:whatever/foo.git")
      file.puts("\tfetch = +refs/heads/*:refs/remotes/#{remote}/*")
    end
  end
end
