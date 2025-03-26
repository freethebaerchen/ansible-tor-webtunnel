#!/usr/bin/python
from ansible.module_utils.basic import AnsibleModule
import subprocess

def run_curl(url, proxy_type, proxy, proxy_user, proxy_pass, extra_args):
    # Building the curl command based on user input
    curl_cmd = ['curl', '--silent', '--show-error', '--location']

    # Add proxy support
    if proxy_type:
        if proxy_type == 'socks5':
            curl_cmd.extend(['--socks5', proxy])
        elif proxy_type == 'http':
            curl_cmd.extend(['--proxy', proxy])
        elif proxy_type == 'https':
            curl_cmd.extend(['--proxy', proxy])
        else:
            raise ValueError("Unsupported proxy type. Supported types are 'socks5', 'http', 'https'.")

    # Add proxy authentication if specified
    if proxy_user and proxy_pass:
        curl_cmd.extend(['--proxy-user', f'{proxy_user}:{proxy_pass}'])

    # Add the URL
    curl_cmd.append(url)

    # Append any additional arguments (like headers, etc.)
    if extra_args:
        curl_cmd.extend(extra_args)

    # Run the curl command
    try:
        result = subprocess.run(curl_cmd, capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        raise ValueError(f"Curl command failed: {e.stderr}")

def main():
    module_args = dict(
        url=dict(type='str', required=True),
        proxy_type=dict(type='str', choices=['socks5', 'http', 'https'], required=True),
        proxy=dict(type='str', required=True),
        proxy_user=dict(type='str', required=False, default=None),
        proxy_pass=dict(type='str', required=False, default=None, no_log=True),
        extra_args=dict(type='list', elements='str', required=False, default=[])
    )

    result = dict(
        changed=False,
        response=None
    )

    # Initialize the module
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # Fetch the parameters
    url = module.params['url']
    proxy_type = module.params['proxy_type']
    proxy = module.params['proxy']
    proxy_user = module.params['proxy_user']
    proxy_pass = module.params['proxy_pass']
    extra_args = module.params['extra_args']

    try:
        # Run the curl command with the provided parameters
        response = run_curl(url, proxy_type, proxy, proxy_user, proxy_pass, extra_args)
        result['response'] = response
        module.exit_json(**result)
    except ValueError as e:
        module.fail_json(msg=str(e))

if __name__ == '__main__':
    main()