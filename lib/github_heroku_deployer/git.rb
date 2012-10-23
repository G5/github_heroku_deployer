require "git"
require "git-ssh-wrapper"

module GithubHerokuDeployer
  class Git

    def initialize(configuration)
      @ssh_enabled = configuration["ssh_enabled"]
      @heroku_repo = configuration["heroku_repo"]
      @github_repo = configuration["github_repo"]
    end

    def push_app_to_heroku
      ssh_push(repo)
    end

    def folder
      @folder ||= "repos/#{Zlib.crc32(@github_repo)}"
    end

    def repo
      @ssh_enabled ? private_repo : public_repo
    end

    def private_repo
      @private_repo ||= setup_private_repo
    end

    def setup_private_repo
      `rm -r #{folder}`
      ssh_clone(folder)
      ::Git.open(folder)
    end

    def public_repo
      @public_repo ||= setup_public_repo
    end

    def setup_public_repo
      ::Git.open(folder).tap do |g|
        g.fetch
        g.remote("origin").merge
      end
    end

    def ssh_clone(folder)
      wrapper = GitSSHWrapper.new(private_key_path: "~/.ssh/id_rsa")
      `env #{wrapper.git_ssh} git clone #{@github_repo} #{folder}`
    ensure
      wrapper.unlink
    end

    def ssh_push(repo, remote="heroku", branch="master")
      wrapper = GitSSHWrapper.new(private_key_path: "~/.ssh/id_rsa")
      repo.add_remote("heroku", @heroku_repo) unless repo.remote("heroku").url
      `cd #{repo.dir}; env #{wrapper.git_ssh} git push -f #{remote} #{branch}`
    ensure
      wrapper.unlink
    end
  end
end
