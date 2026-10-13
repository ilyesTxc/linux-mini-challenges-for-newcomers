# Linux Fundamentals — Flag Hunt (10 levels)

A self-contained Docker image with a 10-level "capture the flag" lab,
getting harder one skill at a time: `cat`, SSH, hidden files, `cd`,
`find`, `grep`, permissions/sudo, `su`, pipes, and a tiny offline
brute-force demo.

## 1. Build it once

```bash
cd linux-ctf-lab
docker build -t YOUR_DOCKERHUB_USERNAME/linux-ctf-lab:latest .
```

## 2. Push it so students can just `docker pull`

```bash
docker login
docker push YOUR_DOCKERHUB_USERNAME/linux-ctf-lab:latest
```

## 3. Run it (you, on your laptop, during the workshop)

```bash
docker run -d --name ctf-lab -p 2222:22 YOUR_DOCKERHUB_USERNAME/linux-ctf-lab:latest
```

Students connect over SSH to **your laptop's IP**, port 2222:

```bash
ssh -p 2222 player@<your-laptop-ip>
# password: player123
```

If you'd rather they pull and run it on their own machines instead
(e.g. if your Wi-Fi is unreliable), tell them:

```bash
docker pull YOUR_DOCKERHUB_USERNAME/linux-ctf-lab:latest
docker run -d --name ctf-lab -p 2222:22 YOUR_DOCKERHUB_USERNAME/linux-ctf-lab:latest
ssh -p 2222 player@localhost
```

## 4. What to hand the students

Just this:

> Connect: `ssh -p 2222 player@<address>`, password `player123`.
> Find all 10 flags, each one looks like `FLAG{...}`. Each level
> tells you what to try next — read the file names and errors
> carefully.

Do **not** share the table below with them — that's your answer key.

---

## Level walkthrough (for you)

| # | Skill | How to get there | Flag |
|---|---|---|---|
| 1 | `cat` | Warm-up, no SSH needed — on your screen, run `docker exec -it ctf-lab bash` then `cat /home/player/level1/flag1.txt` | `FLAG{welcome_to_linux}` |
| 2 | SSH login | `ssh -p 2222 player@<ip>`, password `player123`, then `cat level2/flag2.txt` | `FLAG{ssh_login_works}` |
| 3 | Hidden files | `cd level3 && ls -a` reveals `.flag3.txt`, then `cat .flag3.txt` | `FLAG{hidden_files_use_a_dot}` |
| 4 | `cd` / navigation | `cd level4/docs/2024/reports/final` then `cat flag4.txt` (a couple of decoy empty folders sit alongside the real path) | `FLAG{deep_in_the_tree}` |
| 5 | `find` | Flag lives outside home, at `/var/backups/old/2019/.data/level5/flag5.txt`. `find / -iname "flag5*" 2>/dev/null` | `FLAG{find_finds_everything}` |
| 6 | `grep` | `level6/access.log` has ~450 noise lines; `grep FLAG level6/access.log` | `FLAG{grep_finds_needles}` |
| 7 | permissions / `sudo` | `/root/level7/flag7.txt` is `chmod 600`, owned by root — unreadable directly. `sudo -l` shows they can run exactly one command passwordless: `sudo cat /root/level7/flag7.txt` | `FLAG{sudo_opens_doors}` |
| 8 | `su` | `level8/inventory.csv` is a 200-row haystack; one row (`id 87`) hides `keeper`'s password. `grep keeper level8/inventory.csv`, then `su keeper` (password `TangoFoxtrot42`), then `cat level8/flag8.txt` | `FLAG{su_and_see}` |
| 9 | pipes | `level9/message.b64` is base64. `cat level9/message.b64 \| base64 -d` | `FLAG{pipes_chain_commands}` |
| 10 | brute force | `level10/README.txt` points to the binary; `vault-level10 <3-letter-guess>` — execute-only (they can run it, not read it). Secret is 3 lowercase letters, keyspace `26^3 = 17,576` | `FLAG{3_chars_17576_tries}` |

### Running level 10 as a class demo

Give them this skeleton and let them finish it, or run it yourself on
the projector:

```bash
for a in {a..z}; do
  for b in {a..z}; do
    for c in {a..z}; do
      guess="$a$b$c"
      out=$(/usr/local/bin/vault-level10 "$guess")
      if [[ "$out" == FLAG* ]]; then
        echo "Found: $guess -> $out"
        break 3
      fi
    done
  done
done
```

Talking points while it runs:
- **17,576** is every 3-letter lowercase combination. A computer gets
  through all of them in well under a second.
- Ask: "What if it were 6 characters, mixing upper/lower, digits and
  symbols?" (about 95 possible characters per slot, so `95^6` ≈ 735
  billion — show the jump.)
- That's why a short, simple password is weak no matter how "random"
  it looks, and why SSH keys (covered earlier) don't have this
  problem — nobody is guessing a 256-bit key.

### Notes

- `player` has no general sudo access, only the one `cat` command
  from level 7 — don't widen it, it would let them skip level 8/9 by
  other means.
- The vault binary is `chmod 711` (execute-only, no read) specifically
  so `cat`-ing it won't leak the secret — this is itself worth
  pointing out as a real permission trick.
- Everything is self-contained in the image; `docker rm -f ctf-lab`
  wipes all progress, so restart it fresh for each session if you
  reuse the same laptop across workshops.
