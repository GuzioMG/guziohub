# [guziohub](https://guziohub.ovh/)

Docker Compose configs and related stuff for [my home server](https://guziohub.ovh/); hosted on GH to simplify the deployment.

## All the shit that I had to `apt install`
...because they weren't in baseline Ubuntu Slim (picked over the regular Ubuntu becasue I want the host system to be as light-weigth as possible - since everyting meaningful will happen inside of the container, anyway), nor had any alternatives, despite being some pretty basic system tools. Useful for future reference, I reckon:

```bash
sudo apt install git zip unzip htop iputils-ping jed fish podman-compose thermshark
```

Notes:
* `fish`: OK, there technincally WAS an alternative basic system tool provided (`bash`) and `fish` isn't as basic as `bash`, but this is so much nicer, so I'll allow myself to switch these around (even is this system is technically supposed to be ultra-lightweigth)
* `jed`: It might seem less basic than `nano` - except that even `nano` itself wasn't provided (nor even the most basic `vi` (let alone Vim) - not that I'd count is as an alternative to `jed`/`nano` due to its inhumane control scheme). So if I had to install a text editor anyway, I might as well install the one I prefer.
* `htop`: `top` (built-in) isn't a real alternative
* `podman-compose`: it's not a basic system tool, but it's critical for my use-case (still ligther-weight than a full Docker install, btw)
* `termshark`: it's not a basic system tool, but I installed it after needing it for debugging between-container traffic, so I might as well add it here

## Other bits of wisdom, discovered along the way

For in-container users (other than root, which gets mapped to your UID+GID out-of-container) in Podman to work, you need to let it `chmod` things that are owned out-of-container as you (ie. as root in-container) to some other UID+GID (they can be arbitraty out-of-container - Podman will automatically remap them to something that'd make sense in-container). Since Linux doesn't allow you to `chown` things to arbitraty users by default (makes sense - you wouldn't want some random user to „gracefully donate” a SETUID binary to the `root` user), you need to first add those UIDs+GIDs to yourself, as sub-IDs:

```bash
sudo usermod --add-subuids 100000-165535 --add-subuids 100000-165535 ubuntu
```

After [asking on Reddit](https://www.reddit.com/r/podman/comments/1nujblc/my_podman_network_interface_isnt_showing_up_on/) I found out that if you want your Podman Networks' network interfaces to show up, a simple `ip addr show` (or any other command that relies on interfaces, eg. `termshark -i=podman1 -f="tcp port 8008 or 29319"`) isn't enough. Instead, you need to:

```bash
podman unshare --rootless-netns ip addr show #or any other command instead of ip addr show
```

I also installed `firewalld`, but - looking at my command history and `systemctl status` - it seems like I switched back to vanilla `iptables` since `firewalld` is disabled, so I didn't include it in the list above. And even withing `iptables`, I basically delegated all responsibility for firewalling to Oracle's ingress rules (apparently, this is somehow safe, [according to their own subreddit](https://www.reddit.com/r/oraclecloud/comments/r8lkf7/a_quick_tips_to_people_who_are_having_issue/) and AWS's default security decisions (as mentioned in the same post, they also open all ports on their instances and let their web-UI-panel-thingy be the only controller for firewall policies) - or, at least, it's safe for now, until I eventually find a way to overcome NAT and move this onto my home network), like so:

```bash
sudo iptables -I INPUT -j ACCEPT # This isn't what I did, but that's what the post said
sudo iptables -F # THAT'S what I actually did. It's a bit more „barbaric” (instead of gently telling the INPUT filter to allow all incoming traffic, you just delete it (and the OUTPUT filter too, but that was already set to allow everything) entirely), but the end result is the same: the filters don't filter anything at all anymore (for me: because they don't even exist; for OP: becasue they removed all rules)
sudo netfilter-persistent save # To save your changes
```

Podman has a bizzare bug with its Compose file handling, in that (at least until [this](https://github.com/containers/podman-compose/pull/1283) gets shipped in a relase - at least it already got merged) it tried to stop *dependencies* when `podman compose down`ing a service, rather than *dependents*. Which means that, if I want to re-create `mxtuwunel` (for example), I actually need to run the following commands:

```bash
podman compose down mxtuwunel mxelement mxbot-meta mxbot-discord # Instead of just `podman compose down mxtuwunel`, or Tuwunel will fail to actually delete itself (it will stop, tho), due to dangling mxelement, mxbot-meta and mxbot-discord dependencies. Also, this command will stop web, mxturn and ldap, as mxelement depends on them - but it won't delete them web and ldap, due to some dangling dependencies related to Nextcloud. Also-also, mxtuwunel doesn't actually need to be explicitly mentioned in that command, as all mxelement mxbot-meta mxbot-discord depend on it. Mind you, mxtuwunel is the very service we're ACTUALLY trying to restart here. Absolute madness! That PR needs to find itself in a release ASAP becasue all of this makes zero sense, currently.
podman compose up -d mxtuwunel mxelement mxbot-meta mxbot-discord # web, ldap and mxturn will fail to create (since they already exist), but they'll restart. All other services mentioned there will be fully re-crated.
```