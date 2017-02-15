require 'httparty'

module GitAclShell
  module Acl
    class HTTPAcl
      include HTTParty

      def authorized?(key_id, repo_name)
        response = self.class.get("/permission", query: { keyId: key_id, name: repo_name })
        response.ok?
      end
    end
  end
end
