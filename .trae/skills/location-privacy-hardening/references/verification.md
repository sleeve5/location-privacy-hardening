# Verification

Verify each channel independently. A channel is "fixed" only when its check passes. Re-run after each change.

## Quick terminal checks

**Exit IP + geo (channels 4/6)** — macOS/Linux:
```bash
curl -s https://ipinfo.io | grep -E '"ip"|"city"|"country"|"org"'
```
Windows PowerShell:
```powershell
Invoke-RestMethod https://ipinfo.io | Select ip,city,country,org
```
Pass: the IP/geo/org is the VPN/WARP/corporate egress, not the user's home ISP and home city. Compare against the "before" value recorded during detection.

**DNS resolver (channel 5)** — macOS:
```bash
scutil --dns | grep 'nameserver\[' | sort -u
```
Windows:
```powershell
Get-DnsClientServerAddress | ? {$_.ServerAddresses} | Select InterfaceAlias,ServerAddresses
```
Pass: resolver is the intended encrypted one (e.g. Cloudflare/WARP), not the local ISP. On a managed machine a loopback proxy here is expected and acceptable.

## Browser-based checks

Have the user open these and read the result together:

| Channel | URL | Pass condition |
|---------|-----|----------------|
| IP geo (4) | https://ipleak.net | Shown IP/location is the VPN/egress, not home |
| DNS leak + ECS (5) | https://dnsleaktest.com (Extended test) | Resolvers are the intended provider; no home-ISP server |
| WebRTC (2) | https://browserleaks.com/webrtc | No real public or LAN IP exposed |
| Geolocation API (3) | https://browserleaks.com/geo | Browser blocks the request or returns nothing |
| OS location (1) | any "where am I" map site that asks for precise location | Permission prompt is denied / coordinates not precise |

## If a check still leaks

- **IP still shows home city** → VPN/WARP not actually routing (check it is in WARP mode, not DNS-only), or split-tunnel excludes the test app.
- **DNS shows home ISP** → DNS not forced through tunnel; set resolver explicitly or enable DoH.
- **WebRTC shows real IP** → extension not enabled for that browser, or Safari Develop toggle not set; re-check channel 2.
- **Map site pinpoints you** → OS Location Services still on for that app/browser; re-check channel 1 — this is the most common miss.
- **IPv6 address appears on ipleak** → disable IPv6 (channel 6) or use a VPN that tunnels IPv6.

Name the failing channel explicitly and give the specific fix; never just say "try again".
