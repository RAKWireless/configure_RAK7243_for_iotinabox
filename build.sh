#!/bin/bash

set -e

if [ $UID != 0 ]; then
    echo "ERROR: Operation not permitted. Forgot sudo?"
    exit 1
fi
########
LORA_PKT_PATH=/opt/ttn-gateway/packet_forwarder/lora_pkt_fwd

function echo_yellow()
{
    echo -e "\033[1;33m$1\033[0m"
}

function echo_gateway_frequency()
{
    echo_yellow "Please select gateway frequency:"
    echo_yellow "*\t1.AS923"
    echo_yellow "*\t2.AU_915_928"
    echo_yellow "*\t3.CN_470_510"
    echo_yellow "*\t4.EU_863_870"
    echo_yellow "*\t5.IN_865_867"
    echo_yellow "*\t6.KR_920_923"
    echo_yellow "*\t7.RU_864_870"
    echo_yellow "*\t8.US_902_928"
    echo_yellow  "Please enter 1-8 to select gateway frequency:\c"
}

function echo_gateway_address()
{
    echo_yellow "Please select one server address:"
    echo_yellow "*\t1.Australia"
    echo_yellow "*\t2.China"
    echo_yellow "*\t3.Europe"
    echo_yellow "*\t4.Japan"
    echo_yellow "*\t5.Korea"
    echo_yellow "*\t6.United States"
	echo_yellow  "Please enter 1-6 to select server address:\c"
}

function echo_gateway_eui()
{
	echo_yellow  "Please enter iot-in-a-box gateway EUI:\c"
}

function do_set_requency()
{
	FREQUNENCY="eu_863_870"
	case "$1" in
		1) FREQUNENCY="as_923";;
		2) FREQUNENCY="au_915_928";;
		3) FREQUNENCY="cn_470_510";;
		4) FREQUNENCY="eu_863_870";;
		5) FREQUNENCY="in_865_867";;
		6) FREQUNENCY="kr_920_923";;
		7) FREQUNENCY="ru_864_870";;
		8) FREQUNENCY="us_902_928";;
    esac
	cp $LORA_PKT_PATH/global_conf/global_conf.$FREQUNENCY.json $LORA_PKT_PATH/global_conf.json
}

function do_set_server_address()
{
	server_address="eu-1.lns.mydevices.com";
	case "$1" in
		1) server_address="au-1.lns.mydevices.com";;
		2) server_address="cn-1.lns.mydevices.com";;
		3) server_address="eu-1.lns.mydevices.com";;
		4) server_address="jp-1.lns.mydevices.com";;
		5) server_address="kr-1.lns.mydevices.com";;
		6) server_address="us-1.lns.mydevices.com";;
    esac
	sed -i "s/\"server_address\":.*/\"server_address\": \"$server_address\",/g" $LORA_PKT_PATH/global_conf.json
}

function do_set_gateway_eui()
{
	if [ ! -f $LORA_PKT_PATH/bak_local_conf.json ]; then
		cp $LORA_PKT_PATH/local_conf.json $LORA_PKT_PATH/bak_local_conf.json
	fi
	sed -i "s/\"gateway_ID\":.*/\"gateway_ID\": \"$1\"/g" $LORA_PKT_PATH/local_conf.json
}
#########

echo_gateway_frequency
while [ 1 -eq 1 ]
do
	read RAK_FREQUENCE
	RET=`echo $RAK_FREQUENCE | sed -n '/^[1-8]$/p'`
	if [ -z "$RET" ]; then
		echo_yellow "Please enter 1-8 to select the model:\c"
		continue
	fi
	do_set_requency $RET
	break
done

echo_gateway_address
while [ 1 -eq 1 ]
do
	read RAK_SERVER_ADDRESS
	RET=`echo $RAK_SERVER_ADDRESS | sed -n '/^[1-6]$/p'`
	if [ -z "$RET" ]; then
		echo_yellow "Please enter 1-6 to select server address:\c"
		continue
	fi
	do_set_server_address $RET
	break
done

echo_gateway_eui
while [ 1 -eq 1 ]
do
	read RAK_GATEWAY_EUI
	RET=`echo $RAK_GATEWAY_EUI | sed -n '/^[0-9a-fA-F]*$/p'`
	if [ -z "$RET" ] || [ `echo ${#RET}` != 16 ]; then
		echo_yellow "Please enter 16 hex-characters GwEui:\c"
		continue
	fi
	do_set_gateway_eui $RET
	break
done

systemctl restart ttn-gateway

cp ./lora_online_rak.sh /usr/bin

