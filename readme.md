# Setup for a Tor WebTunnel Bridge with Ansible
[Official Documentation of the Tor-Project](https://community.torproject.org/relay/setup/webtunnel/)

## Consideration
The script can handle Setting up the infrastructure in Hetzner Cloud, but you should consider to not host your bridges at Hetzner, since the [Tor Projects Website](https://community.torproject.org/relay/community-resources/good-bad-isps/) recommends, to use another hoster for bridges/relays.
If you are not able to provide other VMs or servers you can still host the relays in Hetzner Cloud, since it is better to host there, than to not contibute to the Tor project.

If you have servers at another provider or want to create servers there you can follow the "non Hetzner instructions" below.

## General information
The anible project sets up the HCloud servers with the [Ansible hcloud collection](https://docs.ansible.com/ansible/latest/collections/hetzner/hcloud/index.html).\
The project is set up, so the Ansible control node is dockerized. This means, there is no need to setup ansible or a Python3 venv.

In Hetzner there will be created, if you do not make any changes, three [CAX11](https://www.hetzner.com/cloud/) (arm) instances.
They are spawned in the locations, where arm instances are available.
So one will be created in Falkenstein, one in Nuremberg and one in Helsinki.

When using Hetzner Cloud, and you are installing the OS via the "ISO Images" option, you may need to configure the IPv6-Address by yourself.
You can look at this [documentation for some operating systems](https://docs.hetzner.com/de/cloud/servers/static-configuration/).

In the [system role](roles/system) is a [templated /etc/hosts](roles/system/templates/hosts.j2) file.
It adds a GitHub IPv6 "proxy", because GitHub, as of now, doesn't support IPv6.
The proxy is provided by [Daniel Winzen](https://danwin1210.de/github-ipv6-proxy.php).
If you dont want this, as it is not needed for the fetching of the WebSocket Bridge from the [Tor Projects GitLab](https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/webtunnel), you can remove or comment out the following part from [this file](roles/system/tasks/general.yaml).
```
    - name: Generate /etc/hosts file
      ansible.builtin.template:
        src: "{{ role_path }}/templates/hosts.j2"
        dest: /etc/hosts
```

# NO-RISK-NO-FUN
Against all recommendations are unattended-upgrades for the supported Operating Systems configured.
For Debian- and RedHat-based distros it's pretty uncritical, but for the rest, do it at your own risk.
You can disable them by setting `unattended_upgrades: no`or `unattended_upgrades: false` in the [host_vars](host_vars)

## OS Support
This Project supports, as of right now the following distributions:\
    - Debian-based (Ubuntu 24.04)\
    - Alpine-based (Alpine 3.21.0)\
    - RHEL-based (Oracle Linux 9.5, CentOS Stream 9, Almalinux 9.5)\
    - OpenSUSE-based (OpenSUSE Leap 15.6, OpenSUSE Tumbleweed)\
    - OpenBSD-based (OpenBSD 7.6, OpenBSD 7.7)\
    - Archlinux-based (Archlinux 2024.08.01, Archlinux 2025.04.01)\
    - FreeBSD-based (FreeBSD 14.1, FreeBSD 14.2)

The OS-Version in Brackets were tested.\

Regularily tested are the following:\
    - Ubuntu 24.04\
    - Alpine 3.21.3\
    - AlmaLinux 9.5\
    - OpenSUSE Tumbleweed\
    - OpenBSD 7.7\
    - Archlinux 2025.04.01\
    - FreeBSD 14.2
    - Docker-Container Setup (on Alpine 3.21.3 and Ubuntu 24.04)

## Prerequisites

### SSH
At least one (ed25519) SSH-Key is needed.\
If you need help generating one, run the following command:
```ssh-keygen -t ed25519```\
Please consider encrypting the key with a password, when you are asked for one.\
For the other options, you can leave the defaults.

### Python
You need Python >= 3.12 installed

### Hetzner (optional)
1. Create a Account at [Hetzner](https://accounts.hetzner.com/signUp)
2. Create a HCloud project
3. Create a [API-Token](https://docs.hetzner.cloud/#getting-started) with read/write privileges
4. Save the API-Token in a secure place, e.g. BitWarden

### Other
1. A (sub)domain per server
2. ´python3.12.*` installed on the server
3. The code for a website (per server)\
In Future: The Webservers will be able to reverse-proxy an existing domain. If you want to do this you can configure it in the [host_vars/example.yaml](host_vars/your-bridge-fsn-0.yaml).
Set the reverse-proxy value to true and configure the domain you want to reverse proxy to as value for the reverse_proxy_url variable.

## Non-Hetzner-specific Setup
1. Forget the (Hetzner) steps before this one.
2. Copy the [example inventory.ini](inventory.ini.example) to inventory.ini
3. Modify the entry or entries to your fit

## preparation of the code
1. Copy the [group_vars example file](group_vars/all-example.yaml) to the [group_vars](group_vars) named all.yaml\
    1.1 Change the username\
    1.2 Modify the servers to your fit\
    1.3 Change the SSH public key(s).
    1.4 Change the E-Mail you want to use for the certificate request AND as contact address for the bridge\
    Info: For the bridge address the @ and . symbol will be replaced with [at] and [dot]\
    1.5 Change the tor.nickname to your fit
2. Copy the [env file](.env) to .env.local (optinal)\
    2.1 Exchange the comment with your HCloud API-Token from the [prerequisites](#hetzner) step
3. Copy the [example host_var file](host_vars/your-bridge-0.yaml) to host_vars/<name-in-inventory.ini>.yaml
4. Modify the variables, so they match your configuration
    4.1 The ID needs to be set, for the identifier of the or bridge. The name in the end will be <tor.nickname><id>, so with the default values it will be somenickname1, somenickname2, ...\
    4.2 Exchange the example domains with your actual domains\
    4.3 Configure if the webserver should be reverse-proxy to another site, as described above
5. Save custom SSL/TLS-Certificate (optional)
    1.1 Obtain a SSL/TLS certificate (if you don't want to use Let'sEncrypt)\
    1.2 Save the Files (Chain, Certificate, private Key)\
        1.2.1 with the correct fileendings [like in the examples](host_files/your-bridge-fsn-0)\
        1.2.2 with the correct pattern domain.tld.fileending\
    1.3 (IMPORTANT!) Use ansible-vault or another method to encrypt the private key\
        1.3.1 The command to use is `ansible-vault encrypt path/to/file`


## executing ansible
INFO: Step 3 is only for a Hetzner Cloud setup
1. `source .envrc`
2. `ansible-playbook playbook.yaml `
3. After that, the HCloud infrastructure is created\
    2.1 Set an A-Record with the IPv4-Address of the server\
    2.2 Set an AAAA-Record with the IPv6-Address of the server (optinal)
4. Run the script a second time.

Now the Tor WebTunnel Bridge is created.\
You can SSH to your server and run ```sudo journalctl -xeu tor@default```.\
You will find the following lines:
```
Your Tor server's identity key fingerprint is '<YourNicknameID> someFinGerpRinT1234'
Your Tor bridge's hashed identity key fingerprint is '<YourNicknameID> someoTheRFinGerpRinT1234'
Your Tor server's identity key ed25519 fingerprint is '<YourNicknameID> someeD25519FinGerpRinT1234'
You can check the status of your bridge relay at https://bridges.torproject.org/status?id=S0M31DF0RY0UR8R1DG3
```

The link in the last line will not show a status until you ran the relay for some time.
Please don't stress. Some status will soon show up after at most 3 hours.

## Additional information
### Hetzner specific
If you add more servers, you need to copy and paste one of the servers in the [group_vars](group_vars/all-example.yaml).

###
You can configure the distribution method of your bridge via the group_vars/host_vars.
In the [example group_vars](group_vars/all.yaml.example) you can find the [Tor documentation](https://gitlab.torproject.org/tpo/anti-censorship/rdsys/-/blob/main/doc/distributors.md) for the allowed values.