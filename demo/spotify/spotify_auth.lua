---Spotify Auth module
-- @name spotify_auth
-- @version 0.1.0
-- @author C.Byerley
-- @copyright 2015 develephant
-- @license MIT
-- @twitter @develephant
local url = require('socket.url')

local auth =
{
  client_id = "",
  --============================================--
  access_token = "",
  expires_in = 0,
  token_type = "",

  last_state = "",
  last_error = "",

  show_dialog = false,

  --See https://developer.spotify.com/web-api/using-scopes/
  --the scopes are seperated by spaces.
  spotify_scope = "",

  spotify_response_type = 'token',
  spotify_redirect_url = url.escape("http://localhost/auth.html"),
  spotify_auth_url = "https://accounts.spotify.com/authorize?",
}

--== Utils
local function url_decode (s)
  return s:gsub ('+', ' '):gsub ('%%(%x%x)', function (hex) return string.char (tonumber (hex, 16)) end)
end
-- query string parser
local function query_string ( url_str )
  local res = {}
  local url_str = url_str or ""
  for name, value in url_str:gmatch '([^&=]+)=([^&=]+)' do
      value = url_decode (value)
      local key = name:match '%[([^&=]*)%]$'
      if key then
          name, key = url_decode (name:match '^[^[]+'), url_decode (key)
          if type (res [name]) ~= 'table' then
              res [name] = {}
          end
          if key == '' then
              key = #res [name] + 1
          else
              key = tonumber (key) or key
          end
          res [name] [key] = value
      else
          name = url_decode (name)
          res [name] = value
      end
  end
  return res
end

---Prompt for auth
-- @table auth_tbl The prompt options
-- auth_tbl -
--  client_id
--  callback -> string
--  scope
--  show_dialog
-- @return An access token or error
function auth:prompt( auth_tbl )

  local _callback = auth_tbl.callback or nil

  self.show_dialog = auth_tbl.show_dialog or false
  self.client_id = auth_tbl.client_id or nil
  self.spotify_scope = auth_tbl.scope or ''

  -- webView
  local wv

  local auth_url = self:_generateAuthUrl()

  wv = native.newWebView(display.contentCenterX, display.contentCenterY, display.viewableContentWidth, display.viewableContentHeight)
  wv:request( auth_url )
  -- request listener
  local _listener = function( event )
    if event.url then
      --parse up url
      local url_obj = url.parse( event.url )

      --check for our return from web view/spotify
      if (url_obj.authority == 'localhost') and (url_obj.path == '/auth.html') then
        -- this should indicate that we have a response from the user

        local return_str = ""
        if url_obj.fragment then
          return_str = url_obj.fragment
        elseif url_obj.query then
          return_str = url_obj.query
        end

        local query_obj = query_string( return_str )

        self.last_state = query_obj.state

        if query_obj.error then
          self.last_error = query_obj.error
          _callback( { error = query_obj.error } )
        else
          self.access_token = query_obj.access_token
          self.token_type = query_obj.token_type
          self.expires_in = query_obj.expires_in
        end

        _callback( { token = self.access_token, expires_in = self.expires_in } )

        wv:removeSelf()
      end
    end

    if event.errorCode then
      _callback( { error = event.errorCode } )
    end
  end
  wv:addEventListener( 'urlRequest', _listener )
end

function auth:getToken()
  return self.access_token
end

function auth:getLastState()
  return self.last_state
end

function auth:getLastError()
  return self.last_error
end

function auth:_generateAuthUrl( state )
  local state = state or os.time()
  local scope = url.escape( self.spotify_scope )
  local show_dialog = self.show_dialog
  local str_join = self.spotify_auth_url .. "client_id=%s&response_type=%s&redirect_uri=%s&scope=%s&show_dialog=%s&state=%d"
  local request_url = string.format( str_join,
  self.client_id, self.spotify_response_type, self.spotify_redirect_url, scope, tostring(show_dialog), state)
  return request_url
end

return auth
