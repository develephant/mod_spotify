---Spotify API for Corona SDK
-- @author C. Byerley
-- @copyright 2015 develephant
-- @license MIT
-- @twitter @develephant
local composer = require( "composer" )

local spotifyAuth = require('spotify.spotify_auth')
local spotifyApi = require('spotify.spotify_api')

spotify = '' --keep a global spotify instance

--== Auth callback
local access_token

local function onAuthed( result_tbl )
  if result_tbl.error then
    print('opps. error', result_tbl.error )
  elseif result_tbl.token then
    access_token = result_tbl.token
    spotify = spotifyApi:init( access_token )
    composer.gotoScene('scene_list')
  end
end

spotifyAuth:prompt({
  client_id = 'b51817d3b5db4fb2940e17f571835424',
  callback = onAuthed,
  scope = 'user-library-read'
})
