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
  let(:logger) { double('logger', info: true, error: true) }
  let(:repo_dir) { '/my_home/projects' }
  let(:working_dir) { "#{repo_dir}/#{local_repo_folder}" }

  let(:git_repo) do
    instance_double(::Git::Base, remote: empty_remote,
                                 dir: git_working_dir,
                                 add_remote: true,
                                 pull: true,
                                 push: true)
  end
  let(:empty_remote) { instance_double(::Git::Remote, url: nil) }

  let(:bitbucket_remote) do
    instance_double(::Git::Remote, url: bitbucket_repo_url,
                                   remove: true)
  end
  before do
    allow(git_repo).to receive(:remote)
      .with('bitbucket').and_return(bitbucket_remote)
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
        before { create_local_repo(working_dir) }

        let(:other_remote) do
          instance_double(::Git::Remote, url: 'git@heroku.com:my_app.git')
        end
        before do
          allow(git_repo).to receive(:remote)
            .with('heroku').and_return(other_remote)
        end

        it 'pulls from the remote repo' do
          expect(git_repo).to receive(:pull).and_return(true)
          push_app
        end

        context 'when bitbucket remote exists' do
          before do
            allow(git_repo).to receive(:remote)
              .with('bitbucket').and_return(bitbucket_remote)
          end

          it 'removes the existing remote' do
            expect(bitbucket_remote).to receive(:remove)
            push_app
          end

          it 'does not remove the unrelated remote' do
            expect(other_remote).to_not receive(:remove)
            push_app
          end

          it 'creates the bitbucket remote anew' do
            expect(git_repo).to receive(:add_remote)
              .with('bitbucket', bitbucket_repo_url)
            push_app
          end

          it 'force pushes master to bitbucket' do
            expect(git_repo).to receive(:push)
              .with('bitbucket', 'master', force: true)
            push_app
          end
        end

        context 'when bitbucket remote does not exist' do
          before do
            allow(git_repo).to receive(:remote)
              .with('bitbucket').and_return(empty_remote)
          end

          it 'does not remove any remotes' do
            expect(bitbucket_remote).to_not receive(:remove)
            expect(other_remote).to_not receive(:remove)
            push_app
          end

          it 'creates the bitbucket remote' do
            expect(git_repo).to receive(:add_remote)
              .with('bitbucket', bitbucket_repo_url)
            push_app
          end

          it 'force pushes master to bitbucket' do
            expect(git_repo).to receive(:push)
              .with('bitbucket', 'master', force: true)
            push_app
          end
        end
      end

      context 'when local repo does not exist' do
        before do
          allow(git_repo).to receive(:remote)
            .with('bitbucket').and_return(empty_remote)
        end

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
          expect(git_repo).to receive(:push)
            .with('bitbucket', 'master', force: true)
          push_app
        end
      end
    end

    context 'with custom arguments' do
      let(:push_app) { git.push_app_to_bitbucket(remote_name, branch) }

      let(:remote_name) { 'my_git_server' }
      let(:branch) { 'my_topic_branch' }

      context 'when local git repo exists' do
        before { create_local_repo(working_dir) }

        let(:custom_remote) do
          instance_double(Git::Remote, url: bitbucket_repo_url,
                                       remove: true)
        end

        before do
          allow(git_repo).to receive(:remote)
            .with(remote_name).and_return(custom_remote)
        end

        it 'pulls from the remote repo' do
          expect(git_repo).to receive(:pull).and_return(true)
          push_app
        end

        context 'when custom remote already exists' do
          it 'removes the old remote' do
            expect(custom_remote).to receive(:remove)
            push_app
          end

          it 'creates the new remote' do
            expect(git_repo).to receive(:add_remote)
              .with(remote_name, bitbucket_repo_url)
            push_app
          end

          it 'yields to the block' do
            expect do |block|
              git.push_app_to_bitbucket(remote_name, branch, &block)
            end.to yield_with_args(git_repo)
          end

          it 'forces pushes the branch' do
            expect(git_repo).to receive(:push)
              .with(remote_name, branch, force: true)
            push_app
          end
        end

        context 'when custom remote does not exist' do
          let(:custom_remote) { empty_remote }

          it 'does not remove any remotes' do
            expect(custom_remote).to_not receive(:remove)
            push_app
          end

          it 'creates the new remote' do
            expect(git_repo).to receive(:add_remote)
              .with(remote_name, bitbucket_repo_url)
            push_app
          end

          it 'yields to the block' do
            expect do |block|
              git.push_app_to_bitbucket(remote_name, branch, &block)
            end.to yield_with_args(git_repo)
          end

          it 'force pushes the branch' do
            expect(git_repo).to receive(:push)
              .with(remote_name, branch, force: true)
            push_app
          end
        end
      end

      context 'when local git repo does not exist' do
        let(:custom_remote) { empty_remote }

        it 'clones the repo' do
          expect(::Git).to receive(:clone)
            .with(bitbucket_repo_url, working_dir, log: logger)
            .and_return(git_repo)
          push_app
        end

        it 'creates the remote' do
          expect(git_repo).to receive(:add_remote)
            .with(remote_name, bitbucket_repo_url)
          push_app
        end

        it 'yields the repo to the block' do
          expect do |block|
            git.push_app_to_bitbucket(remote_name, branch, &block)
          end.to yield_with_args(git_repo)
        end

        it 'forces pushes the branch' do
          expect(git_repo).to receive(:push)
            .with(remote_name, branch, force: true)
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
        before { create_local_repo(working_dir) }

        it { is_expected.to eq(git_repo) }

        it 'points to the local working dir' do
          expect(repo.dir.path).to eq(working_dir)
        end

        it 'pulls into the existing repo' do
          expect(git_repo).to receive(:pull).and_return(true)
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

  describe '#pull', :fakefs do
    subject(:pull) { git.pull }

    it { is_expected.to be(git_repo) }

    it 'pulls from the remote server' do
      expect(git_repo).to receive(:pull)
      pull
    end

    it 'does not change the current dir' do
      expect { pull }.to_not change { Dir.pwd }
    end

    it_behaves_like 'a git error handler' do
      before { allow(git_repo).to receive(:pull).and_raise(error) }

      let(:retry_git_command) do
        expect(git_repo).to have_received(:pull).exactly(retry_limit).times
      end
    end

    it_behaves_like 'a git ssh wrapper' do
      def run_git_command
        expect(git_repo).to receive(:pull) { yield }
      end
    end
  end

  describe '#clone', :fakefs do
    subject(:clone) { git.clone }

    it { is_expected.to be(git_repo) }

    it 'clones the bitbucket repo into the local folder' do
      expect(::Git).to receive(:clone)
        .with(bitbucket_repo_url, working_dir, log: logger)
        .and_return(git_repo)
      clone
    end

    it_behaves_like 'a git error handler' do
      before { allow(::Git).to receive(:clone).and_raise(error) }

      let(:retry_git_command) do
        expect(::Git).to have_received(:clone).exactly(retry_limit).times
      end
    end

    it_behaves_like 'a git ssh wrapper' do
      def run_git_command
        expect(::Git).to receive(:clone) { yield }
      end
    end
  end

  describe '#open', :fakefs do
    subject(:open) { git.open }

    it { is_expected.to eq(git_repo) }

    it 'opens the local repo with logging' do
      expect(::Git).to receive(:open)
        .with(working_dir, log: logger).and_return(git_repo)
      open
    end
  end

  describe '#push' do
    subject(:push) { git.push(remote_name, branch) }

    let(:remote_name) { 'bitbucket' }
    let(:branch) { 'master' }

    it 'force pushes the branch to the remote' do
      expect(git_repo).to receive(:push).with(remote_name, branch, force: true)
      push
    end

    it_behaves_like 'a git error handler' do
      before { allow(git_repo).to receive(:push).and_raise(error) }

      let(:retry_git_command) do
        expect(git_repo).to have_received(:push).exactly(retry_limit).times
      end
    end

    it_behaves_like 'a git ssh wrapper' do
      def run_git_command
        expect(git_repo).to receive(:push) { yield }
      end
    end
  end

  describe '#add_remote', :fakefs do
    subject { add_remote }

    let(:unrelated_remote) do
      instance_double(::Git::Remote, url: 'git@heroku.com:my_app.git')
    end

    before do
      allow(git_repo).to receive(:remote)
        .with('heroku').and_return(unrelated_remote)
    end

    context 'with default remote name' do
      let(:add_remote) { git.add_remote }

      context 'when bitbucket remote already exists' do
        it 'removes the existing remote' do
          expect(bitbucket_remote).to receive(:remove)
          add_remote
        end

        it 'does not remove the unrelated remote' do
          expect(unrelated_remote).to_not receive(:remove)
          add_remote
        end

        it 'adds the new bitbucket remote' do
          expect(git_repo).to receive(:add_remote)
            .with('bitbucket', bitbucket_repo_url)
          add_remote
        end
      end

      context 'when bitbucket remote does not exist' do
        let(:bitbucket_remote) { empty_remote }

        it 'does not remove any existing remotes' do
          expect(empty_remote).to_not receive(:remove)
          expect(unrelated_remote).to_not receive(:remove)
          add_remote
        end

        it 'adds the new bitbucket remote' do
          expect(git_repo).to receive(:add_remote)
            .with('bitbucket', bitbucket_repo_url)
          add_remote
        end
      end
    end

    context 'with custom remote name' do
      let(:add_remote) { git.add_remote(remote_name) }

      let(:custom_remote) do
        instance_double(::Git::Remote, url: 'git@some_server.com:my_app.git',
                                       remove: true)
      end
      let(:remote_name) { 'custom_remote' }
      before do
        allow(git_repo).to receive(:remote)
          .with(remote_name).and_return(custom_remote)
      end

      context 'when custom remote already exists' do
        it 'removes the existing remote' do
          expect(custom_remote).to receive(:remove)
          add_remote
        end

        it 'does not remove unrelated remotes' do
          expect(unrelated_remote).to_not receive(:remove)
          add_remote
        end

        it 'creates the new custom remote' do
          expect(git_repo).to receive(:add_remote)
            .with(remote_name, bitbucket_repo_url)
          add_remote
        end
      end

      context 'when custom remote does not already exist' do
        let(:custom_remote) { empty_remote }

        it 'does not remove any existing remotes' do
          expect(empty_remote).to_not receive(:remove)
          expect(unrelated_remote).to_not receive(:remove)
          add_remote
        end

        it 'creates the new custom remote' do
          expect(git_repo).to receive(:add_remote)
            .with(remote_name, bitbucket_repo_url)
          add_remote
        end
      end
    end
  end
end
