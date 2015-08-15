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
    params = { limit = 1, country = 'TW' },
    onResult = function( res )
      local imgurl = res.albums.items[1].images[1].url
      local function _listener( event )
        event.target.x = display.contentCenterX
        event.target.y = display.contentCenterY
      end
      display.loadRemoteImage( imgurl, 'GET', _listener, 'img')
      print( res.albums.items[1].images[2].url )
    end
  }
  spotify:request( req )
end

--== Start the OAuth flow ==--

local function callback( res_tbl )
  if res_tbl.error then
    print( res_tbl.error )
  elseif res_tbl.token then
    spotify = spotifyApi:init( res_tbl.token, true )
    startApp()
  end
end

local auth =
{
  client_id = 'b51817d3b5db4fb2940e17f571835424', --See README
  callback = callback,
  scope = 'user-library-read'
}

spotifyAuth:prompt( auth )
