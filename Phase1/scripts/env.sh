#!/usr/bin/env bash

#Phase1 variables

#Namespaces
NS_HQ="hq"
NS_A="branch-a"
NS_B="branch-b"
NS_ISP="isp"
NS_HQ_H="hq-host"
NS_A_H="a-host"
NS_B_H="b-host"

#Veth Links between HQ and ISP
IF_HQ_ISP="veth-hq-isp"
IF_ISP_HQ="veth-isp-hq"
IP_HQ_ISP="192.0.2.2/30"
IP_ISP_HQ="192.0.2.1/30"

#Veth Links between Branch-A ISP
IF_A_ISP="veth-a-isp"
IF_ISP_A="veth-isp-a"
IP_A_ISP="192.0.2.6/30"
IP_ISP_A="192.0.2.5/30"

#Veth links between Branch_B and ISP
IF_ISP_B="veth-isp-b"
IF_B_ISP="veth-b-isp"
IP_B_ISP="192.0.2.10/30"
IP_ISP_B="192.0.2.9/30"

#LAN (router ki IP aur host ki IP)
IP_HQ_LAN="10.1.0.1/24";  IP_HQ_HOST="10.1.0.10/24"
IP_A_LAN="10.2.0.1/24";   IP_A_HOST="10.2.0.10/24"
IP_B_LAN="10.3.0.1/24";   IP_B_HOST="10.3.0.10/24"


