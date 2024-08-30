fx_version "bodacious"
game "gta5"
lua54 "yes"

name "Quags Jailing"
description "Jailing Script."
author "Quags Garcia"
version "1.0.0"

client_scripts {
    "client.lua",
    "config.lua"
}

server_scripts {
    "server.lua"
}

escrow_ignore {
    'config.lua',
}

files {
    '*.html',
    '*.json'
}

ui_page 'index.html'