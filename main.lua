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
require 'logger'

function love.load()
  global = {
    center = {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2},
    map = loader.LoadMapLove('maps/level1.tmx'),
    keyhandle = keyhandler.KeyHandler('keys.lua'),
    logger = logger.Logger(),

    camera = nil,
    player = nil
  }

  for i,v in ipairs(global.map.tilesets.images) do
    v.image = tileset.Tileset(v.source, v.tileX, v.tileY)
  end  

  local start = global.map:FindObject('Start', 'Player')
  global.player = player.Player(global, start.x, start.y)

  global.camera = camera.Camera(love.graphics.getWidth() - global.map.width, love.graphics.getHeight() - global.map.height)

  global.map.DisplayLayer = global.map:FindLayer('Display')
  global.map.CollideLayer = global.map:FindLayer('Collides')
  love.graphics.setLine(1, 'rough')
end

function love.update(dt)
  global.player:update(dt)
  global.player:collide(global.map)
  
  global.camera:update(
    math.floor(-global.player.pos.x + global.center.x),
    math.floor(-global.player.pos.y + global.center.y)
  )
end

function love.draw()
  for tile, x, y in loader.tileIter(global.camera, global.map.DisplayLayer, global.map.tilesets.images[1]) do
    local usetile = global.map.tilesets.tiles[tonumber(tile)]
    if usetile then
      usetile.image.image:draw(x, y, tonumber(tile))
      love.graphics.line(x, y, x + global.map.tileWidth, y)
      love.graphics.line(x, y, x, y + global.map.tileHeight)
    end
  end

  global.player:draw(global.camera:drawPos(global.player.pos.x, global.player.pos.y))

  global.logger:draw()
end

function love.keypressed(key)
  if key == 'escape' or key == 'q' then
    love.event.push('quit')
  end
  global.player:handleKeyPress(global.keyhandle.keys, key)
end
