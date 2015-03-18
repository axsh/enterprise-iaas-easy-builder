#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

# Do some changes ...
### copy of vagrant/config.d/base.sh

{
  # *** don't install java-1.7.0-openjdk ***
  yum install --disablerepo=updates -y java-1.6.0-openjdk

  curl -fSkL http://pkg.jenkins-ci.org/redhat/jenkins.repo -o /etc/yum.repos.d/jenkins.repo
  rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
  # *** don't install java-1.7.0-openjdk ***
  yum install --disablerepo=updates -y jenkins
  # in order to draw graphs/charts
  yum install --disablerepo=updates -y dejavu-sans-fonts
  # prevent jenkins starting
  chkconfig --list jenkins
  chkconfig jenkins off
  chkconfig --list jenkins
}

{
  [[ -d /var/lib/jenkins/plugins ]] || mkdir -p /var/lib/jenkins/plugins
  # install git plugin
  base_url=http://updates.jenkins-ci.org
  while read line; do
    set ${line}
    name=${1} version=${2}
    if [[ -z "${version}" ]]; then
      version=latest
    else
      version=download/plugins/${name}/${version}
    fi
    curl -fSkL ${base_url}/${version}/${name}.hpi -o /var/lib/jenkins/plugins/${name}.hpi
  done < <(cat <<-_EOS_ | egrep -v '^#|^$'
	PrioritySorter 1.3
	config-autorefresh-plugin
	configurationslicing
	config-file-provider
	cron_column
	downstream-buildview
	git        1.4.0
	git-client 1.1.1
	hipchat 0.1.5
	greenballs
	managed-scripts 1.1
	nested-view
	next-executions
	parameterized-trigger 2.18
	rebuild 1.20
	timestamper 1.5.6
	token-macro
	urltrigger
	view-job-filters
	_EOS_
	)

  chown -R jenkins:jenkins /var/lib/jenkins/plugins
}
