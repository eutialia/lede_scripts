#!/bin/sh
#*/5 * * * * /root/crontask/resolve.sh >/dev/null 2>&1
#MC is cfg084a8f

IMS_IP=$(uci get shadowsocks.cfg054a8f.server)
IMS_HOST=$(uci get shadowsocks.cfg054a8f.host)
HKBN_IP=$(uci get shadowsocks.cfg074a8f.server)
HKBN_HOST=$(uci get shadowsocks.cfg074a8f.host)
LOGTIME=$(date "+%Y-%m-%d %H:%M:%S")

set -euo

resolve() {
  # pidof ss-redir >/dev/null || return 1
  new_ip_ims=$(nslookup "$IMS_HOST" 119.29.29.29 | awk '/Address 1:/{print $3}')
  new_ip_hkbn=$(nslookup "$HKBN_HOST" 119.29.29.29 | awk '/Address 1:/{print $3}')

  if [ "$IMS_IP" != "$new_ip_ims" ] && [ -n "$new_ip_ims" ]
  then
    uci set shadowsocks.cfg054a8f.server="$new_ip_ims"
    uci commit shadowsocks
    /etc/init.d/shadowsocks restart
    echo "[$LOGTIME] NEW IP FOR HKT: [$new_ip_ims]."
  fi

  if [ "$HKBN_IP" != "$new_ip_hkbn" ] && [ -n "$new_ip_hkbn" ]
  then
    uci set shadowsocks.cfg074a8f.server="$new_ip_hkbn"
    uci commit shadowsocks
    /etc/init.d/shadowsocks restart
    echo "[$LOGTIME] NEW IP FOR HKBN: [$new_ip_hkbn]."
  fi
}

resolve