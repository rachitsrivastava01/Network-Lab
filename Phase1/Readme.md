# Phase 1: Base Setup

## Goal

Build the physical-layer skeleton of the lab: three site routers, one ISP, and one LAN host per site, all as network namespaces connected by veth pairs and bridges. At the end of this phase every host can reach its own site router, and every router can reach the ISP. No NAT, routing protocols or firewall yet.

## Why this matters

Every later phase (NAT, VLANs, nftables, WireGuard, BGP) builds on this wiring. A mistake here shows up as confusing failures later, so this phase is about getting links, addresses and forwarding right and being able to explain each one.

## Topology

```
 hq-h ──(br-lan)── [hq-r] ──── veth ──── [isp]
 bra-h ─(br-lan)── [bra-r] ─── veth ──── [isp]
 brb-h ─(br-lan)── [brb-r] ─── veth ──── [isp]
```

## Addressing

| Site | Router LAN (br-lan) | Host | Router WAN | ISP side |
|------|---------------------|------|------------|----------|
| HQ | 10.1.0.1/24 | 10.1.0.10/24 | 192.0.2.2/30 | 192.0.2.1/30 |
| Branch-A | 10.2.0.1/24 | 10.2.0.10/24 | 192.0.2.6/30 | 192.0.2.5/30 |
| Branch-B | 10.3.0.1/24 | 10.3.0.10/24 | 192.0.2.10/30 | 192.0.2.9/30 |

The site /16 blocks (10.1/16, 10.2/16, 10.3/16) are reserved. Only a /24 is used per site now; VLAN subnets are carved out in Phase 3.

## Namespaces

`hq-r`, `bra-r`, `brb-r` (site routers), `isp`, `hq-h`, `bra-h`, `brb-h` (LAN hosts).

## Concepts covered

- Network namespaces: isolated network stack (interfaces, routes, sysctls)
- veth pairs: virtual cable, each end in a different namespace
- Linux bridge: virtual L2 switch inside the router namespace
- `net.ipv4.ip_forward`: per-namespace switch that turns a host into a router
- Default routes and why a router with no return path drops replies

## Reading list

`man ip-netns`, `man network_namespaces`, `man veth`, `man ip-link`, `man ip-address`, `man ip-route`, `man sysctl`

## Steps (summary)

1. Create the 7 namespaces and bring `lo` up in each.
2. Create a WAN veth per site (router end and ISP end), assign /30 addresses, bring up.
3. In each router, create `br-lan`, attach the host-facing veth port, assign the .1/24 address.
4. Assign the host IP and set its default route to the router.
5. Set each router's default route to the ISP.
6. Enable `ip_forward` inside each router and the ISP namespace.

Full commands with explanations: see `manual-steps.md`. Automated version: `setup.sh` / `teardown.sh`.

## Verification

```bash
sudo ip netns exec hq-h  ping -c2 10.1.0.1     # host -> own router
sudo ip netns exec hq-r  ping -c2 192.0.2.1    # router -> ISP
sudo ip netns exec hq-h  ping -c2 192.0.2.1    # expected to FAIL (see below)
```

Repeat for Branch-A and Branch-B.

## Done criteria

- [ ] `ip netns list` shows all 7 namespaces
- [ ] Each host pings its own router
- [ ] Each router pings the ISP-side address of its /30
- [ ] `ip_forward` is 1 in each router and in `isp`
- [ ] Host to ISP ping fails, and I can explain why
- [ ] `teardown.sh` followed by `setup.sh` rebuilds everything cleanly

## Expected failure (by design)

A host pinging the ISP fails because the ISP has no route back to the private 10.x.0.0/24 networks. The request arrives, but the reply has nowhere to go. This is the reason NAT is introduced in Phase 2.

## Troubleshooting

| Symptom | Check |
|---------|-------|
| `Network is unreachable` | Missing default route in that namespace: `ip -n <ns> route` |
| Ping hangs, no reply | Interface down: `ip -n <ns> link`; or `ip_forward` is 0 |
| Host can't reach router | veth port not enslaved to `br-lan` (`bridge link` inside the router) |
| `Cannot find device` | veth end not moved to the namespace yet |
| Works for one site, not another | Overlapping or mistyped /30 or /24 |

Useful tools: `ip -n <ns> addr`, `ip -n <ns> route`, `bridge -n <ns> link`, `tcpdump -i <iface> -n` inside a namespace.

## Runbook notes

- **Rebuild:** run `teardown.sh`, then `setup.sh`.
- **State is not persistent:** namespaces and veths disappear on VM reboot; rerun `setup.sh`.
- **Cleanup:** `ip netns del <name>` removes a namespace and the veth ends inside it.

## What I learned

_To be filled in after running the lab (key mistakes, what the failing ping taught me)._

## Next

Phase 2: routing, NAT and DHCP/DNS.
