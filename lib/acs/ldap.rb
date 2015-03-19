require 'rails'
require 'net/ldap'
require "acs/ldap/version"

require "acs/ldap/logger"
require "acs/ldap/result"
require "acs/ldap/connector"
require "acs/ldap/model"

module Acs
  module Ldap

    def self.logger
      @logger || Acs::Ldap::Logger
    end

    def self.logger=(logger)
      @logger = logger
    end

    class Railtie < ::Rails::Railtie
      initializer :acs_ldap do |app|
        Acs::Ldap.logger = Rails.logger
      end
    end

  end
end
