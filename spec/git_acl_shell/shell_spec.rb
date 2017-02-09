require "spec_helper"
class CapturingKernel
  attr_reader :command

  def exec(command)
    @command = command
  end
end

describe GitAclShell do
  it "has a version number" do
    expect(GitAclShell::VERSION).not_to be nil
  end

  describe "allowed commands" do
    it "allows `git-upload-pack`" do
      kernel = CapturingKernel.new
      shell = GitAclShell::Shell.new('some-key-id', kernel: kernel)

      command = "git-upload-pack '/home/git/alias.git'"

      expect(shell.exec(command)).to be true
      expect(kernel.command).to eq command
    end

    it "does not allow `rm`" do
      kernel = CapturingKernel.new
      shell = GitAclShell::Shell.new('some-key-id', kernel: kernel)

      command = "rm -rf tmp"

      expect(shell.exec(command)).to be false
      expect(kernel.command).to be nil
    end
  end

  describe "access control" do

  end

  describe "aliasing" do

  end
end
