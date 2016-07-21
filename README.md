# filecache

[![Gem Version](https://badge.fury.io/rb/filecache.svg)](http://badge.fury.io/rb/filecache)
[![Build Status](https://travis-ci.org/leighmcculloch/filecache-ruby.svg)](https://travis-ci.org/leighmcculloch/filecache-ruby)

FileCache is a file-based caching library for Ruby.

## Install

```
gem install filecache
```

or

```ruby
gem 'filecache'
```

## Usage

The following code will create a cache called `my-cache` rooted at `/tmp/caches` with an expiry time of `30` seconds, and a file hierarchy three directories deep.

```ruby
require 'filecache'

cache = FileCache.new("my-cache", "/tmp/caches", 30, 3)
cache.set("key", "value")
puts(cache.get("key")) # "value"
sleep 30
puts(cache.get("key")) # nil
```

## Thanks

Thanks to [Simon Whitaker](http://github.com/simonwhitaker/filecache-ruby) who created this ruby gem.