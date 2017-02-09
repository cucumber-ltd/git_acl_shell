require 'shellwords'

module GitAclShell
  class Shell
    # See https://git-scm.com/docs/git-shell#_commands
    #                     (git push)       (git fetch)     (git archive)
    COMMAND_WHITELIST = %w(git-receive-pack git-upload-pack git-upload-archive).freeze

    def initialize(key_id, kernel:)
      @key_id = key_id
      @kernel = kernel
    end

    def exec(command)
      if whitelist?(command)
        @kernel.exec(command)
        true
      else
        false
      end
    end

    private

    def whitelist?(command)
      args = Shellwords.shellwords(command)
      program = args[0]
      COMMAND_WHITELIST.include?(program)
    end

  end
end
