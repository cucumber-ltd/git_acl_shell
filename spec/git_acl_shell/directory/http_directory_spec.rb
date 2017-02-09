require "spec_helper"
require "service_providers/pact_helper"

module GitAclShell
module Directory

describe HTTPDirectory, :pact => true do
  before do
    HTTPDirectory.base_uri 'localhost:1234'
  end

  before do
    alias_service.given("an alias is defined").
      upon_receiving("a lookup").
      with(method: :get, path: '/real-name', query: 'alias=/home/git/alias.git').
      will_respond_with(
        status: 200,
        headers: {'Content-Type' => 'text/plain; charset=utf-8'},
        body: '/home/git/real-name.git' )
  end

  let(:directory) { HTTPDirectory.new }

  it "looks up an alias" do
    expect(directory.lookup('/home/git/alias.git')).to eq('/home/git/real-name.git')
  end
end

end
end
