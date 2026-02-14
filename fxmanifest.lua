fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'uProject'
description 'Character customization for u* ecosystem'
version '2.0.0'

dependencies { 'uGen', 'es_extended' }

shared_script 'config.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

client_scripts {
    'client.lua',
    'client_camera.lua',
    'client_nui.lua',
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'peds.json',
    'tattoos.json',
}

ui_page 'html/index.html'
