require 'httparty'

module GitAclShell
  module Directory
    class HTTPDirectory
      include HTTParty

      def lookup(repo_alias)
        # TODO: URL encode
        response = self.class.get("/real-name?alias=" + repo_alias)
        if response.ok?
          return response.body
        else
          raise UnknownAlias
        end
      end
    end
  end
end
