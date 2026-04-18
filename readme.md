# kg_bodybag

Standalone FiveM body bag resource. No framework required.

Authorised players place a body bag prop over a dead player or NPC. Dead players are hidden and sent to the hospital. Dead NPCs are deleted locally. Multiple bags can exist simultaneously. All state is server-authoritative.

---

## Commands

| Command      | Description                                                |
| ------------ | ---------------------------------------------------------- |
| `/bodybag`   | Place a bag on the nearest dead player or NPC within range |
| `/removebag` | Remove the nearest bag within range                        |

Both commands play a 3-second animation before firing the server event. Spamming is blocked while an action is in progress.

---

## Installation

1. Drop `kg_bodybag` into your resources folder
2. Add `ensure kg_bodybag` to your `server.cfg`
3. Configure `shared/config.lua` as needed
4. Restart the server

---

## Configuration — `shared/config.lua`

```lua
Config.AnimTime     = 3000          -- animation duration in ms
Config.MaxDistance  = 2.5           -- max range for placing/removing a bag

Config.HospitalCoords = vector3(239.17, -1380.86, 33.74)

Config.RequireItem  = false         -- require item in inventory to place bag
Config.ItemName     = 'bodybag'     -- item name (if RequireItem = true)

Config.AuthorisedJobs = {}          -- empty = anyone can use
                                    -- e.g. {'police', 'ambulance'}

Config.BagModel = 'xm_prop_body_bag'
```

### Notifications

All notification strings are configurable under `Config.Notifications`:

```lua
Config.Notifications = {
    noBagNearby     = 'No body bag nearby.',
    noDeadNearby    = 'No dead player nearby.',
    notAuthorised   = 'You are not authorised to do this.',
    noItem          = "You don't have a body bag.",
    bagged          = 'Body bagged.',
    removed         = 'Body bag removed.',
}
```

---

## Architecture

**Server owns all state.** Clients never trust each other for coordinates or validity.

- Dead player coordinates are derived server-side from `GetEntityCoords(GetPlayerPed(deadSource))` — the client never sends position data for player bags
- For NPC bags the client sends the NPC's coords (NPCs have no server-side source); the NPC is deleted locally via `DeleteEntity` before the event fires
- Every server event validates that the acting player has a valid ped (`GetPlayerPed ~= 0`)
- `IsEntityDead` is checked server-side for players; NPC death is validated client-side before the event is sent
- The `bodybag` command checks for a dead player first, then falls back to a dead NPC within range
- Bags are tracked in a server-side table keyed by a unique ID; clients track their local prop handles in a parallel table keyed by the same ID
- Bag props are spawned as non-networked local objects on every client simultaneously via broadcast — this prevents Onesync double-spawning on top of a manually broadcast spawn
- The bag model is requested in a loop (`RequestModel` inside `while not HasModelLoaded`) and validated with `IsModelValid` before spawning
- Player disconnect cleans up all bags they owned or were inside
- Resource stop broadcasts removal of all active bags before unloading

---

## Job Integration

`Config.AuthorisedJobs` and the `IsAuthorised` function in `server/server.lua` are wired up but the job lookup is a placeholder returning `true`. To add framework job checking, replace the body of `IsAuthorised` with your framework's player job lookup.

---

## Known Limitations

- Dead player's ped remains visible to other clients until the bag prop visually covers it; there is no server-side entity hide
- Players who join mid-session will not see bags placed before they connected (no late-join sync)
- NPC deletion via `DeleteEntity` only works if the bagging client owns the NPC entity; if another player owns it the corpse will remain visible under the bag prop
- Framework integration (item requirement, job restriction) not yet implemented

---

## Version

`2.0.0` — full rewrite. Standalone, multi-bag, server-authoritative.
