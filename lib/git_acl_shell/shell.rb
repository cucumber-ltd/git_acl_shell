require 'shellwords'

module GitAclShell
  class Shell
    # See https://git-scm.com/docs/git-shell#_commands
    #                     (git push)       (git fetch)     (git archive)
    COMMAND_WHITELIST = %w(git-receive-pack git-upload-pack git-upload-archive).freeze

    def initialize(key_id, acl:, kernel:, stderr:)
      @key_id = key_id
      @acl    = acl
      @kernel = kernel
      @stderr = stderr
    end

    def exec(command)
      args = Shellwords.shellwords(command)
      if whitelist?(args)
        repo_path = args.last
        if @acl.authorized?(@key_id, repo_path)
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
