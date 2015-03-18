#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

rm   -fr tmp
mkdir -p tmp

vagrant ssh <<-EOS
	cp -r /var/lib/jenkins/jobs/      /vagrant/tmp/
	cp -p /var/lib/jenkins/config.xml /vagrant/tmp/
	EOS

while read line; do
  dst=../jenkins/deploy/${line/tmp/}
  diff ${line} ${dst} && continue
  cp   ${line} ${dst}
  echo $?
done < <(find tmp -type f -name config.xml)
