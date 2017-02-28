require "spec_helper"
require "service_providers/pact_helper"

module GitAclShell
module Directory

describe HTTPDirectory, :pact => true do
  before do
    HTTPDirectory.base_uri 'localhost:1234'
  end

  let(:directory) { HTTPDirectory.new }

  it "returns the real name when an alias exists" do
    acl_service.given("alias is an alias of repo-base-name")
      .upon_receiving("a repo base name lookup by alias")
      .with(method: :get, path: '/repo-base-name', query: 'alias=alias-for-the-real-repo')
      .will_respond_with(
        status: 200,
        headers: {'Content-Type' => 'text/plain; charset=utf-8'},
        body: 'the-real-repo'
      )
    expect(directory.lookup('alias-for-the-real-repo')).to eq('the-real-repo')
  end

  it "raises an UnknownAlias error when the alias does not exist" do
    acl_service.given("an unknown alias")
      .upon_receiving("a repo base name lookup by alias")
      .with(method: :get, path: '/repo-base-name', query: 'alias=unknown-alias')
      .will_respond_with(status: 404)
    expect { directory.lookup('unknown-alias') }.to raise_error(UnknownAlias)
  end
end

end
end
