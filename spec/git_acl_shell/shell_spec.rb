require "stringio"
require "spec_helper"

class CapturingKernel
  attr_reader :args

  def exec(*args)
    @args = args
  end
end

class IdentityDirectory
  def lookup(repo_alias)
    repo_alias
  end
end

describe GitAclShell::Shell do
  let(:kernel) { CapturingKernel.new }
  let(:stderr) { StringIO.new }
  let(:acl) { double(:acl, authorized?: true) }
  let(:directory) { IdentityDirectory.new }
  let(:shell) { GitAclShell::Shell.new('some-key-id', acl: acl, directory: directory, kernel: kernel, stderr: stderr) }

  describe "commands" do
    it "allows `git-upload-pack`" do
      command = "git-upload-pack '/home/git/repo-name.git'"

      expect(shell.exec(command)).to be true
      expect(kernel.args).to eq ["git-upload-pack", "/home/git/repo-name.git"]
    end

    it "does not allow `rm`" do
      command = "rm -rf tmp"

      expect(shell.exec(command)).to be false
      expect(kernel.args).to be nil
    end

    it "does not allow a command with appended semicolon" do
      command = "git-upload-pack;rm -rf tmp"

      expect(shell.exec(command)).to be false
      expect(kernel.args).to eq nil
    end

    it "allows a command with appended space and semicolon, delegating to git-* to fail it" do
      command = "git-upload-pack /home/git/repo-name.git ; rm -rf tmp"

      expect(shell.exec(command)).to be true
      expect(kernel.args).to eq ["git-upload-pack", "/home/git/repo-name.git", ";", "rm", "-rf", "tmp"]
    end
  end

  describe "access control" do
    let(:acl) { double(:acl) }

    it "denies access to unauthorized keys" do
      expect(acl).to receive(:authorized?).with('some-key-id', "/home/git/some repo.git").and_return(false)

      command = "git-upload-pack '/home/git/some repo.git'"

      expect(shell.exec(command)).to be false
      stderr.rewind
      expect(stderr.read).to eq "Access denied\n"
    end
  end

  describe "aliasing" do
    let(:directory) { double(:directory) }

    it "allows `git-upload-pack`" do
      expect(directory).to receive(:lookup).with("/home/git/alias.git").and_return("/home/git/repo-name.git")

      command = "git-upload-pack '/home/git/alias.git'"

      expect(shell.exec(command)).to be true
      expect(kernel.args).to eq ["git-upload-pack", "/home/git/repo-name.git"]
    end
  end
end
