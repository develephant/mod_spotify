---Spotify API module
-- @name spotify_api
-- @version 0.1.0
-- @author C.Byerley
-- @copyright 2015 develephant
-- @license MIT
-- @twitter @develephant
local json = require('json')
local url = require('socket.url')

local api = {}

function api:init( access_token, show_results )

  local o =
  {
    Get     = 'GET',
    Post    = 'POST',
    Delete  = 'DELETE',
    Put     = 'PUT',

    show_results = show_results or false,

    spotify_api_url = "https://api.spotify.com/v1/",
    spotify_access_token = access_token
  }

  o.encode = url.escape
  o.decode = url.unescape

  o.tbl2json = json.encode
  o.json2tbl = json.decode

  function o:request( req_tbl )

    local http_method = req_tbl.method or self.Get
    local api_path = req_tbl.path or ""
    local params_tbl = req_tbl.params or {}
    local post_body = req_tbl.body or nil
    local onResult = req_tbl.onResult or nil

    assert(api_path, "The api path is missing!")

    local params = {}
    for name, value in pairs( params_tbl ) do
      table.insert( params, (name..'='..value) )
    end
    local params = table.concat( params, '&' )

    local api_url = self.spotify_api_url .. api_path .. '?' .. params

    local function callback( event )

      local success, tbl_result = pcall( json.decode, event.response )
      if success then
        if self.show_results then
          self.dump( tbl_result )
        end
        if onResult then
          onResult( tbl_result )
        end
      else
        print('err', tbl_result)
      end
    end

    network.request(api_url, http_method, callback, {
      headers =
      {
        ['Authorization'] = "Bearer " .. access_token
      },
      body = post_body -- for POST/PUT
    })
  end

  local _toString = function( t, indent )

  -- print contents of a table, with keys sorted. second parameter is optional, used for indenting subtables
    local names = {}
    if not indent then indent = "" end
    for n,g in pairs(t) do
        table.insert(names,n)
    end
    table.sort(names)
    for i,n in pairs(names) do
        local v = t[n]
        if type(v) == "table" then
            if(v==t) then -- prevent endless loop if table contains reference to itself
                print(indent..tostring(n)..": <-")
            else
                print(indent..tostring(n)..":")
                o.dump(v,indent.."   ")
            end
        else
            if type(v) == "function" then
                print(indent..tostring(n).."()")
            else
                print(indent..tostring(n)..": "..tostring(v))
            end
        end
    end
  end
  o.dump = _toString

  return o
end

return api
