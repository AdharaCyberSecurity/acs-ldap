class Acs::Ldap::Model

  def initialize(connector, options = {})
    @connector = connector
    @id = options[:id] || :id
  end

  def ou
    @ou
  end

  def base
    "ou=#{ou},#{@connector.base}"
  end

  def dn(model)
    "uid=#{model.send @id},#{base}"
  end

  def find_by(key, value)
    @connector.search_by(
      base,
      key,
      value
    )
  end

  def create(model)
    attributes = attributes(model).except!(:uid)
    attributes.merge!(objectClass: object_class)

    @connector.add(
      dn(model),
      #base,
      attributes
    )
  end

  def update(model, attributes = nil)
    operations = []
    update_attributes = []
    update_attributes << attributes
    update_attributes.flatten
    attributes(model).each do |sym, value|
      if attributes == nil || update_attributes.include?(sym)
        operations << [:replace, sym.to_s, value] unless sym.to_s == "uid"
      end
    end
    @connector.update(
      dn(model),
      operations
    )
  end

  def destroy(model)
    @connector.delete(dn(model))
  end

  def flush
    @connector.delete_all(ou)
  end

  def count
    count = 0
    @connector.search({base: base}).data.each do |entry|
      count += 1 if entry[:uid].present?
    end
    count
  end

protected

  def logger
    Acs::Ldap::Logger
  end

end
