import os
from jinja2 import Template

os_list = ["alpine", "archlinux", "freebsd", "openbsd", "rhel", "suse", "ubuntu"]
webserver_list = ["apache", "caddy", "nginx"]
tld = os.getenv("TEST_SERVER_TLD")
if tld is None:
    raise ValueError("TEST_SERVER_TLD environment variable is required")

template_str = """---
domain: {{ os }}.{{ webserver }}.{{ tld }}
id: "{{ os }}{{ webserver }}"
reverse_proxy: false
deploy_webroot: true
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
        rendered_config = template.render(os=os_name, webserver=webserver_name, tld=tld)
        filename = os.path.join(target_dir, f"{os_name}-{webserver_name}.yaml")
        with open(filename, "w") as file:
            file.write(rendered_config)
        print(f"✅ Config written to {filename}")