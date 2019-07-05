#!/usr/bin/env bash
# C-Russell 05/07/2019
# Setup cPanel provided Apache (EA4) for Bitninja WAF 2.0

# Check if running EA4
if ! rpm -qa | grep ea-apache24-2.4; then
  exit 1
fi

# Check and install mod_remoteip if not already installed
if ! rpm -qa | grep -q remoteip; then
  yum -y install ea-apache24-mod_remoteip.x86_64
fi

# Edit remoteip.conf file
MODFILE=$(find /etc/apache2/conf.modules.d/ -name "*mod_remoteip.conf")
cat >> $MODFILE <<EOL
<IfModule remoteip_module>
 RemoteIPHeader X-Forwarded-For
 RemoteIPTrustedProxy 127.0.0.1 $(hostname -i)
</IfModule>
EOL

# Set logging for forwarded IP
cp /etc/apache2/conf.d/includes/pre_main_global.conf{,.pre-waf2.0}
cat >> /etc/apache2/conf.d/includes/pre_main_global.conf <<EOL
<IfModule remoteip_module>
  RemoteIPHeader X-Forwarded-For
</IfModule>
<IfModule log_config_module>
  LogFormat "%{Referer}i -> %U" referer
  LogFormat "%{User-agent}i" agent
  LogFormat "%a %l %u %t \"%r\" %>s %b" common
  LogFormat "%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
  CustomLog logs/access_log combined
</IfModule>
EOL

# Restart Apache
service httpd restart

# Done
echo -e "Apache has been prepared for WAF 2.0. You may now enable it inside the Bitninja control panel."

# Is Bitninja WAF 2.0 running? 
# netstat -lntp | grep -E '60300|60301' ; iptables -S -t nat | grep -E 'BN_WAF_REDIR'
