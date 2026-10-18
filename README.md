# Multi-Site Enterprise Network Lab

A three-site enterprise network (HQ + 2 branches) built entirely on Linux, inside a single Ubuntu VM, and operated the way a real network team would: as code, monitored, and with runbooks for when things break.

No Cisco/Fortinet boxes, no cloud bill. Network namespaces, veth pairs and bridges stand in for routers, cables and switches.

## Aim

Show that I can design, build, break, monitor and automate a multi-site network, not just configure it once.

The lab answers the questions a company like "Acme Corp" would ask:

- Can branch employees get internet, DNS and HQ apps with zero manual setup?
- Is traffic segmented (staff, guest, servers) and filtered by a firewall?
- Are branch-to-HQ links encrypted?
- If one ISP fails, does traffic fail over automatically?
- When something breaks at 3 AM, can an on-call engineer fix it from a runbook?
- Can the whole environment be rebuilt from scratch with one command?

## Topology (high level)

```
        hq-h ── [hq-r] ──┐
                         │
      bra-h ── [bra-r] ──┼── [isp]
                         │
      brb-h ── [brb-r] ──┘
```

| Site | LAN block | WAN link to ISP |
|------|-----------|-----------------|
| HQ | 10.1.0.0/16 | 192.0.2.0/30 |
| Branch-A | 10.2.0.0/16 | 192.0.2.4/30 |
| Branch-B | 10.3.0.0/16 | 192.0.2.8/30 |

## Stack

| Area | Tool |
|------|------|
| Virtual network | Linux network namespaces, veth, bridges |
| Dynamic routing (ISP failover only) | FRRouting (BGP) |
| Firewall / NAT | nftables |
| Site-to-site VPN | WireGuard |
| DHCP / DNS | dnsmasq |
| Segmentation | VLANs |
| Automation | Ansible |
| Monitoring | Prometheus + Grafana |

## Phases

| # | Phase | Status |
|---|-------|--------|
| 1 | Base setup (namespaces, veth, bridges, forwarding) | In progress |
| 2 | Routing + NAT + DHCP/DNS | Planned |
| 3 | VLANs | Planned |
| 4 | nftables firewall | Planned |
| 5 | WireGuard site-to-site | Planned |
| 6 | BGP ISP failover | Planned |
| 7 | Failure injection + runbooks | Planned |
| 8 | Monitoring | Planned |
| 9 | Ansible automation | Planned |

Each phase folder contains: overview, concepts to read, manual commands with explanations, break/debug exercises, "done" criteria, script/Ansible version, and runbook notes.

## Repo layout

```
.
├── README.md
├── phase-1-base-setup/
├── phase-2-routing-nat-dhcp-dns/
├── ...
└── docs/runbooks/
```

## Requirements

- Ubuntu 22.04+ VM (root/sudo access)
- `iproute2`, `tcpdump`, `nftables` (more per phase)

## Who this is for

Recruiters and clients who want to see hands-on networking and SRE skills: build, failure handling, observability and automation, all in one reproducible repo.

## Author

Rachit Srivastava, DevOps Engineer
