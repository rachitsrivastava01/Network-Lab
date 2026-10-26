#!/usr/bin/env bash
# Phase 1: namespaces, WAN links to ISP, site LANs with hosts, routes, forwarding
set -euo pipefail
source "$(dirname "$0")/env.sh"

[[ $EUID -eq 0 ]] || { echo "Run as root: sudo $0"; exit 1; }

# ---------- functions ----------

# add_ns <name>: namespace banao (agar pehle se nahi hai) aur lo up karo
add_ns() {
  local ns="$1"
  [[ -e "/run/netns/$ns" ]] || ip netns add "$ns"
  ip -n "$ns" link set lo up
}

# make_link <ns1> <if1> <ip1> <ns2> <if2> <ip2>: do namespaces ke beech veth cable
make_link() {
  local ns1="$1" if1="$2" ip1="$3" ns2="$4" if2="$5" ip2="$6"
  if ip -n "$ns1" link show "$if1" &>/dev/null; then
    echo "skip: $if1 already exists"
    return 0
  fi
  ip link add "$if1" type veth peer name "$if2"
  ip link set "$if1" netns "$ns1"
  ip link set "$if2" netns "$ns2"
  ip -n "$ns1" addr add "$ip1" dev "$if1"
  ip -n "$ns2" addr add "$ip2" dev "$if2"
  ip -n "$ns1" link set "$if1" up
  ip -n "$ns2" link set "$if2" up
}

# make_lan <router_ns> <host_ns> <router_ip/24> <host_ip/24> <gateway> <host_if> <port_if>
# router ke andar bridge (switch), host usse veth se juda, host ka default route router pe
make_lan() {
  local rns="$1" hns="$2" rip="$3" hip="$4" gw="$5" hif="$6" pif="$7"
  if ip -n "$rns" link show br-lan &>/dev/null; then
    echo "skip: br-lan already exists in $rns"
    return 0
  fi
  ip -n "$rns" link add br-lan type bridge
  ip link add "$hif" type veth peer name "$pif"
  ip link set "$hif" netns "$hns"
  ip link set "$pif" netns "$rns"
  ip -n "$rns" link set "$pif" master br-lan
  ip -n "$rns" addr add "$rip" dev br-lan
  ip -n "$rns" link set br-lan up
  ip -n "$rns" link set "$pif" up
  ip -n "$hns" addr add "$hip" dev "$hif"
  ip -n "$hns" link set "$hif" up
  ip -n "$hns" route replace default via "$gw"
}

# ---------- 1. namespaces ----------
for ns in "$NS_HQ" "$NS_A" "$NS_B" "$NS_ISP" "$NS_HQ_H" "$NS_A_H" "$NS_B_H"; do
  add_ns "$ns"
done

# ---------- 2. WAN links (router <-> ISP) ----------
make_link "$NS_HQ" "$IF_HQ_ISP" "$IP_HQ_ISP" "$NS_ISP" "$IF_ISP_HQ" "$IP_ISP_HQ"
make_link "$NS_A"  "$IF_A_ISP"  "$IP_A_ISP"  "$NS_ISP" "$IF_ISP_A"  "$IP_ISP_A"
make_link "$NS_B"  "$IF_B_ISP"  "$IP_B_ISP"  "$NS_ISP" "$IF_ISP_B"  "$IP_ISP_B"

# ---------- 3. LANs (bridge + host) ----------
make_lan "$NS_HQ" "$NS_HQ_H" "$IP_HQ_LAN" "$IP_HQ_HOST" "${IP_HQ_LAN%/*}" veth-hq-h veth-hq-p
make_lan "$NS_A"  "$NS_A_H"  "$IP_A_LAN"  "$IP_A_HOST"  "${IP_A_LAN%/*}"  veth-a-h  veth-a-p
make_lan "$NS_B"  "$NS_B_H"  "$IP_B_LAN"  "$IP_B_HOST"  "${IP_B_LAN%/*}"  veth-b-h  veth-b-p

# ---------- 4. default routes: router -> ISP ----------
ip -n "$NS_HQ" route replace default via "${IP_ISP_HQ%/*}"
ip -n "$NS_A"  route replace default via "${IP_ISP_A%/*}"
ip -n "$NS_B"  route replace default via "${IP_ISP_B%/*}"

# ---------- 5. IP forwarding (routers + ISP) ----------
for ns in "$NS_HQ" "$NS_A" "$NS_B" "$NS_ISP"; do
  ip netns exec "$ns" sysctl -qw net.ipv4.ip_forward=1
done

echo "Phase 1 setup done."
ip netns list
