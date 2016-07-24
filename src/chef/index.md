---
layout: plain

title: Chef
---

## Overview

* [About the Omnibus Installer](https://docs.chef.io/install_omnibus.html)
* [chef-solo (executable)](http://docs.chef.io/client/ctl_chef_solo.html)
* [About Resources and Providers](https://docs.chef.io/resource.html)
* [Opscode Public Cookbooks](https://github.com/opscode-cookbooks)

## Installation

### Omnibus Installer

    % curl -L https://www.chef.io/chef/install.sh | sudo bash -s -- -v 11.8.2
    ...

    % chef-client -v
    Chef: 11.8.2

    # Use a stable version of Ruby as part of the omnibus installer (Optional)
    # echo 'export PATH="/opt/chef/embedded/bin:$PATH"' >> ~/.bash_profile
    # source ~/.bash_profile
    % which ruby
    /opt/chef/embedded/bin/ruby

## Setup

### Knife

Create a `knife.rb` file.

    % knife configure
    ...
    % ls ~/.chef
    knife.rb


## Chef Solo

    # Clone the chef-repo on github
    % git clone git://github.com/opscode/chef-repo.git
    % cd chef-repo

    # Create a chef-solo configuration file
    % vi solo.rb
    file_cache_path "/tmp/chef-solo"
    cookbook_path ["./cookbooks"]

    # Create a cookbook for httpd
    % knife cookbook create httpd -o cookbooks
    % vi cookbooks/httpd/recipes/default.rb
    package 'httpd' do
      action :install
    end

    service 'httpd' do
    supports :status => true, :restart => true, :reload => true
      action [:enable, :start]
    end

    # Create a node configuration file
    % vi localhost.json
    {
      "run_list": [
        "recipe[httpd]"
      ]
    }

    % sudo chef-solo -c solo.rb -j localhost.json

## Tips

### Checking .rb .erb syntax

    % ruby -c path/to/cookbook/recipe/default.rb
    % erb -x path/to/cookbook/templates/default/httpd.conf.erb | ruby -c

