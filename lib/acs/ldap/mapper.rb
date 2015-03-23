class Acs::Ldap::Mapper

  # mapping
  # [key: method, key: method] => [uid: :id, sn: 'object.other_object.sn']]
  #
  # object_class
  # ["top", "extensibleObject"]
  #
  # options
  # method_separator => used to separate methods call if they are composed
  # force_method_calls => perform method calls even if object#respond_to? :method returns false (util when method_missing is used)
  def initialize(mapping, object_class, ou, options = {})
    @mapping = mapping
    @object_class = object_class
    @ou = ou
    @method_separator = options[:method_separator] || '.'
    @force_method_calls = options[:force_method_calls] || false
    Acs::Ldap::logger.debug "Acs::Ldap::Mapper with options methods_separator '#{@method_separator}' force_method_calls '#{@force_method_calls}'"
  end

  # Populate a hash based on the provided mapping and object
  def attributes(object)
    attributes = {}
    @mapping.each do |key, method|
      attributes[key.to_sym] = chain_methods(object, method, {method_separator: @method_separator, force_method_calls: @force_method_calls}) # unless key.to_sym == :uid
    end
    attributes
  end

  # return the object classes
  def object_class
    @object_class
  end

  # returns the value correponding to the key of the object based on the provided mapping
  def get(key, object)
    if @mapping.has_key?(key)
      chain_methods(object, @mapping[key], {method_separator: @method_separator, force_method_calls: @force_method_calls})
    else
      Acs::Ldap::logger.error "Acs::Ldap::Mapper Error while trying to fetch key '#{key}' on object '#{object}' with mapping '#{@mapping}'"
      nil
    end
  end

  # shortcut method
  def uid(object)
    get(:uid, object)
  end

  # get the ou (eg. 'people')
  def ou
    @ou
  end

protected

  # go deeper in objects
  def chain_methods(object, chain_method, options = {})
    separator = options[:separator] || '.'
    force_method_calls = options[:force_method_calls] || false
    Acs::Ldap.logger.debug "Acs::Ldap::Mapper chain_method on object '#{object}' with chain '#{chain_method}' separator '#{separator}' force_method_calls '#{force_method_calls}'"
    methods = chain_method.to_s.split(separator)
    if methods.length > 1
      method = methods.shift.to_sym
      if object.respond_to?(method) || force_method_calls
        child_object = object.send(method)
        return chain_methods(child_object, methods.join(separator), options)
      else
        Acs::Ldap.logger.debug "Acs::Ldap::Mapper chain_method returns 'nil'"
        return nil
      end
    else
      if object.respond_to?(methods[0].to_sym) || force_method_calls
        value = object.send(methods[0].to_sym)
        Acs::Ldap.logger.debug "Acs::Ldap::Mapper chain_method returns '#{value}'"
        return value
      else
        Acs::Ldap.logger.debug "Acs::Ldap::Mapper chain_method ended without result, returning 'nil'"
        return nil
      end
    end
  end


  def _chain_methods(object, chain_method, options = {})
    separator = options[:separator] || '.'
    force_method_calls = options[:force_method_calls] || false
    Acs::Ldap.logger.debug "Acs::Ldap::Mapper chain_method on object '#{object}' with chain '#{chain_method}' separator '#{separator}'"
    methods = chain_method.to_s.split(separator)
    if methods.length > 1
      method = methods.shift.to_sym
      child_object = object.send(method)
      return chain_methods(child_object, methods.join(separator), options)
    else
      value = object.send(methods[0].to_sym)
      Acs::Ldap.logger.debug "Acs::Ldap::Mapper chain_method returns '#{value}'"
      return value
    end
  end

end
