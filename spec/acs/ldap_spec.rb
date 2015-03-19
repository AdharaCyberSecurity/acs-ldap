require 'spec_helper'

describe Acs::Ldap do
  it "should have a default logger" do
    expect(Acs::Ldap.logger).not_to be nil
  end
end
