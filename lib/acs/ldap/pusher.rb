class Acs::Ldap::Pusher

  # connector : Acs::Ldap::Connector instance
  # options[:mapper] : directly set a mapper at initialization
  def initialize(connector, options = {})
    @connector = connector
    @mapper = options[:mapper] || nil
  end

  def mapper=(mapper)
    @mapper = mapper
  end

  def save(model, options = {})
    if exist?(model)
      update(model)
    else
      create(model)
    end
  end

  def index
    filter = Net::LDAP::Filter.pres('uid')
    @connector.search({base: base, filter: filter})
  end

  def create(model, options = {})
    attributes = @mapper.attributes(model).except!(:uid)
    attributes.merge!(objectClass: @mapper.object_class)

    Acs::Ldap.logger.debug "Pusher#create dn '#{dn(model)}' attributes '#{attributes.inspect}'"

    @connector.add(
      dn(model),
      attributes
    )
  end

  def update(model, options = {})
    changes = options.fetch(:changes, nil)
    attributes = @mapper.attributes(model).except(:uid)
    operations = []
    attributes.each do |key, value|
      if attributes.nil? or attributes.include?(key)
        if changes.nil?
          operations << [:replace, key.to_s, value]
        else
          operations << [:replace, key.to_s, value] if changes.has_key?(key)
        end
      end
    end

    @connector.update(
      dn(model),
      operations
    )
  end

  def destroy(model, options = {})
    @connector.delete(dn(model))
  end

  def flush
    @connector.delete_all(ou)
  end

  def exist?(model)
    @connector.search({base: dn(model)}).data.length > 0
  end

  def find_by(key, value)
    @connector.search_by(
      base,
      key,
      value
    )
  end

  def count
    filter = Net::LDAP::Filter.pres('uid')
    @connector.search({base: base, filter: filter}).data.count
  end

  def connector
    @connector
  end

protected

  def ou
    @mapper.ou
  end

  def base
    "ou=#{ou},#{@connector.base}"
  end

  def dn(model)
    "uid=#{@mapper.uid(model)},#{base}"
  end

end
