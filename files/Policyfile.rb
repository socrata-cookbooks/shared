# frozen_string_literal: true

require 'chef/cookbook/metadata'

name '<%= policy_name %>'

md = Chef::Cookbook::Metadata.new
md.from_file(File.expand_path('metadata.rb', __dir__))

if md.license.downcase.include?('rights')
  default_source :artifactory, 'https://repo.socrata.com/artifactory/api/chef/chef'
else
  default_source :supermarket
end

run_list '<%= policy_run_list %>'

%w[spec/support test/fixtures].each do |dir|
  path = File.expand_path("#{dir}/cookbooks", __dir__)
  File.exist?(path) && Dir.entries(path).each do |cb|
    next if %w[. ..].include?(cb)
    cookbook cb, path: File.join(path, cb)
  end
end
