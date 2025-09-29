# Here, create:
*Note: Anything realted to Minecraft can - right now - be just garbage data: There is no fuctional Minecraft server here, as of now.*

## `mc_seed.txt`
Holds the Minecraft seed. Can be left blank to randomize a seed.

## `bot_minecraft.txt`
Holds the bot token for the Minecraft bot.

## `pgpass.txt`
Password for the root (`postgres`) user in the DB.

## `ncappkey.txt`
Shared secret between Nextcloud and ExApps DSP

## `mxregkey.txt`
The password used for registration on Matrix.
*Note: Registration is disabled for now, due to LDAP being used for accounts instead. This is kept for future reference, tho.*

## `mxturnfull.conf`
A full config for COTURN. Unfortunatley, it's not possible to just pass the actual secret values as `_FILE` envars - or any envars, for that matter - becasue Coturn doesn't support those.

The file should look like:
```conf
use-auth-secret
static-auth-secret=<a secret key>
realm=rtc.chat.guziohub.ovh
```

## `mxturn.txt`
The value of `static-auth-secret=` from `mxturnfull.conf`.

*The world would've been such a great place if everyone had followed the damn specs..... I wouldn't need to split this stupid secret into 2 different files.*

## `ldap_key.txt`
The seed for LDAP's secret key. Should be generated using [`./generate_secrets.sh`](https://github.com/lldap/lldap/blob/main/generate_secrets.sh).

## `ldap_jwt.txt`
A JSON Web Token secret for LDAP. Should be generated using [`./generate_secrets.sh`](https://github.com/lldap/lldap/blob/main/generate_secrets.sh).

## `ldap_pass.txt`
A password of the `admin` account on LDAP.