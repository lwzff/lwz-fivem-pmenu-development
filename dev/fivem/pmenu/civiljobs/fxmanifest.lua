
-- Resource Metadatas
fx_version 'cerulean'
games { 'gta5' }

author 'lwz, lwz#2051'
description 'Simple civil jobs made in pmenu.'
version '1.0.0'

-- Server side
server_scripts {
  'server/**.lua',
}

-- Client side
client_scripts {
  'client/*.lua',
  'client/*.lua',
  'client/*.lua',

  -- Chantier
  'client/jobs/chantier/*.lua',

  -- Jardinier
  'client/jobs/jardinier/*.lua',

   -- Mineur
  'client/jobs/mine/*.lua',

  -- Bucheron
  'client/jobs/bucheron/*.lua',

  -- Dependence
  'dependency/*.lua'
}