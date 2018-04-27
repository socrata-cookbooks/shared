# Shared Cookbook Files

A set of common files that can be shared between cookbooks.

## Usage

***Bundler***

The included `Gemfile` includes gems we commonly add on top of what comes packed with the Chef-DK. It can be imported into a cookbook as follows:

```ruby
# frozen_string_literal: true

require 'net/http'
require 'uri'

uri = URI('https://raw.githubusercontent.com/socrata-cookbooks/shared/' \
          'master/files/Gemfile')
instance_eval Net::HTTP.get(uri)
```

***Delivery***

Cookbook testing can be handled by Chef Delivery. The included config can be imported into a cookbook by adding this to its `.delivery/project.toml`:

```
remote_file = "https://raw.githubusercontent.com/socrata-cookbooks/shared/master/files/project.toml"
```

***RuboCop***

The included RuboCop config can be imported into another cookbook by adding this to its `.rubocop.yml`:

```
inherit_from:
  - https://raw.githubusercontent.com/socrata-cookbooks/shared/master/files/.rubocop.yml
```

***Documentation***

Markdown has no facility to include the content of another Markdown file. To reference the included testing documentation, add the following to your cookbook's `TESTING.md`:

```
Please refer to the shared testing doc [here](https://github.com/socrata-cookbooks/blob/master/shared/TESTING.MD).
```
