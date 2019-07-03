#!/usr/bin/env bash
# C-Russell 01/07/2019
# After you configure ClamAV, we recommend that you schedule a root cron job to run daily during off-peak hours. The following example demonstrates a command that will scan the server's accounts:
# Loop through all accounts:
while read domain user; do echo -e "\n$user" ; /usr/local/cpanel/3rdparty/bin/clamscan -i -r /home/"$user" 2>&1; done </etc/trueuserdomains >>/root/infections-$(date +"%d_%m_%Y").txt
# Send report once done:
/usr/bin/mail -s "ClamAV scan for $(hostname) on $(date +"%d_%m_%Y")" user@example.com < /root/infections-$(date +"%d_%m_%Y").txt
# Done
