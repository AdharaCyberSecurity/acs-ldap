require 'spec_helper'

describe Acs::Ldap::Pusher, order: :defined do

  before(:each) do
    @connector = Acs::Ldap::Connector.new({host: '192.168.59.103', port: 49389, base: "dc=adharacs,dc=lan", dn: "cn=admin,dc=adharacs,dc=lan", password: "admin"})
    @mapper = Acs::Ldap::Mapper.new(
      {
        uid: :id,
        sn: :sn,
        cn: :cn,
        givenName: :givenName,
        mail: :mail,
        userPassword: :userPassword
      },
      [
        "organizationalPerson",
        "person",
        "top",
        "extensibleObject"
      ],
      'people',
      {
        force_method_calls: true
      }
    )
    @pusher = Acs::Ldap::Pusher.new(@connector, {mapper: @mapper})
    @pusher.mapper = @mapper
    @user = User.new({id: 2, sn: "dark.vador", cn: "dark.vador", givenName: "Dark Vador", userPassword: "{SSHA}+MBMtUqzkOeH8hI1KVnl+djdqzw0YmU5M2Y5MmQyOTgxMDU1", mail: "dvador@adharacs.lan"})
  end

  it "should be possible to flush an OU" do
    @pusher.flush
    expect(@pusher.count).to eq 0
  end

  it "should be possible to create a User" do
    expect(@pusher.create(@user).success?).to eq true
    expect(@pusher.count).to eq 1
  end

  it "should be possible to update a User" do
    @user.givenName = "Vador Dark"
    expect(@pusher.update(@user).success?).to eq true
    expect(@pusher.find_by('uid', 2).data[0][:givenName]).to eq ["Vador Dark"]
  end

  it "should be possible to update only an attribute for a User" do
    @user.givenName = "D V"
    @user.mail = "dv@adharacs.lan"
    expect(@pusher.update(@user, {changes: {givenName: ["Vador Dark" => "D V"]}}).success?).to eq true
    expect(@pusher.find_by('uid', 2).data[0][:givenName]).to eq ["D V"]
    expect(@pusher.find_by('uid', 2).data[0][:mail]).to eq ["dvador@adharacs.lan"]
  end

  it "should be possible to remove a User" do
    expect(@pusher.destroy(@user).success?).to eq true
    expect(@pusher.count).to eq 0
  end

  it "should be possible to check if a User exists" do
    @pusher.flush
    expect(@pusher.exist?(@user)).to eq false
    @pusher.create(@user)
    expect(@pusher.exist?(@user)).to eq true
    @pusher.flush
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
