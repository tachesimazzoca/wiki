# Concourse CI Scripts

## Usage

```shell
# To begin with, save <target> with the login command
$ fly -t <target> login -c <concourse-api-url> -u <username> -p <password>

# <target> is one of the credential keys saved in ~/.flyrc
$ cat ~/.flyrc
targets:
  <target>:
    api: <concourse-api-url>
    team: main
    token:
      type: Bearer
      value: ...

# Prepare load-vars .yml file for parameters in pipeline.yml
$ cat /path/to/config.yml
publishing-outputs-private-key: |-
    -----BEGIN RSA PRIVATE KEY-----
    ...
    -----END RSA PRIVATE KEY-----

# Set and unpause pipeline
$ fly -t <target> set-pipeline -p <pipeline-name> -c pipeline.yml -l /path/to/config.yml
$ fly -t <target> unpause-pipeline -p <pipeline-name>
```
