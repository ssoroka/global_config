class Object
  def try(arg)
    send(arg) if respond_to?(arg)
  end
end

class ActiveRecord
  class Base
    def initialize(options = {})
      @key = options[:key]
      @value = options[:value]
    end
    
    def self.first(options)
      key = options[:conditions].last
      @@records.detect{|r| r.instance_variable_get("@key") == key}
    end
    
    def self.create!(options)
      @@records << self.new(options)
    end
    
    def update_attribute(k, v)
      instance_variable_set("@#{k}", v)
      @@records << self unless @@records.include?(self)
    end
    
    def value
      @value
    end
  end
end

class Rails
  def self.cache
    @@cache ||= FakeCache.new
  end
  
  def self.reset_cache
    @@cache = nil
  end
end

class FakeCache
  def fetch(key, &b)
    @cache ||= {}
    if @cache[key]
      @cache[key]
    else
      @cache[key] = b.call
    end
  end
  
  def write(key, val)
    @cache ||= {}
    @cache[key] = val
  end
end
