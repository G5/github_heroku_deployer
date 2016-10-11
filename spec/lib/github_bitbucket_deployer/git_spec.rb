require 'spec_helper'

describe GithubBitbucketDeployer::Git do
  include GitHelpers

  let(:git) { described_class.new(options) }

  let(:options) do
    { bitbucket_repo_url: bitbucket_repo_url,
      git_repo_name: git_repo_name,
      id_rsa: id_rsa,
      logger: logger,
      repo_dir: repo_dir }
  end

  let(:bitbucket_repo_url) { 'git@bitbucket.org:g5dev/some_repo.git' }
  let(:git_repo_name) { 'some_repo' }
  let(:local_repo_folder) { Zlib.crc32(git_repo_name) }
  let(:id_rsa) { 'this is the value of my key' }
  let(:logger) { double('logger', info: true) }
  let(:repo_dir) { '/my_home/projects' }
  let(:working_dir) { "#{repo_dir}/#{local_repo_folder}" }

  before do
    allow(git).to receive(:run).with(a_kind_of(String)).and_return(true)
  end

  let(:git_repo) do
    instance_double(::Git::Base, remote: git_remote,
                                 dir: git_working_dir,
                                 add_remote: true)
  end
  let(:git_remote) do
    instance_double(::Git::Remote, url: bitbucket_repo_url)
  end
  let(:git_working_dir) do
    instance_double(::Git::WorkingDirectory, path: working_dir,
                                             to_s: working_dir)
  end

  before do
    allow(::Git).to receive(:open).and_return(git_repo)
    allow(::Git).to receive(:clone).and_return(git_repo)
  end

  describe '#initialize' do
    subject { git }

    context 'without options' do
      let(:options) { Hash.new }

      it 'has no bitbucket_repo_url' do
        expect(git.bitbucket_repo_url).to be_nil
      end

      it 'has no git_repo_name' do
        expect(git.git_repo_name).to be_nil
      end

      it 'has no id_rsa' do
        expect(git.id_rsa).to be_nil
      end

      it 'has no repo_dir' do
        expect(git.repo_dir).to be_nil
      end

      it 'has a default logger' do
        expect(git.logger).to be_an_instance_of(Logger)
      end
    end

    context 'with options' do
      it 'sets the bitbucket_repo_url' do
        expect(git.bitbucket_repo_url).to eq(bitbucket_repo_url)
      end

      it 'sets the git_repo_name' do
        expect(git.git_repo_name).to eq(git_repo_name)
      end

      it 'sets the id_rsa' do
        expect(git.id_rsa).to eq(id_rsa)
      end

      it 'sets the logger' do
        expect(git.logger).to eq(logger)
      end

      it 'sets the repo_dir' do
        expect(git.repo_dir).to eq(repo_dir)
      end
    end
  end

  describe '#push_app_to_bitbucket', :fakefs do
    subject { push_app }

    context 'with default arguments' do
      let(:push_app) { git.push_app_to_bitbucket }

      context 'when local repo already exists' do
        before { create_local_repo(git_repo_name, working_dir) }
        before { add_git_remote(unrelated_remote, working_dir) }
        let(:unrelated_remote) { 'heroku' }

        it 'pulls from the remote repo' do
          expect(git).to receive(:run).with(/git pull/)
          push_app
        end

        context 'when bitbucket remote exists' do
          before { add_git_remote(existing_remote, working_dir) }
          let(:existing_remote) { 'bitbucket' }

          it 'removes the existing remote' do
            expect(git).to receive(:run)
              .with(/cd #{working_dir}; git remote rm #{existing_remote}/)
            push_app
          end

          it 'does not remove the unrelated remote' do
            expect(git).to_not receive(:run)
              .with(/git remote rm #{unrelated_remote}/)
            push_app
          end

          it 'creates the bitbucket remote' do
            expect(git_repo).to receive(:add_remote)
              .with('bitbucket', bitbucket_repo_url)
            push_app
          end

          it 'force pushes master to bitbucket' do
            expect(git).to receive(:run).with(/git push -f bitbucket master/)
            push_app
          end
        end

        context 'when bitbucket remote does not exist' do
          let(:git_remote) { instance_double(Git::Remote, url: nil) }

          it 'does not remove any remotes' do
            expect(git).to_not receive(:run).with(/git remote rm/)
            push_app
          end

          it 'creates the bitbucket remote' do
            expect(git_repo).to receive(:add_remote)
              .with('bitbucket', bitbucket_repo_url)
            push_app
          end

          it 'force pushes master to bitbucket' do
            expect(git).to receive(:run).with(/git push -f bitbucket master/)
            push_app
          end
        end
      end

      context 'when local repo does not exist' do
        let(:git_remote) { instance_double(Git::Remote, url: nil) }

        it 'clones the bitbucket repo into the local folder' do
          expect(::Git).to receive(:clone)
            .with(bitbucket_repo_url, working_dir, log: logger)
            .and_return(git_repo)
          push_app
        end

        it 'creates the bitbucket remote' do
          expect(git_repo).to receive(:add_remote)
            .with('bitbucket', bitbucket_repo_url)
          push_app
        end

        it 'force pushes master to bitbucket' do
          expect(git).to receive(:run).with(/git push -f bitbucket master/)
          push_app
        end
      end
    end

    context 'with custom arguments' do
      let(:push_app) { git.push_app_to_bitbucket(remote, branch, &block) }

      let(:remote) { 'my_git_server' }
      let(:branch) { 'my_topic_branch' }
      let(:block) { ->(arg) { @block_arg = arg } }

      context 'when local git repo exists' do
        before { create_local_repo(git_repo_name, working_dir) }

        it 'pulls from the remote repo' do
          expect(git).to receive(:run).with(/git pull/)
          push_app
        end

        context 'when custom remote already exists' do
          before do
            allow(git_repo).to receive(:remote).with(remote).and_return(git_remote)
          end

          it 'removes the old remote' do
            expect(git).to receive(:run).with(/git remote rm #{remote}/)
            push_app
          end

          it 'creates the new remote' do
            expect(git_repo).to receive(:add_remote).with(remote, bitbucket_repo_url)
            push_app
          end

          it 'yields to the block' do
            expect { push_app }.to change { @block_arg }.from(nil).to(git_repo)
          end

          it 'forces pushes the branch' do
            expect(git).to receive(:run).with(/git push -f #{remote} #{branch}/)
            push_app
          end
        end

        context 'when custom remote does not exist' do
          before do
            allow(git_repo).to receive(:remote).with(remote).and_return(git_remote)
          end
          let(:git_remote) { instance_double(Git::Remote, url: nil) }

          it 'does not remove any remotes' do
            expect(git).to_not receive(:run).with(/git remote rm/)
            push_app
          end

          it 'creates the new remote' do
            expect(git_repo).to receive(:add_remote).with(remote, bitbucket_repo_url)
            push_app
          end

          it 'yields to the block' do
            expect { push_app }.to change { @block_arg }.from(nil).to(git_repo)
          end

          it 'force pushes the branch' do
            expect(git).to receive(:run).with(/git push -f #{remote} #{branch}/)
            push_app
          end
        end
      end

      context 'when local git repo does not exist' do
        it 'clones the repo' do
          expect(::Git).to receive(:clone)
            .with(bitbucket_repo_url, working_dir, log: logger)
            .and_return(git_repo)
          push_app
        end

        it 'creates the remote' do
          expect(git_repo).to receive(:add_remote).with(remote, bitbucket_repo_url)
          push_app
        end

        it 'yields the repo to the block' do
          push_app
          expect(@block_arg).to eq(git_repo)
        end

        it 'forces pushes the branch' do
          expect(git).to receive(:run).with(/git push -f #{remote} #{branch}/)
          push_app
        end
      end
    end
  end

  describe '#repo', :fakefs do
    subject(:repo) { git.repo }

    context 'when repo_dir exists' do
      before { FileUtils.mkdir_p(repo_dir) }

      context 'with a git repo' do
        before { create_local_repo(git_repo_name, working_dir) }

        it { is_expected.to eq(git_repo) }

        it 'points to the local working dir' do
          expect(repo.dir.path).to eq(working_dir)
        end

        it 'pulls into the existing repo' do
          expect(git).to receive(:run).with(/git pull/)
          repo
        end
      end

      context 'without a git repo' do
        before do
          FileUtils.rm_rf(working_dir)
        end

        it { is_expected.to eq(git_repo) }

        it 'clones the repo locally' do
          expect(::Git).to receive(:clone)
            .with(bitbucket_repo_url, working_dir, log: logger)
            .and_return(git_repo)
          repo
        end
      end
    end

    context 'when repo_dir does not exist' do
      before do
        FileUtils.rm_rf(repo_dir)
      end

      it 'creates the local repo dir' do
        repo
        expect(File).to exist(repo_dir)
      end

      it { is_expected.to eq(git_repo) }

      it 'clones the repo locally' do
        expect(::Git).to receive(:clone)
          .with(bitbucket_repo_url, working_dir, log: logger)
          .and_return(git_repo)
        repo
      end
    end
  end

  describe '#folder', :fakefs do
    subject(:folder) { git.folder }

    context 'when repo_dir exists' do
      before { FileUtils.mkdir_p(repo_dir) }

      it { is_expected.to eq(working_dir) }

      it 'creates the local folder' do
        expect(File).to exist(folder)
      end
    end

    context 'when repo_dir does not exist' do
      before { FileUtils.rm_rf(repo_dir) }

      it { is_expected.to eq(working_dir) }

      it 'creates the absolute path to the local folder' do
        expect(File).to exist(folder)
      end
    end
  end

  describe '#exists_locally?', :fakefs do
    subject(:exists_locally) { git.exists_locally? }

    context 'when local folder exists' do
      before { FileUtils.mkdir_p(working_dir) }

      context 'with a git repo' do
        before { create_local_repo(git_repo_name, working_dir) }

        it { is_expected.to be true }
      end

      context 'without a git repo' do
        before { FileUtils.rm_rf("#{working_dir}/.git") }

        it { is_expected.to be false }
      end
    end

    context 'when local folder does not exist' do
      before { FileUtils.rm_rf(repo_dir) }

      it { is_expected.to be false }
    end
  end

  describe '#pull', :fakefs do
    subject(:pull) { git.pull }

    it 'changes into the directory' do
      pull
      expect(git).to have_received(:run).with(/^cd #{working_dir};/)
    end

    it 'interacts with bitbucket using the git ssh wrapper' do
      expect(git).to receive(:run)
        .with(%r{env GIT_SSH='/tmp/git-ssh-wrapper\S+'})
      pull
    end

    it 'pulls from bitbucket' do
      expect(git).to receive(:run).with(/git pull/)
      pull
    end

    it 'changes back to original dir' do
      expect(git).to receive(:run).with(/cd #{Dir.pwd}$/)
      pull
    end
  end

  describe '#clone', :fakefs do
    subject(:clone) { git.clone }

    it { is_expected.to be(git_repo) }

    it 'clones the bitbucket repo into the local folder' do
      expect(Git).to receive(:clone)
        .with(bitbucket_repo_url, working_dir, log: logger)
        .and_return(git_repo)
      clone
    end
  end

  # TODO: rename this method something more generic (e.g. update_working_copy)
  describe '#clone_or_pull', :fakefs do
    subject(:clone_or_pull) { git.clone_or_pull }

    context 'when local repo already exists' do
      before { create_local_repo(git_repo_name, working_dir) }

      it 'pulls' do
        expect(git).to receive(:run).with(/git pull/)
        clone_or_pull
      end
    end

    context 'without existing local repo' do
      before { FileUtils.rm_rf(working_dir) }

      it 'clones' do
        expect(::Git).to receive(:clone).and_return(git_repo)
        clone_or_pull
      end
    end
  end

  describe '#with_ssh', :fakefs do
    subject(:with_ssh) { git.with_ssh(&block) }

    let(:temp_files) do
      Dir.glob("#{Dir.tmpdir}/git-ssh-wrapper*").sort_by { |f| File.mtime(f) }
    end
    let(:key_file) { temp_files.first }
    let(:wrapper_file) { temp_files.last }

    context 'when block exits successfully' do
      let(:block) { -> { block_return_value } }
      let(:block_return_value) { 'whatever' }

      it { is_expected.to eq(block_return_value) }

      it 'writes the private key to a file' do
        git.with_ssh do
          expect(key_file).to be
          expect(File.read(key_file)).to eq(id_rsa)
        end
      end

      it 'writes the git ssh wrapper to use the private key' do
        git.with_ssh do
          expect(wrapper_file).to be
          expect(File.read(wrapper_file)).to match(/IdentityFile=#{key_file}/)
        end
      end

      it 'sets the GIT_SSH env var before yielding' do
        git.with_ssh do
          expect(ENV['GIT_SSH']).to eq(wrapper_file)
        end
      end

      it 'resets the GIT_SSH env var after exiting' do
        expect { with_ssh }.to_not change { ENV['GIT_SSH'] }
      end

      it 'unlinks the temp ssh files' do
        with_ssh
        expect(temp_files).to be_empty
      end
    end

    context 'when block raises an error' do
      let(:block) { -> { fail block_error } }
      let(:block_error) { 'oopsy' }

      let(:with_ssh_safe) { with_ssh rescue block_error }

      it 'raises the error' do
        expect { with_ssh }.to raise_error(block_error)
      end

      it 'resets the GIT_SSH env var' do
        expect { with_ssh_safe }.to_not change { ENV['GIT_SSH'] }
      end

      it 'unlinks the temp ssh files' do
        with_ssh_safe
        expect(temp_files).to be_empty
      end
    end
  end

  describe '#ssh_wrapper', :fakefs do
    subject(:ssh_wrapper) { git.ssh_wrapper }

    it { is_expected.to be_kind_of(GitSSHWrapper) }

    it 'writes the private key to a tempfile' do
      ssh_wrapper
      tmpfile = Dir.glob("#{Dir.tmpdir}/id_rsa*").first
      expect(File.read(tmpfile)).to eq(id_rsa)
    end

    it 'initializes an ssh wrapper with the private key' do
      expect(GitSSHWrapper).to receive(:new)
        .with(private_key_path: %r{^#{Dir.tmpdir}/id_rsa})
      ssh_wrapper
    end
  end

  describe '#open', :fakefs do
    subject(:open) { git.open }

    it { is_expected.to eq(git_repo) }

    it 'opens the local repo with logging' do
      expect(::Git).to receive(:open).with(working_dir, log: logger).and_return(git_repo)
      open
    end
  end
end
