#!/bin/sh
#0 5 * * 1 /root/crontask/update.sh >/dev/null 2>&1

set -euo
 
wget -P /tmp/ --quiet https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf
sed -i "s|^\(server.*\)/[^/]*$|\1/119.29.29.29|" /tmp/accelerated-domains.china.conf
sed -i /hicloud.com/d /tmp/accelerated-domains.china.conf
sed -i /dbankcdn.com/d /tmp/accelerated-domains.china.conf
mv -f /tmp/accelerated-domains.china.conf /etc/dnsmasq.d
 
if pidof dnsmasq>/dev/null; then
    /etc/init.d/dnsmasq restart
fi