#!/bin/bash
# Runs at container start (not build time), so one image can be reused
# on all 5 VMs and still show a different team name on each, via:
#   docker run -e TEAM_NAME="Team Falcon" ...
set -e

TEAM_NAME="${TEAM_NAME:-Linux Fundamentals}"

cat > /etc/motd <<EOF

  $TEAM_NAME — Flag Hunt (10 levels)
  Start with: ls -a

EOF

exec /usr/sbin/sshd -D
