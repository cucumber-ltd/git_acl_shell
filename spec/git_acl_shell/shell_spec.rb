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

module GitAclShell

describe Shell do
  let(:kernel) { CapturingKernel.new }
  let(:stderr) { StringIO.new }
  let(:acl) { double(:acl, authorized?: true) }
  let(:directory) { IdentityDirectory.new }
  let(:shell) { Shell.new('some-key-id', acl: acl, directory: directory, kernel: kernel, stderr: stderr) }

  describe "commands" do
    it "allows `git-upload-pack`" do
      command = "git-upload-pack '/home/git/repo-name.git'"

      expect(shell.exec(command)).to be true
      expect(kernel.args).to eq ["git-upload-pack", "/home/git/repo-name.git"]
    end

    it "does not allow interactive sessions (no command)" do
      command = nil

      expect(shell.exec(command)).to be false
      expect(kernel.args).to be nil
      stderr.rewind
      expect(stderr.read).to eq "#{GitAclShell::Shell::NO_SHELL_ACCESS_MESSAGE}\n"
    end

    it "does not allow `rm`" do
      command = "rm -rf tmp"

      expect(shell.exec(command)).to be false
      expect(kernel.args).to be nil
      stderr.rewind
      expect(stderr.read).to eq "#{GitAclShell::Shell::COMMAND_DENIED_MESSAGE}\n"
    end

    it "does not allow a command with appended semicolon" do
      command = "git-upload-pack;rm -rf tmp"

      expect(shell.exec(command)).to be false
      expect(kernel.args).to eq nil
    end

    it "allows a command with appended space and semicolon, delegating to git-* to fail it" do
      command = "git-upload-pack /home/git/repo-name.git ; rm -rf tmp"

      expect(shell.exec(command)).to be true
      expect(kernel.args).to eq ["git-upload-pack", "/home/git/repo-name.git", ";", "rm", "-rf", "./tmp"]
    end
  end

  describe "access control" do
    let(:acl) { double(:acl) }
    let(:directory) { double(:directory, lookup: "the-repo-base-name") }

    it "denies access to unauthorized keys" do
      expect(acl).to receive(:authorized?).with("some-key-id", "the-repo-base-name").and_return(false)

      command = "git-upload-pack '/home/git/some repo.git'"

      expect(shell.exec(command)).to be false
      stderr.rewind
      expect(stderr.read).to eq "#{GitAclShell::Shell::ACCESS_DENIED_MESSAGE}\n"
    end
  end

  describe "aliasing" do
    let(:directory) { double(:directory) }

    it "uses the real name looked up from the directory in the command" do
      expect(directory).to receive(:lookup).with("alias").and_return("repo-name")

      command = "git-upload-pack '/home/git/alias.git'"

      expect(shell.exec(command)).to be true
      expect(kernel.args).to eq ["git-upload-pack", "/home/git/repo-name.git"]
    end

    it "decodes the alias before looking up the real name" do
      expect(directory).to receive(:lookup).with("complex/+alias").and_return("repo-name")

      command = "git-upload-pack '/home/git/complex%2F%2Balias.git'"

      expect(shell.exec(command)).to be true
      expect(kernel.args).to eq ["git-upload-pack", "/home/git/repo-name.git"]
    end

    it "does not execute if the alias is unknown" do
      expect(directory).to receive(:lookup).and_raise(UnknownAlias)

      command = "git-upload-pack '/home/git/alias.git'"

      expect(shell.exec(command)).to be false
      expect(kernel.args).to be_nil

      stderr.rewind
      expect(stderr.read).to eq "Not found\n"
    end
  end
end

end
