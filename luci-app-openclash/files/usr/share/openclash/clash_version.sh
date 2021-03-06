#!/bin/sh
CKTIME=$(date "+%Y-%m-%d-%H")
LAST_OPVER="/tmp/clash_last_version"
LAST_VER=$(sed -n 1p "$LAST_OPVER" 2>/dev/null |awk -F '-' '{print $1$2}' 2>/dev/null |awk -F '.' '{print $2$3}' 2>/dev/null)
CLASH_VERF=$(/etc/openclash/clash -v 2>/dev/null)
CLASH_VER=$(echo "$CLASH_VERF" 2>/dev/null |awk -F ' ' '{print $2}' 2>/dev/null |awk -F '-' '{print $1$2}' 2>/dev/null |awk -F '.' '{print $2$3}' 2>/dev/null)
HTTP_PORT=$(uci get openclash.config.http_port 2>/dev/null)
PROXY_ADDR=$(uci get network.lan.ipaddr 2>/dev/null |awk -F '/' '{print $1}' 2>/dev/null)

if [ -s "/tmp/openclash.auth" ]; then
   PROXY_AUTH=$(cat /tmp/openclash.auth |awk -F '- ' '{print $2}' |sed -n '1p' 2>/dev/null)
fi

VERSION_URL="https://raw.githubusercontent.com/vernesong/OpenClash/master/core_version"
if [ "$CKTIME" != "$(grep "CheckTime" $LAST_OPVER 2>/dev/null |awk -F ':' '{print $2}')" ]; then
	 if pidof clash >/dev/null; then
      curl -sL --connect-timeout 10 --retry 2 -x http://$PROXY_ADDR:$HTTP_PORT -U "$PROXY_AUTH" "$VERSION_URL" -o $LAST_OPVER >/dev/null 2>&1
   else
      curl -sL --connect-timeout 10 --retry 2 "$VERSION_URL" -o $LAST_OPVER >/dev/null 2>&1
   fi
   if [ "$?" -eq "0" ] && [ -s "$LAST_OPVER" ]; then
      echo "CheckTime:$CKTIME" >>$LAST_OPVER
   else
      rm -rf $LAST_OPVER
   fi
fi
if [ "$LAST_VER" -gt "$CLASH_VER" ]; then
   return 2
fi 2>/dev/null