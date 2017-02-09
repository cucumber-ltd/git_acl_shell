require "spec_helper"
require "service_providers/pact_helper"

module GitAclShell
module Acl

describe HTTPAcl, :pact => true do
  before do
    HTTPAcl.base_uri 'localhost:1234'
  end

  let(:acl) { HTTPAcl.new }

  describe "authorized access" do
    before do
    end

    it "returns true" do
      expect(acl.authorized?('some-key-id', '/home/git/alias.git')).to be true
    end
  end


end

end
end
