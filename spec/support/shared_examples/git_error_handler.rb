# Prerequisites:
# * set up any method stubs on the git repo to raise error, e.g.
#     before { allow(git_repo).to receive(:pull).and raise_error(error) }
# * define a method named retry_git_command to set up retry expectations, e.g.
#     let(:retry_git_command) do
#       expect(git_repo).to have_received(:pull).exactly(retry_limit).times
#     end
shared_examples_for 'a git error handler' do
  let(:safe_subject) { subject rescue error }

  context 'with Git::GitExecuteError' do
    let(:error) { Git::GitExecuteError.new('some git error') }

    let(:retry_limit) { 3 }

    it 'retries 3 times' do
      safe_subject
      retry_git_command
    end

    it 'logs the error' do
      expect(logger).to receive(:error)
      safe_subject
    end

    it 'raises a GithubBitbucketDeployer::CommandException' do
      expect { subject }
        .to raise_error(GithubBitbucketDeployer::CommandException)
    end
  end

  context 'with any other type of error' do
    let(:error) { ArgumentError.new('some non-git error') }

    let(:retry_limit) { 1 }

    it 'only tries once' do
      safe_subject
      retry_git_command
    end

    it 'raises the original exception' do
      expect { subject }.to raise_error(error)
    end
  end
end
