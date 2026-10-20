# Windows configuration

Walk the user through each channel. The agent runs detection/verification in a terminal (PowerShell); the user clicks GUI toggles. Confirm each channel before moving on. Windows 10/11.

## Detection

Run in PowerShell (read-only, changes nothing):

```powershell
Write-Host "=== Public exit IP + geo ==="
try { (Invoke-RestMethod -Uri "https://ipinfo.io" -TimeoutSec 8) } catch { "no network / request failed" }

Write-Host "`n=== DNS servers ==="
Get-DnsClientServerAddress | Where-Object {$_.ServerAddresses} | Select-Object InterfaceAlias,AddressFamily,ServerAddresses | Format-Table -Auto

Write-Host "`n=== Default route interface ==="
Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object ifIndex,NextHop,RouteMetric | Format-Table -Auto

Write-Host "`n=== VPN / proxy clients ==="
Get-ChildItem "C:\Program Files","C:\Program Files (x86)" -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -match "WARP|Cloudflare|Zscaler|GlobalProtect|Cisco|AnyConnect|OpenVPN|WireGuard|Clash" } |
  Select-Object Name

Write-Host "`n=== MDM / management ==="
dsregcmd /status | Select-String "AzureAdJoined|DomainJoined|MDMUrl"
```

Interpret:
- DNS pointing at a loopback/corporate resolver, or a corporate exit IP, or `AzureAdJoined : YES` / an `MDMUrl` → managed machine. Apply the safety gate (channels 1–3 only).
- Record the current exit IP + geo as the "before" value.

---

## Channel 1 — Location (do this first, most precise)

1. **Settings** → **Privacy & security** → **Location**
2. Turn off the **Location services** master switch, OR under "Let apps access your location" turn OFF each untrusted app (including the terminal/editor hosting a coding agent).
3. Scroll down → **Clear** location history.
4. Also check "Let desktop apps access your location" — Win32 apps (including CLI agents) are governed here; turn it off to block desktop apps broadly.

## Channel 2 — WebRTC (bypasses VPN, leaks real IP)

- **Edge / Chrome:** install **uBlock Origin** → enable **"Prevent WebRTC from leaking local IP addresses"** in its settings. (Edge: allow extensions from other stores, or use the Edge add-ons store.)
- **Firefox:** address bar `about:config` → set `media.peerconnection.enabled` to **false** (fully disables WebRTC).

## Channel 3 — Browser Geolocation permission

- **Edge:** `edge://settings/content/location` → block, or enable "Ask before accessing".
- **Chrome:** `chrome://settings/content/location` → "Don't allow sites to see your location".
- Note: the OS Location toggle (channel 1) already gates browsers too, but set this as defense in depth.

---

## Channels 4–6 — network layer (SKIP on a managed machine unless user overrides)

### Channel 4 — exit IP (Cloudflare WARP)

Same as macOS: install the "1.1.1.1 / WARP" app from Cloudflare, open it, switch the toggle to **WARP** mode (not DNS-only) to replace the exit IP. It also encrypts DNS with no/stripped ECS. It does not stop channels 1–2, and does not hide you from Cloudflare.

If a corporate VPN/proxy already masks the IP, skip WARP to avoid conflicts.

### Channel 5 — encrypted DNS (DoH, native on Windows 11)

- **Settings** → **Network & internet** → (current adapter) → **Hardware properties** → **DNS server assignment** → **Edit**
- Set **Manual**, enable IPv4, enter `1.1.1.1` (alt `1.0.0.1`), and set **DNS over HTTPS** to **On (automatic)** — this On(automatic) is what makes it encrypted.
- For IPv6 enter `2606:4700:4700::1111` or disable IPv6 (channel 6).

### Channel 6 — IPv6 leak (only when using an IPv4-only VPN/WARP)

- **Control Panel** → Network and Sharing Center → **Change adapter settings** → right-click the active adapter → **Properties** → untick **Internet Protocol Version 6 (TCP/IPv6)** → OK.
- Record that it was originally ticked so it can be restored.

---

After each channel, run the matching check in [verification.md](verification.md).
