require 'httparty'

module GitAclShell
  module Acl
    class HTTPAcl
      include HTTParty

      def authorized?(key_id, repo_alias)
        # TODO: URL encode
        response = self.class.get("/permission?keyId=#{key_id}&alias=#{repo_alias}")
        response.ok?
      end
    end
  end
end
