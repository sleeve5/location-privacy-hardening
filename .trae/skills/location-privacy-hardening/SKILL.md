---
name: location-privacy-hardening
description: Harden macOS or Windows to stop software (including AI coding agents such as Claude Code) from deriving the user physical location through IP, DNS, system location services, or WebRTC. Use when the user wants to prevent location tracking, asks about 防止定位 / IP定位 / DNS定位泄露, or wants a privacy configuration on mac or windows. Do not use for anonymity against a nation-state adversary or Tor-grade threat models.
---

# Location Privacy Hardening

Configure a macOS or Windows machine so that software running on it — including AI coding agents such as Claude Code, CLI tools, apps, and web pages — cannot derive the user's real physical location.

This skill is a guided procedure, not a one-shot script. Location leaks come from several independent channels; the agent must probe the machine first, then apply only the changes that are safe for that machine, then verify each channel.

## Threat model (what this does and does not cover)

Covers: an ordinary app, CLI, or coding agent on the user's own machine trying to learn the user's city/region via network identity or OS APIs.

Does NOT cover: Tor-grade anonymity, defeating a network operator who already owns the link, or hiding from an adversary with root/MDM control of the machine. Say this plainly if the user expects more.

## Leak channels, in priority order

Fix in this order — the top ones are more precise and more often missed than IP.

| Priority | Channel | How software locates the user | Where to fix |
|----------|---------|-------------------------------|--------------|
| 1 | OS location services | GPS / Wi-Fi scan / cell — far more precise than IP | System privacy settings |
| 2 | WebRTC | Leaks real public/LAN IP from a browser, bypassing any VPN | Browser setting / extension |
| 3 | Browser Geolocation API | Web page asks OS for exact coordinates | Per-site browser permission |
| 4 | Public IP to geo database | Network request reveals exit IP, looked up in a geo DB | VPN / WARP / existing proxy |
| 5 | DNS leak + EDNS Client Subnet | Resolver or ECS reports the user network location | Encrypted DNS, resolver without ECS |
| 6 | IPv6 leak | VPN tunnels only IPv4; IPv6 goes direct | Disable IPv6 or confirm tunnel |

An agent that only changes IP/DNS has missed the two most precise channels (1 and 2). Always handle them.

## Mandatory safety gate — before touching the network layer

Network-layer changes (replacing DNS, installing WARP, disabling IPv6) can break a corporate-managed or proxied machine: internal name resolution, existing VPN/proxy, or office connectivity.

Run the detection first (see below). Treat the machine as managed / do-not-touch-network if ANY of these hold:

- DNS resolver is a loopback proxy (for example `nameserver 127.0.0.1`).
- The public exit IP already belongs to a corporate ASN / cloud egress rather than a home ISP.
- An MDM profile or corporate VPN/proxy client is present.

On a managed machine: apply only the **zero-risk GUI steps** (channels 1–3). Do NOT change DNS, install WARP, or disable IPv6 unless the user explicitly overrides after being warned. Note that if the exit IP is already a corporate egress, the IP channel is effectively already masked, so the benefit is low and the risk is high.

## Workflow

1. **Detect.** Run the detection for the OS and read the result:
   - macOS: run `scripts/detect_macos.sh` (see [references/macos.md](references/macos.md)).
   - Windows: run the detection block in [references/windows.md](references/windows.md).
   Report the current exit IP + geo, DNS resolvers, whether a proxy/MDM is present, and installed browsers.
2. **Apply the safety gate** above. Decide: zero-risk only, or full (including network layer).
3. **Configure channels 1–3 (always).** Follow the OS reference:
   - macOS: [references/macos.md](references/macos.md)
   - Windows: [references/windows.md](references/windows.md)
   These are GUI steps the user performs; walk them through step by step, one channel at a time.
4. **Configure channels 4–6 (only if not a managed machine, or user overrode).** Same references.
5. **Verify every channel.** Follow [references/verification.md](references/verification.md). Do not claim a channel is fixed until its check passes.

## Operating rules for the agent

- Never run destructive or irreversible network changes silently. Each network-layer change must be announced, and ideally reversible (note the original value first).
- Most privacy toggles live in GUI panels the agent cannot click. Give exact click paths and have the user confirm each step; use the terminal for detection and verification, not for flipping protected settings.
- Re-run the relevant verification after each change, not only at the end.
- If a check still leaks, name which channel and give the specific next action — do not just say "try again".

## Version

Current version: **1.0.0**

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-10-20 | Initial release: macOS + Windows guided hardening across 6 leak channels, managed-machine safety gate, detection script, verification checklist. |
