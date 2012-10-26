require "git"
require "git-ssh-wrapper"

module GithubHerokuDeployer
  class Git

    def initialize(options)
      @ssh_enabled = options[:ssh_enabled]
      @heroku_repo = options[:heroku_repo]
      @github_repo = options[:github_repo]
    end

    def push_app_to_heroku(remote="heroku", branch="master")
      wrapper = GitSSHWrapper.new(private_key_path: "~/.ssh/id_rsa")
      repo.add_remote("heroku", @heroku_repo) unless repo.remote("heroku").url
      `cd #{repo.dir}; env #{wrapper.git_ssh} git push -f #{remote} #{branch}`
    ensure
      wrapper.unlink
    end

    def repo
      @repo ||= setup_repo
    end

    def setup_repo
      # remove_folder
      clone_or_pull
      open_repo
    end

    # def remove_folder
    #   `rm -r #{folder}`
    # end

    def folder
      @folder ||= "repos/#{Zlib.crc32(@github_repo)}"
    end

    def clone_or_pull
      !exists_locally? ? clone : pull
    end

    def exists_locally?
      File.exists?(File.join(folder, ".git", "config"))
    end

    def clone
      wrapper = GitSSHWrapper.new(private_key_path: "~/.ssh/id_rsa")
      `env #{wrapper.git_ssh} git clone #{@github_repo} #{folder}`
    ensure
      wrapper.unlink
    end

    def pull
      wrapper = GitSSHWrapper.new(private_key_path: "~/.ssh/id_rsa")
      dir = Dir.pwd # need to cd back to here
      `cd #{folder}; env #{wrapper.git_ssh} git pull; cd #{dir}`
    ensure
      wrapper.unlink
    end

    def open_repo
      ::Git.open(folder)
    end
  end
end
