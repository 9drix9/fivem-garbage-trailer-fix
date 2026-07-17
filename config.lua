Config = {}

-- ─────────────────────────────────────────────────────────────────────────────
--  prop_hide config
--  Everything you edit lives here. See README.md for the full walkthrough.
-- ─────────────────────────────────────────────────────────────────────────────

-- Enable the /prophideinfo admin diagnostic (used to find a prop's model hash).
-- It is ACE-restricted, so normal players can't run it even when this is true.
-- Grant access with, in server.cfg:   add_ace group.admin command.prophideinfo allow
Config.EnableCommands = true

-- How close (metres) the player must be to a blocker before it is (re)hidden.
-- Keeps the loop cheap: it does nothing while nobody is near a configured prop.
Config.ActivationRange = 150.0

-- ─────────────────────────────────────────────────────────────────────────────
--  1) STATIC MAP PROPS to hide (the main use case).
--     Matched by MODEL HASH within RADIUS of POS, so a stock prop that GTA reuses
--     elsewhere on the map is only removed at the one spot you list here.
--
--     To add your own: stand next to the offending prop in-game, run /prophideinfo,
--     and read the F8 console. Copy the hash + pos of the closest matching object.
-- ─────────────────────────────────────────────────────────────────────────────
Config.Props = {
    -- The Cfx.re FM map-data packs ("cfx-fm-map-data-01/02-sub", the free FiveM base
    -- map) park a stock trailer prop on the La Puerta garbage depot, blocking the
    -- garbage-job unload point (17mov_GarbageCollector and the vanilla trash job both
    -- use this spot). Confirmed model hash + world position:
    {
        hash   = 1152297372,
        pos    = vec3(-346.68, -1525.71, 26.71),
        radius = 4.0,
        label  = 'La Puerta garbage depot trailer (Cfx.re FM map)',
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
--  2) OPTIONAL: delete ambient VEHICLE-type trailers inside a zone. This is the
--     *other* variant of the problem - a drivable/tow trailer that the traffic
--     system parks on the spot, rather than a baked map prop. Leave the list empty
--     to disable this entirely (zero cost when empty).
--
--     Each zone is an axis-aligned box (min/max corners). Any driverless, unhitched
--     vehicle whose model is in VehicleTrailerModels is removed inside it.
-- ─────────────────────────────────────────────────────────────────────────────
Config.VehicleZones = {
    -- Example (disabled): the garbage depot box.
    -- {
    --     min = vec3(-362.0, -1554.0, 15.0),
    --     max = vec3(-306.0, -1514.0, 45.0),
    --     suppressTraffic = true,   -- also stop ambient traffic + vehicle generators in the box
    -- },
}

-- Vehicle models treated as "a trailer" for the VehicleZones cleanup above.
Config.VehicleTrailerModels = {
    'trailers', 'trailers2', 'trailers3', 'trailerlarge', 'trailersmall2', 'docktrailer',
    'tr2', 'tr3', 'tr4', 'trailerlogs', 'freighttrailer', 'boattrailer', 'graintrailer',
    'baletrailer', 'armytrailer', 'armytrailer2', 'tanker', 'tanker2', 'tvtrailer',
}
