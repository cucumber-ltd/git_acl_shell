require "spec_helper"
require "service_providers/pact_helper"

module GitAclShell
module Directory

describe HTTPDirectory, :pact => true do
  before do
    HTTPDirectory.base_uri 'localhost:1234'
  end

  let(:directory) { HTTPDirectory.new }

  describe "successful lookup" do
    before do
      acl_service.given("alias is an alias of real-name")
        .upon_receiving("a real repo name lookup by alias")
        .with(method: :get, path: '/real-name', query: 'alias=/home/git/alias.git')
        .will_respond_with(
          status: 200,
          headers: {'Content-Type' => 'text/plain; charset=utf-8'},
          body: '/home/git/real-name.git'
        )
    end

    it "returns the real name" do
      expect(directory.lookup('/home/git/alias.git')).to eq('/home/git/real-name.git')
    end
  end

  describe "unsuccesful lookup" do
    before do
      acl_service.given("an unknown alias")
        .upon_receiving("a real repo name lookup by alias")
        .with(method: :get, path: '/real-name', query: 'alias=/home/git/unknown-alias.git')
        .will_respond_with(
          status: 404,
          headers: {'Content-Type' => 'text/plain; charset=utf-8'},
          body: '' )
    end

    it "raises an UnknownAlias error" do
      expect { directory.lookup('/home/git/unknown-alias.git') }.to raise_error(UnknownAlias)
    end
  end
end

end
end
