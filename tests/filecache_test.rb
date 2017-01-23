require 'filecache'
require 'test/unit'

class FileCacheTest < Test::Unit::TestCase
  KEY1 = "key1"
  KEY2 = "key2"
  VALUE1 = "value1"
  VALUE2 = "value2"
  
  def test_basic
    f = FileCache.new("unit-test", "/tmp")
    
    f.set(KEY1, VALUE1)
    assert_equal(f.get(KEY1), VALUE1, "set/get")
    
    f.delete(KEY1)
    assert_nil(f.get(KEY1), "delete")
    
    assert_equal(
      f.get_or_set(KEY1) do
        VALUE1
      end,
      VALUE1,
      "set_or_get"
    )
    
    assert_equal(
      f.get_or_set(KEY1) do
        VALUE2
      end,
      VALUE1,
      "set_or_get"
    )

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

  class SlowValueClass
    # This value will be slow when marshalled
    def value
      sleep 1
      "slow_value"
    end

    def marshal_dump
      [value]
    end
  end

  def test_concurrency
    logger = Class.new do
      def warn(*args)
        warnings << args.join(' ')
      end

      def warnings
        @warnings ||= []
      end
    end.new

    f = FileCache.new("unit-test", "/tmp", nil, nil, logger)
    f.clear

    slow_thread = Thread.new do
      f.set(KEY2, SlowValueClass.new)
    end
    fast_thread = Thread.new do
      sleep 0.5 # make sure slow_thread is has got to the point of writing the value and the cache file is open
      assert_nil(f.get(KEY2), "get returns true because the file is open and results in EOFError")
    end
    fast_thread.join
    slow_thread.join

    assert_true(logger.warnings.length == 1, "Warning is sent to the logger")
    assert_true(logger.warnings[0].include?('EOFError'))
    f.clear
  end
end
