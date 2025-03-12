#!/usr/bin/env python3
import subprocess
import json
import argparse
import sys
import re

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

def get_hosts_with_vars(inventory_data, limit):
    """Get a list of (host, ip, domain) tuples for the given `limit`."""
    if limit in inventory_data:
        hosts = inventory_data[limit]['hosts']
    elif limit in inventory_data.get('_meta', {}).get('hostvars', {}):
        hosts = [limit]
    else:
        print(f"❌ Host or group '{limit}' not found in the inventory.")
        sys.exit(1)

    host_var_list = []
    for host in hosts:
        hostvars = inventory_data.get('_meta', {}).get('hostvars', {}).get(host, {})
        ip = hostvars.get('ansible_host', host)
        domain = hostvars.get('domain', None)
        host_var_list.append((host, ip, domain))

    return host_var_list

def check_http_redirect(host, ip, domain):
    """Check if HTTP response is 301 and HTTPS response is 200."""
    http_code = subprocess.run(
        ["curl", "-o", "/dev/null", "-s", "-w", "%{http_code}", f"http://{domain}"],
        capture_output=True, text=True
    ).stdout.strip()

    https_code = subprocess.run(
        ["curl", "-o", "/dev/null", "-s", "-w", "%{http_code}", f"https://{domain}"],
        capture_output=True, text=True
    ).stdout.strip()

    if http_code == "301" and https_code == "200":
        print(f"✅ {host} ({ip}): HTTP 301 and HTTPS 200 detected.")
    else:
        print(f"❌ {host} ({ip}): Unexpected HTTP codes (HTTP: {http_code}, HTTPS: {https_code}).")

def check_page_title(host, ip, domain):
    """Check if the page title is Bear Follows Cursor'."""
    result = subprocess.run(
        ["curl", "-s", f"https://{domain}"],
        capture_output=True, text=True
    )

    match = re.search(r"<title>(.*?)</title>", result.stdout, re.IGNORECASE)
    if match:
        title = match.group(1).strip()
        if title == "Bear Follows Cursor":
            print(f"✅ {host} ({ip}): Title matches 'Bear Follows Cursor'.")
        else:
            print(f"❌ {host} ({ip}): Title mismatch. Found '{title}'.")
    else:
        print(f"❌ {host} ({ip}): No title found in response.")

def check_host_vars(inventory_file, limit):
    inventory_data = get_inventory_data(inventory_file)
    hosts_with_vars = get_hosts_with_vars(inventory_data, limit)

    for host, ip, domain in hosts_with_vars:
        print(f"🔄 Checking host: {host} (IP: {ip})")
        if domain:
            check_http_redirect(host, ip, domain)
            check_page_title(host, ip, domain)
        else:
            print(f"⚠️ {host} ({ip}): No 'domain' variable found.")

def main():
    parser = argparse.ArgumentParser(description="Check Ansible hosts for HTTP redirects and page title.")
    
    parser.add_argument('-i', '--inventory', required=True, help="Path to the Ansible inventory file.")
    parser.add_argument('-l', '--limit', required=True, help="Group name OR single host to check.")

    args = parser.parse_args()
    check_host_vars(args.inventory, args.limit)

if __name__ == '__main__':
    main()