require 'cached_hash'

class CachedHash
  attr_accessor :cached_keys
end

describe CachedHash do

  specify "initializing from a hash" do
    h = CachedHash.new.merge 5=>1, 1=>5
    h.keys.sort.should == [1,5]
    h.cached_keys.sort.should == [1,5]
  end
  
  specify "setting items" do
    h = CachedHash.new
    
    h[1] = 5
    h.keys.should == [1]
    h.cached_keys.should == [1]
    
    h[5] = 2
    h.keys.sort.should == [1,5]
    h.cached_keys.sort.should == [1,5]
    
    h.cached_keys.hash.should == h.keys.hash
  end

  specify "convertable" do
    {}.to_cached_hash.is_a?(CachedHash).should == true
  end
  
end
