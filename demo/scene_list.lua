local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here

-- -------------------------------------------------------------------------------


-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view

end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
    elseif ( phase == "did" ) then

      local function videoListener( event )
        print( "Event phase: " .. event.phase )
        if event.phase == 'ended' then
          native.setActivityIndicator( false )
        end
      end

      local function _playMp3( mp3 )
        local video = native.newVideo( -100, -100, 10, 10 )
        video:load( mp3, media.RemoteSource )
        video:addEventListener( "video", videoListener )
        video:play()
        native.setActivityIndicator( true )
      end



      local function _loadSample( album_id )

        --get album info
        spotify:request({
          path = 'albums/'..album_id..'/tracks',
          params = {
            limit = 1
          },
          onResult = function( results )
            --spotify.dump( results )
            local mp3 = results.items[1].preview_url
            if mp3 ~= nil then
              _playMp3( mp3 )
            else
              print('no preview available')
            end
          end
        })

      end







      local req =
      {
        path = 'browse/new-releases',
        params = { limit = 10, country = 'US' },
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
      spotify:request( req )

    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene
