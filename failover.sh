#!/bin/sh
#* * * * * /root/crontask/switch.sh >/dev/null 2>&1

NAME=shadowsocks
CURRENT_SERVER=$(uci get shadowsocks.@transparent_proxy[0].main_server | awk '{print $1}')
LOGTIME=$(date "+%Y-%m-%d %H:%M:%S")

set -euo

is_timeout() {
  pidof ss-redir >/dev/null || return 1
  if [ "$(curl -Is -K HEAD https://www.google.com/ | head -n 1 | awk '{print $2}')" != 200 ]; then
    if [ "$(curl -Is -K HEAD https://www.baidu.com/ | head -n 1 | awk '{print $2}')" = 200 ]; then
      return 0
    fi
  fi
  return 1
}

while is_timeout; do
  NEXT_SERVER=$(uci -n export $NAME | awk '$2=/servers/{print substr($3,2,9)}' | sed "/""$CURRENT_SERVER""/d")
  if [ -n "$NEXT_SERVER" ]; then
    uci delete $NAME.@transparent_proxy[0].main_server
    uci add_list $NAME.@transparent_proxy[0].main_server="$NEXT_SERVER"
    uci add_list $NAME.@transparent_proxy[0].main_server="$NEXT_SERVER"
    uci commit $NAME
    /etc/init.d/$NAME restart
    echo "[$LOGTIME] FAILOVER DETECTED AND RECOVERED."
  fi
done