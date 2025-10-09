# [guziohub](https://guziohub.ovh/)

Docker Compose configs and related stuff for [my home server](https://guziohub.ovh/); hosted on GH to simplify the deployment.

## All the shit that I had to `apt install`
...because they weren't in baseline Ubuntu Slim (picked over the regular Ubuntu becasue I want the host system to be as light-weigth as possible - since everyting meaningful will happen inside of the container, anyway), nor had any alternatives, despite being some pretty basic system tools. Useful for future reference, I reckon:

```bash
sudo apt install git zip unzip htop iputils-ping jed fish podman-compose thermshark
```

Notes:
* `fish`: OK, there technincally WAS an alternative basic system tool provided (`bash`) and `fish` isn't as basic as `bash`, but this is so much nicer, so I'll allow myself to switch these around (even is this system is technically supposed to be ultra-lightweigth)
* `jed`: It might seem less basic than `nano` - except that even `nano` itself wasn't provided. So if I had to install a text editor anyway (I'm not counting Vim - it's not a text editor, it's a trap that noone can exit without Googling), I might as well install the one I prefer.
* `htop`: `top` (built-in) isn't a real alternative
* `podman-compose`: it's not a basic system tool, but its't critical for my use-case (still ligther-weight than a full Docker install, btw)
* `termshark`: it's not a basic system tool, but I installed it after needing it for debugging between-container traffic, so I might as well add it here

## Other bits of wisdom, discovered along the way

For in-container users (other than root, which gets mapped to your UID+GID out-of-container) in Podman to work, you need to let it `chmod` things that are owned out-of-container as you (ie. as root in-container) to some other UID+GID (they can be arbitraty out-of-container - Podman will automatically remap them to something that'd make sense in-container). Since Linux doesn't allow you to `chown` things to arbitraty users by default (makes sense - you wouldn't want some random user to „gracefully donate” a SETUID binary to the `root` user), you need to first add those UIDs+GIDs to yourself, as sub-IDs:

```bash
sudo usermod --add-subuids 100000-165535 --add-subuids 100000-165535 ubuntu
```

After [asking on Reddit]() I found out that if you want your Podman Networks' network interfaces to show up, a simple `ip addr show` (or any other command that relies on interfaces, eg. `termshark -i=podman1 -f="tcp port 8008 or 29319"`) isn't enough. Instead, you need to:

```bash
podman unshare --rootless-netns ip addr show #or any other command instead of ip addr show
```