# Shared Cookbook Files

A set of common files that can be shared between cookbooks.

## Usage

***Bundler***

The included `Gemfile` includes gems we commonly add on top of what comes packed with Chef Workstation/DK. It can be imported into a cookbook as follows:

```ruby
# frozen_string_literal: true

require 'open-uri'

instance_eval(open('https://raw.githubusercontent.com/socrata-cookbooks/shared/main/files/Gemfile').read)
```

***Berkshelf***

The included `Berksfile` will automatically point at the public Supermarket or our internal Artifactory instance depending on the cookbook's license. It will include any test wrapper cookbooks found in `spec/support/cookbooks/` (for ChefSpec) or `test/fixtures/cookbooks/` (for Test Kitchen). It can be imported by adding this to a cookbook's `Berksfile`:

```
# frozen_string_literal: true

require 'open-uri'

instance_eval(open('https://raw.githubusercontent.com/socrata-cookbooks/shared/main/files/Berksfile').read)
```

***Delivery***

Cookbook testing can be handled by Chef Delivery. The included config can be imported into a cookbook by adding this to its `.delivery/project.toml`:

```
remote_file = "https://raw.githubusercontent.com/socrata-cookbooks/shared/main/files/project.toml"
```

***RuboCop***

The included RuboCop config can be imported into another cookbook by adding this to its `.rubocop.yml`:

```
inherit_from:
  - https://raw.githubusercontent.com/socrata-cookbooks/shared/main/files/.rubocop.yml
```

***Documentation***

Markdown has no facility to include the content of another Markdown file. The included doc files can only be referenced as follows:


`TESTING.md`:

```
Please refer to the shared testing doc [here](https://github.com/socrata-cookbooks/shared/blob/main/files/TESTING.md).
```

`CONTRIBUTING.md`:

```
Please refer to the shared contributing doc [here](https://github.com/socrata-cookbooks/shared/blob/main/files/CONTRIBUTING.md).
```

`CODE_OF_CONDUCT.md`:

```
Please refer to the shared code of conduct [here](https://github.com/socrata-cookbooks/shared/blob/main/files/CODE_OF_CONDUCT.md).
```
