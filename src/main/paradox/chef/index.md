# Chef

## Overview

* [About the Omnibus Installer](https://docs.chef.io/install_omnibus.html)
* [chef-solo (executable)](http://docs.chef.io/client/ctl_chef_solo.html)
* [About Resources and Providers](https://docs.chef.io/resource.html)
* [Opscode Public Cookbooks](https://github.com/opscode-cookbooks)

## Installation

### Omnibus Installer

    % curl -L https://www.chef.io/chef/install.sh | sudo bash -s -- -v 12.16.42
    ...

    % chef-client -v
    Chef: 12.16.42

    # Use a stable version of Ruby as part of the omnibus installer (Optional)
    # echo 'export PATH="/opt/chef/embedded/bin:$PATH"' >> ~/.bash_profile
    # source ~/.bash_profile
    % which ruby
    /opt/chef/embedded/bin/ruby

## chef-zero vs. chef-solo

The command `chef-solo` has been deprecated. Use the command `chef-client -z`, instead.

    $ mkdir chef-repo
    $ cd chef-repo

    # Create a cookbook
    % knife cookbook create httpd -o cookbooks

    # Define a recipe
    $ vi cookbooks/httpd/recipes/default.rb
    package 'httpd' do
      action :install
    end

    service 'httpd' do
    supports :status => true, :restart => true, :reload => true
      action [:enable, :start]
    end

    # Add the recipe to the run_list
    % vi nodes/localhost.json
    {
      "run_list": [
        "recipe[httpd]"
      ]
    }

    # Execute chef-client in local mode
    % sudo chef-client -z -N localhost -j nodes/localhost.json

The option `-z` means that the client runs in local mode. The client will load the cookbooks on localhost (i.e. the same machine). The chef-zero server, which serves the local chef-repo, will be launching in memory during applying cookbooks.

* [chef-client (executable) Run in Local Mode](https://docs.chef.io/ctl_chef_client.html#run-in-local-mode)

## knife

The command `knife` is useful to manage nodes even in local mode.

I would rather create the configuration file `chef-repo/knife.rb` so as not to specify the same options every time.

    $ cd chef-repo
    $ cat knife.rb
    local_mode true
    chef_repo_path File.expand_path('../' , __FILE__)

    knife[:ssh_attribute] = 'ipaddress'
    knife[:sudo] = true

The `nodes/*.json` files must be created. Each file contains each target node information.

    # create nodes/<hostname>.json
    $ knife node create <hostname> --disable-editing
    {
      "name": "<hostname>"
    }

You can specify another node name with the real IP address.

    $ vi nodes/<node-name>.json
    {
      "name": "<node-name>",
      "normal": {
        "ipaddress": "192.168.33.101"
      }
    }

Assume that the following nodes exist.

    $ tree nodes
    nodes
    ├── development-ap.json
    └── production-ap1.json
    └── production-ap2.json

The `knife search` command shows the nodes that match a search query.

    $ knife search node "name:*"
    Node Name:   development-ap
    ...
    Node Name:   production-ap1
    ...
    Node Name:   production-ap2
    ...

The `knife environment` command can manage `environments/*.json`

    $ knife environment create development --disable-editing
    $ knife environment create production --disable-editing
    $ tree environments
    environments
    ├── development.json
    └── production.json

Specifying the `chef_environment` of each node is helpful to pick up nodes with environment names.

    $ knife node enviroment set development-ap development
    $ cat nodes/development-ap.json
    {
      "name": "development-ap",
      "chef_environment": "development",
      ...
    }
    $ knife node enviroment set production-ap1 production
    $ knife node enviroment set production-ap2 production

    $ knife search node "chef_environment:production"
    Node Name:   production-ap1
    ...
    Node Name:   production-ap2
    ...

The `knife ssh` command can execute any command on each node via. SSH.

    $ knife ssh "name:production-*" "sudo systemctl is-active httpd"
    production-ap1 active
    production-ap2 active

The `knife exec` command can execute a ruby script under the knife configuration.

    $ knife exec -E 'nodes.all {|n| p n }'
    $ cat chec_chef_version.rb
    nodes.all do |n|
      system "ssh #{n['ipaddress']} 'sudo chef-client -v'"
    end
    $ knife exec -z check_chef_version.rb

## Tips

### Checking .rb .erb Syntax

    $ ruby -c path/to/cookbook/recipe/default.rb
    $ erb -x path/to/cookbook/templates/default/httpd.conf.erb | ruby -c

### Converge Nodes via. SSH Port Forwarding

    $ cat converge.rb
    nodes.all do |n|
      system "ssh -R8889:127.0.0.1:8889 #{n['ipaddress']}" <<
          " sudo chef-client -S http://127.0.0.1:8889 -N #{n.name}"
    end
    $ knife exec converge.rb

1. Launch a chef-zero server on the local chef-repo.
2. Connect to each node with SSH port forwarding (local) 8889 -> (node) 127.0.0.1:8889
3. Execute chef-client in server mode on each node to connect the local chef-zero server.

Make sure that the chef-zero server launches on the local chef-repo (i.e. your working directory). Those who can access the remote nodes can also communicate with your chef-repo via the bound port. In other words, any OS users on the nodes can send arbitrary TCP/IP packets to the working machine.
