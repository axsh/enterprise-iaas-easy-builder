#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

declare chroot_dir=${1}

chroot $1 $SHELL -ex <<'EOS'
  if [[ -d /var/lib/jenkins/jobs ]]; then
    for i in /var/lib/jenkins/jobs/*/config.xml; do
      sed -i \
       -e 's,https://.*github.com/axsh/wakame-vdc-mita.git,/var/tmp/gitlocal/wakame-vdc-mita,' \
       -e 's,https://.*github.com/axsh/hipchat-cli.git,/var/tmp/gitlocal/hipchat-cli,'         \
       -e 's,https://.*github.com/axsh/wakame-vdc.git,/var/tmp/gitlocal/wakame-vdc,'           \
       -e 's,https://.*github.com/hansode/hipchat-bash.git,/var/tmp/gitlocal/hipchat-bash,'    \
       -e 's,https://.*github.com/hansode/zabbix-bash,/var/tmp/gitlocal/zabbix-bash,'          \
       -e 's,https://.*github.com/rcrowley/json.sh,/var/tmp/gitlocal/json.sh,'                 \
       ${i}
    done

    rm -rf /var/lib/jenkins/jobs/*/builds
    rm -rf /var/lib/jenkins/jobs/*/workspace
  fi
EOS
