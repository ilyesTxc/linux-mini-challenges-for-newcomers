#!/bin/bash
# Builds every level's files, users and permissions inside the image.
set -euo pipefail

# ---------- users ----------
useradd -m -s /bin/bash player
echo "player:player123" | chpasswd

useradd -m -s /bin/bash keeper
echo "keeper:TangoFoxtrot42" | chpasswd

mkdir -p /home/player /home/keeper

# ---------- level 1: cat flag.txt (meant for `docker exec`, no ssh needed) ----------
mkdir -p /home/player/level1
echo "FLAG{welcome_to_linux}" > /home/player/level1/flag.txt
chmod 644 /home/player/level1/flag.txt

# ---------- level 2: just logging in over ssh ----------
echo "FLAG{ssh_login_works}" > /home/player/flag2.txt
chmod 644 /home/player/flag2.txt

# ---------- level 3: hidden file ----------
echo "FLAG{hidden_files_use_a_dot}" > /home/player/.flag3.txt
chmod 644 /home/player/.flag3.txt

# ---------- level 4: nested directories ----------
mkdir -p /home/player/level4/docs/2024/reports/final
echo "FLAG{deep_in_the_tree}" > /home/player/level4/docs/2024/reports/final/flag4.txt
chmod 644 /home/player/level4/docs/2024/reports/final/flag4.txt
# a couple of decoy empty folders so cd / ls actually takes a few steps
mkdir -p /home/player/level4/docs/2024/drafts
mkdir -p /home/player/level4/docs/2023

# ---------- level 5: find (flag lives outside their home) ----------
mkdir -p /var/backups/old/2019/.data
echo "FLAG{find_finds_everything}" > /var/backups/old/2019/.data/flag5_8f3a.txt
chmod 644 /var/backups/old/2019/.data/flag5_8f3a.txt
chmod -R o+rx /var/backups

# ---------- level 6: grep inside a noisy log ----------
mkdir -p /home/player/level6
{
  for i in $(seq 1 400); do
    printf '2024-01-%02d 0%d:%02d:%02d INFO  request handled in %dms\n' \
      "$((i % 28 + 1))" "$((i % 9))" "$((i % 60))" "$((i % 60))" "$((i % 300))"
  done
  echo "2024-01-15 03:14:07 DEBUG payload=FLAG{grep_finds_needles}"
  for i in $(seq 401 450); do
    printf '2024-01-%02d 1%d:%02d:%02d WARN  slow query detected\n' \
      "$((i % 28 + 1))" "$((i % 9))" "$((i % 60))" "$((i % 60))"
  done
} > /home/player/level6/access.log
chmod 644 /home/player/level6/access.log

# ---------- level 7: permissions + narrow sudo ----------
echo "FLAG{sudo_opens_doors}" > /root/flag7.txt
chmod 600 /root/flag7.txt
mkdir -p /etc/sudoers.d
echo 'player ALL=(root) NOPASSWD: /usr/bin/cat /root/flag7.txt' > /etc/sudoers.d/player-level7
chmod 440 /etc/sudoers.d/player-level7

# ---------- level 8: password buried in a haystack, then su ----------
mkdir -p /home/player/level8
{
  echo "id,name,role,note"
  for i in $(seq 1 120); do
    echo "$i,user$i,staff,ok"
  done
  echo "87,keeper,ops,temp pass TangoFoxtrot42 - rotate after onboarding"
  for i in $(seq 121 200); do
    echo "$i,user$i,staff,ok"
  done
} > /home/player/level8/inventory.csv
chmod 644 /home/player/level8/inventory.csv

echo "FLAG{su_and_see}" > /home/keeper/flag8.txt
chmod 600 /home/keeper/flag8.txt
chown keeper:keeper /home/keeper/flag8.txt

# ---------- level 9: pipe / decode ----------
mkdir -p /home/player/level9
echo -n "FLAG{pipes_chain_commands}" | base64 > /home/player/level9/message.b64
chmod 644 /home/player/level9/message.b64

# ---------- level 10: compiled brute-force vault (see vault.c) ----------
gcc -O2 -o /usr/local/bin/vault-level10 /tmp/vault.c
strip /usr/local/bin/vault-level10
chown root:root /usr/local/bin/vault-level10
chmod 711 /usr/local/bin/vault-level10   # execute-only: runnable, not readable

# ---------- ownership ----------
chown -R player:player /home/player
chown keeper:keeper /home/keeper

# ---------- ssh ----------
mkdir -p /run/sshd
ssh-keygen -A

# Note: /etc/motd is written at container START (not here) by
# entrypoint.sh, so the same image can show a different team name
# per VM via `docker run -e TEAM_NAME=...`.
