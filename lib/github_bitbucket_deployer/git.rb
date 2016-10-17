require 'git'
require 'git-ssh-wrapper'
require 'retriable'
require 'github_bitbucket_deployer/clone_logger_fix'

module GithubBitbucketDeployer
  class Git
    attr_reader :bitbucket_repo_url, :git_repo_name, :id_rsa, :repo_dir

    def initialize(options)
      @bitbucket_repo_url = options[:bitbucket_repo_url]
      @git_repo_name = options[:git_repo_name]
      @id_rsa = options[:id_rsa]
      @logger = options[:logger]
      @repo_dir = options[:repo_dir]
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def push_app_to_bitbucket(remote = 'bitbucket', branch = 'master')
      logger.info('push_app_to_bitbucket')
      update_remote(remote)
      with_ssh do
        yield(repo) if block_given?
        push(remote, branch)
      end
    end

    def repo
      @repo ||= setup_repo
    end

    def folder
      @folder ||= setup_folder
    end

    def update_working_copy
      logger.info('update_working_copy')
      exists_locally? ? pull : clone
    end

    def exists_locally?
      git_config = File.join(folder, '.git', 'config')
      File.exist?(git_config)
    end

    def clone
      logger.info('git clone')
      with_ssh do
        logger.info("cloning #{bitbucket_repo_url} to #{folder}")
        run { ::Git.clone(bitbucket_repo_url, folder, log: logger) }
      end
    end

    def pull
      logger.info('git pull')
      local_repo = open

      with_ssh do
        logger.info("pulling from #{folder}")
        run { local_repo.pull }
      end

      local_repo
    end

    def open
      logger.info('git open')
      ::Git.open(folder, log: logger)
    end

    def push(remote, branch)
      logger.info("deploying #{repo.dir} to #{repo.remote(remote).url}" \
                  "from branch #{branch}")
      run { repo.push(remote, branch, force: true) }
    end

    def with_ssh
      GitSSHWrapper.with_wrapper(private_key: id_rsa) do |wrapper|
        wrapper.set_env
        yield if block_given?
      end
    end

    private

    def setup_folder
      logger.info('setup_folder')
      folder = File.join(@repo_dir, Zlib.crc32(@git_repo_name).to_s)
      FileUtils.mkdir_p(folder).first
    end

    def setup_repo
      logger.info('setup_repo')
      update_working_copy
      open
    end

    def update_remote(remote)
      logger.info('update_remote')
      repo.remote(remote).remove if repo.remote(remote).url
      repo.add_remote(remote, bitbucket_repo_url)
    end

    def run
      Retriable.retriable(on: ::Git::GitExecuteError, tries: 3) { yield }
    rescue ::Git::GitExecuteError => error
      logger.error(error)
      raise GithubBitbucketDeployer::CommandException, error
    end
  end
end
