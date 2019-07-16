#!/bin/bash
## remote-logger hostname port
## (C) 2019, Raphaël.droz+floss@gmail.com, GPLv3+
#
# Workaround for GitLab.com https://gitlab.com/gitlab-org/gitlab-runner/issues/2119
# Create a logger to the main-container set as argument.
#
# Example: `remote-logger runner--project-0-concurrent-0`

[[ -n "$VERBOSE" ]] && set -vx
if [[ -z "$1" || -z "$2" ]] || ! type socat &> /dev/null; then
     exit 0
fi

MAIN_CONTAINER="$1" && shift
LOGGER_PORT="$1" && shift

while ! < "/dev/tcp/$MAIN_CONTAINER/$LOGGER_PORT"; do
    echo -n .
    sleep 1
done

test -p /tmp/log || mkfifo /tmp/log
if ! pgrep -nx socat; then
     socat PIPE:/tmp/log TCP:$MAIN_CONTAINER:11109,retry=5,fork &
fi

exit 0
