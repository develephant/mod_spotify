---Spotify API for Corona SDK
-- @author C. Byerley
-- @copyright 2015 develephant
-- @license MIT
-- @twitter @develephant

--===========================================================--
--== Add your Spotify Client ID at the bottom of this file.
--===========================================================--

--== Add the Spotify modules ==--
local spotifyAuth = require('spotify.spotify_auth')
local spotifyApi = require('spotify.spotify_api')

--== api object
local spotify

--== Start up app, after auth ==--

function startApp()
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
    spotify = spotifyApi:init( res_tbl.token )
    startApp()
  end
end

local auth =
{
  client_id = 'YOUR_SPOTIFY_CLIENT_ID', --See README
  callback = callback,
  scope = 'user-library-read'
}

spotifyAuth:prompt( auth )
