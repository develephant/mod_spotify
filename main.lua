--- Spotify API for Corona SDK

local spotifyAuth = require('spotify.spotify_auth')
local spotifyApi = require('spotify.spotify_api')

--== Start up app, after auth ==--

function startApp( spotify )
  local req =
  {
    path = 'browse/new-releases',
    params = { limit = 1, country = 'US' },
    onResult = function( res )
      print( res )
    end
  }
  spotify:request( req )
end

--== Start the OAuth flow ==--

local function callback( res_tbl )
  if res_tbl.error then
    print( res_tbl.error )
  elseif res_tbl.token then
    local spotify = spotifyApi:init( res_tbl.token, true )

    startApp( spotify )
  end
end

local auth =
{
  client_id = 'ebb7daa460c54120a0b71bb28c43509f',
  callback = callback,
  scope = '',
  show_dialog = false
}

spotifyAuth:promptForAuth( auth )
