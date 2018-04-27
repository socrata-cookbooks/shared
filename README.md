# Shared Cookbook Files

A set of common files that can be shared between cookbooks.

## Usage

***Bundler***

The included `Gemfile` includes gems we commonly add on top of what comes
packed with the Chef-DK. It can be imported into a cookbook as follows:

```ruby
# frozen_string_literal: true

require 'net/http'
require 'uri'

uri = URI('https://raw.githubusercontent.com/socrata-cookbooks/shared/' \
          'master/files/Gemfile')
instance_eval Net::HTTP.get(uri)
```

***Delivery***

Cookbook testing can be handled by Chef Delivery. The included config can be
imported into a cookbook by adding this to its `.delivery/project.toml`:

```
remote_file = "https://raw.githubusercontent.com/socrata-cookbooks/shared/master/files/project.toml"
```
