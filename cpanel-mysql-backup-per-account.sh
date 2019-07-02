#!/usr/bin/env bash
# C-Russell 01/07/2019
# Set date
today=$(date +%Y-%m-%d)
# Get list
/usr/local/cpanel/bin/whmapi1 list_databases > /root/list_databases.log
# Sort list
cat /root/list_databases.log | egrep "cpuser|name" | awk {'print $2'} | paste - - -d" " > /root/list_databases_sorted.log
# Start the loop
while IFS=" " read -r value1 value2 remainder
do
        if [[ ! -e /home/$value1/mysqlbackup ]]; then
            mkdir /home/$value1/mysqlbackup
        fi
        /usr/bin/mysqldump --single-transaction $value2 | gzip > /home/$value1/mysqlbackup/$value2-$today.sql.gz
        chown -R $value1:$value1 /home/$value1/mysqlbackup
        find /home/$value1/mysqlbackup -maxdepth 1 -mtime +7 -type f -delete
done < "/root/list_databases_sorted.log"
