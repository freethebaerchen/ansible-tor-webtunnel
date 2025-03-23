import subprocess
import json
import argparse
import socket
import time
import sys

def check_port(ip, port=22, timeout=2):
    """Check if the given IP is reachable on the specified port (default: 22)."""
    try:
        with socket.create_connection((ip, port), timeout=timeout):
            return True
    except (socket.timeout, socket.error):
        return False

def get_inventory_data(inventory_file):
    """Retrieve the full inventory data as JSON."""
    command = f"ansible-inventory -i {inventory_file} --list"
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    output, error = process.communicate()

    if process.returncode != 0:
        sys.stdout.write(f"Error executing command: {error}\n")
        sys.stdout.flush()
        sys.exit(1)
    
    try:
        return json.loads(output)
    except json.JSONDecodeError:
        sys.stdout.write("Error parsing inventory data.\n")
        sys.stdout.flush()
        sys.exit(1)

def get_hosts(inventory_data, limit):
    """Get the list of hosts for the given `limit`, which can be a group or a single host."""
    if limit in inventory_data:
        return inventory_data[limit]['hosts']
    
    elif limit in inventory_data.get('_meta', {}).get('hostvars', {}):
        return [limit]

    else:
        sys.stdout.write(f"Host or group '{limit}' not found in the inventory.\n")
        sys.stdout.flush()
        sys.exit(1)

def wait_for_hosts(inventory_file, limit, max_retries=100):
    """Check if the hosts in the limit (group or single) are reachable via SSH."""
    inventory_data = get_inventory_data(inventory_file)
    hosts = get_hosts(inventory_data, limit)

    retries = {host: 0 for host in hosts}
    all_reachable = False
    attempts = 0

    while attempts < max_retries:
        for host in hosts:
            host_info = inventory_data['_meta']['hostvars'].get(host, {})
            ip = host_info.get('ansible_host', host)

            sys.stdout.write(f"Checking Host: {host} (IP: {ip})\n")
            sys.stdout.flush()

            if check_port(ip):
                sys.stdout.write(f"✅ {host} ({ip}) is reachable.\n")
                sys.stdout.flush()
                retries[host] = 0  # Reset retry counter
            else:
                retries[host] += 1
                if retries[host] < max_retries:
                    sys.stdout.write(f"⏳ {host} ({ip}) is unreachable. Retrying for {attempts+1}. time in 5 seconds...\n")
                    sys.stdout.flush()
                    time.sleep(5)
                else:
                    sys.stdout.write(f"❌ {host} ({ip}) is still unreachable after {max_retries} attempts.\n")
                    sys.stdout.flush()
                    sys.exit(1)
        
        if all(retries[host] == 0 for host in hosts):
            sys.stdout.write("✅ All hosts are reachable. Proceeding.\n")
            sys.stdout.flush()
            sys.exit(0)

        time.sleep(1)
        attempts += 1

def main():
    parser = argparse.ArgumentParser(description="Check host reachability in an Ansible inventory.")
    
    parser.add_argument('-i', '--inventory', required=True, help="Path to the Ansible inventory file.")
    parser.add_argument('-l', '--limit', required=True, help="Group name OR single host to check.")

    args = parser.parse_args()
    wait_for_hosts(args.inventory, args.limit)

if __name__ == '__main__':
    main()
