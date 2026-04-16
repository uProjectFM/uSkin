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
    '@uBridge/client_hook.lua',
    'client.lua',
    'client_camera.lua',
    'client_nui.lua',
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/fonts.css',
    'html/fonts/Teko.woff2',
    'html/fonts/Archivo.woff2',
    'html/fonts/Archivo-Italic.woff2',
    'html/fonts/Oxanium.woff2',
    'peds.json',
    'tattoos.json',
}

ui_page 'html/index.html'
