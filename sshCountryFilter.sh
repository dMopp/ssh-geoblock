#!/bin/bash

# UPPERCASE space-separated country codes to ACCEPT
ALLOW_COUNTRIES="DE"
WHITELIST_IPS=(192.168.1.54 192.168.1.1)

if [ $# -ne 1 ]; then
  echo "Usage: `basename $0` <ip>" 1>&2
  exit 0 # return true in case of config issue
fi

if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        geoiplookupbin=$(which geoiplookup)
else
        geoiplookupbin=$(which geoiplookup6)
fi

for IP in ${WHITELIST_IPS[@]}; do
        if [ $1 == $IP ]; then
                RESPONSE="ALLOW WHITELIST"
                logger "$RESPONSE sshd connection from $1 (WHITELIST)"
                exit 0
        fi
done


COUNTRY=$($geoiplookupbin $1 | awk -F ": " '{ print $2 }' | awk -F "," '{ print $1 }' | head -n 1)

[[ $ALLOW_COUNTRIES =~ $COUNTRY ]] && RESPONSE="ALLOW" || RESPONSE="DENY"

if [ $RESPONSE = "ALLOW" ]
then
  logger "$RESPONSE sshd connection from $1 ($COUNTRY)"
  exit 0
else
  logger "$RESPONSE sshd connection from $1 ($COUNTRY)"
  exit 1
fi
