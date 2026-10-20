#!/usr/bin/env bash
# Location-privacy detection for macOS. Read-only. Does not change any setting.
set -u

echo "=== Default route interface ==="
route get default 2>/dev/null | grep -E "interface|gateway"

echo
echo "=== Public exit IP + geo ==="
curl -s --max-time 8 https://ipinfo.io 2>/dev/null || echo "(no network / curl failed)"

echo
echo "=== DNS resolvers (scutil) ==="
scutil --dns 2>/dev/null | grep -E "nameserver\[" | sort -u

echo
echo "=== Loopback DNS proxy? (managed-machine signal) ==="
if scutil --dns 2>/dev/null | grep -qE "nameserver\[0\] : 127\."; then
  echo "YES - DNS goes through a local proxy (127.x). Treat as managed: do NOT change DNS/WARP/IPv6 without override."
else
  echo "no local DNS proxy detected"
fi

echo
echo "=== MDM / corporate management ==="
profiles status -type enrollment 2>/dev/null || echo "(profiles query needs privileges; check System Settings > Device Management)"

echo
echo "=== VPN / proxy clients present ==="
ls /Applications 2>/dev/null | grep -i -E "warp|1.1.1.1|cloudflare|zscaler|globalprotect|cisco|anyconnect|openvpn|wireguard|clash|surge" || echo "(none of the common ones found in /Applications)"

echo
echo "=== Installed browsers ==="
ls /Applications 2>/dev/null | grep -i -E "safari|chrome|edge|firefox|arc|brave" || echo "(system Safari only)"

echo
echo "=== IPv6 active? ==="
ifconfig 2>/dev/null | grep -c "inet6 " | xargs -I{} echo "inet6 addresses present: {}"

echo
echo "NOTE: Location Services master toggle cannot be read reliably from CLI."
echo "Check it in: System Settings > Privacy & Security > Location Services."
