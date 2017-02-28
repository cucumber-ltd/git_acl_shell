require 'httparty'
require 'git_acl_shell/errors'

module GitAclShell
  module Directory
    class HTTPDirectory
      include HTTParty

      def lookup(repo_alias)
        response = self.class.get("/repo-base-name", query: { alias: repo_alias })
        if response.ok?
          return response.body
        else
          raise UnknownAlias
        end
      end
    end
  end
end
