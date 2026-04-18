# kg_bodybag

A standalone FiveM body bag resource. Server-authoritative, no framework dependency. Place a body bag prop over a dead player or NPC — multiple bags supported simultaneously.

![Version](https://img.shields.io/badge/version-2.0.0-orange) ![FiveM](https://img.shields.io/badge/FiveM-standalone-blue) ![License](https://img.shields.io/badge/license-MIT-green)

---

## Features

- Place a body bag over any dead player or NPC within range
- Multiple active bags tracked simultaneously — no single-bag limitation
- Server owns all player state — coords derived server-side, not client-reported
- Broadcasts prop to all connected clients (non-networked local props to avoid Onesync double-spawn)
- Configurable: model, distance, animation time, authorised jobs, notifications
- Cleanup on player disconnect and resource stop

---

## Dependencies

None. Pure Lua, native FiveM only.

---

## Installation

1. Drop `kg_bodybag` into your resources folder
2. Add `ensure kg_bodybag` to your `server.cfg`
3. Configure `shared/config.lua` to your server's needs

---

## Configuration

All values live in `shared/config.lua`.

```lua
Config = {}

Config.AnimTime = 3000              -- Animation duration (ms)
Config.MaxDistance = 2.5            -- Max range to interact with a body or bag

Config.HospitalCoords = vector3(239.17, -1380.86, 33.74)

Config.RequireItem = false          -- Require item to place bag (not yet enforced)
Config.ItemName = 'bodybag'

Config.AuthorisedJobs = {}          -- Empty = anyone can use
                                    -- e.g. {'police', 'ambulance'}

Config.BagModel = 'xm_prop_body_bag'

Config.Notifications = {
    noBagNearby    = "No body bag nearby.",
    noDeadNearby   = "No dead player nearby.",
    notAuthorised  = "You are not authorised to do this.",
    noItem         = "You don't have a body bag.",
    bagged         = "Body bagged.",
    removed        = "Body bag removed.",
}
```

---

## Commands

| Command      | Description                                   |
| ------------ | --------------------------------------------- |
| `/bodybag`   | Place a bag on the nearest dead player or NPC |
| `/removebag` | Remove the nearest body bag                   |

---

## File Structure

```
kg_bodybag/
├── fxmanifest.lua
├── shared/
│   └── config.lua
├── client/
│   └── main.lua
└── server/
    └── main.lua
```

---

## How It Works

1. Player runs `/bodybag` near a dead entity
2. Client validates proximity and fires a server event
3. **For dead players** — server derives coords from `GetPlayerPed(deadSource)` (never trusts client-reported position)
4. **For NPCs** — client sends coords after deleting the corpse locally (trust trade-off; no server-side NPC)
5. Server generates a unique bag ID, stores in `ActiveBags`, broadcasts spawn to all clients
6. Every client spawns the prop locally using the broadcast coords
7. On `/removebag` — server validates ownership, broadcasts removal, all clients delete their local prop

---

## Known Limitations

- **Late-join sync** — players who connect after bags are placed won't see them
- **Job check** — `Config.AuthorisedJobs` config key exists but enforcement is not yet wired up
- **Item check** — `Config.RequireItem` not yet enforced

These are on the roadmap for v2.1.

---

## Author

**devkayne** (Kayne Graham)  
GitHub: [github.com/kaynegraham](https://github.com/kaynegraham)

---

## License

MIT — free to use, modify and distribute. Credit appreciated but not required.
