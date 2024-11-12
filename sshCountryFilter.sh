#!/bin/bash

# UPPERCASE space-separated country codes to ACCEPT
ALLOW_COUNTRIES="DE"
WHITELIST_IPS=(192.168.1.12 fd11:192:168:1::12)

###Only /24 /128
WHITELIST_NETWORKS=(fd11:192:168:2:: 192.168.2.)

if [ $# -ne 1 ]; then
  echo "Usage:  `basename $0` <ip>" 1>&2
  exit 0 # return true in case of config issue
fi

if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        geoiplookupbin=$(which geoiplookup)
else
        geoiplookupbin=$(which geoiplookup6)
fi

for IP in ${WHITELIST_IPS[@]}; do
        if [ $1 == $IP ]; then
                RESPONSE="ALLOW WHITELIST IP"
                logger "$RESPONSE sshd connection from $1"
                exit 0
        fi
done

for NUMBER in {1..254}; do
        for NETWORK in ${WHITELIST_NETWORKS[@]}; do
                for IP in $(echo "${NETWORK}${NUMBER}"); do
                        if [ $1 == $IP ]; then
                                RESPONSE="ALLOW WHITELIST NETWORK"
                                logger "$RESPONSE sshd connection from $1"
                                exit 0
                        fi
                done
        done
done

COUNTRY=$($geoiplookupbin $1 | awk -F ": " '{ print $2 }' | awk -F "," '{ print $1 }' | head -n 1)

[[ $ALLOW_COUNTRIES =~ $COUNTRY ]] && RESPONSE="ALLOW" || RESPONSE="DENY"

if [ $RESPONSE = "ALLOW" ]
then
  logger "$RESPONSE sshd connection from $1 ($COUNTRY)"
  exit 0
else
  logger "GEOBLOCKED sshd connection from $1 ($COUNTRY)" #Fail2Ban friendly
  exit 1
fi
