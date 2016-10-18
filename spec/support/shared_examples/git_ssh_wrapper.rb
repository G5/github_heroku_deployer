# Prerequisites:
# Must define a method names run_git_command that yields control, e.g.
#   def run_git_command
#     expect(git_repo).to receive(:pull) { yield }
#   end
shared_examples_for 'a git ssh wrapper' do
  let(:temp_files) do
    Dir.glob("#{Dir.tmpdir}/git-ssh-wrapper*").sort_by { |f| File.mtime(f) }
  end

  it 'constructs a wrapper with the private key' do
    expect(GitSSHWrapper).to receive(:with_wrapper)
      .with(private_key: id_rsa).at_least(:once)
    subject
  end

  it 'writes the ssh wrapper to a tempfile' do
    run_git_command do
      expect(temp_files).to_not be_empty
    end
    subject
  end

  it 'sets the GIT_SSH env var during command execution' do
    run_git_command do
      expect(temp_files).to include(ENV['GIT_SSH'])
    end
    subject
  end

  context 'when command is successful' do
    it 'resets the GIT_SSH env var after exiting' do
      expect { subject }.to_not change { ENV['GIT_SSH'] }
    end

    it 'unlinks the temp ssh files' do
      subject
      expect(temp_files).to be_empty
    end
  end

  context 'when command raises an error' do
    let(:safe_subject) do
      run_git_command do
        raise GitExecuteError, 'some git error'
      end
      subject rescue 'whatever'
    end

    it 'resets the GIT_SSH env var after exiting' do
      expect { safe_subject }.to_not change { ENV['GIT_SSH'] }.from(nil)
    end

    it 'unlinks the temp ssh files' do
      safe_subject
      expect(temp_files).to be_empty
    end
  end
end
