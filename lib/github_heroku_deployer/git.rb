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
      repo.add_remote("heroku", @heroku_repo)
      `cd #{repo.dir}; env #{wrapper.git_ssh} git push -f #{remote} #{branch}`
    ensure
      wrapper.unlink
    end

    def repo
      @repo ||= setup_repo
    end

    def setup_repo
      remove_folder
      clone
      open_folder
    end

    def remove_folder
      `rm -r #{folder}`
    end

    def folder
      @folder ||= "repos/#{Zlib.crc32(@github_repo)}"
    end

    def clone
      wrapper = GitSSHWrapper.new(private_key_path: "~/.ssh/id_rsa")
      `env #{wrapper.git_ssh} git clone #{@github_repo} #{folder}`
    ensure
      wrapper.unlink
    end

    def open_folder
      ::Git.open(folder)
    end
  end
end
