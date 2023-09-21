#!/bin/bash

#set -x

vpn_state() {
    aws ec2 describe-vpn-connections --region us-east-1 --filters --vpn-connection-ids $1 --query 'VpnConnections[].State[]' --output json | jq .[]
}
# Function Usage: vpn_state $1

tunnel_status() {
    aws ec2 describe-vpn-connections --region us-east-1 --filters --vpn-connection-ids $1 --query 'VpnConnections[].VgwTelemetry[?OutsideIpAddress==`'"$2"'`]|[].Status' --output json | jq .[]
}
# Function Usage: tunnel_status $1 $2


replace_tunnel() {
    aws ec2 replace-vpn-tunnel --region us-east-1 --vpn-connection-id $1 --vpn-tunnel-outside-ip-address $2
}
## Function Usage: replace_tunnel $1 $2


echo "$1 `vpn_state $1`"
echo "$1 tunnel 1 `tunnel_status $1 $2`"

while true
do
    if [[ `vpn_state $1` = '"available"' ]];
    then echo "VPN $1 is Available, checking Tunnels...";

        if [[ `tunnel_status $1 $2` = '"DOWN"' ]]
        then
            echo "Replacing $1 tunnel"
            replace_tunnel $1 $2 &
            sleep 600
        elif [[ `tunnel_status $1 $2` = '"UP"' ]]
        then
            echo "Tunnel $1 is up"
            sleep 300
        else
            echo "Bad input, exiting..."
            break
        fi
    elif [[ `vpn_state $1` = '"modifying"' ]]
    then
        echo "State for $1 is Modifying, backoff"
        sleep 600
    else
        echo "Bad input, exiting..."
    fi
done
