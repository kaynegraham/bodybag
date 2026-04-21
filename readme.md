# kg_bodybag

A standalone FiveM bodybag script — place and remove body bags over dead players and NPCs, with automatic cleanup and hospital revival.

---

## Version

**v2.0.0** — Full rewrite. Improved entity handling, NPC support, server-authoritative bag tracking, and clean resource/player-drop cleanup.

---

## Features

- Place a body bag over a dead player or NPC within range
- Dead player is faded out and respawned at the configured hospital coords
- Non-networked local props broadcast server-side to avoid OnesSync duplicates
- Bags are tracked server-side and cleaned up on player disconnect or resource stop
- Job restriction support via `Config.AuthorisedJobs` (empty = anyone can use)
- Optional item requirement via `Config.RequireItem`

---

## Framework

Currently **standalone** — no framework dependency. The `IsAuthorised` function on the server has a placeholder comment ready for job checks. To integrate with a framework (Qbox, QBCore, ESX, etc.), swap in your job lookup there and populate `Config.AuthorisedJobs`.

---

## Configuration

`shared/config.lua`

| Key | Default | Description |
|---|---|---|
| `AnimTime` | `3000` | Bagging animation duration (ms) |
| `MaxDistance` | `2.5` | Max interaction range (units) |
| `HospitalCoords` | Sandy hospital | Where bagged players respawn |
| `RequireItem` | `false` | Require item to use |
| `ItemName` | `'bodybag'` | Item name if required |
| `AuthorisedJobs` | `{}` | Allowed jobs — empty allows all |
| `BagModel` | `'xm_prop_body_bag'` | Prop model for the bag |
| `Notifications` | see config | All notification strings |

---

## Commands

| Command | Description |
|---|---|
| `/bodybag` | Place a bag on the nearest dead player or NPC |
| `/removebag` | Remove the nearest placed bag |

---

## Roadmap / Future

- Framework job integration (Qbox / QBCore / ESX)
- Item consumption on bag placement
- Ability to physically move/drag a bagged body to a vehicle or location before transport
- Coroner job workflow — bag handling, transport, and processing

---

## Installation

1. Drop the `bodybag` folder into your resources directory
2. Add `ensure bodybag` to your `server.cfg`
3. Configure `shared/config.lua` to suit your server
