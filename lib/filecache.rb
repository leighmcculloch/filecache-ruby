require 'digest/md5'
require 'fileutils'
require 'thread'

# A file-based caching library. It uses Marshal::dump and Marshal::load
# to serialize/deserialize cache values - so you should be OK to cache
# object values.
class FileCache

  MAX_DEPTH = 32
  MUTEX_DEPTH = 2

  # Create a new reference to a file cache system.
  # domain:: A string that uniquely identifies this caching
  #          system on the given host
  # root_dir:: The root directory of the cache file hierarchy
  #            The cache will be rooted at root_dir/domain/
  # expiry:: The expiry time for cache entries, in seconds. Use
  #          0 if you want cached values never to expire.
  # depth:: The depth of the file tree storing the cache. Should
  #         be large enough that no cache directory has more than
  #         a couple of hundred objects in it
  # logger:: optional Ruby Logger object or Logger interface
  def initialize(domain = "default", root_dir = "/tmp", expiry = nil, depth = nil, logger = nil, use_mutex = true)
    @domain  = domain
    @root_dir = root_dir
    @expiry  = expiry || 0
    @depth   = [depth || 2, MAX_DEPTH].min
    @root    = nil # define to avoid instance variable @root not initialized
    @logger  = logger
    @mutexes = use_mutex ? {} : nil

    FileUtils.mkdir_p(get_root)
  end

  # Set a cache value for the given key. If the cache contains an existing value for
  # the key it will be overwritten.
  def set(key, value)
    with_mutex(key) do
      f = File.open(get_path(key), "w")
      Marshal.dump(value, f)
      f.close
    end
  end

  # Return the value for the specified key from the cache. Returns nil if
  # the value isn't found.
  def get(key)
    with_mutex(key) do
      path = get_path(key)

      # expire
      if @expiry > 0 && File.exist?(path) && Time.new - File.new(path).mtime >= @expiry
        FileUtils.rm(path)
      end

      if File.exist?(path)
        f = File.open(path, "r")
        result = Marshal.load(f)
        f.close
        return result
      else
        return nil
      end
    end
  rescue EOFError => e
    # See https://www.ruby-forum.com/topic/194747
    logger.warn "EOFError whilst getting key #{key}. Race condition where key file is probably still being written. Err: #{e}" if logger
    return nil
  end

  # Return the value for the specified key from the cache if the key exists in the
  # cache, otherwise set the value returned by the block. Returns the value if found
  # or the value from calling the block that was set.
  def get_or_set(key)
    value = get(key)
    return value if value
    value = yield
    set(key, value)
    value
  end

  # Delete the value for the given key from the cache
  def delete(key)
    with_mutex(key) do
      FileUtils.rm(get_path(key))
    end
  end

  # Delete ALL data from the cache, regardless of expiry time
  # Mutex cannot be used here as the Mutex is calculated from key yet there is no key
  def clear
    if File.exist?(get_root)
      FileUtils.rm_r(get_root)
      FileUtils.mkdir_p(get_root)
    end
  end

  # Delete all expired data from the cache
  def purge
    @t_purge = Time.new
    purge_dir(get_root) if @expiry > 0
  end

#-------- private methods ---------------------------------
private
  def logger
    @logger
  end

  def mutexes
    @mutexes
  end

  def depth
    @depth
  end

  def get_path(key)
    md5 = get_md5(key)
    dir = File.join(get_root, md5.split(//)[0...depth])
    FileUtils.mkdir_p(dir)
    return File.join(dir, md5)
  end

  # Create a mutex up to two levels deep
  # i.e. to prevent a lock now being present for every cache read / write
  #      we instead have 255 mutexes based on first two Hex chars of key hash
  def with_mutex(key)
    if mutexes.nil?
      yield
    else
      mutex_depth = [depth, MUTEX_DEPTH].min
      md5 = get_md5(key)
      mutex_key = md5.split(//)[0...mutex_depth].join(':')
      mutexes[mutex_key] ||= Mutex.new
      mutexes[mutex_key].synchronize do
        yield
      end
    end
  end

  def get_md5(key)
    Digest::MD5.hexdigest(key.to_s).to_s
  end

  def get_root
    if @root == nil
      @root = File.join(@root_dir, @domain)
    end
    return @root
  end

  def purge_dir(dir)
    Dir.foreach(dir) do |f|
      next if f =~ /^\.\.?$/
      path = File.join(dir, f)
      if File.directory?(path)
        purge_dir(path)
      elsif @t_purge - File.new(path).mtime >= @expiry
        # Ignore files starting with . - we didn't create those
        next if f =~ /^\./
        FileUtils.rm(path)
      end
    end

    # Delete empty directories
    if Dir.entries(dir).delete_if{|e| e =~ /^\.\.?$/}.empty?
      Dir.delete(dir)
    end
  end
end
