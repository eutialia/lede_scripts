#!/bin/sh
#* * * * * /root/crontask/switch.sh >/dev/null 2>&1

NAME=shadowsocks
CURRENT_SERVER=$(uci get shadowsocks.@transparent_proxy[0].main_server)

is_timeout() {
  pidof ss-redir >/dev/null || return 1
  if [ ! "$(wget --spider --quiet --timeout=2 --tries=1 https://www.google.com/)" ]; then
    if [ ! "$(wget --spider --quiet --timeout=2 --tries=1 https://www.baidu.com/)" ]; then
      return 0
    fi
  fi
  return 1
}

if is_timeout; then
  NEXT_SERVER=$(uci -n export $NAME | awk '$2=/servers/{print substr($3,2,9)}' | sed "/""$CURRENT_SERVER""/d")
  if [ -n "$NEXT_SERVER" ]; then
    uci delete $NAME.@transparent_proxy[0].main_server
    uci add_list $NAME.@transparent_proxy[0].main_server="$NEXT_SERVER"
    uci commit $NAME
    /etc/init.d/$NAME restart
  fi
fi