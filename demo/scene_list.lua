--- Spotify list scene
local composer = require( "composer" )
local scene = composer.newScene()

function scene:create( event )
  local sceneGroup = self.view
end

function scene:show( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
  elseif ( phase == "did" ) then

    --== Forward methods ==--

    --== Listening for the 'audio' track
    local function videoListener( event )
      print( "Event phase: " .. event.phase )
      if event.phase == 'ended' then
        native.setActivityIndicator( false )
      end
    end

    --== Start playing the 30 second clip
    local function _playMp3( mp3 )
      local video = native.newVideo( -100, -100, 10, 10 )
      video:load( mp3, media.RemoteSource )
      video:addEventListener( "video", videoListener )
      video:play()
      native.setActivityIndicator( true )
    end

    -- With album id, get the sample url and play it
    local function _loadSample( album_id )
      --get album info
      spotify:request({
        path = 'albums/'..album_id..'/tracks',
        params = {
          limit = 1
        },
        onResult = function( results )
          local mp3 = results.items[1].preview_url
          if mp3 ~= nil then
            _playMp3( mp3 )
          else
            print('no preview available')
          end
        end
      })
    end

    --== Spotify Request ==--
    local req =
    {
      path = 'browse/new-releases',
      params = { limit = 10, country = 'US' },
      --== On data result start rendering some data
      onResult = function( res )
        for i=1, 10 do

          local album = res.albums.items[i]
          local mini = album.images[3].url

          local x = 60
          local y = ( 80 * i ) + 60

          local album_name = album.name
          display.newText({
            text = album_name,
            width = 680,
            y = y,
            x = x + 400
          })

          local id = album.id

          --== Add tap listener to the minis for preview
          local function _listener( event )
            event.target.meta = { id = id }
            event.target:addEventListener('tap', function( e )
              local album_id = e.target.meta.id
              _loadSample( album_id )
            end)
          end
          display.loadRemoteImage( mini, 'GET', _listener, 'img'..i, system.TemporaryDirectory, x, y )

        end
      end
    }
    --== Submit the request
    spotify:request( req )
  end
end


function scene:hide( event )
  local sceneGroup = self.view
  local phase = event.phase
  if ( phase == "will" ) then
  elseif ( phase == "did" ) then
  end
end

function scene:destroy( event )
  local sceneGroup = self.view
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
