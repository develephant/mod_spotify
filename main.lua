---Spotify API for Corona SDK
-- @author C. Byerley
-- @copyright 2015 develephant
-- @license MIT
-- @twitter @develephant

--== Add the Spotify modules ==--
local spotifyAuth = require('spotify.spotify_auth')
local spotifyApi = require('spotify.spotify_api')

--== Start up app, after auth ==--

function startApp( spotify )
  local req =
  {
    path = 'browse/new-releases',
    params = { limit = 1, country = 'US' },
    onResult = function( res )
      print( res.albums.items[1].uri )
    end
  }
  spotify:request( req )
end

--== Start the OAuth flow ==--

local function callback( res_tbl )
  if res_tbl.error then
    print( res_tbl.error )
  elseif res_tbl.token then
    local spotify = spotifyApi:init( res_tbl.token )

    startApp( spotify )
  end
end

local auth =
{
  --client_id = 'YOUR_SPOTIFY_CLIENT_ID',
  client_id = 'b51817d3b5db4fb2940e17f571835424',
  callback = callback,
  scope = 'user-library-read playlist-modify-private',
  show_dialog = false
}

spotifyAuth:prompt( auth )
