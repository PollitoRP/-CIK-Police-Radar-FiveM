fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'CIK Scripts'
description 'CIK Police Radar - Radar Policial Delantero y Trasero con Detección de Matrícula, Modelo, Velocidad y Control Remoto'
version '1.0.0'

shared_scripts {
    'locales/es.lua',
    'locales/en.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

