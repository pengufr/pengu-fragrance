fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'pengu'
description 'Custom Fragrance System for QB-Core'
version '1.0.0'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
}

client_scripts {
    'client/client.lua',
}

dependencies {
    'qb-core',
    'ox_lib',
    'qb-menu',
    'progressbar',
    -- 'ox_target',
}
