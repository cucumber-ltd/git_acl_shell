module GitAclShell
  class Shell
    def initialize(key_id, kernel:)
      @key_id = key_id
      @kernel = kernel
    end

    def exec(command)
      @kernel.exec(command)
      true
    end
  end
end
