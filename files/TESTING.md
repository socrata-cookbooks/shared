# Cookbook Testing

This document describes the process for testing a Socrata cookbook.

## Prerequisites

A working Chef Workstation or Chef Development Kit installation is required.

Chef Workstation can be installed via...

- Direct [download](https://downloads.chef.io/chef-workstation/)
- Homebrew (`brew cask install chef-workstation`)
- Chocolatey (`choco install chef-workstation`)
- APT/YUM/shell script (documented [here](https://docs.chef.io/packages.html))
- The [chef-ingredient cookbook](https://supermarket.chef.io/cookbooks/chef-ingredient)

The Chef-DK can be installed via...

- Direct [download](https://downloads.chef.io/chef-dk/)
- Homebrew (`brew cask install chefdk`)
- Chocolatey (`choco install chefdk`)
- APT/YUM/shell script (documented [here](https://docs.chef.io/packages.html))
- The [chefdk cookbook](https://supermarket.chef.io/cookbooks/chefdk)
- The [chef-dk cookbook](https://supermarket.chef.io/cookbooks/chef-dk)
- The [chef-ingredient cookbook](https://supermarket.chef.io/cookbooks/chef-ingredient)

The integration tests assume a running instance of Docker on the test machine. Docker can be installed via

- Direct [download](https://store.docker.com/search?type=edition&offering=community)
- Homebrew (`brew cask install docker`)
- Chocolatey (`choco install docker`)
- APT (documented [here](https://docs.docker.com/install/linux/docker-ce/ubuntu/))
- YUM (documented [here](https://docs.docker.com/install/linux/docker-ce/centos/))
- The [docker cookbook](https://supermarket.chef.io/cookbooks/docker)

## Installing Dependencies

Install additional gem dependencies into Chef's Ruby environment:

```shell
> chef exec bundle install
```

## Local Delivery

Syntax, style, and unit tests are handled by the Delivery CLI tool running in
the local delivery mode.

***Lint Phase***

The lint phase uses [RuboCop](https://github.com/bbatsov/rubocop) to examine the cookbook's Ruby code for style violations. To run only the lint phase:

```shell
> delivery local lint
```

***Syntax Phase***

The syntax phase uses [FoodCritic](http://www.foodcritic.io) to catch any Chef-specific cookbook issues. To run only the syntax phase:

```shell
> delivery local syntax
```

***Unit Phase***

The unit phase uses [ChefSpec](https://github.com/chefspec/chefspec) to run any unit tests present in the `spec/` directory. To run only the unit phase:

```shell
> delivery local unit
```

***All Phases***

To run all the above phases in sequence:

```shell
> delivery local all
```

## Test Kitchen

Integration testing is handled outside of Delivery by [Microwave](https://github.com/socrata-platform/kitchen-microwave), a wrapper around  [Test Kitchen](https://kitchen.ci). To run all available integration tests on all plaforms and suites:

```shell
> chef exec microwave test
```

To run tests on a single platform/suite:

```shell
> chef exec microwave list
Instance                       Driver  Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-1804-chef-14    Dokken  Dokken       Inspec    Dokken     <Not Created>  <None>
default-ubuntu-1604-chef-14    Dokken  Dokken       Inspec    Dokken     <Not Created>  <None>
default-amazonlinux-2-chef-14  Dokken  Dokken       Inspec    Dokken     <Not Created>  <None>
default-ubuntu-1804-chef-13    Dokken  Dokken       Inspec    Dokken     <Not Created>  <None>
default-ubuntu-1604-chef-13    Dokken  Dokken       Inspec    Dokken     <Not Created>  <None>
default-amazonlinux-2-chef-13  Dokken  Dokken       Inspec    Dokken     <Not Created>  <None>

> chef exec microwave test default-ubuntu-1604-chef-14
```
