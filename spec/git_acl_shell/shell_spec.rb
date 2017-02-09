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

  describe "commands" do
    it "allows `git-upload-pack`" do
      kernel = CapturingKernel.new
      shell = GitAclShell::Shell.new('some-key-id', kernel: kernel)

      command = "git-upload-pack '/home/git/alias.git'"

      expect(shell.exec(command)).to be true
      expect(kernel.args).to eq ["git-upload-pack", "/home/git/alias.git"]
    end

    it "does not allow `rm`" do
      kernel = CapturingKernel.new
      shell = GitAclShell::Shell.new('some-key-id', kernel: kernel)

      command = "rm -rf tmp"

      expect(shell.exec(command)).to be false
      expect(kernel.args).to be nil
    end

    it "does not allow a command with appended semicolon" do
      kernel = CapturingKernel.new
      shell = GitAclShell::Shell.new('some-key-id', kernel: kernel)

      command = "git-upload-pack;rm -rf tmp"

      expect(shell.exec(command)).to be false
      expect(kernel.args).to eq nil
    end
  end

  describe "access control" do

  end

  describe "aliasing" do

  end
end
