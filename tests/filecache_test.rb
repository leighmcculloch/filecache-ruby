require 'filecache'
require 'test/unit'

class FileCacheTest < Test::Unit::TestCase
  KEY1 = "key1"
  VALUE1 = "value1"
  VALUE2 = "value2"
  
  def test_basic
    f = FileCache.new("unit-test", "/tmp")
    
    f.set(KEY1, VALUE1)
    assert_equal(f.get(KEY1), VALUE1, "set/get")
    
    f.delete(KEY1)
    assert_nil(f.get(KEY1), "delete")

    f.set(KEY1, VALUE1)
    assert_equal(f.get(KEY1), VALUE1, "set on previously deleted key")
    
    f.set(KEY1, VALUE2)
    assert_equal(f.get(KEY1), VALUE2, "set new value on previously set key")
    
    f.purge
    assert_equal(f.get(KEY1), VALUE2, "purge has no effect on cache with expiry=0")
    
    f.clear
    assert_nil(f.get(KEY1), "clear removes previously set value")
  end
end
