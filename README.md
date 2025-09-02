# [guziohub](https://guziohub.ovh/)

Docker Compose configs and related stuff for [my home server](https://guziohub.ovh/); hosted on GH to simplify the deployment.

## All the shit that I had to `apt install`
...because they weren't in baseline Ubuntu Slim (picked over the regular Ubuntu becasue I want the host system to be as light-weigth as possible - since everyting meaningful will happen inside of the container, anyway), nor had any alternatives, despite being some pretty basic system tools. Useful for future reference, I reckon:

```bash
sudo apt install git zip unzip htop iputils-ping jed fish podman-compose
```

Notes:
* `fish`: OK, there technincally WAS an alternative basic system tool provided (`bash`) and `fish` isn't as basic as `bash`, but this is so much nicer, so I'll allow myself to switch these around (even is this system is technically supposed to be ultra-lightweigth)
* `jed`: It might seem less basic than `nano` - except that even `nano` itself wasn't provided. So if I had to install a text editor anyway (I'm not counting Vim - it's not a text editor, it's a trap that noone can exit without Googling), I might as well install the one I prefer.
* `htop`: `top` (built-in) isn't a real alternative
* `podman-compose`: it's not a basic system tool, but its't critical for my use-case (still ligther-weight than a full Docker install, btw)