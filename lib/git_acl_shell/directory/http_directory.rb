require 'httparty'

module GitAclShell
  module Directory
    class HTTPDirectory
      include HTTParty

      def lookup(repo_alias)
        # TODO: URL encode
        self.class.get("/real-name?alias=" + repo_alias).body
      end
    end
  end
end
