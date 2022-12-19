# ssh-geoblock
Based of https://www.axllent.org/docs/ssh-geoip/ i've created a script to block all SSH Login Attempts not from a Whitelist OR whitelist Country.

Installation:

 1. Download Script: `wget xxx`
 2. Modify Script. (Modify Whitelist, Separated by Space, Modify Country Whitelist)
 3. install geoip:  `apt install geoip-database geoip-bin`
 4. Test script: `sshCountryFilter.sh <addIPhere>`
 5. **ATTENTION: If you did somethign wrong, you need local/KVM access to the VM to repair**
 6. Modify `/etc/hosts.deny` --> add `sshd: ALL`
 7. Modify `/etc/hosts.allow` --> add `sshd: ALL: aclexec /path/to/sshCountryFilter.sh %a`
