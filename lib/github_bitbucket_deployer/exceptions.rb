module GithubBitbucketDeployer
  class ConfigurationException < StandardError; end
  class CommandException < StandardError; end
  class GitRepoLockAlreadyHeldError < StandardError; end
end
