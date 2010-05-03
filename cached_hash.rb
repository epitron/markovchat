module HashWithCachedKeys

  def self.included(klass)
    klass.extend(ClassMethods)
    klass.invalidate_on :[]=, :update!, :merge!
  end

  module ClassMethods
    
    def invalidate_on(*meths)
      for meth in meths
        class_eval %{
          def #{meth}(*args)
            invalidate!
            super(*args)
          end
        }
      end
    end
    
  end

  ############################################################
  ## Instance Methods
  
  def keys
    @cached_keys ||= super
  end

  def invalidate!
    puts "INVALIDATE!"
    @cached_keys = nil
    self
  end
  
  def random_key
    keys[ rand(keys.size) ]
  end
    
  def find_random_key(&block)
    ks = keys
    start_at = rand(@cached_keys.size)
    
    (start_at...@cached_keys.size).each do |n|
      return @cached_keys[n] if yield(@cached_keys[n])
    end
    
    (0...start_at).each do |n|
      return @cached_keys[n] if yield(@cached_keys[n])
    end
    
    nil
  end
  
end


class CachedHash < Hash
  include HashWithCachedKeys
end

class Hash
  def to_cached_hash
    CachedHash.new.merge(self)
  end
end
