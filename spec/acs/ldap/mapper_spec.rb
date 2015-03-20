require 'spec_helper'

describe Acs::Ldap::Mapper, order: :defined do

  class TestObject
    def initialize(value, value2 = 'value2')
      @val = value
      @val2 = value2
    end
    def get
      @val
    end

    def get2
      @val2
    end
  end

  before(:context) do

  end

  before(:each) do
    Acs::Ldap::Mapper.send(:public, *Acs::Ldap::Mapper.protected_instance_methods)
    @array = [[[1, 2], 3], 4]
    @simple_object = TestObject.new('test')
    @nested_object = TestObject.new(TestObject.new('test'))
  end

  it "should be possible to use chain_methods" do
    expect(Acs::Ldap::Mapper.new(nil, nil, nil).chain_methods(@array, 'shift.shift.shift')).to eq 1
    expect(Acs::Ldap::Mapper.new(nil, nil, nil).chain_methods(@simple_object, :get)).to eq 'test'
    expect(Acs::Ldap::Mapper.new(nil, nil, nil).chain_methods(@nested_object, 'get.get')).to eq 'test'
  end

  it "should be possible to use chain_methods with a specific method separator" do
    expect(Acs::Ldap::Mapper.new(nil, nil, nil).chain_methods(@array, 'shift:shift:shift', {separator: ':'})).to eq 1
    expect(Acs::Ldap::Mapper.new(nil, nil, nil).chain_methods(@nested_object, 'get:get', {separator: ':'})).to eq 'test'
  end

  it "should be possible to fetch an nested_object value with get" do
    expect(Acs::Ldap::Mapper.new({value: 'get.get'}, nil, nil).get(:value, @nested_object)).to eq 'test'
    expect(Acs::Ldap::Mapper.new({value: :get}, nil, nil).get(:value, @simple_object)).to eq 'test'
  end

  it "should be possible to fetch UID with shortcut method" do
    expect(Acs::Ldap::Mapper.new({uid: 'get.get'}, nil, nil).uid(@nested_object)).to eq 'test'
    expect(Acs::Ldap::Mapper.new({uid: :get}, nil, nil).uid(@simple_object)).to eq 'test'
  end

  it "should be possible to fetch all attributes" do
    mapper = Acs::Ldap::Mapper.new({uid: :get, sn: :get2}, nil, nil)
    expected_result = {uid: 'test', sn: 'value2'}
    expect(mapper.attributes(@simple_object)).to eq expected_result
  end

end
