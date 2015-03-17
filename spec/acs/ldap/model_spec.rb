require 'spec_helper'

describe Acs::Ldap::Model, order: :defined do
  before(:context) do
    @connector = Acs::Ldap::Connector.new({host: '192.168.59.103', port: 49389, base: "dc=adharacs,dc=lan", dn: "cn=admin,dc=adharacs,dc=lan", password: "admin"})
    @user_model = UserModel.new(@connector)
    @user = User.new({uid: 2, sn: "dark.vador", cn: "dark.vador", givenName: "Dark Vador", userPassword: "{SSHA}+MBMtUqzkOeH8hI1KVnl+djdqzw0YmU5M2Y5MmQyOTgxMDU1", mail: "dvador@adharacs.lan"})
  end

  it "should be possible to flush an OU" do
    @user_model.flush
    expect(@user_model.count).to eq 0
  end

  it "should be possible to create a User" do
    expect(@user_model.create(@user).success?).to eq true
    expect(@user_model.count).to eq 1
  end

  it "should be possible to update a User" do
    @user.givenName = "Vador Dark"
    expect(@user_model.update(@user, :givenName).success?).to eq true
    expect(@user_model.find_by('uid', 2).data[0][:givenName]).to eq ["Vador Dark"]
  end

  it "should be possible to remove a User" do
    expect(@user_model.destroy(@user).success?).to eq true
    expect(@user_model.count).to eq 0
  end

  class UserModel < Acs::Ldap::Model
    def initialize(connector, ou = nil)
      @ou = ou || 'people'
      super(connector, {id: :uid})
    end

    def attributes(user)
      {
        uid: user.id,
        sn: user.sn,
        cn: user.cn,
        givenName: user.givenName,
        mail: user.mail,
        userPassword: user.userPassword
      }
    end

    def object_class
      [
        "organizationalPerson",
        "person",
        "top",
        "extensibleObject"
      ]
    end
  end

  class User

    def initialize(options = {})
      @options = options
    end

    def method_missing(method_sym, *args, &block)
      if args.length > 0
        @options[method_sym.to_s.gsub(/=/,'').to_sym] = args[0]
      else
        @options[method_sym] || nil
      end
    end

    def to_s
      @options.inspect
    end

  end

end
