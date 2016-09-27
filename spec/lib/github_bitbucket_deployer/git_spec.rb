require 'spec_helper'

describe GithubBitbucketDeployer::Git do
  let(:git) { described_class.new(options) }

  let(:options) do
    { bitbucket_repo_url: 'git@bitbucket.org:g5dev/some_repo.git',
      git_repo_name: git_repo_name,
      id_rsa: 'some-crazy-value-i-dunno',
      logger: logger,
      repo_dir: repo_dir }
  end

  let(:repo_dir) { '/my_home/projects' }
  let(:git_repo_name) { 'my_repo' }
  let(:local_repo_folder) { Zlib.crc32(git_repo_name) }

  let(:logger) { double('logger', info: true) }

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

  describe '#push_app_to_bitbucket' do
    # TODO
  end

  describe '#repo' do
    # TODO
  end

  describe '#folder', :fakefs do
    subject(:folder) { git.folder }

    context 'when repo_dir exists' do
      before { FileUtils.mkdir_p(repo_dir) }

      it { is_expected.to eq("#{repo_dir}/#{local_repo_folder}") }

      it 'creates the local folder' do
        expect(File).to exist(folder)
      end
    end

    context 'when repo_dir does not exist' do
      before { FileUtils.rm_rf(repo_dir) }

      it { is_expected.to eq("#{repo_dir}/#{local_repo_folder}") }

      it 'creates the absolute path to the local folder' do
        expect(File).to exist(folder)
      end
    end
  end

  describe '#exists_locally?', :fakefs do
    subject(:exists_locally) { git.exists_locally? }

    let(:absolute_path) { "#{repo_dir}/#{local_repo_folder}" }

    context 'when local folder exists' do
      before { FileUtils.mkdir_p(absolute_path) }

      context 'with a git repo' do
        before do
          git_dir = "#{absolute_path}/.git"
          FileUtils.mkdir(git_dir)
          FileUtils.touch("#{git_dir}/config") 
        end

        it { is_expected.to be true }
      end

      context 'without a git repo' do
        before { FileUtils.rm_rf("#{absolute_path}/.git") }

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

    before { allow(git).to receive(:run).with(kind_of(String)).and_return(true) }

    it 'changes into the directory' do
      pull
      expect(git).to have_received(:run).with(/^cd #{local_repo_folder};/)
    end

    it 'pulls from bitbucket using the git ssh wrapper' do
      expect(git).to receive(:run).with(/env GIT_SSH=\S+ git pull;/)
      pull
    end

    it 'changes back to original dir' do
      expect(git).to receive(:run).with(/cd #{Dir.pwd}$/)
      pull
    end
  end

  describe '#clone' do
    # TODO
  end
end
