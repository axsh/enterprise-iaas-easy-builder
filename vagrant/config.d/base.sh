#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

# Do some changes ...

{
  chkconfig --list jenkins
  chkconfig jenkins on
  chkconfig --list jenkins
  service jenkins restart
}

{
  maki_path=/usr/local/bin/maki

  curl -fsSkL https://raw.githubusercontent.com/axsh/makistrano/master/bin/maki -o ${maki_path}
  chmod +x ${maki_path}
}

usermod -s /bin/bash jenkins
su - jenkins -c "${SHELL} -ex" <<EOS
  if [[ -e /var/lib/jenkins/config.xml ]]; then
    rm  -f /var/lib/jenkins/config.xml
  fi
  if [[ -e /var/lib/jenkins/jobs ]]; then
    rm -rf /var/lib/jenkins/jobs
  fi

  ln -s /opt/axsh/eieb/jenkins/config.xml /var/lib/jenkins/
  ln -s /opt/axsh/eieb/jenkins/jobs       /var/lib/jenkins/
EOS
usermod -s /bin/false jenkins
