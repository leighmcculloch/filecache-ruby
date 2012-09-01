FileCache is a file-based caching library for Ruby. It's 
available for download from [RubyForge][rubyforge-filecache]

# Note about the current code

I haven't touched this code since I wrote it in 2008! I don't
use Ruby much any more. I'm putting it on Github to make it easy
for people to find, tweak and extend it. Please feel free to 
drag it into the 21st century and send me pull requests.

# Installation

    gem install -r filecache
 
(On a Unix-like system you'll probably want to run that with sudo.)

# Synopsis

```ruby
require 'rubygems'
require 'filecache'

cache = FileCache.new
cache.set(:key, "value")
puts cache.get(:key)     # "value"
cache.delete(:key)
puts cache.get(:key)     # nil

# create a new cache called "my-cache", rooted in /home/simon/caches
# with an expiry time of 30 seconds, and a file hierarchy three 
# directories deep
cache = FileCache.new("my-cache", "/home/simon/caches", 30, 3)
cache.put("joe", "bloggs")
puts(cache.get("joe"))   # "bloggs"
sleep 30
puts(cache.get("joe"))   # nil
```

[rubyforge-filecache]: http://rubyforge.org/projects/filecache/