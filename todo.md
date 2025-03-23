# ToDos
## OS's
### arm
- [x] Ubuntu
- [x] FreeBSD
- [x] CentOS
- [x] openSuse
- [x] Alpine
- [x] OpenBSD
### x64
- [x] Ubuntu
- [x] FreeBSD
- [x] AlmaLinux
- [x] openSuse
- [x] Alpine
- [x] OpenBSD
- [x] Archlinux
- [ ] NixOS
- [ ] MacOS


## Other
- [x] (Refactor) Change from root to tor user
- [x] (Refactor) Change SSH-Key setup to template
- [x] (Refactor) Change to certbot webroot validation
- [x] (Fix) Put random-string file in tor.directory
- [x] (Feature/Fix) Save webserver error-logs, but not Access-Logs
- [x] (Fix) server shutdown after successful test
- [ ] (Feature) Reverse Proxy
- [ ] (Feature) Grafana Monitoring -> [Metrics Documentation](https://support.torproject.org/relay-operators/relay-bridge-overloaded/)
- [ ] (Feature) Auto-Update Report via Mail
- [ ] (Feature) Security (SElinux/AppArmor, [Internal Firewall](https://community.torproject.org/relay/setup/post-install/))
- [ ] (Refactor) Cleanup (defaults/group_vars/host_vars/...)
- [ ] (Refactor) Tasks (OS-Vars, instead of ansible_os_family blocks)
- [ ] (Fix) Certificate renewal Cronjob
- [x] (Actions) Configure [S3-Artifacts](https://github.com/marketplace/actions/s3-artifact-upload)
- [ ] (Feature) Build tor from source
