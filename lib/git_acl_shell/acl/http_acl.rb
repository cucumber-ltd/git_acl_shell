require 'httparty'

module GitAclShell
  module Acl
    class HTTPAcl
      include HTTParty

      def authorized?(key_id, repo_base_name)
        response = self.class.get("/permission", query: { 'key-id' => key_id, 'repo-base-name' => repo_base_name })
        response.ok?
      end
    end
  end
end
