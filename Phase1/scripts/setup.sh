#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"

# 1. Namespaces 
for ns in "$NS_HQ" "$NS_A" "$NS_B"; do
  ip netns list | grep -qw "$ns" || ip netns add "$ns"
  ip netns exec "$ns" ip link set lo up
done

# 2. Link hq <-> branch-a
ip netns exec "$NS_HQ" ip link show "$IF_HQ_A" &>/dev/null || {
  ip link add "$IF_HQ_A" type veth peer name "$IF_A_HQ"
  ip link set "$IF_HQ_A" netns "$NS_HQ"
  ip link set "$IF_A_HQ" netns "$NS_A"
  ip netns exec "$NS_HQ" ip addr add "$IP_HQ_A" dev "$IF_HQ_A"
  ip netns exec "$NS_A"  ip addr add "$IP_A_HQ" dev "$IF_A_HQ"
  ip netns exec "$NS_HQ" ip link set "$IF_HQ_A" up
  ip netns exec "$NS_A"  ip link set "$IF_A_HQ" up
}

# 3. Link a<->b
ip netns exec "$NS_A" ip link show "$IF_A_B" &>/dev/null || {
  ip link add "$IF_A_B" type veth peer name "$IF_B_A"
  ip link set "$IF_A_B" netns "$NS_A"
  ip link set "$IF_B_A" netns "$NS_B"
  ip netns exec "$NS_A" ip addr add "$IP_A_B" dev "$IF_A_B"
  ip netns exec "$NS_B"  ip addr add "$IP_B_A" dev "$IF_B_A"
  ip netns exec "$NS_A" ip link set "$IF_A_B" up
  ip netns exec "$NS_B"  ip link set "$IF_B_A" up
}

# 4. Link b<->HQ
ip netns exec "$NS_HQ" ip link show "$IF_HQ_B" &>/dev/null || {
  ip link add "$IF_HQ_B" type veth peer name "$IF_B_HQ"
  ip link set "$IF_HQ_B" netns "$NS_HQ"
  ip link set "$IF_B_HQ" netns "$NS_B"
  ip netns exec "$NS_HQ" ip addr add "$IP_HQ_B" dev "$IF_HQ_B"
  ip netns exec "$NS_B"  ip addr add "$IP_B_HQ" dev "$IF_B_HQ"
  ip netns exec "$NS_HQ" ip link set "$IF_HQ_B" up
  ip netns exec "$NS_B"  ip link set "$IF_B_HQ" up
}

 
