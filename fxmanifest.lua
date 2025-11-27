-- TwoPoint Development — Unified AI Control
-- Handles AI density/dispatch, driving curves, and emergency cleanup.

fx_version 'cerulean'
lua54 'yes'
game 'gta5'

name 'TwoPoint_AI_Control'
description 'Unified AI density/dispatch + handling + emergency cleanup for TwoPoint Development.'
author 'TwoPoint Development'
version '1.0.0'

client_scripts {
    'config.lua',           -- AI config
       -- AI density / relationships / dispatch
    'client.lua' -- Unified client
}

files {
    'events.meta',          -- AI event reactions (siren, etc.)
    'handling.meta'         -- AI driving curves
}

data_file 'EVENTS_OVERRIDE_FILE' 'events.meta'
data_file 'HANDLING_FILE'        'handling.meta'
