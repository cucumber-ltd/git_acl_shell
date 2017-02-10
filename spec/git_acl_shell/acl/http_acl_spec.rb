require "spec_helper"
require "service_providers/pact_helper"

module GitAclShell
module Acl

describe HTTPAcl, :pact => true do
  before do
    HTTPAcl.base_uri 'localhost:1234'
  end

  let(:acl) { HTTPAcl.new }

  it "grants access when the key id is allowed to access the repo" do
    acl_service.given("some-key-id is allowed to access /home/git/alias.git")
      .upon_receiving("a permission request")
      .with(method: :get, path: '/permission', query: 'keyId=some-key-id&alias=/home/git/alias.git')
      .will_respond_with(status: 200)

    expect(acl.authorized?('some-key-id', '/home/git/alias.git')).to be true
  end

  it "denies access when the key id is not allowed to access the repo" do
    acl_service.given("some-key-id is not allowed to access /home/git/alias.git")
      .upon_receiving("a permission request")
      .with(method: :get, path: '/permission', query: 'keyId=some-key-id&alias=/home/git/alias.git')
      .will_respond_with(status: 403)

    expect(acl.authorized?('some-key-id', '/home/git/alias.git')).to be false
  end
end

end
end
