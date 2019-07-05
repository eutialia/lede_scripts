#!/bin/sh
#0 5 * * 1 /root/crontask/update.sh >/dev/null 2>&1

LOGTIME=$(date "+%Y-%m-%d %H:%M:%S")

set -e -o pipefail
 
wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | \
    awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > \
    /tmp/chinadns_chnroute.txt
 
mv -f /tmp/chinadns_chnroute.txt /etc/
 
if pidof ss-redir>/dev/null; then
    /etc/init.d/shadowsocks restart
    echo "["$LOGTIME"] CHN IP LIST UPDATED."
fi