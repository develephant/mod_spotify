# mod_spotify

___A package for authentication and access to the Spotify Web API for use with Corona SDK.___

The package containes two modules, one for the OAuth workflow, and the other is a __"request"__ module to call the __Spotify__ API. These modules reside in the __spotify__ folder and should be left in that directory.

## Setting up a Spotify app for mod_spotify

You will need to set up an app at the [__Spotify developer portal__](https://developer.spotify.com) before you can start using the API in the mod. Most importantly, we need a __client_id__.

> __mod_spotify__ is using the __Spotify Web API__. You cannot stream music directly with this API. You _can_ open a __Spotify__ app, and send it a deep link, if its installed

 1. Log into your Spotify developer account (or register) at https://developer.spotify.com

 1. Click the __My Apps__ navigation link

 1. Click the __Create an app__ button

 1. Fill in the app details and click __Create__

 1. On the next page, scroll down and click __Add Uri__

 1. Enter: __http://localhost/auth.html__

 1. Click __Add Uri__ again to add it. (huh?)

 1. Note the __Client ID__. You will use that in the mod.

 1. Make sure to click __Save__ to update the changes.

 1. _You're all done here!_

## Working with mod_spotify

Add the __Spotify__ modules to your project:

```lua
local spotifyAuth = require('spotify.spotify_auth')
local spotifyApi = require('spotify.spotify_api')
```

## spotify_auth module
`spotify_auth.lua`

The __Spotify__ API uses __OAuth2__ for authentication, which means that the user must manually "whitelist" your application. This usually requires a visit to a web page for the user to log into the service and accept any special options your app requires (see 'scope' below).

The entire process is handled by the __spotify_auth__ module. Leaving you (hopefully) with a user confirmed access token, which is then sent with each API request behind the scenes.

To start the OAuth workflow, which should happen towards the start of your app:

Set up a callback for the authorization
```lua
--hold the api instance
local spotify
-- Set up the callback
local function callback( table_result )
  if table_result.error then --error
    print('error', table_result.error)
  elseif table_result.token then --success
    --store the access token
    self.access_token = table_result.token
    --initialize the spotify_api
    --module with the access token.
    spotify = spotifyApi:init( self.access_token )
  end
end
```

### Visualizing the output

You can pass `true` along with the `access_token` to enable auto table printing in the terminal, as the requests resolve.

```lua
-- Turn on auto output logging
spotify = spotifyApi:init( self.access_token, true )
```
You can also use the built-in command `dump` to manually output a table.

```lua
spotify.dump( api_tbl_data ) --prints to the terminal
```

### Running the OAuth prompt

Prompt the user for the confirmation using
an options table with some specific keys.
```lua
local options =
{
  client_id = 'YOUR_SPOTIFY_APP_CLIENT_ID',
  scope = 'user-library-read user-read-email'
  callback = callback
}

spotifyAuth:prompt( options )
```

> __Make sure to read up on the [scoping options here](https://developer.spotify.com/web-api/using-scopes/). Scroll down a bit to the Scope list on the page.__

### Spotify Auth methods

#### spotifyAuth:prompt( options )

> Prompt for confirmation. Returns access token, or error.

_Options table keys_

* client_id (required)
* scope
* show_dialog
* callback (required)

---

## spotify_api module
`spotify_api.lua`


The __spotify_api__ module provides a method of calling the Web REST API. You can view the [__Spotify__ API docs](https://developer.spotify.com/web-api/endpoint-reference/) as a reference on putting together requests.

Search for an item [(doc source)](https://developer.spotify.com/web-api/search-item/)

```lua
local api_request =
{
  method = spotify.Get -- default, optional.
  path = 'search',
  params =
  {
    q = "A Tribe Called Quest",
    limit = 4,
    type = "track"
  },
  onResult = function( result_tbl )
    local media = result_tbl.items[1].images[1].url
  end
}
spotifyApi:request( api_request )
```

In the `api_request` above, the `method` key defaults to 'GET', so you can exclude it for any 'GET' requests (which is most). The `params` key will depend on each API function, and is a table of key/value pairs. See the [__Spotify Web API__ docs](https://developer.spotify.com/web-api/endpoint-reference/).

### Figuring out the `path` parameter

On the __Spotify__ [endpoint reference](https://developer.spotify.com/web-api/endpoint-reference/) page is a table of API actions. You can find the `method` from the __Method__ column. In the __Endpoint__ column is where you derive the `path` property for your request. As an example, the endpoints will look like so:

`/v1/browse/categories`

__For your request path you only need everything after the "v1/"__. So for the endpoint above, you would use as the `path` parameter:

`browse/categories`

### Building the `params` parameter

If you click on one of the doc links for an endpoint, you will be taken to a detail page that will commonly list additional query string modifiers you can add.

For example, the `browse/categories` options include `country`, `locale`, `limit`, etc. The query parameters vary for each endpoint.

> Though output in JSON, you can also view the expected response structure on the API detail pages.

To add parameters to the query string, just build up an associative table.

```lua
local query_params =
{
  limit = 10,
  country = US
}
```
If the key names are exotic in any way -- contain spaces or the like -- then put the key name in quotes, and some brackets.

```lua
local query_params =
{
  limit = 10,
  country = "US",
  ["exotic key!"] = spotify.encode("a value with spaces")
}
```

### Including data with 'POST' and 'PUT'

```lua
local req =
{
  path = 'browse/new-releases',
  body = '{"genre":"rock"}',
  method = spotify.Post
}
```

Any 'POST' or 'PUSH' actions take JSON data in the body. You can build these structures as tables first and then convert them.

```lua
local bt = { genre = "rock" }
local body = spotify.tbl2json( bt )
```
Some actions use both the `body` and `params`

```lua
local req =
{
  method = spotify.Put
  params = { username = "Martha" },
  body = spotify.tbl2json({ dogs = { 'Fred', 'Alice' }, reads = true })
}
```

> You must specify the http `method` in every case, except 'GET'.

### Setting up the `onResult` parameter

You need to set up a callback in `onResult` to retrieve any results.

```lua
local req =
{
  path = 'browse/new-releases',
  params = { limit = 1, country = 'US' },
  onResult = function( result_tbl )
    --output table to terminal
    spotify.dump( result_tbl )
  end
}
```

### Send the Spotify Web API request

The results will be returned to the `onResult` handler.

> __Results are always returned as Lua tables.__

```lua
spotify:request( req )
```

### Spotify API methods

#### spotify:request( req_tbl )

> Sends a request to Spotify

_Request table keys_

* path (required)
* method (required)
* params
* body
* onResult (required)

#### spotify.encode( url_str )

> URL encode a string (escape)

#### spotify.decode( enc_url )

> Decode a URL (unescape)

#### spotify.tbl2json( tbl )

> Converts a Lua table to JSON string

#### spotify.json2tbl( json_str )

> Converts JSON string to Lua table

#### spotify.dump( tbl )

> Outputs a table in the terminal

### Http method constants

#### spotify.Get

> GET

#### spotify.Post

> POST

#### spotify.Put

> PUT

#### spotify.Delete

> DELETE

You can use the `method` string in place of the constants in the request table.

:elephant: &copy;2015 C. Byerley - [@develephant](https://twitter.com/develephant)
