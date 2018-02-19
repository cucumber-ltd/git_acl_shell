require 'shellwords'
require 'git_acl_shell/errors'

module GitAclShell
  class Shell
    # See https://git-scm.com/docs/git-shell#_commands
    #                     (git push)       (git fetch)     (git archive)
    COMMAND_WHITELIST = %w(git-receive-pack git-upload-pack git-upload-archive).freeze
    NO_SHELL_ACCESS_MESSAGE = ENV['git_acl_shell_no_shell_access_message'] || "You've succesfully authenticated, but shell access is not available."
    ACCESS_DENIED_MESSAGE = ENV['git_acl_shell_access_denied_message'] || "You've successfully authenticated, but you don't have access to this repo."
    COMMAND_DENIED_MESSAGE = ENV['git_acl_shell_command_denied_message'] || "You've successfully authenticated, but the only allowed commands are #{COMMAND_WHITELIST.join(', ')}."

    def initialize(key_id, acl:, directory:, kernel: Kernel, stderr: $stderr)
      @key_id    = key_id
      @acl       = acl
      @directory = directory
      @kernel    = kernel
      @stderr    = stderr
    end

    def exec(command)
      if command.nil?
        @stderr.puts(NO_SHELL_ACCESS_MESSAGE)
        return false
      end

      args = Shellwords.shellwords(command)
      if whitelist?(args)
        repo_path = args.pop
        repo_extension = File.extname(repo_path)
        repo_alias = URI.decode(File.basename(repo_path, repo_extension))

        begin
          repo_name = @directory.lookup(repo_alias)
          repo_path = File.join(File.dirname(repo_path), "#{repo_name}#{repo_extension}")
          args.push(repo_path)
        rescue UnknownAlias
          @stderr.puts("Not found")
          return false
        end

        if @acl.authorized?(@key_id, repo_name)
          @kernel.exec(*args)
          true
        else
          @stderr.puts(ACCESS_DENIED_MESSAGE)
          false
        end
      else
        @stderr.puts(COMMAND_DENIED_MESSAGE)
        false
      end
    end

    private

    def whitelist?(args)
      program = args[0]
      COMMAND_WHITELIST.include?(program)
    end
  end
end
