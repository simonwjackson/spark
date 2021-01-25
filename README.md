# Spark

Spark is an [Ansible][1] playbook meant to provision a personal machine running
[Arch Linux][2]. It is intended to run locally on a fresh Arch install (ie,
taking the place of any [post-installation][3]), but due to Ansible's idempotent
nature it may also be run on top of an already configured machine.

Spark assumes it will be run on a laptop and performs some configuration based
on this assumption. This behaviour may be changed by removing the `laptop` role
from the playbook or by skipping the `laptop` tag.

If Spark is run on either a ThinkPad or a MacBook, it will detect this and
execute platform-specific tasks.

**Note:** If you would like to try recreating all the tasks that are currently
included in the ansible playbook, through a VM, you would need a disk of at
least **16GB** in size.


## Running

First, sync mirrors and install Ansible:

    $ pacman -Syy python-passlib ansible

Second, install and update the submodules:

    $ git submodule init && git submodule update
    
Run the playbook as root.

    # ansible-playbook -i localhost playbook.yml

When run, Ansible will prompt for the user password. This only needs to be
provided on the first run when the user is being created. On later runs,
providing any password -- whether the current user password or a new one -- will
have no effect.


## SSH

By default, Ansible will attempt to install the private SSH key for the user.
The key should be available at the path specified in the `ssh.user_key`
variable.  Removing this variable will cause the key installation task to be
skipped.  

### SSHD

If `ssh.enable_sshd` is set to `True` the [systemd socket service][4] will be enabled. By default, sshd is configured but not enabled.


## Tagging

All tasks are tagged with their role, allowing them to be skipped by tag in
addition to modifying `playbook.yml`.


## AUR

All tasks involving the [AUR][6] are tagged `aur`. To provision an AUR-free
system, pass this tag to ansible's `--skip-tag`.

AUR packages are installed via the [ansible-aur][7] module. Note that while
[yay][8], an [AUR helper][9], is installed by default, it will *not* be used
during any of the provisioning.


## Mail

### Receiving Mail

Receiving mail is supported by syncing from IMAP servers via both [isync][13]
and [OfflineIMAP][14]. By default isync is enabled, but this can be changed to
OfflineIMAP by setting the value of the `mail.sync_tool` variable to
`offlineimap`.

### Sending Mail

[msmtp][15] is used to send mail. Included as part of msmtp's documentation are
a set of [msmtpq scripts][16] for queuing mail. These scripts are copied to the
user's path for use. When calling `msmtpq` instead of `msmtp`, mail is sent
normally if internet connectivity is available. If the user is offline, the mail
is saved in a queue, to be sent out when internet connectivity is again
available. This helps support a seamless workflow, both offline and online.

### System Mail

If the `email.user` variable is defined, the system will be configured to
forward mail for the user and root to this address. Removing this variable will
cause no mail aliases to be put in place.

The cron implementation is configured to send mail using `msmtp`.  

### Syncing and Scheduling Mail

A shell script called `mailsync` is included to sync mail, by first sending any
mail in the msmtp queue and then syncing with the chosen IMAP servers via either
isync or OfflineIMAP. The script will also attempt to sync contacts and
calendars via [vdirsyncer][17]. To disable this behavior, set the
`mail.sync_pim` variable to `False`.

Before syncing, the `mailsync` script checks for internet connectivity using
NetworkMananger. `mailsync` may be called directly by the user, ie by
configuring a hotkey in Mutt.

A [systemd timer][18] is also included to periodically call `mailsync`. The
timer is set to sync every 5 minutes (configurable through the `mail.sync_time`
variable).

The timer is not started or enabled by default. Instead, the timer is added to
`/etc/nmtrust/trusted_units`, causing the NetworkManager trusted unit dispatcher
to activate the timer whenever a connection is established to a trusted network.
The timer is stopped whenever the network goes down or a connection is
established to an untrusted network.

To have the timer activated at boot, change the `mail.sync_on` variable from
`trusted` to `all`.

If the `mail.sync_on` variable is set to anything other than `trusted` or `all`,
the timer will never be activated.


## Tarsnap

[Tarsnap][19] is installed with its default configuration file. However, setting
up Tarsnap is left as an exercise for the user. New Tarsnap users should
[register their machine and generate a key][20]. Existing users should recover
their key(s) and cache directory from their backups (or, alternatively, recover
their key(s) and rebuild the cache directory with `tarsnap --fsck`).

[Tarsnapper][21] is installed to manage backups. A basic configuration file to
backup `/etc` is included. Tarsnapper is configured to look in
`/usr/local/etc/tarsnapper.d` for additional jobs. As with with the Tarsnap key
and cache directory, users should recover their jobs files from backups after
the Tarsnapper install is complete. See the Tarsnapper documentation for more
details.  

### Running Tarsnap

A systemd unit file and timer are included for Tarsnapper. Rather than calling
it directly, the systemd unit wraps Tarsnapper with [backitup][22].

The timer is set to execute the unit hourly, but backitup will only call
Tarsnapper once within the period defined in the `tarsnapper.period` variable.
This defaults to `DAILY`. This increases the likelyhood of completing daily
backups by checking each hour if the unit has run succesfully on the current
calendar day.

In addition to the period limitation, backitup defaults to only calling
Tarsnapper when it detects the machine ison AC power. To allow Tarsnapper to run
when on battery, set the `tarsnapper.ac_only` variable to `False`.

As with `mailsync`, the timer is not started or enabled by default. Instead, the
timer is added to `/etc/nmtrust/trusted_units`, causing the NetworkManager
trusted unit dispatcher to activate the timer whenever a connection is
established to a trusted network. The timer is stopped whenever the network goes
down or a connection is established to an untrusted network.

To have the timer activated at boot, change the `tarsnapper.run_on` variable
from `trusted` to `all`.

If the `tarsnapper.run_on` variable is set to anything other than `trusted` or
`all`, the timer will never be activated.


## Tor

[Tor][23] is installed by default. A systemd service unit for Tor is installed,
but not enabled or started. instead, the service is added to
`/etc/nmtrust/trusted_units`, causing the NetworkManager trusted unit dispatcher
to activate the service whenever a connection is established to a trusted
network. The service is stopped whenever the network goes down or a connection
is established to an untrusted network.

To have the service activated at boot, change the `tor.run_on` variable from
`trusted` to `all`.

If you do not wish to use Tor, simply remove the `tor` variable from the
configuration.


## BitlBee

[BitlBee][25] and [WeeChat][26] are used to provide chat services. A systemd
service unit for BitlBee is installed, but not enabled or started by default.
Instead, the service is added to `/etc/nmtrust/trusted_units`, causing the
NetworkManager trusted unit dispatcher to activate the service whenever a
connection is established to a trusted network. The service is stopped whenever
the network goes down or a connection is established to an untrusted network.

To have the service activated at boot, change the `bitlbee.run_on` variable from
`trusted` to `all`.  

If the `bitlbee.run_on` variable is set to anything other than `trusted` or
`all`, the service will never be activated.

By default BitlBee will be configured to proxy through Tor. To disable this,
remove the `bitlebee.torify` variable or disable Tor entirely by removing the
`tor` variable.


## git-annex

[git-annex][27] is installed for file syncing. A systemd service unit for the
git-annex assistant is enabled and started by default. To prevent this, remove
the `gitannex` variable from the config.

Additionally, the git-annex unit is added to `/etc/nmtrust/trusted_units`,
causing the NetworkManager trusted unit dispatcher to activate the service
whenever a connection is established to a trusted network. The service is
stopped whenever a connection is established to an untrusted network. Unlike
other units using the trusted network framework, the git-annex unit is also
activated when there are no active network connections. This allows the
git-annex assistant to be used when on trusted networks and when offline, but
not when on untrusted networks.

If the `gitannex.stop_on_untrusted` variable is set to anything other than
`True` or is not defined, the git-annex unit will not be added to the trusted
unit file, resulting in the git-annex assistant not being stopped on untrusted
networks.



[1]: http://www.ansible.com
[2]: https://www.archlinux.org
[3]: https://wiki.archlinux.org/index.php/Installation_guide#Post-installation
[4]: https://wiki.archlinux.org/index.php/Secure_Shell#Managing_the_sshd_daemon
[6]: https://aur.archlinux.org
[7]: https://github.com/pigmonkey/ansible-aur
[8]: https://github.com/Jguer/yay
[9]: https://wiki.archlinux.org/index.php/AUR_helpers
[13]: http://isync.sourceforge.net/
[14]: http://offlineimap.org/
[15]: http://msmtp.sourceforge.net/
[16]: http://sourceforge.net/p/msmtp/code/ci/master/tree/scripts/msmtpq/README.msmtpq
[17]: https://github.com/pimutils/vdirsyncer
[18]: https://wiki.archlinux.org/index.php/Systemd/Timers
[19]: https://www.tarsnap.com/
[20]: https://www.tarsnap.com/gettingstarted.html
[21]: https://github.com/miracle2k/tarsnapper
[22]: https://github.com/pigmonkey/backitup
[23]: https://www.torproject.org/
[25]: https://www.bitlbee.org/main.php/news.r.html
[26]: https://weechat.org/
[27]: https://git-annex.branchable.com/
[28]: http://www.postgresql.org/
[29]: https://github.com/boramalper/himawaripy
[30]: https://en.wikipedia.org/wiki/Himawari_8
