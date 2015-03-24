class Acs::Ldap::Connector

  def initialize(options = {})
    @host     = options[:host] || '127.0.0.1'
    @port     = options[:port] || 389
    @base     = options[:base] || nil
    @dn       = options[:dn] || nil
    @password = options[:password] || nil
    @tls      = options[:tls] || false

    @connected = false
  end

  def ldap_params
    ldap_params = {
      host: @host,
      port: @port,
      base: @base,
      auth: {
        method: :simple, #other method ?
        username: @dn,
        password: @password
      }
    }

    ldap_params[:encryption] = :simple_tls if @tls

    logger.debug "Connection params: #{ldap_params}"

    ldap_params
  end

  def search(options = {})
    base        = options[:base] || nil
    filter      = options[:filter] || nil # instance of Net::LDAP::Filter
    attributes  = options[:attributes] || nil
    logger.info "Search base '#{base}' filter '#{filter}' attributes '#{attributes}'"
    entries = []
    get_connection.search({base: base, filter: filter, attributes: attributes}) do |entry|
      entries << entry
    end
    result = Acs::Ldap::Result.new(get_connection.get_operation_result, entries)
    logger.info "Search result #{result}"
    result
  end

  def search_by(base, key, value, attributes = nil)
    filter = Net::LDAP::Filter.eq(key, value.to_s)
    search({base: base, filter: filter, attributes: attributes})
  end

  def search_one(base, key, value, attributes = nil)
    result = search_by(base, key, value, attributes)
    if result.data.count > 0
      result.data[0]
    else
      nil
    end
  end

  def add(dn, attributes)
    #debugger
    logger.info "Add dn '#{dn}'  attributes '#{attributes.inspect}'"
    get_connection.add(dn: dn, attributes: attributes)
    result = Acs::Ldap::Result.new(get_connection.get_operation_result)
    logger.info "Add result #{result}"

    result
  end

  def update(dn, operations)
    logger.info "Modify dn '#{dn}' operations '#{operations.inspect}'"
    get_connection.modify(dn: dn, operations: operations)
    result = Acs::Ldap::Result.new(get_connection.get_operation_result)
    logger.info "Modify result #{result}"

    result
  end

  def delete(dn)
    logger.info "Delete dn '#{dn}'"
    get_connection.delete(dn: dn)
    result = Acs::Ldap::Result.new(get_connection.get_operation_result)
    logger.info "Delete result #{result}"

    result
  end

  def delete_all(ou)
    logger.info "Delete all ou=#{ou}"
    search({base: "ou=#{ou},#{base}", attributes: 'uid'}).data.each do |entry|
      delete(entry[:dn].first) if entry[:uid].present?
    end
  end

  def base
    @base
  end

  def close_connection
    if @connected
      @ldap = nil
    end
    @connected = false
  end

  def get_connection
    if @connected
      @ldap
    else
      @ldap = connect
    end
    @ldap
  end

protected

  # get_connection should be used
  def connect
    logger.debug "LDAP connect"
    if ! @connected
      logger.debug "Binding to ldap..."
      @ldap = Net::LDAP.new(ldap_params)
      begin
        if @ldap.bind
          logger.debug "Connection succeed"
          @connected = true
        else
          @connected = false
          @ldap = nil
          logger.debug "Connection failed"
        end
      rescue Net::LDAP::Error => e
        logger.error "Connection refused '#{e.inspect}'"
        @connected = false
        @ldap = nil
      end
      @ldap
    else
      @logger.debug "LDAP already connected"
      nil
    end
  end

  def logger
    Acs::Ldap.logger
  end

end
