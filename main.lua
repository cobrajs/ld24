--
-- Ludum Dare 24 Entry
--

------------------------------------------------------------
-- Libraries
--
-- Make it so I can store libraries in the lib folder
package.path = package.path .. ';./lib/?.lua'
require 'animated'
require 'loader'
require 'camera'
require 'utils'
require 'keyhandler'
require 'logger'
require 'collider'

------------------------------------------------------------
-- Game objects
--
require 'player'
require 'enemy'
require 'item'

------------------------------------------------------------
-- Load function
function love.load()
  global = {
    center = {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2},
    map = loader.LoadMapLove('maps/level1.tmx'),
    keyhandle = keyhandler.KeyHandler('keys.lua'),
    logger = logger.Logger(),
    gravity = vector.Vector:new(0, 0.2),

    camera = nil,
    player = nil
  }

  for i,v in ipairs(global.map.tilesets.images) do
    local tempSource = v.source
    if v.source:sub(1,2) == '..' then
      tempSource = v.source:split('/')
      table.remove(tempSource, 1)
      tempSource = table.concat(tempSource, '/')
    end
    v.image = tileset.Tileset(tempSource, v.tileX, v.tileY)
  end  

  local start = global.map:FindObject('Start', 'Player')
  global.player = player.Player(global, start.x, start.y)

  global.collider = collider.Collider()
  global.collider:register(global.player, {global.player.rect}, {
    blue = function(self, other) print('BLUE DUDE HIT ME!') end,
    cake = function(self, other) print('SWEET, CAKE!') end,
    carrot = function(self, other) print('AH, A CARROT!') end,
    chicken = function(self, other) print('YUM, CHICKEN LEG!') end
  })

  global.camera = camera.Camera(love.graphics.getWidth() - global.map.width, love.graphics.getHeight() - global.map.height)

  global.map.DisplayLayer = global.map:FindLayer('Display')
  global.map.CollideLayer = global.map:FindLayer('Collides')
  global.map.CollectsLayer = global.map:FindLayer('Collects')
  global.map.CollectsTiles = global.map.tilesets.images[2]
  global.map.EnemiesLayer = global.map:FindLayer('Enemies')
  global.map.EnemiesTiles = global.map.tilesets.images[3]
  love.graphics.setLine(1, 'rough')

  love.graphics.setBackgroundColor(150, 150, 150, 255)

  --global.blue = enemy.BlueEnemy(global, 50, 40)
  --global.collider:register(global.blue, {global.blue.rect}, {player = function() print('PLAYER HIT ME!') end})

  --
  -- Get Items from Collects Layer
  global.items = {}
  local types = {'Cake', 'Carrot', 'Chicken'}
  local firstgid = global.map.CollectsTiles.firstgid
  local tileWidth = global.map.CollectsTiles.tilewidth
  local tileHeight = global.map.CollectsTiles.tileheight
  for y, yL in ipairs(global.map.CollectsLayer.grid) do
    for x, tileNum in ipairs(yL) do
      tileNum = tonumber(tileNum)
      local useTile = global.map.tilesets.tiles[tileNum]
      local baseTile = tonumber(1 + tileNum - firstgid)
      if useTile then
        local tempItem = item[types[baseTile]](global, (x-1) * tileWidth, (y-1) * tileHeight)
        table.insert(global.items, tempItem)
        global.collider:register(tempItem, {tempItem.rect}, {player = function(self, other) self.remove = true end})
      end
    end
  end

  --
  -- Get Enemies from Enemies Layer
  global.enemies = {}
  local types = {[1] = 'BlueEnemy'}
  local firstgid = global.map.EnemiesTiles.firstgid
  local tileWidth = global.map.EnemiesTiles.tilewidth
  local tileHeight = global.map.EnemiesTiles.tileheight
  for y, yL in ipairs(global.map.EnemiesLayer.grid) do
    for x, tileNum in ipairs(yL) do
      tileNum = tonumber(tileNum)
      local useTile = global.map.tilesets.tiles[tileNum]
      local baseTile = tonumber(1 + tileNum - firstgid)
      if useTile then
        local tempItem = enemy[types[baseTile]](global, (x-1) * tileWidth, (y-1) * tileHeight)
        table.insert(global.enemies, tempItem)
        global.collider:register(tempItem, {tempItem.rect}, {
          player = function(self, player) end,
          blue = function(self, blue) print("QUIT BUMPING INTO ME PLEASE") end
        })
      end
    end
  end
end

function love.update(dt)
  --love.timer.sleep(0.1)
  global.player:update(dt)
  global.player:collide(global.map)

  global.keyhandle:updateTimes(dt)
  
  for _,v in ipairs(global.enemies) do
    v:update(dt)
    v:collide(global.map)
  end

  global.collider:update(dt)

  for i=#global.items, 1, -1 do
    local v = global.items[i]
    if v.remove then
      global.collider:deregister(v)
      table.remove(global.items, i)
    end
  end

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
    end
  end

  global.player:draw(global.camera:drawPlayer(global.player.pos.x, global.player.pos.y))

  --global.blue:draw(global.camera:drawOther(global.blue.rect.x, global.blue.rect.y))

  for _, v in ipairs(global.items) do
    v:draw(global.camera:drawOther(v.rect.x, v.rect.y))
  end

  for _, v in ipairs(global.enemies) do
    v:draw(global.camera:drawOther(v.rect.x, v.rect.y))
  end

  --global.logger:draw()
end

function love.keypressed(key)
  if key == 'escape' or key == 'q' then
    love.event.push('quit')
  end
  global.player:handleKeyPress(global.keyhandle.keys, key)
  global.keyhandle:update(key, true)
end

function love.keyreleased(key)
  global.keyhandle:update(key, false)
end
