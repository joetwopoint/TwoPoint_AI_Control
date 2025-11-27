# TwoPoint Development — AI Control

FOR USE WITH BIG DADDY SIREN RESPONSE https://bigdaddyscripts.com/Products/View/2924/Siren-Response

MUST REMOVE CALM-AI, REALISTIC AI TRAFFIC, AND REMOVE AI COPS, IF YOU USE THEM

Unified AI control system for TwoPoint servers.

This resource centralizes AI behaviour into a single script that:

- Calms and standardizes NPC relationships and density
- Disables wanted levels and dispatch services
- Removes ambient emergency vehicles and emergency peds
- Improves AI driving behaviour with tuned handling curves
- Disables NPC reaction to emergency sirens
- Helps NPC traffic **brake** instead of rear-ending blocked emergency vehicles

No commands, no UI — completely automatic once started.

---

## Features

### 🌆 World & AI Behaviour

- Configurable **ped and vehicle density** (via `config.lua`)
- Adjusted NPC **relationship groups** to reduce random chaos
- Dispatch services disabled:
  - No random AI police response
  - Wanted level is forced to 0 and continually cleared
- Keeps the world feeling alive but not hyper-aggressive

### 🚓 Emergency Cleanup

- Suppresses and cleans up:
  - Emergency vehicles (police, ambulance, fire, military, etc.)
  - Emergency / military / medic peds
- Periodically scans the world and deletes matching entities
- Keeps scenes clean so player-based services remain the focus

### 🧠 AI Driving Curves

- Includes a custom `handling.meta` with tuned **AI handling curves** for:
  - `SPORTS_CAR`
  - `AVERAGE`
  - `CRAP`
  - `TRUCK`
- Results:
  - More confident speeds on straights and gentle curves
  - Less “crawling” through simple turns
  - Still conservative on sharper angles to avoid chaos

### 🔊 Siren Reaction Disabled

- AI **no longer reacts** to shocking siren events:
  - No global panic behaviour tied to sirens
  - Siren event chances are forced to `0.0` in `events.meta`
- This helps keep AI from doing unpredictable moves just because an emergency vehicle is nearby.

### 🚧 Blocked Emergency Vehicle Logic

- Additional safety logic for blocked emergency units:
  - Scans for **stopped emergency vehicles** (vehicle class 18)
  - For NPC-driven vehicles heading toward them:
    - Checks distance, direction, and speed
    - If they’re directly behind and close, it sends a **temporary brake task**
  - Helps NPC traffic avoid smashing into an emergency unit blocking the lane

---

## Files

This resource is meant to live as a single folder:

```text
twopoint_ai_control/
  fxmanifest.lua
  config.lua
  client.lua
  events.meta
  handling.meta
fxmanifest.lua
Defines the resource as a unified AI control system and loads the data files.

config.lua
All configurable values for density, toggles, and general AI tuning live here.

client.lua
Unified client script that:

Sets relationships and density

Disables dispatch and wanted level

Handles emergency vehicle & ped cleanup

Runs the “blocked emergency vehicle” brake logic

events.meta
Overrides AI event responses, including siren reaction (set to effectively ignored).

handling.meta
AI driving behaviour curves for traffic vehicles.

Installation
Drop the twopoint_ai_control folder into your server’s resources/ directory.

In your server.cfg, ensure this resource:

cfg
Copy code
ensure twopoint_ai_control
Remove or disable any other AI control / cop removal / AI handling resources that:

Change global AI densities

Remove cops / emergency vehicles

Override events.meta or AI handling

This resource is designed to be the single authority for those systems.

Restart your server.

Configuration
All configuration is done in:

text
Copy code
twopoint_ai_control/config.lua
Typical things you’ll find there (names may vary slightly depending on version):

Ped density multipliers

Vehicle density multipliers

Scenario density multipliers

Toggles for specific AI behaviours / systems

Important: Only edit config.lua.
The .meta files and client.lua are not meant to be changed unless you know exactly what you’re doing.

Behaviour Summary In-Game
Once running, this resource will:

Keep AI densities at the levels you set in config.lua

Make NPCs less chaotic and less hostile by default

Stop random cop spawns and disable wanted levels

Clean up emergency vehicles and peds so the focus stays on player agencies

Make traffic drive a bit more like actual drivers instead of slow bots

Prevent most rear-end collisions into a stopped emergency vehicle blocking a lane

Ignore sirens as a “shocking event” so NPCs don’t freak out around you
