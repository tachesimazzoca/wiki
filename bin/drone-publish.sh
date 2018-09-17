#!/bin/bash

set -e

cd "$(dirname "${0}")"

mkdir -p /root/.ssh
chmod 700 /root/.ssh

echo "${GITHUB_SSH_KEY}" > /root/.ssh/github-tachesimazzoca
chmod 600 /root/.ssh/github-tachesimazzoca

cat <<EOS > /root/.ssh/config
Host github-tachesimazzoca
  User git
  HostName github.com
  IdentityFile /root/.ssh/github-tachesimazzoca
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOS
chmod 600 /root/.ssh/config

echo n | ./publish.sh
