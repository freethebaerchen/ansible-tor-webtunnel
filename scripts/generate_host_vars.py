import os
from jinja2 import Template

os_list = ["alpine", "archlinux", "freebsd", "openbsd", "rhel", "suse", "ubuntu"]
webserver_list = ["apache", "caddy", "nginx", "docker"]
docker_supported_oses = ["alpine", "ubuntu"]  # Only generate for these OSes

tld = os.getenv("TEST_SERVER_TLD")
if tld is None:
    raise ValueError("TEST_SERVER_TLD environment variable is required")

template_str = """---

domain: {{ os }}.{{ webserver }}.{% raw %}{{ lookup('env', 'TEST_SERVER_TLD') }}{% endraw %}
id: "{{ os }}{{ webserver }}"
reverse_proxy: true
reverse_proxy_url: static.{% raw %}{{ lookup('env', 'TEST_SERVER_TLD') }}{% endraw %}
deploy_webroot: false
use_webserver: {{ webserver }}
tor:
  nickname:
  test: true

"""

template = Template(template_str)

target_dir = "test_host_vars/"
os.makedirs(target_dir, exist_ok=True)

for os_name in os_list:
    for webserver_name in webserver_list:
        if webserver_name == "docker" and os_name not in docker_supported_oses:
            continue  # Skip generating docker config for unsupported OSes
        rendered_config = template.render(os=os_name, webserver=webserver_name, tld=tld)
        filename = os.path.join(target_dir, f"{os_name}-{webserver_name}.yaml")
        with open(filename, "w") as file:
            file.write(rendered_config)
        print(f"✅ Config written to {filename}")
