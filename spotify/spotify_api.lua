--- Spotify API Request
local http = require('socket.http')
local ltn12 = require('ltn12')
local json = require('json')

local api = {}

function api:init( access_token )
  
  local o =
  {
    Get     = 'GET',
    Post    = 'POST',
    Delete  = 'DELETE',
    Put     = 'PUT',

    spotify_api_url = "https://api.spotify.com/v1/",
    spotify_access_token = access_token
  }

  function o:request( http_method, api_path, params_tbl, post_put_body )
    assert(api_path, "The api path is missing!")

    local http_method = http_method

    if http_method ~= self.Get then
      local body = post_put_body or nil
    end

    local params = {}
    for name, value in pairs( params_tbl ) do
      table.insert( params, (name..'='..value) )
    end
    local params = table.concat( params, '&' )

    local api_url = self.spotify_api_url .. api_path .. '?' .. params

    local function callback( event )
      print( event.response )
    end
    network.request(api_url, http_method, callback, {
      headers =
      {
        ['Authorization'] = "Bearer " .. access_token
      },
      body = body
    })
  end

  return o
end

return api
