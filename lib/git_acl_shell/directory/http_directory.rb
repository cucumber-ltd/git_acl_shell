require 'httparty'

module GitAclShell
  module Directory
    class HTTPDirectory
      include HTTParty

      def lookup(repo_alias)
        response = self.class.get("/real-name", query: { alias: repo_alias })
        if response.ok?
          return response.body
        else
          raise UnknownAlias
        end
      end
    end
  end
end
