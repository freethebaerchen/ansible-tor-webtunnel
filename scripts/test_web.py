#!/usr/bin/env python3
import subprocess
import json
import argparse
import sys
import re
import os
from jinja2 import Environment

def render_jinja_template(template_str):
    env = Environment()
    env.globals['lookup'] = lambda scope, key: os.environ[key] if scope == 'env' and key in os.environ else None
    template = env.from_string(template_str)
    return template.render()

def get_inventory_data(inventory_file):
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

def get_hosts_with_vars(inventory_data, limit):
    if limit in inventory_data:
        hosts = inventory_data[limit]['hosts']
    elif limit in inventory_data.get('_meta', {}).get('hostvars', {}):
        hosts = [limit]
    else:
        sys.stdout.write(f"❌ Host or group '{limit}' not found in the inventory.\n")
        sys.stdout.flush()
        sys.exit(1)

    host_var_list = []
    for host in hosts:
        hostvars = inventory_data.get('_meta', {}).get('hostvars', {}).get(host, {})
        ip = hostvars.get('ansible_host', host)
        raw_domain = hostvars.get('domain', None)
        domain = render_jinja_template(raw_domain) if raw_domain else None
        host_var_list.append((host, ip, domain))

    return host_var_list

def run_curl_command(url):
    process = subprocess.Popen(
        ["curl", "-4", "-o", "/dev/null", "-s", "-w", "%{http_code}", url],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
    )

    stdout, stderr = process.communicate()

    if stderr:
        sys.stdout.write(f"⚠️ Curl error for {url}: {stderr}\n")
        sys.stdout.flush()

    return stdout.strip() if stdout.strip() else "000"

def check_http_redirect(host, ip, domain):
    sys.stdout.write(f"🔄 Checking HTTP redirect for {host} ({ip})\n")
    sys.stdout.flush()

    http_code = run_curl_command(f"http://{domain}")
    https_code = run_curl_command(f"https://{domain}")

    if http_code == "301" and https_code == "200":
        sys.stdout.write(f"✅ {host} ({ip}): HTTP 301 and HTTPS 200 detected.\n")
    elif http_code == "308" and https_code == "200":
        sys.stdout.write(f"✅ {host} ({ip}): HTTP 308 and HTTPS 200 detected.\n")
    else:
        sys.stdout.write(f"❌ {host} ({ip}): Unexpected HTTP codes (HTTP: {http_code}, HTTPS: {https_code}).\n")
        sys.exit(1)

    sys.stdout.flush()

def check_page_title(host, ip, domain):
    sys.stdout.write(f"🔄 Checking page title for {host} ({ip})\n")
    sys.stdout.flush()

    process = subprocess.Popen(
        ["curl", "-s", f"https://{domain}"],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
    )

    stdout, stderr = process.communicate()

    match = re.search(r"<title>(.*?)</title>", stdout, re.IGNORECASE)
    if match:
        title = match.group(1).strip()
        if title == "Bear Follows Cursor":
            sys.stdout.write(f"✅ {host} ({ip}): Title matches 'Bear Follows Cursor'.\n")
        else:
            sys.stdout.write(f"❌ {host} ({ip}): Title mismatch. Found '{title}'.\n")
            sys.exit(1)
    else:
        sys.stdout.write(f"❌ {host} ({ip}): No title found in response.\n")
        sys.exit(1)

    sys.stdout.flush()

def check_host_vars(inventory_file, limit):
    inventory_data = get_inventory_data(inventory_file)
    hosts_with_vars = get_hosts_with_vars(inventory_data, limit)

    for host, ip, domain in hosts_with_vars:
        sys.stdout.write(f"🔄 Checking host: {host} (IP: {ip})\n")
        sys.stdout.flush()
        
        if domain:
            check_http_redirect(host, ip, domain)
            check_page_title(host, ip, domain)
        else:
            sys.stdout.write(f"⚠️ {host} ({ip}): No 'domain' variable found.\n")
            sys.stdout.flush()

def main():
    parser = argparse.ArgumentParser(description="Check Ansible hosts for HTTP redirects and page title.")
    
    parser.add_argument('-i', '--inventory', required=True, help="Path to the Ansible inventory file.")
    parser.add_argument('-l', '--limit', required=True, help="Group name OR single host to check.")

    args = parser.parse_args()
    check_host_vars(args.inventory, args.limit)

if __name__ == '__main__':
    main()
