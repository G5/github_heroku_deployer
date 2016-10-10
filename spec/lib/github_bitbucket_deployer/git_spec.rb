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
    instance_double(Git::Base, remote: git_remote,
                               dir: working_dir,
                               add_remote: true)
  end

  let(:git_remote) do
    instance_double(Git::Remote, url: bitbucket_repo_url)
  end

  describe '#initialize' do
    subject { git }

    context 'without options' do
      let(:options) { Hash.new }

      # TODO: sensible defaults

      it 'has no bitbucket_repo_url' do
        expect(git.bitbucket_repo_url).to be_nil
      end

      it 'has no git_repo_name' do
        expect(git.git_repo_name).to be_nil
      end

      it 'has no id_rsa' do
        expect(git.id_rsa).to be_nil
      end

      it 'has no logger' do
        expect(git.logger).to be_nil
      end

      it 'has no repo_dir' do
        expect(git.repo_dir).to be_nil
      end
    end

    context 'with options' do
      it 'sets the bitbucket_repo_url' do
        expect(git.bitbucket_repo_url).to eq(options[:bitbucket_repo_url])
      end

      it 'sets the git_repo_name' do
        expect(git.git_repo_name).to eq(git_repo_name)
      end

      it 'sets the id_rsa' do
        expect(git.id_rsa).to eq(options[:id_rsa])
      end

      it 'sets the logger' do
        expect(git.logger).to eq(options[:logger])
      end

      it 'sets the repo_dir' do
        expect(git.repo_dir).to eq(repo_dir)
      end
    end
  end

  describe '#push_app_to_bitbucket', :fakefs do
    subject { push_app }

    before { allow(Git).to receive(:open).and_return(git_repo) }

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
          expect(git).to receive(:run)
            .with(/git clone #{bitbucket_repo_url} #{working_dir}/)
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
      let(:block) { lambda { |arg| @block_arg = arg } }

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
          expect(git).to receive(:run).with(/git clone #{bitbucket_repo_url} #{working_dir}/)
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

        it { is_expected.to be_kind_of(Git::Base) }

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
          allow(git).to receive(:run).with(/git clone/) do
            create_local_repo(git_repo_name, working_dir)
          end
        end

        it { is_expected.to be_kind_of(Git::Base) }

        it 'points to the local working dir' do
          expect(repo.dir.path).to eq(working_dir)
        end

        it 'clones the repo locally' do
          expect(git).to receive(:run)
            .with(/git clone #{bitbucket_repo_url} #{working_dir}/)
          repo
        end
      end
    end

    context 'when repo_dir does not exist' do
      before do
        FileUtils.rm_rf(repo_dir)
        allow(git).to receive(:run).with(/git clone/) do
          create_local_repo(git_repo_name, working_dir)
        end
      end

      it 'creates the local repo dir' do
        repo
        expect(File).to exist(repo_dir)
      end

      it { is_expected.to be_kind_of(Git::Base) }

      it 'points to the local working dir' do
        expect(repo.dir.path).to eq(working_dir)
      end

      it 'clones the repo locally' do
        expect(git).to receive(:run)
          .with(/git clone #{bitbucket_repo_url} #{working_dir}/)
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

    it 'unsets the git work tree' do
      expect(git).to receive(:run).with(/^unset GIT_WORK_TREE/)
      clone
    end

    it 'interacts with bitbucket via the git ssh wrapper' do
      expect(git).to receive(:run)
        .with(%r{env GIT_SSH='/tmp/git-ssh-wrapper\S+'})
      clone
    end

    it 'clones the bitbucket repo into the local folder' do
      expect(git).to receive(:run)
        .with(/git clone #{bitbucket_repo_url} #{working_dir}/)
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
        expect(git).to receive(:run).with(/git clone/)
        clone_or_pull
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

    before { create_local_repo(git_repo_name, working_dir) }

    it { is_expected.to be_kind_of Git::Base }

    it 'points to the local working dir' do
      expect(open.dir.path).to eq(working_dir)
    end
  end
end
