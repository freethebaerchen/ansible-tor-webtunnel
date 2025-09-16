import subprocess
import json
import argparse
import sys

def get_inventory_data(inventory_file):
    """Retrieve the full inventory data as JSON."""
    command = f"ansible-inventory -i {inventory_file} --list"
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    stdout, stderr = process.communicate()

    if process.returncode != 0:
        sys.stdout.write(f"❌ Error executing ansible-inventory: {stderr}\n")
        sys.stdout.flush()
        sys.exit(1)
    
    try:
        return json.loads(stdout)
    except json.JSONDecodeError:
        sys.stdout.write("❌ Error parsing inventory data.\n")
        sys.stdout.flush()
        sys.exit(1)

def get_hosts_with_ips(inventory_data, limit):
    """Get a list of (host, ip) tuples for the given `limit`."""
    if limit in inventory_data:
        hosts = inventory_data[limit]['hosts']
    elif limit in inventory_data.get('_meta', {}).get('hostvars', {}):
        hosts = [limit]
    else:
        sys.stdout.write(f"❌ Host or group '{limit}' not found in the inventory.\n")
        sys.stdout.flush()
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
        process = subprocess.Popen(
            ["ssh", "-o", "StrictHostKeyChecking=no", "-i", "~/.ssh/id_ed25519", ip, command],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        stdout, stderr = process.communicate()

        if process.returncode != 0:
            sys.stdout.write(f"❌ {host} ({ip}): ERROR running SSH command. Details:\n{stderr.strip()}\n")
            sys.stdout.flush()
            return None

        return stdout.strip()
    except subprocess.CalledProcessError as e:
        sys.stdout.write(f"❌ {host} ({ip}): SSH command failed.\n{e.output}\n")
        sys.stdout.flush()
        return None

def check_uname(inventory_file, limit):
    """Run 'uname -a' on each host in the limit group and filter for Linux/OpenBSD/FreeBSD."""
    inventory_data = get_inventory_data(inventory_file)
    hosts_with_ips = get_hosts_with_ips(inventory_data, limit)

    for host, ip in hosts_with_ips:
        sys.stdout.write(f"🔄 Checking host: {host} (IP: {ip})\n")
        sys.stdout.flush()

        output = run_ssh_command(host, ip, "uname -a")
        if output is None:
            sys.stdout.write(f"❌ {host} ({ip}): SSH command failed.\n")
            sys.stdout.flush()
            sys.exit(1)

        if "alpine" in output.lower():
            os_type = "Alpine Linux"
        elif "arch" in output.lower():
            os_type = "Arch Linux"
        elif "suse" in output.lower() or "opensuse" in output.lower():
            os_type = "SUSE Linux"
        elif "almalinux" in output.lower():
            os_type = "AlmaLinux"
        elif "ubuntu" in output.lower():
            os_type = "Ubuntu"
        elif "linux" in output.lower():
            os_type = "Linux"
        elif "openbsd" in output.lower():
            os_type = "OpenBSD"
        elif "freebsd" in output.lower():
            os_type = "FreeBSD"
        else:
            os_type = "Unknown"

        if os_type != "Unknown":
            sys.stdout.write(f"✅ {host} ({ip}): {os_type} detected.\n")
        else:
            sys.stdout.write(f"⚠️ {host} ({ip}): OS not recognized. Output: {output}\n")

        sys.stdout.flush()

def main():
    parser = argparse.ArgumentParser(description="Run 'ssh <host> \"uname -a\"' on hosts in an Ansible inventory and filter for Linux/OpenBSD/FreeBSD.")
    
    parser.add_argument('-i', '--inventory', required=True, help="Path to the Ansible inventory file.")
    parser.add_argument('-l', '--limit', required=True, help="Group name OR single host to check.")

    args = parser.parse_args()
    check_uname(args.inventory, args.limit)

if __name__ == '__main__':
    main()
