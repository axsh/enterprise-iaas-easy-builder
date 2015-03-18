#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

### >>>>>

function run_in_target() {
  local chroot_dir=$1; shift; local args="$*"
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  chroot ${chroot_dir} bash -e -c "${args}"
}

### >>>>>

function configure_sudo_sudoers() {
  local chroot_dir=$1 user_name=$2 tag_specs=${3:-"NOPASSWD:"}
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${user_name}"  ]] || { echo "[ERROR] Invalid argument: user_name:${user_name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  #
  # Tag_Spec ::= ('NOPASSWD:' | 'PASSWD:' | 'NOEXEC:' | 'EXEC:' |
  #               'SETENV:' | 'NOSETENV:' | 'LOG_INPUT:' | 'NOLOG_INPUT:' |
  #               'LOG_OUTPUT:' | 'NOLOG_OUTPUT:')
  #
  # **don't forget suffix ":" to tag_specs.**
  #
  egrep ^${user_name} -w ${chroot_dir}/etc/sudoers || { echo "${user_name} ALL=(ALL) ${tag_specs} ALL" >> ${chroot_dir}/etc/sudoers; }
}

### >>>>>

function create_user_account() {
  local chroot_dir=$1 user_name=$2 gid=$3 uid=$4
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${user_name}"  ]] || { echo "[ERROR] Invalid argument: user_name:${user_name} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  printf "[INFO] Creating user: %s\n" ${user_name}

  local user_group=${user_name}
  local user_home=/home/${user_name}

  run_in_target ${chroot_dir} "getent group  ${user_group} >/dev/null || groupadd $([[ -z ${gid} ]] || echo --gid ${gid}) ${user_group}"
  run_in_target ${chroot_dir} "getent passwd ${user_name}  >/dev/null || useradd  $([[ -z ${uid} ]] || echo --uid ${uid}) -g ${user_group} -d ${user_home} -s /bin/bash -m ${user_name}"

  egrep -q ^umask ${chroot_dir}/${user_home}/.bashrc || {
    echo umask 022 >> ${chroot_dir}/${user_home}/.bashrc
  }
}

### >>> ssh public key

function add_authorized_keys() {
  local user_dir=$1; shift
  local ssh_key_paths="$@"
  [[ -d "${user_dir}"      ]] || { echo "[ERROR] directory not found: ${user_dir} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  [[ -n "${ssh_key_paths}" ]] || { echo "[ERROR] Invalid argument: ssh_key_paths:${ssh_key_paths} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }

  local user_ssh_dir=${user_dir}/.ssh
  local authorized_keys_path=${user_ssh_dir}/authorized_keys

  printf "[INFO] Installing authorized_keys %s\n" ${authorized_keys_path}

  [[ -d "${user_ssh_dir}" ]] || mkdir -m 0700 ${user_ssh_dir}
  # make sure to directory attribute is 0700
  chmod 0700 ${user_ssh_dir}

  # make sure to create file
  [[ -f "${authorized_keys_path}" ]] || : > ${authorized_keys_path}

  local ssh_key_path=
  for ssh_key_path in ${ssh_key_paths}; do
    printf "[DEBUG] Adding authorized_keys %s\n" ${ssh_key_path}
    cat ${ssh_key_path} >> ${authorized_keys_path}
  done

  # make sure to file attribute is 0644
  chmod 0644 ${authorized_keys_path}
}

### >>> main

declare chroot_dir=${1}
declare username=${2:-"eieb-deploy"}
declare deploykey=${3:-"keys/${username}.pub"}

create_user_account    ${chroot_dir}  ${username} # 6001 6001
configure_sudo_sudoers ${chroot_dir} %${username} NOPASSWD:

if [[ -f "${deploykey}" ]]; then
  add_authorized_keys    ${chroot_dir}/home/${username} ${deploykey}
  run_in_target ${chroot_dir} "chown -R ${username}:${username} /home/${username}/.ssh/"
fi
