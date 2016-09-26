require 'spec_helper'
require 'github_bitbucket_deployer/git'

describe GithubBitbucketDeployer::Git do
  let(:git) { described_class.new(options) }

  let(:options) do
    { bitbucket_repo_url: 'git@bitbucket.org:g5dev/some_repo.git',
      git_repo_name: 'some_repo',
      id_rsa: 'some-crazy-value-i-dunno',
      logger: Logger.new(STDOUT),
      repo_dir: 'say/what' }
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
        expect(git.git_repo_name).to eq(options[:git_repo_name])
      end

      it 'sets the id_rsa' do
        expect(git.id_rsa).to eq(options[:id_rsa])
      end

      it 'sets the logger' do
        expect(git.logger).to eq(options[:logger])
      end

      it 'sets the repo_dir' do
        expect(git.repo_dir).to eq(options[:repo_dir])
      end
    end
  end
end
