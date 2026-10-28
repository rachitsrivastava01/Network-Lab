#!/usr/bin/env bash 

set -euo pipefail
source "$(dirname "$0")/env.sh"

[[ $EUID -eq 0 ]] || { echo "Run this as a root user: sudo $0"; exit 1; }

for ns in "$NS_HQ" "$NS_A" "$NS_B" "$NS_ISP" "$NS_HQ_H" "$NS_A_H" "$NS_B_H"; do
   if [[ -e  "/run/netns/$ns" ]]; then
     ip netns del "$ns"
     echo "deleted: $ns"
   else
     echo "not found: $ns"

  fi
done
    
