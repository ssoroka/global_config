# use GlobalConfig.setting_name to get and set database values.
# eg. GlobalConfig.admin_email = 'john@mydomain.com'
#     GlobalConfig.admin_email # now set to 'john@mydomain.com'
#
# Note for the caching to work properly in production across multiple servers you'll want to use
# something like Memcached, and not Rails' default memory_cache
class GlobalConfig < ActiveRecord::Base
  class << self
    def method_missing(method, *args)
      key = method.to_s.gsub(/\=$/, '')
      if method.to_s =~ /\=$/
        set(key, *args)
      else
        get(key)
      end
    end
    
    def get(key)
      value = value_for_key(key)
      YAML::load(value) if value
    end

    def set(key, value)
      record = record_for_key(key) || new(:key => key)
      record.update_attribute(:value, value.to_yaml)
      Rails.cache.write(key, value.to_yaml)
    end
    
    def record_for_key(key)
      first(:conditions => ['key = ?', key])
    end
    
    def value_for_key(key)
      Rails.cache.fetch(key) {
        record_for_key(key).try(:value)
      }
    end
  end
end
