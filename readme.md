# Setup for a Tor WebTunnel Bridge with Ansible in Hetzner Cloud
[Official Documentation of the Tor-Project](https://community.torproject.org/relay/setup/webtunnel/)

## General information
The anible project sets up the HCloud servers with the [ansbile hcloud colection](https://docs.ansible.com/ansible/latest/collections/hetzner/hcloud/index.html).\
The project is set up, so the Ansible control node is dockerized. This means, there is no need to setup ansible or a Python3 venv.

In Hetzner there will be created, if you do not make any changes for the servers, three [CAX11](https://www.hetzner.com/cloud/) (arm) instances.
They are spawned in the locations, the arm instances are available.
So one will be created in Falkenstein, one in Nuremberg and one in Helsinki.

In the [system role](roles/system) is a [templated /etc/hosts](roles/system/templates/hosts.j2) file.
It adds a GitHub IPv6 "proxy", because GitHub, as of now, doesnt support IPv6.
The proxy is provided by [Daniel Winzen](https://danwin1210.de/github-ipv6-proxy.php).
If you dont want this, as it is not needed for the fetching of the WebSocket Bridge from the torproject GitLab, you can remove or comment out the following part from [this file](roles/system/tasks/general.yaml).
```
    - name: Generate /etc/hosts file
      ansible.builtin.template:
        src: "{{ role_path }}/templates/hosts.j2"
        dest: /etc/hosts
```

## Prerequisites
### SSH
At least one (ed25519) SSH-Key is needed.\
If you need help generating one, run the following command:
```ssh-keygen -t ed25519```\
Please consider encrypting the Key with a password, when you are asked for one.\
For the other options, you can leave the defaults.

### Docker
You need a device, that is able to run Docker.

### Hetzner
1. Create a Account at [Hetzner](https://accounts.hetzner.com/signUp)
2. Create a HCloud project
3. Create a [API-Token](https://docs.hetzner.cloud/#getting-started) with read/write privileges
4. Save the API-Token in a secure place, e.g. BitWarden

### Other
1. A (sub)domain per server
2. The code for a website (per server)
Optional: The Webservers can be configured to reverse-proxy an existing domain. If you want to do this you can configure it in the [group-vars/all.yaml](group-vars/all.yaml).
Set the reverse-proxy value to true and configure the domain you want to reverse proxy to as value for the reverse_proxy_url variable.

## preparation of the code
1. Copy the [group-vars example file](group-vars/all-example.yaml) to the [group-vars](group-vars) named all.yaml\
    1.1 Change the username\
    1.2 Change the public key(s)\
    1.3 Modify the servers to your fit\
        1.3.1 The ID needs to be set, for the identifier of the or bridge. The name in the end will be <tor.nickname><id>, so with the default values it will be somenickname1, somenickname2, ...\
    1.4 Exchange the example domains with your actual domains\
    1.5 Change the SSH-Key. This will be the key, that is added for the root-User to the Hetzner instance and in the HCloud Console in Security/SSH-Keys\
    1.6 Change the E-Mail you want to use for the certificate request AND as contact address for the bridge\
    Info: For the bridge address the @ and . symbol will be replaced with [at] and [dot]\
    1.7 Change the tor.nickname to a your fit
2. Copy the [env file](.env) to .env.local\
    2.1 Exchange the comment with your HCloud API-Token from the [prerequisites](#hetzner) step

## executing ansible
1. ```./ansible-playbook.sh playbook.yaml (--tags hetzner)```
2. After that, the HCloud infrastructure is created\
    2.1 Now the DNS-Record(s) need to be set.\
    2.2 Set an AAAA-Record with the IPv6-Address of the server\
    2.3 Set an A-Record with the IPv4-Address of the server (if you enbaled it)
3. Run the script a second time.\

Now the Tor WebTunnel Bridge is created.\
You can SSH to your server and run ```sudo journalctl -xeu tor@default```.\
You will find the following lines:
```
Your Tor server's identity key fingerprint is '<YourNicknameID> someFinGerpRinT1234'
Your Tor bridge's hashed identity key fingerprint is '<YourNicknameID> someoTheRFinGerpRinT1234'
Your Tor server's identity key ed25519 fingerprint is '<YourNicknameID> someeD25519FinGerpRinT1234'
You can check the status of your bridge relay at https://bridges.torproject.org/status?id=S0M31DF0RY0URR3L4Y
```

The link in the last line will not show a status until you ran the relay for some time.
Please don't stress. Some status will show up.

## Additional information
If you add more servers, you need to copy and paste one of the servers in the [group-vars](group-vars/all-example.yaml).
Change the variables to your fit and count the id one up.