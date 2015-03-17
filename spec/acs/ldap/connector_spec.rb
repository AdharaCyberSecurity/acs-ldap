require 'spec_helper'

describe Acs::Ldap::Connector, order: :defined do
  before(:context) do
    @connector = Acs::Ldap::Connector.new({host: '192.168.59.103', port: 49389, base: "dc=adharacs,dc=lan", dn: "cn=admin,dc=adharacs,dc=lan", password: "admin"})
  end

  it "should be possible to create a connector" do
    expect(@connector).not_to be_nil
  end

  it "should be possible to create a connection" do
    expect(@connector.get_connection()).not_to be_nil
  end

  it "should be possible to search without specs" do
    expect(@connector.search()).not_to be_nil
  end

  it "should be possible to add a user" do
    result = @connector.add(
    "uid=1,ou=people,dc=adharacs,dc=lan",
    {
      sn: "john.doe",
      cn: "John Doe",
      givenName: "John Doe",
      mail: "john.doe@adharacs.lan",
      userPassword: "{SSHA}+MBMtUqzkOeH8hI1KVnl+djdqzw0YmU5M2Y5MmQyOTgxMDU1",
      objectClass: [
        "organizationalPerson",
        "person",
        "top",
        "extensibleObject"
      ]
    }
    )
    expect(result.success?).to eq true
  end

  it "should be possible to find a user" do
    result = @connector.search_by(
      "ou=people,dc=adharacs,dc=lan",
      'mail',
      'john.doe@adharacs.lan',
      'mail'
    )
    expect(result.success?).to eq true
    expect(result.data.length).to eq 1
  end

  it "should be possible to remove a user" do
    result = @connector.delete(
    "uid=1,ou=people,dc=adharacs,dc=lan"
    )
    expect(result.success?).to eq true
  end

end
