module SmartEnv
  EXPLICITLY_FALSE_VALUES = [0, "0", "false", "no"]

  def self.keys
    @keys ||= []
  end

  def self.default_values
    @default_values ||= {}
  end

  def self.required_keys
    @required_keys ||= []
  end

  def self.boolean_keys
    @boolean_keys ||= []
  end

  def self.hash_keys
    @hash_keys ||= []
  end

  def self.reset!
    @keys = nil
    @required_keys = nil
    @boolean_keys = nil
    @hash_keys = nil
    @default_values = nil
  end

  def self.set key, opts={}
    self.add key, opts
  end

  def self.add key, opts={}
    key = key.to_s
    keys << key unless keys.include?(key)
    if opts.has_key?(:required)
      required_keys.delete key
      required_keys << key if opts[:required]
    end
    if opts.has_key?(:boolean)
      boolean_keys.delete key
      boolean_keys << key if opts[:boolean]
    end
    if opts.has_key?(:hash) || opts[:default].is_a?(Hash)
      hash_keys.delete key
      hash_keys << key if opts[:hash] || opts[:default].is_a?(Hash)
    end
    if opts.has_key?(:default)
      default_values[key] = opts[:default]
    end
  end

  def self.add_required key, opts={}
    self.add key, opts.update({required: true})
  end

  def self.add_boolean key, opts={}
    self.add key, opts.update({boolean: true})
  end

  def self.check!
    required_keys.each do |k|
      raise MissingKey.new("Missing mandatory ENV key `#{k}`") unless ENV.has_key?(k)
    end
  end

  def self.[] key
    self.fetch(key)
  end

  def self.boolean key, opts={}
    self.fetch key, opts.update({boolean: true})
  end

  def self.hash key, opts={}
    self.fetch key, opts.update({hash: true})
  end

  def self.fetch key, opts={}
    key = key.to_s
    unless keys.include?(key)
      logger.warn("Fetching unexpected ENV key `#{key}`")
      keys << key
    end

    is_hash = opts[:hash] || hash_keys.include?(key)
    is_boolean = opts[:boolean] || boolean_keys.include?(key)

    default = nil
    default = opts[:default] if opts.has_key?(:default)
    default = yield if block_given?
    default ||= default_values[key]
    default ||= {} if is_hash
    default ||= false if is_boolean

    val = ENV.fetch(key, nil)
    if val
      val = cast_boolean(val) if is_boolean
      val = cast_hash(val) if is_hash
    end
    val || default
  end

  @@default_logger = nil
  def self.default_logger
    @@default_logger ||= Logger.new($stdout)
  end

  def self.logger
    Rails.logger || default_logger
  end

  def self.cast_boolean value
    value = value.downcase if value.is_a?(String)
    return false if EXPLICITLY_FALSE_VALUES.include?(value)
    return value.present? if value.is_a?(String)
    !!value
  end

  def self.cast_hash value
    JSON.parse(value, symbolize_names: true) rescue nil
  end

  class MissingKey < Exception
  end
end
