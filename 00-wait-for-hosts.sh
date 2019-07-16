#!/bin/bash
## wait-for-hosts [-f etc-host-file] [hostname(s)...]
## (C) 2019, Raphaël.droz+floss@gmail.com, GPLv3+
#
# Workaround for GitLab.com https://gitlab.com/gitlab-org/gitlab-runner/issues/1042#note_61788095
# Wait until <hostname> is up.
#
# If a path is set for <etc-host-file>, wait until this file come available
# and use it as /etc/hosts file because waiting for (now resolvable) hostname(s).
#
# Example: `wait-for-hosts -f $CI_PROJECT_DIR/hosts $DB_HOST`

[[ -n "$VERBOSE" ]] && set -vx

file=
while getopts :f: opt; do
    case $opt in
	f) file="${OPTARG}" ;;
    esac
done
shift $((OPTIND-1))

if [[ -n "$file" ]]; then
    echo "Waiting for $file"
    while [[ ! -e $file ]]; do
	echo -n .
	sleep 1
    done
    cat "$file" > /etc/hosts
fi

if (( ${#@} > 0 )); then
    echo "Waiting for ${#@} hosts: $@"
    while ! fping -uqc1 "$@"; do
	echo -n .
	sleep 1
    done
    echo
fi

exit 0
