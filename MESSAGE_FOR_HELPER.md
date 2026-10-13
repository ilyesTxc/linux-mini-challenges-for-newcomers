# What I need from you for the 5 VMs

The game is a Docker image (attached/linked below). It runs its own
tiny SSH server inside the container on port 22 — please keep that
**separate** from the VM's own admin SSH (the one your key logs into).
Otherwise you'll lock yourself out or get a port clash.

## On each of the 5 VMs

```bash
docker pull YOUR_DOCKERHUB_USERNAME/linux-ctf-lab:latest

docker run -d --name ctf-lab \
  -p 2222:22 \
  -e TEAM_NAME="Team 1" \
  YOUR_DOCKERHUB_USERNAME/linux-ctf-lab:latest
```

- Change `TEAM_NAME` for each VM (`Team 1` … `Team 5`) — it's just a
  cosmetic banner students see when they log in, nothing else differs.
- `-p 2222:22` maps container port 22 to **host port 2222**. The VM's
  own sshd keeps using port 22 for you, untouched.
- Make sure each VM's firewall / security group allows **inbound TCP
  2222** from wherever the students will be (campus Wi-Fi, etc.).

## What students will use to connect

```bash
ssh -p 2222 player@<that VM's public IP>
# password: player123
```

That's the only login they need — it's baked into the image, same on
all 5 VMs. No SSH key required on their side.

## Please send me back, once the VMs are up

Just the 5 public IPs (or hostnames), one per team, so I can print
the team cards.

## If you'd rather build locally than pull from Docker Hub

The image also builds from source in under a minute if that's easier
for you:

```bash
docker build -t linux-ctf-lab:latest .
docker run -d --name ctf-lab -p 2222:22 -e TEAM_NAME="Team 1" linux-ctf-lab:latest
```

(Dockerfile + everything it needs is in this folder.)
