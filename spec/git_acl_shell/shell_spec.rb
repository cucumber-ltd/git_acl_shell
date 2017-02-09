require "stringio"
require "spec_helper"

class CapturingKernel
  attr_reader :args

  def exec(*args)
    @args = args
  end
end

class DenyingAcl
  def authorized?(key_id, repo_path)
    false
  end
end

class PermissiveAcl
  def authorized?(key_id, repo_path)
    true
  end
end

describe GitAclShell do
  it "has a version number" do
    expect(GitAclShell::VERSION).not_to be nil
  end

  let(:kernel) { CapturingKernel.new }
  let(:stderr) { StringIO.new }

  describe "commands" do
    it "allows `git-upload-pack`" do
      kernel = CapturingKernel.new
      shell = GitAclShell::Shell.new('some-key-id', acl: PermissiveAcl.new, kernel: kernel, stderr: stderr)

      command = "git-upload-pack '/home/git/alias.git'"

      expect(shell.exec(command)).to be true
      expect(kernel.args).to eq ["git-upload-pack", "/home/git/alias.git"]
    end

    it "does not allow `rm`" do
      kernel = CapturingKernel.new
      shell = GitAclShell::Shell.new('some-key-id', acl: PermissiveAcl.new, kernel: kernel, stderr: stderr)

      command = "rm -rf tmp"

      expect(shell.exec(command)).to be false
      expect(kernel.args).to be nil
    end

    it "does not allow a command with appended semicolon" do
      kernel = CapturingKernel.new
      shell = GitAclShell::Shell.new('some-key-id', acl: PermissiveAcl.new, kernel: kernel, stderr: stderr)

      command = "git-upload-pack;rm -rf tmp"

      expect(shell.exec(command)).to be false
      expect(kernel.args).to eq nil
    end

    it "allows a command with appended space and semicolon, delegating to git-* to fail it" do
      kernel = CapturingKernel.new
      shell = GitAclShell::Shell.new('some-key-id', acl: PermissiveAcl.new, kernel: kernel, stderr: stderr)

      command = "git-upload-pack /home/git/alias.git ; rm -rf tmp"

      expect(shell.exec(command)).to be true
      expect(kernel.args).to eq ["git-upload-pack", "/home/git/alias.git",
        ";", "rm", "-rf", "tmp"]
    end
  end

  describe "access control" do
    it "denies access to unauthorized keys" do
      shell = GitAclShell::Shell.new('some-key-id', acl: DenyingAcl.new, kernel: kernel, stderr: stderr)

      command = "git-upload-pack '/home/git/alias.git'"

      expect(shell.exec(command)).to be false
      stderr.rewind
      expect(stderr.read).to eq "Access denied\n"
    end
  end

  describe "aliasing" do

  end
end
