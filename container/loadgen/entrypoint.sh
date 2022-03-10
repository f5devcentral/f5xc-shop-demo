#!/bin/sh

mkdir /tmp/tor
mkdir /tmp/log
touch /tmp/log/tor.log
touch /tmp/log/privoxy.log

/usr/bin/tor --quiet -f /etc/tor/torrc
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start tor process: $status"
  exit $status
fi
curl -s -o /dev/null -f --connect-timeout 10 --retry 5 \
    --socks5-hostname localhost:9150 $TARGET_URL || exit 1
echo "tor started and check succeeded."

/usr/sbin/privoxy /tmp/privoxy/config
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start proxy process: $status"
  exit $status
fi
curl -s -o /dev/null -f --connect-timeout 10 --retry 5 \
    -x "http://localhost:8118" $TARGET_URL || exit 1
echo "proxy started and check suceeded."

k6 run main.js