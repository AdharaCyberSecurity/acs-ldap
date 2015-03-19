class Acs::Ldap::Result
  def initialize(result, data = nil, log = false)
    @code = result.code
    @dn = result.matched_dn
    @message = result.message
    @data = data
    logger.info to_s if log
  end

  def success?
    @code == 0
  end

  def code
    @code
  end

  def dn
    @dn
  end

  def message
    @message
  end

  def data=(data)
    @data = data
  end

  def data
    @data
  end

  def to_s
    result = success? ? 'SUCCESS' : 'ERROR'
    "#{result} return code:#{@code}, matched_dn: #{@dn}, message:#{@message}, data:#{@data.inspect}"
  end

  def logger
    Acs::Ldap.logger
  end
end
