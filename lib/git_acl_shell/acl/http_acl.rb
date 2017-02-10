require 'httparty'

module GitAclShell
  module Acl
    class HTTPAcl
      include HTTParty

      def authorized?(key_id, repo_alias)
        response = self.class.get("/permission", query: { keyId: key_id, alias: repo_alias })
        response.ok?
      end
    end
  end
end
