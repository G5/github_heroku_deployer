require 'git'
require 'git-ssh-wrapper'
require 'retriable'
require 'github_bitbucket_deployer/clone_logger_fix'

module GithubBitbucketDeployer
  class Git
    attr_reader :bitbucket_repo_url, :git_repo_name, :id_rsa, :repo_dir, :logger, :force

    def initialize(options)
      @bitbucket_repo_url = options[:bitbucket_repo_url]
      @git_repo_name = options[:git_repo_name]
      @id_rsa = options[:id_rsa]
      @logger = options[:logger]
      @repo_dir = options[:repo_dir]
      @force = options[:force].nil? ? true : options[:force]
    end

    def push_app_to_bitbucket(remote = 'bitbucket', branch = 'master')
      logger.info('push_app_to_bitbucket')
      add_remote(remote)
      with_ssh { yield(repo) } if block_given?
      push(remote, branch)
    end

    def repo
      @repo ||= setup_repo
    end

    def folder
      @folder ||= setup_folder
    end

    def clone
      logger.info("git clone: cloning #{bitbucket_repo_url} to #{folder}")
      run { ::Git.clone(bitbucket_repo_url, folder, log: logger) }
    end

    def pull
      logger.info("git pull: pulling from #{folder}")
      run { open.pull }
      open
    end

    def open
      logger.info('git open')
      ::Git.open(folder, log: logger)
    end

    def push(remote, branch)
      logger.info("git push: deploying #{repo.dir} to " \
                  "#{repo.remote(remote).url} from branch #{branch}")
      run { repo.push(remote, branch, force: force) }
    end

    def add_remote(remote = 'bitbucket')
      logger.info("git add_remote: #{remote}")
      repo.remote(remote).remove if repo.remote(remote).url
      repo.add_remote(remote, bitbucket_repo_url)
    end

    private

    def setup_folder
      logger.info('setup_folder')
      folder = File.join(repo_dir, Zlib.crc32(git_repo_name).to_s)
      FileUtils.mkdir_p(folder).first
    end

    def setup_repo
      logger.info('setup_repo')
      update_working_copy
      open
    end

    def update_working_copy
      logger.info('update_working_copy')
      exists_locally? ? pull : clone
    end

    def exists_locally?
      git_config = File.join(folder, '.git', 'config')
      File.exist?(git_config)
    end

    def run
      Retriable.retriable(on: ::Git::GitExecuteError, tries: 3) do
        with_ssh { yield }
      end
    rescue ::Git::GitExecuteError => error
      logger.error(error)
      raise GithubBitbucketDeployer::CommandException, error
    end

    def with_ssh
      @old_git_ssh = ENV['GIT_SSH']

      GitSSHWrapper.with_wrapper(private_key: id_rsa) do |wrapper|
        wrapper.set_env
        yield if block_given?
      end
    ensure
      ENV['GIT_SSH'] = @old_git_ssh
    end
  end
end
