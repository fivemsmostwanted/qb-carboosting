fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_script {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/function.lua',
    'client/client.lua'
}

server_scripts {
    'server/*.lua'
}
