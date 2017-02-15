require 'shellwords'

module GitAclShell
  class Shell
    # See https://git-scm.com/docs/git-shell#_commands
    #                     (git push)       (git fetch)     (git archive)
    COMMAND_WHITELIST = %w(git-receive-pack git-upload-pack git-upload-archive).freeze

    def initialize(key_id, acl:, directory:, kernel:, stderr:)
      @key_id    = key_id
      @acl       = acl
      @directory = directory
      @kernel    = kernel
      @stderr    = stderr
    end

    def exec(command)
      args = Shellwords.shellwords(command)
      if whitelist?(args)
        repo_path = args.pop
        repo_extension = File.extname(repo_path)
        repo_alias = File.basename(repo_path, repo_extension)

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
          @stderr.puts("Access denied")
          false
        end
      else
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
