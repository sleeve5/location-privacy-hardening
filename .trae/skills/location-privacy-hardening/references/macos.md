# macOS configuration

Walk the user through each channel. The agent runs detection/verification in the terminal; the user clicks GUI toggles. Confirm each channel before moving on.

## Detection

Run the bundled script (read-only, changes nothing):

```bash
bash scripts/detect_macos.sh
```

Interpret:
- Loopback DNS (`127.x`) or a corporate exit IP → managed machine, apply the safety gate (channels 1–3 only).
- Record the current exit IP + geo as the "before" value to compare after.

---

## Channel 1 — Location Services (do this first, most precise)

> GPS / Wi-Fi / cell positioning. More accurate than IP; a VPN does nothing against it.

1.  menu → **System Settings**
2. **Privacy & Security** → **Location Services**
3. Either:
   - **Thorough:** turn off the top **Location Services** master switch (prompts for password), or
   - **Targeted (recommended):** keep it on, and turn OFF the switch for each app you don't trust (including terminal apps / editors that host coding agents).
4. Scroll to the bottom → **System Services** → **Details** → turn off "Location-Based Suggestions", "Significant Locations", etc. as desired.

To deny a coding agent specifically: find its host app (Terminal, iTerm, VS Code, the IDE running the agent) in the list and turn it OFF. If it is not listed, it has not requested location — leave as is.

## Channel 2 — WebRTC (bypasses VPN, leaks real IP)

**Chrome:** install **uBlock Origin** (or "WebRTC Leak Prevent") → in uBlock settings enable **"Prevent WebRTC from leaking local IP addresses"**.

**Edge:** install uBlock Origin from the Edge add-ons store → same toggle.

**Safari:** menu bar **Safari → Settings → Advanced** → enable **"Show features for web developers"** → a **Develop** menu appears → **Develop → WebRTC** → enable the option that hides local IP / uses mDNS candidates (wording varies by version).

## Channel 3 — Browser Geolocation permission

- **Safari:** Settings → Websites → left column **Location** → set listed sites and "When visiting other websites" to **Deny**.
- **Chrome:** open `chrome://settings/content/location` → choose **"Don't allow sites to see your location"**.
- **Edge:** open `edge://settings/content/location` → turn off "Ask before accessing" or set to block.

---

## Channels 4–6 — network layer (SKIP on a managed machine unless user overrides)

### Channel 4 — exit IP (Cloudflare WARP)

WARP = lightweight WireGuard VPN + encrypted DNS (1.1.1.1), free.
- It replaces the exit IP (software sees a Cloudflare IP) and encrypts DNS with no/stripped ECS.
- It does NOT hide you from Cloudflare, and does NOT stop channels 1–2.

Install the "1.1.1.1 / WARP" app from Cloudflare, open it, and switch the mode toggle to **WARP** (not the "1.1.1.1" DNS-only mode) to replace the IP.

If an existing corporate VPN/proxy already masks the IP (detection showed a corporate egress IP), WARP is usually unnecessary and may conflict — skip it.

### Channel 5 — encrypted DNS without ECS

If not using WARP and the machine is not managed:
- System Settings → Network → (current service) → Details → **DNS** → set servers to `1.1.1.1` and `1.0.0.1`.
- For true DoH (encrypted), install Cloudflare's `.mobileconfig` profile (from Cloudflare's site): System Settings → General → Device Management → install it.

Cloudflare (1.1.1.1) and Quad9 (9.9.9.9) default to not sending / stripping ECS — prefer them.

### Channel 6 — IPv6 leak (only when using a VPN/WARP that is IPv4-only)

System Settings → Network → (current service) → Details → **TCP/IP** → **Configure IPv6** → set to **Link-local only** or **Off**.
Record the original value first so it can be restored.

---

After each channel, run the matching check in [verification.md](verification.md).
