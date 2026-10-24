#!/usr/bin/env bash

#Phase1 variables

#Namespaces
NS_HQ="hq"
NS_A="branch-a"
NS_B="branch-b"

#Veth Links between HQ and Branch A
IF_HQ_A="veth-hq-a"
IF_A_HQ="veth-a-hq"
IP_HQ_A="172.16.12.1/30"
IP_A_HQ="172.16.12.2/30"

#Veth Links between Branch-A and Branch-B
IF_A_B="veth-a-b"
IF_B_A="veth-b-a"
IP_A_B="172.16.23.1/30"
IP_B_A="172.16.23.2/30"

#Veth links between HQ and Branch_B
IF_HQ_B="veth-hq-b"
IF_B_HQ="veth-b-hq"
IP_B_HQ="172.16.31.1/30"
IP_HQ_B="172.16.31.2/30"


