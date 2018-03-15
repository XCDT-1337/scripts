

# Linux Hardening

Cannibalized from https://www.computerworld.com/article/3144985/linux/linux-hardening-a-15-step-checklist-for-a-secure-linux-server.html

## Document the host information

Document the following information:

* Machine name
* IP address
* Mac address

## Lock the boot directory

The boot directory contains important files related to the Linux kernel, so you
need to make sure that this directory is locked down to read-only permissions by
following the next simple steps. Add the following to `/etc/fstab`:

```
LABEL=/boot /boot   ext2    defaults,ro 1   2
```

When you finish editing the file, you need to set the owner by executing the
following command: `chown root:root /etc/fstab`.

Securing the boot settings:

```
# Set the owner and group of /etc/grub.conf to the root user:
chown root:root /etc/grub.conf

# Set permission on the /etc/grub.conf
chmod og-rwx /etc/grub.conf

# Require authentication for single-user mode

sed -i "/SINGLE/s/sushell/sulogin/" /etc/sysconfig/init
sed -i "/PROMPT/s/yes/no/" /etc/sysconfig/init
```
## Disable USB usage

Depending on how critical your system is, sometimes it’s necessary to disable
the USB sticks usage on the Linux host. There are multiple ways to deny the
usage of USB storage; here’s a popular one:

Open the `/etc/modprobe.d/blacklist.conf` file. Add the following:

```
blacklist usb_storage
```

## System update

From https://superuser.com/questions/339537/where-can-i-get-the-repositories-for-old-ubuntu-versions:

> Your system is End-of-Line (EOL), therefore not officially supported. Unless
> you have a good reason for sticking with 9.04, upgrade to a newer version.
> 16.04 is the next long-term supported release for Ubuntu, which will continue
> to receive updates.
> 
> To access old Ubuntu repositories, take a look at
> http://old-releases.ubuntu.com/.
> 
> There is also an official Ubuntu documentation for EOL upgrades:
> https://help.ubuntu.com/community/EOLUpgrades
> 
> They say you should be able to access your packages by putting the following
> into /etc/apt/sources.list. Important: Change CODENAME to your distribution's
> code name, e.g. jaunty.
> 
> ```
> ## EOL upgrade sources.list
> # Required
> deb http://old-releases.ubuntu.com/ubuntu/ CODENAME main restricted universe multiverse
> deb http://old-releases.ubuntu.com/ubuntu/ CODENAME-updates main restricted universe multiverse
> deb http://old-releases.ubuntu.com/ubuntu/ CODENAME-security main restricted universe multiverse
> 
> # Optional
> #deb http://old-releases.ubuntu.com/ubuntu/ CODENAME-backports main restricted universe multiverse
> ```
>
> Just run apt-get update and you can use them.

## Check the installed packages

```bash
# Redhat
dnf search kernel*-4* # To find specific package
dnf list

# Ubuntu
dpkg --get-selections
```

Disable legacy services:

* Telnet server
* RSH server
* NIS server
* TFTP server
* TALK server

## Check for open ports

Run the following:

```
netstat -antp
```

Explanation:

* `-a`: Show all sockets, listening and non-listening
* `-n`: Don't resolve hostnames or guess protocols
* `-t`: Find TCP connections (Use `-u` for UDP)
* `-p`: Show PID of the program

## Secure SSH

Here are some additional options that you need to make sure exist in `/etc/ssh/sshd_config`:

```
Port 99
PermitRootLogin no
AllowUsers [user whitelist]
Protocol2
IgnoreRhosts to yes
HostbasedAuthentication no
PermitEmptyPasswords no
X11Forwarding no
MaxAuthTries 5
Ciphers aes128-ctr,aes192-ctr,aes256-ctr
ClientAliveInterval 900
ClientAliveCountMax 0
UsePAM yes
```

Set the permissions on the sshd_config file so that only root users can change
its contents:

```
chown root:root /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config
```

## Network parameters

In `/etc/sysctl.conf`:

- Disable the IP Forwarding by setting the `net.ipv4.ip_forward parameter` to 0 
- Disable the Send Packet Redirects by setting the
  `net.ipv4.conf.all.send_redirects` and `net.ipv4.conf.default.send_redirects`
  parameters to 0
- Disable ICMP Redirect Acceptance by setting the
  `net.ipv4.conf.all.accept_redirects` and `net.ipv4.conf.default.accept_redirects`
  parameters to 0
- Enable Bad Error Message Protection by setting the
  `net.ipv4.icmp_ignore_bogus_error_responses` parameter to 1

TODO more on iptables here

## Password policies

People often reuse their passwords, which is a bad security practice. The old
passwords are stored in the file “/etc/security/opasswd”. We are going to use
the PAM module to manage the security policies of the Linux host. Under a debian
distro, open the file “/etc/pam.d/common-password” using a text editor and add
the following two lines:

First, we need to install PAM (Pluggable Authentication Module) or ensure it's
installed.

The find the password config and add the following lines:

```
# Remember the last four passwords (user cannot reuse)
auth       sufficient   pam_unix.so likeauth nullok
password   sufficient   pam_unix.so remember=4
```

This file is `/etc/pam.d/common-password` on Debian and `/etc/pam.d/...` on
Redhat.

Add to `/etc/pam.d/system-auth`:

```
# Prevent brute-force attacks
/lib/security/$ISA/pam_cracklib.so retry=3 minlen=8 lcredit=-1 ucredit=-2 dcredit=-2 ocredit=-1

# Lock users out after five attempts
auth required pam_env.so
auth required pam_faillock.so preauth audit silent deny=5 unlock_time=604800
auth [success=1 default=bad] pam_unix.so
auth [default=die] pam_faillock.so authfail audit deny=5 unlock_time=604800
auth sufficient pam_faillock.so authsucc audit deny=5 unlock_time=604800
auth required pam_deny.so
```

Add to `/etc/pam.d/password-auth`:

```
# Lock users out after five attempts
auth required pam_env.so
auth required pam_faillock.so preauth audit silent deny=5 unlock_time=604800
auth [success=1 default=bad] pam_unix.so
auth [default=die] pam_faillock.so authfail audit deny=5 unlock_time=604800
auth sufficient pam_faillock.so authsucc audit deny=5 unlock_time=604800
auth required pam_deny.so

# To unlock a user, run: /usr/sbin/faillock --user $USERNAME --reset
```

Open up `/etc/login.defs` and make sure the `PASS_MAX_DAYS` is set to 90.
(Passwords expire after 90 days.) Also run `chage --maxdays 90 $USERNAME` to set
it for the active user.


The next tip for enhancing the passwords policies is to restrict access to the su command by setting the pam_wheel.so parameters in “/etc/pam.d/su”:
Add to `/etc/pam.d/su`:

```
# Restrict access to su command
auth required pam_wheel.so use_uid
```

Finally, run this script:

```bash
#!/bin/bash

# Disable system accounts for non-root users 
for user in `awk -F: '($3 < 500) {print $1 }' /etc/passwd`; do
    if [ $user != "root" ] then
        /usr/sbin/usermod -L $user # -L : lock a user's password

        if [ $user != "sync" ] && [ $user != "shutdown" ] && [ $user != "halt" ] then 
            /usr/sbin/usermod -s /sbin/nologin $user # -s : Set login shell
        fi
    fi
done
```
## Permissions and verifications

```bash
# Secure crontab
chown root:root /etc/anacrontab
chmod og-rwx /etc/anacrontab
chown root:root /etc/crontab
chmod og-rwx /etc/crontab
chown root:root /etc/cron.hourly
chmod og-rwx /etc/cron.hourly
chown root:root /etc/cron.daily
chmod og-rwx /etc/cron.daily
chown root:root /etc/cron.weekly
chmod og-rwx /etc/cron.weekly
chown root:root /etc/cron.monthly
chmod og-rwx /etc/cron.monthly
chown root:root /etc/cron.d
chmod og-rwx /etc/cron.d

# Set the right and permissions on “/var/spool/cron” for “root crontab”
chown root:root <crontabfile>
chmod og-rwx <crontabfile>

# Set User/Group Owner and Permission on “passwd” file
chmod 644 /etc/passwd
chown root:root /etc/passwd

# Set User/Group Owner and Permission on the “group” file
chmod 644 /etc/group
chown root:root /etc/group

# Set User/Group Owner and Permission on the “shadow” file
chmod 600 /etc/shadow
chown root:root /etc/shadow

# Set User/Group Owner and Permission on the “gshadow” file

chmod 600 /etc/gshadow
chown root:root /etc/gshadow
```