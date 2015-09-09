require "git"
require "git-ssh-wrapper"

module GithubBitbucketDeployer
  class Git

    def initialize(options)
      @bitbucket_repo_url = options[:bitbucket_repo_url]
      @bitbucket_repo_name = options[:bitbucket_repo_name]
      @id_rsa = options[:id_rsa]
      @logger = options[:logger]
      @repo_dir = options[:repo_dir]
    end

    def push_app_to_bitbucket(remote="bitbucket", branch="master", &block)
      wrapper = ssh_wrapper
      run "cd #{repo.dir}; git remote rm #{remote}" if repo.remote(remote).url
      repo.add_remote(remote, @bitbucket_repo_url)
      yield(repo) if block_given?
      @logger.info "deploying #{repo.dir} to #{repo.remote(remote).url} from branch #{branch}"
      run "cd #{repo.dir}; env #{wrapper.git_ssh} git push -f #{remote} #{branch}"
    ensure
      wrapper.unlink
    end

    def repo
      @repo ||= setup_repo
    end

    def setup_repo
      clone_or_pull
      open
    end

    def folder
      @folder ||= setup_folder
    end

    def setup_folder
      folder = File.join(@repo_dir, Zlib.crc32(@bitbucket_repo_name).to_s)
      FileUtils.mkdir_p(folder)
      folder
    end

    def clone_or_pull
      !exists_locally? ? clone : pull
    end

    def exists_locally?
      File.exists?(File.join(folder, ".git", "config"))
    end

    def clone
      wrapper = ssh_wrapper
      @logger.info "cloning #{@bitbucket_repo_url} to #{folder}"
      run "env #{wrapper.git_ssh} git clone #{@bitbucket_repo_url} #{folder}"
    ensure
      wrapper.unlink
    end

    def pull
      wrapper = ssh_wrapper
      dir = Dir.pwd # need to cd back to here
      @logger.info "pulling from #{folder}"
      run "cd #{folder}; env #{wrapper.git_ssh} git pull; cd #{dir}"
    ensure
      wrapper.unlink
    end

    def open
      ::Git.open(folder)
    end

    def ssh_wrapper
      GitSSHWrapper.new(private_key_path: id_rsa_path)
    end

    def id_rsa_path
      file = Tempfile.new("id_rsa")
      file.write(@id_rsa)
      file.rewind
      file.path
    end

    def run(command)
      result = `#{command} 2>&1`
      status = $?.exitstatus
      if status == 0
        @logger.info result
      else
        raise GithubBitbucketDeployer::CommandException, result
      end
    end
  end
end
