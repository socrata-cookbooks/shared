# frozen_string_literal: true

require 'chef/cookbook/metadata'
require 'yaml'

yaml = {
  driver: {
    name: 'dokken',
    privileged: true,
    chef_version: 'latest'
  },
  transport: {
    name: 'dokken'
  },
  provisioner: {
    name: 'dokken'
  },
  verifier: {
    name: 'inspec',
    root_path: '/opt/verifier',
    sudo: true
  },
  platforms: [],
  suites: []
}

md = Chef::Cookbook::Metadata.new
md.from_file(File.expand_path('metadata.rb', __dir__))
platforms = md.platforms.keys

%w[14 13 12].each do |chef|
  if platforms.include?('ubuntu')
    yaml[:platforms] << {
      name: "ubuntu-18.04-chef-#{chef}",
      driver: {
        image: 'ubuntu:18.04',
        chef_version: chef,
        intermediate_instructions: [
          'RUN apt-get update',
          'RUN apt-get -y install systemd'
        ]
      }
    }

    yaml[:platforms] << {
      name: "ubuntu-16.04-chef-#{chef}",
      driver: {
        image: 'ubuntu:16.04',
        chef_version: chef
      }
    }

    yaml[:platforms] << {
      name: "ubuntu-14.04-chef-#{chef}",
      driver: {
        image: 'ubuntu:14.04',
        chef_version: chef,
        intermediate_instructions: [
          'RUN dpkg-divert --remove /sbin/initctl',
          'RUN ln -sf /sbin/initctl.distrib /sbin/initctl'
        ]
      }
    }
  end

  if platforms.include?('debian')
    yaml[:platforms] << {
      name: "debian-9-chef-#{chef}",
      driver: {
        image: 'debian:9',
        chef_version: chef,
        intermediate_instructions: [
          'RUN echo DISTRIB_CODENAME=stretch > /etc/lsb-release',
          'RUN apt-get update',
          'RUN apt-get -y install systemd gnupg'
        ]
      }
    }

    yaml[:platforms] << {
      name: "debian-8-chef-#{chef}",
      driver: {
        image: 'debian:8',
        chef_version: chef,
        intermediate_instructions: [
          'RUN echo DISTRIB_CODENAME=jessie > /etc/lsb-release'
        ]
      }
    }
  end

  if platforms.include?('centos')
    yaml[:platforms] << {
      name: "centos-7-chef-#{chef}",
      driver: {
        image: 'centos:7',
        chef_version: chef
      }
    }

    yaml[:platforms] << {
      name: "centos-6-chef-#{chef}",
      driver: {
        image: 'centos:6',
        chef_version: chef,
        intermediate_instructions: [
          'RUN yum -y install upstart initscripts'
        ]
      }
    }
  end

  if platforms.include?('amazon')
    yaml[:platforms] << {
      name: "amazonlinux-2-chef-#{chef}",
      driver: {
        image: 'amazonlinux:2',
        chef_version: chef,
        intermediate_instructions: [
          'RUN yum -y install systemd'
        ]
      }
    }

    yaml[:platforms] << {
      name: "amazonlinux-1-chef-#{chef}",
      driver: {
        image: 'amazonlinux:1',
        chef_version: chef,
        intermediate_instructions: [
          'RUN yum -y install upstart initscripts'
        ]
      }
    }
  end

  if platforms.include?('fedora')
    yaml[:platforms] << {
      name: "fedora-27-chef-#{chef}",
      driver: {
        image: 'fedora:27',
        chef_version: chef,
        intermediate_instructions: [
          'RUN dnf -y install procps'
        ]
      }
    }
  end
end

Dir.entries(
  File.expand_path('test/fixtures/cookbooks/test/recipes', __dir__)
).each do |f|
  next if %w[. ..].include?(f)

  yaml[:suites] << {
    name: File.basename(f, '.rb'),
    run_list: [
      "recipe[test::#{File.basename(f, '.rb')}]"
    ]
  }
end

yaml.to_yaml
