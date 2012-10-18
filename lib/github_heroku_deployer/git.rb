require "git"
require "git-ssh-wrapper"

module GithubHerokuDeployer
  class Git

    def initialize(configuration)
      @heroku_repo = configuration["heroku_repo"]
      @github_repo = configuration["github_repo"]
    end

    def push_app_to_heroku
      repo = open_or_setup
      wrapped_push(repo)
    end

    def open_or_setup
      local_folder = "repos/#{Zlib.crc32(@github_repo)}"

      repo = begin
        ::Git.open(local_folder).tap do |g|
          g.fetch
          g.remote("origin").merge
        end
      rescue ArgumentError => e
        `rm -r #{local_folder}`
        wrapped_clone(local_folder)
        retry
      end
      repo.add_remote("heroku", @heroku_repo) unless repo.remote("heroku").url
      repo
    end

    def wrapped_clone(local_folder)
      wrapper = GitSSHWrapper.new(private_key_path: "~/.ssh/id_rsa")
      `env #{wrapper.git_ssh} git clone #{@github_repo} #{local_folder}`
    ensure
      wrapper.unlink
    end

    def wrapped_push(repo, remote="heroku", branch="master")
      wrapper = GitSSHWrapper.new(private_key_path: "~/.ssh/id_rsa")
      `cd #{repo.dir}; env #{wrapper.git_ssh} git push -f #{remote} #{branch}`
    ensure
      wrapper.unlink
    end

    def local_state
      repo = open_or_setup(@github_repo)
      repo.object("HEAD")
    end

  end
end
