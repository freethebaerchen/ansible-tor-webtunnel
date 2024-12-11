#!/usr/bin/python3
from ansible.module_utils.basic import AnsibleModule
import re
import random

def get_fingerprint_from_file(file_path):
    try:
        with open(file_path, "r") as file:
            for line in file:
                match = re.search(r"([A-F0-9]{40})", line)
                if match:
                    return match.group(1)
    except FileNotFoundError:
        print(f"Error: File not found - {file_path}")
    except Exception as e:
        print(f"Error reading file {file_path}: {e}")
    return None

def get_url_from_file(file_path):
    try:
        with open(file_path, "r") as file:
            for line in file:
                if "ServerTransportOptions webtunnel" in line:
                    match = re.search(r"url=(.*)", line)
                    if match:
                        return match.group(0)
    except FileNotFoundError:
        print(f"Error: File not found - {file_path}")
    except Exception as e:
        print(f"Error reading file {file_path}: {e}")
    return None

def main():
    module = AnsibleModule(
        argument_spec=dict(
            fingerprint_path=dict(type='str', required=True),
            torrc_path=dict(type='str', required=True)
        )
    )

    fingerprint_path = module.params['fingerprint_path']
    torrc_path = module.params['torrc_path']

    fingerprint = get_fingerprint_from_file(fingerprint_path)
    if not fingerprint:
        module.fail_json(msg="Fingerprint not found.")

    third_octet = random.randint(2, 253)
    fourth_octet = random.randint(2, 253)

    url = get_url_from_file(torrc_path)
    if not url:
        module.fail_json(msg="URL not found.")

    output = f"webtunnel 10.0.{third_octet}.{fourth_octet}:443 {fingerprint} {url} ver=0.0.1"
    module.exit_json(changed=False, stdout=output, url=url, fingerprint=fingerprint)

if __name__ == "__main__":
    main()
