# frozen_string_literal: true

require 'chef/cookbook/metadata'
require 'yaml'

# A module for Test Kitchen helpers.
#
# @author Jonathan Hartman <jonathan.hartman@socrata.com>
module KitchenConfigurator
  # The major Chef versions we could potentially test against in cookbooks
  # that support them.
  POTENTIAL_CHEFS ||= %w[14 13 12].freeze

  # The platforms and versions we could potentiall test against in cookbooks
  # that support them.
  POTENTIAL_PLATFORMS ||= {
    'ubuntu' => %w[18.04 16.04 14.04],
    'debian' => %w[9 8],
    'centos' => %w[7 6],
    'amazonlinux' => %w[2 1],
    'fedora' => %w[27]
  }.freeze

  # The intermediate Docker RUN commands for each platform to make its Docker
  # image behave more like a full VM, e.g. the Ubuntu 18.04 image no longer
  # comes with Systemd preinstalled.
  INTERMEDIATE_INSTRUCTIONS ||= {
    'ubuntu' => {
      '18.04' => [
        'RUN apt-get update',
        'RUN apt-get -y install systemd'
      ],
      '14.04' => [
        'RUN dpkg-divert --remove /sbin/initctl',
        'RUN ln -sf /sbin/initctl.distrib /sbin/initctl'
      ]
    },
    'debian' => {
      '9' => [
        'RUN echo DISTRIB_CODENAME=stretch > /etc/lsb-release',
        'RUN apt-get update',
        'RUN apt-get -y install systemd gnupg'
      ],
      '8' => ['RUN echo DISTRIB_CODENAME=jessie > /etc/lsb-release']
    },
    'centos' => {
      '6' => ['RUN yum -y install upstart initscripts']
    },
    'amazonlinux' => {
      '2' => ['RUN yum -y install systemd'],
      '1' => ['RUN yum -y install upstart initscripts']
    },
    'fedora' => {
      '27' => ['RUN dnf -y install procps']
    }
  }.freeze

  # The path to a potential data bags directory in test/fixtures/.
  DATA_BAGS_PATH ||= File.expand_path('test/fixtures/data_bags', __dir__).freeze

  # The path to the test wrapper cookbook's recipes, used to generate the list
  # of test suites.
  RECIPES_PATH ||= File.expand_path('test/fixtures/cookbooks/test/recipes',
                                    __dir__).freeze

  # A helper class for generating Kitchen configs.
  #
  # @author Jonathan Hartman <jonathan.hartman@socrata.com>
  class Config
    def initialize(options = {})
      options.to_h[:excluded_platforms].to_a.each do |plat|
        case plat
        when String
          platforms.delete_if { |p| p['name'] == plat }
        when Regexp
          platforms.delete_if { |p| p['name'].match(plat) }
        end
      end
    end

    #
    # Build the driver section of the config.
    #
    # @return [Hash] the driver section of a Kitchen config
    #
    def driver
      @driver ||= {
        'name' => 'dokken',
        'privileged' => true,
        'chef_version' => 'latest'
      }
    end

    #
    # Build the transport section of the config.
    #
    # @return [Hash] the transport section of a Kitchen config
    #
    def transport
      @transport ||= { 'name' => 'dokken' }
    end

    #
    # Build the provisioner section of the config.
    #
    # @return [Hash] the provisioner section of a Kitchen config
    #
    def provisioner
      @provisioner ||= { 'name' => 'dokken' }
    end

    #
    # Build the verifier section of the config.
    #
    # @return [Hash] the verifier section of a Kitchen config
    #
    def verifier
      @verifier ||= {
        'name' => 'inspec',
        'root_path' => '/opt/verifier',
        'sudo' => true
      }
    end

    #
    # Build the platforms section of the config, including all supported
    # platforms/versions/Chef versions it's possible to test against with this
    # cookbook + Dokken.
    #
    # @return [Hash] the platforms section of a Kitchen config
    #
    def platforms
      @platforms ||= begin
        plats = []
        supported_chefs.each do |chef|
          supported_platforms.each do |name, versions|
            versions.each { |ver| plats << platform_for(name, ver, chef) }
          end
        end
        plats
      end
    end

    #
    # Build the stanza for a single platform+version+Chef version, including any
    # intermediate steps we use to make the Docker container behave more like a
    # real VM.
    #
    # @return [Hash] a single platform stanza
    #
    def platform_for(name, version, chef)
      {
        'name' => "#{name}-#{version}-chef-#{chef}",
        'driver' => {
          'image' => "#{name}:#{version}",
          'chef_version' => chef,
          'intermediate_instructions' =>
            INTERMEDIATE_INSTRUCTIONS[name][version].dup
        }
      }
    end

    #
    # Look at the supported Chef versions in the metadata to figure out which
    # should be tested against.
    #
    # @return [Array<String>] an array of major Chef versions/Docker image tags
    #
    def supported_chefs
      @supported_chefs ||= POTENTIAL_CHEFS.select do |chef|
        metadata.chef_versions.find do |cv|
          # The Docker tag e.g. "14" should always be the newest release of
          # that major version and satisfy e.g. "~> 14.2".
          Gem::Requirement.new(cv.requirement.to_s.split('.').first)
                          .satisfied_by?(Gem::Version.new(chef))
        end
      end
    end

    #
    # Look at the supported platforms in the metadata and figure out what
    # platforms and versions should be tested.
    #
    # @return [Hash] a hash of platform => [version1, version2...]
    #
    def supported_platforms
      @supported_platforms ||= metadata
                               .platforms
                               .each_with_object({}) do |(name, req_str), hsh|
        # Amazon Linux is named "amazon" in Chef metadata but "amazonlinux" in Docker Hub.
        name = 'amazonlinux' if name == 'amazon'

        next unless POTENTIAL_PLATFORMS.keys.include?(name)
        hsh[name] = []
        req = Gem::Requirement.new(req_str)

        POTENTIAL_PLATFORMS[name].each do |version|
          hsh[name] << version if req.satisfied_by?(Gem::Version.new(version))
        end
      end
    end

    #
    # Build a list of suites derived from the public recipes in the wrapper
    # cookbook found in `test/fixtures/cookbooks/test`. Each recipe that does
    # not start with an underscore gets its own suite.
    #
    # @return [Array<Hash>] the suites section of a Kitchen config
    #
    def suites
      @suites ||= Dir.entries(RECIPES_PATH).each_with_object([]) do |f, arr|
        next if %w[. ..].include?(f) || f.start_with?('_')
        arr << {
          'name' => File.basename(f, '.rb'),
          'run_list' => ["recipe[test::#{File.basename(f, '.rb')}]"]
        }
      end
    end

    #
    # Read and store the local cookbook's metadata.
    #
    # @return [Chef::Cookbook::Metadata] the cookbook metadata
    #
    def metadata
      @metadata ||= begin
        md = Chef::Cookbook::Metadata.new
        md.from_file(File.expand_path('metadata.rb', __dir__))
        md
      end
    end

    #
    # Build the hash for a complete Kitchen config.
    #
    # @return [Hash] a Kitchen config in a hash format
    #
    def to_h
      {
        'driver' => driver,
        'transport' => transport,
        'provisioner' => provisioner,
        'verifier' => verifier,
        'platforms' => platforms,
        'suites' => suites
      }
    end

    #
    # Return the object as a YAML string suitable for insertion into a
    # .kitchen.yml.
    #
    # @return [String] a YAML string
    #
    def to_yaml
      to_h.to_yaml
    end
    alias to_s to_yaml
    alias inspect to_yaml
  end
end
