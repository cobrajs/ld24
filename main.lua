--
-- Ludum Dare 24 Entry
--

------------------------------------------------------------
-- Libraries
--
-- Make it so I can store libraries in the lib folder
package.path = package.path .. ';./lib/?.lua'
require 'animated'
require 'player'
require 'loader'
require 'camera'
require 'utils'
require 'keyhandler'

function love.load()
  center = {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2}
  map = loader.LoadMapLove('maps/level1.tmx')
  map.DisplayLayer = map:FindLayer('Display')
  map.CollideLayer = map:FindLayer('Collides')

  camera = camera.Camera(love.graphics.getWidth() - map.width, love.graphics.getHeight() - map.height)
  for i,v in ipairs(map.tilesets.images) do
    v.image = tileset.Tileset(v.source, v.tileX, v.tileY)
  end  

  local start = map:FindObject('Start', 'Player')
  player = player.Player(start.x, start.y)

  keyhandle = keyhandler.KeyHandler('keys.lua')
end

function love.update(dt)
  player:update(dt)
  player:collide(map)
  
  camera:update(
    math.floor(-player.pos.x + center.x),
    math.floor(-player.pos.y + center.y)
  )
end

function love.draw()
  for tile, x, y in loader.tileIter(camera, map.DisplayLayer, map.tilesets.images[1]) do
    local usetile = map.tilesets.tiles[tonumber(tile)]
    if usetile then
      usetile.image.image:draw(x, y, tonumber(tile))
    end
  end

  player:draw(camera:drawPos(player.pos.x, player.pos.y))
end

function love.keypressed(key)
  if key == 'escape' or key == 'q' then
    love.event.push('quit')
  end
  player:handleKeyPress(keyhandle.keys, key)
end
