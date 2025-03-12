#!/usr/bin/env python3
import subprocess
import json
import argparse
import sys

def get_inventory_data(inventory_file):
    """Retrieve the full inventory data as JSON."""
    command = f"ansible-inventory -i {inventory_file} --list"
    result = subprocess.run(command, shell=True, capture_output=True, text=True)

    if result.returncode != 0:
        print(f"❌ Error executing ansible-inventory: {result.stderr}")
        sys.exit(1)
    
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError:
        print("❌ Error parsing inventory data.")
        sys.exit(1)

def get_hosts_with_ips(inventory_data, limit):
    """Get a list of (host, ip) tuples for the given `limit`."""
    if limit in inventory_data:
        hosts = inventory_data[limit]['hosts']
    elif limit in inventory_data.get('_meta', {}).get('hostvars', {}):
        hosts = [limit]
    else:
        print(f"❌ Host or group '{limit}' not found in the inventory.")
        sys.exit(1)

    host_ip_list = []
    for host in hosts:
        hostvars = inventory_data.get('_meta', {}).get('hostvars', {}).get(host, {})
        ip = hostvars.get('ansible_host', host)
        host_ip_list.append((host, ip))

    return host_ip_list

def run_ssh_command(host, ip, command):
    """Run an SSH command on a remote host and return the output."""
    try:
        output = subprocess.check_output(
            ["ssh", ip, command],
            stderr=subprocess.STDOUT,
            text=True
        ).strip()
        return output
    except subprocess.CalledProcessError as e:
        print(f"❌ {host} ({ip}): ERROR running SSH command. Details:\n{e.output}")
        sys.exit(1)

def check_uname(inventory_file, limit):
    """Run 'uname -a' on each host in the limit group and filter for Linux/OpenBSD/FreeBSD."""
    inventory_data = get_inventory_data(inventory_file)
    hosts_with_ips = get_hosts_with_ips(inventory_data, limit)

    for host, ip in hosts_with_ips:
        print(f"🔄 Checking host: {host} (IP: {ip})")

        output = run_ssh_command(host, ip, "uname -a")
        if output is None:
            print(f"❌ {host} ({ip}): SSH command failed.")
            sys.exit(1)

        if "linux" in output.lower():
            os_type = "Linux"
        elif "openbsd" in output.lower():
            os_type = "OpenBSD"
        elif "freebsd" in output.lower():
            os_type = "FreeBSD"
        else:
            os_type = "Unknown"

        if os_type != "Unknown":
            print(f"✅ {host} ({ip}): {os_type} detected.")
        else:
            print(f"⚠️ {host} ({ip}): OS not recognized. Output: {output}")

def main():
    parser = argparse.ArgumentParser(description="Run 'ssh <host> \"uname -a\"' on hosts in an Ansible inventory and filter for Linux/OpenBSD/FreeBSD.")
    
    parser.add_argument('-i', '--inventory', required=True, help="Path to the Ansible inventory file.")
    parser.add_argument('-l', '--limit', required=True, help="Group name OR single host to check.")

    args = parser.parse_args()
    check_uname(args.inventory, args.limit)

if __name__ == '__main__':
    main()