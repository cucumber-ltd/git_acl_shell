require 'pact/consumer/rspec'

Pact.service_consumer "Git ACL Shell" do
  has_pact_with "Git ACL Service" do
    mock_service :acl_service do
      port 1234
    end
  end
end
