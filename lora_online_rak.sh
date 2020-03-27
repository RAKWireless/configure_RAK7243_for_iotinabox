#!/bin/sh
# Copyright (C) 2017 myDevices

wget="wget"
NETWORK="ttn"

#gateway id
CONFIG_FILE="/opt/ttn-gateway/packet_forwarder/lora_pkt_fwd/local_conf.json"
TAG_GW_MAC="gateway_ID"
GATEWAY_ID=$( sed -n 's/.*"'$TAG_GW_MAC'": "\(.*\)"/\1/p' $CONFIG_FILE | sed -e 's/^[ ]*//g' | sed -e 's/[ ]*$//g' )

# append eui in front of the gateway id
GATEWAY_ID="eui-$GATEWAY_ID"


BROADCAST_HOSTS_URL=http://gw-ping.simplysense.com/pingtargets
BROADCAST_HOSTS_DIR=/tmp
BROADCAST_HOSTS_FILE=$BROADCAST_HOSTS_DIR/pingtargets
#optional payload is keepalive
#default keepalive is 1 minute = 60 seconds
#set this a cron job of 1 minute
# * * * * * username /some_path/lora_online.sh

if [ ! -f "$BROADCAST_HOSTS_FILE" ]
then
    echo "$0: File '${BROADCAST_HOSTS_FILE}' not found. Downloading the file."
    $wget $BROADCAST_HOSTS_URL -P $BROADCAST_HOSTS_DIR
fi

while IFS= read -r CAYENNE_LORA_HOST; do
    CAYENNE_LORA_URI="$CAYENNE_LORA_HOST/$NETWORK/gateways/$GATEWAY_ID/state"
    echo "Calling server host for cayenne: $CAYENNE_LORA_URI"
    result=$($wget --server-response --post-data \"\" --no-check-certificate $CAYENNE_LORA_URI 2>&1 -O /dev/null | awk '/^  HTTP/{print $2}')
    # result=$($wget -qO- --post-data "" $CAYENNE_LORA_URI)
    if [ "$result" != "200" ]; then
        echo "Error from the server: '$result'"
    fi
done <$BROADCAST_HOSTS_FILE
