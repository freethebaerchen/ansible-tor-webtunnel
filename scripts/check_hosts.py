import subprocess
import json
import argparse
import socket
import time
import sys

def check_port(ip, port=22, timeout=2):
    try:
        with socket.create_connection((ip, port), timeout=timeout):
            return True
    except (socket.timeout, socket.error):
        return False

def get_host_info(inventory_file, group_name, max_retries=5):
    command = f"ansible-inventory -i {inventory_file} --list"
    result = subprocess.run(command, shell=True, capture_output=True, text=True)

    if result.returncode != 0:
        print(f"Error executing command: {result.stderr}")
        sys.exit(1)  # Exit if inventory command fails
    
    try:
        inventory_data = json.loads(result.stdout)
    except json.JSONDecodeError:
        print("Error parsing inventory data.")
        sys.exit(1)  # Exit if JSON parsing fails

    if group_name not in inventory_data:
        print(f"Group '{group_name}' not found in the inventory.")
        sys.exit(1)  # Exit if group is not found

    hosts = inventory_data[group_name]['hosts']
    retries = {host: 0 for host in hosts}
    all_reachable = False

    # First check if all hosts are reachable, if so, exit immediately
    if all(check_port(inventory_data['_meta']['hostvars'].get(host, {}).get('ansible_host', 'No IP')) for host in hosts):
        print("All hosts are reachable. Exiting immediately.")
        sys.exit(0)  # Exit with success if all hosts are reachable

    # If not all are reachable, retry up to max_retries
    attempts = 0
    failed_hosts = 0

    while attempts < max_retries:
        for host in hosts:
            host_info = inventory_data['_meta']['hostvars'].get(host, {})
            hostname = host
            ip = host_info.get('ansible_host', 'No IP')

            print(f"Checking Hostname: {hostname}, IP: {ip}")

            if check_port(ip):
                print(f"Port 22 is open and reachable on {hostname} ({ip})")
                retries[host] = 0
            else:
                retries[host] += 1
                if retries[host] < max_retries:
                    print(f"Port 22 is not reachable on {hostname} ({ip}). Retrying...")
                else:
                    print(f"Port 22 is still not reachable on {hostname} ({ip}) after {max_retries} attempts.")
                    failed_hosts += 1
        
        # If all hosts fail after max retries, stop the pipeline
        if failed_hosts == len(hosts):
            print("All hosts have failed after maximum retries. Stopping pipeline.")
            sys.exit(1)  # Exit with error if all hosts failed

        if all(retries[host] >= max_retries for host in hosts):
            print("All hosts have been probed for maximum retries.")
            break

        time.sleep(1)
        attempts += 1

    # If at least one host is reachable, exit successfully
    print("All reachable hosts confirmed, proceeding to next step.")
    sys.exit(0)

def main():
    parser = argparse.ArgumentParser(description="Get host information for a group in an Ansible inventory.")
    
    parser.add_argument('-i', '--inventory', required=True, help="Path to the Ansible inventory file.")
    parser.add_argument('-l', '--limit', required=True, help="Group name to get host information for.")
    
    args = parser.parse_args()
    
    get_host_info(args.inventory, args.limit)

if __name__ == '__main__':
    main()
