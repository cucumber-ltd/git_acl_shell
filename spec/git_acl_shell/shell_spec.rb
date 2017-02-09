require "stringio"
require "spec_helper"

class CapturingKernel
  attr_reader :args

  def exec(*args)
    @args = args
  end
end

describe GitAclShell do
  it "has a version number" do
    expect(GitAclShell::VERSION).not_to be nil
  end

  let(:kernel) { CapturingKernel.new }
  let(:stderr) { StringIO.new }
  let(:permissive_acl) { double(:acl, authorized?: true) }

  describe "commands" do
    it "allows `git-upload-pack`" do
      kernel = CapturingKernel.new
      shell = GitAclShell::Shell.new('some-key-id', acl: permissive_acl, kernel: kernel, stderr: stderr)

      command = "git-upload-pack '/home/git/alias.git'"

      expect(shell.exec(command)).to be true
      expect(kernel.args).to eq ["git-upload-pack", "/home/git/alias.git"]
    end

    it "does not allow `rm`" do
      kernel = CapturingKernel.new
      shell = GitAclShell::Shell.new('some-key-id', acl: permissive_acl, kernel: kernel, stderr: stderr)

      command = "rm -rf tmp"

      expect(shell.exec(command)).to be false
      expect(kernel.args).to be nil
    end

    it "does not allow a command with appended semicolon" do
      kernel = CapturingKernel.new
      shell = GitAclShell::Shell.new('some-key-id', acl: permissive_acl, kernel: kernel, stderr: stderr)

      command = "git-upload-pack;rm -rf tmp"

      expect(shell.exec(command)).to be false
      expect(kernel.args).to eq nil
    end

    it "allows a command with appended space and semicolon, delegating to git-* to fail it" do
      kernel = CapturingKernel.new
      shell = GitAclShell::Shell.new('some-key-id', acl: permissive_acl, kernel: kernel, stderr: stderr)

      command = "git-upload-pack /home/git/alias.git ; rm -rf tmp"

      expect(shell.exec(command)).to be true
      expect(kernel.args).to eq ["git-upload-pack", "/home/git/alias.git", ";", "rm", "-rf", "tmp"]
    end
  end

  describe "access control" do
    it "denies access to unauthorized keys" do
      acl = double(:acl)
      expect(acl).to receive(:authorized?).with('some-key-id', "/home/git/some repo.git").and_return(false)
      shell = GitAclShell::Shell.new('some-key-id', acl: acl, kernel: kernel, stderr: stderr)

      command = "git-upload-pack '/home/git/some repo.git'"

      expect(shell.exec(command)).to be false
      stderr.rewind
      expect(stderr.read).to eq "Access denied\n"
    end
  end

  describe "aliasing" do

  end
end
