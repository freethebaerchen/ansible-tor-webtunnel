import os
import subprocess
import argparse
from jinja2 import Template
from concurrent.futures import ThreadPoolExecutor, as_completed

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Sync certificates for specified OS and webserver.")
parser.add_argument(
    "--limit", "-l", 
    type=str, 
    help="Limit the execution to a specific OS (e.g., alpine, ubuntu). If not provided, all OS will be included."
)

args = parser.parse_args()

os_list = ["alpine", "archlinux", "freebsd", "openbsd", "rhel", "suse", "ubuntu"]
webserver_list = ["apache", "caddy", "nginx"]
tld = os.getenv("TEST_SERVER_TLD")

if tld is None:
    raise ValueError("TEST_SERVER_TLD environment variable is required")

source_template_str = "{{ webserver }}-certificate/{{ webserver }}.{{ tld }}.{{ file_ext }}"
destination_template_str = "{{ os }}.{{ webserver }}.{{ tld }}.{{ file_ext }}"
target_base_dir = "host_files"
file_extensions = ["crt", "key"]

os.makedirs(target_base_dir, exist_ok=True)

if args.limit:
    os_list = [os_name for os_name in os_list if os_name == args.limit]

def sync_file(os_name, webserver_name, ext):
    source_path = source_template_str.replace("{{ webserver }}", webserver_name).replace("{{ tld }}", tld).replace("{{ file_ext }}", ext)
    destination_path = destination_template_str.replace("{{ os }}", os_name).replace("{{ webserver }}", webserver_name).replace("{{ tld }}", tld).replace("{{ file_ext }}", ext)

    local_target_path = os.path.join(target_base_dir, f"{os_name}-{webserver_name}", destination_path)
    os.makedirs(os.path.dirname(local_target_path), exist_ok=True)

    command = [
        "rsync", "-avz", "--no-o", "--no-g",
        f"github-runner@10.1.0.100:{source_path}",
        local_target_path
    ]
    
    try:
        subprocess.run(command, check=True)
        return f"✅ Successfully synchronized {os_name}.{webserver_name}.{ext}"
    except subprocess.CalledProcessError as e:
        return f"❌ Error synchronizing {os_name}.{webserver_name}.{ext}"

with ThreadPoolExecutor() as executor:
    futures = []
    for os_name in os_list:
        for webserver_name in webserver_list:
            for ext in file_extensions:
                futures.append(executor.submit(sync_file, os_name, webserver_name, ext))
    
    for future in as_completed(futures):
        print(future.result())
