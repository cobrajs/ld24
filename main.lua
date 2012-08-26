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
require 'collection'
require 'screenhandler'
require 'menuhandler'
require 'hud'

------------------------------------------------------------
-- Game objects
--
require 'player'
require 'enemy'
require 'item'


function loadMap(global, level)
  global.currentLevel = level or global.currentLevel
  global.map = loader.LoadMapLove(global.currentLevel)

  for i,v in ipairs(global.map.tilesets.images) do
    local tempSource = v.source
    if v.source:sub(1,2) == '..' then
      tempSource = v.source:split('/')
      table.remove(tempSource, 1)
      tempSource = table.concat(tempSource, '/')
    end
    v.image = tileset.Tileset(tempSource, v.tileX, v.tileY)
  end  

  global.map.start = global.map:FindObject('Start', 'Player')

  if global.player then
    global.player:reset(global.map.start.x, global.map.start.y)
  end

  --
  -- Preload some map stuff
  global.map.DisplayLayer = global.map:FindLayer('Display')
  global.map.CollideLayer = global.map:FindLayer('Collides')
  global.map.CollectsLayer = global.map:FindLayer('Collects')
  global.map.CollectsTiles = global.map.tilesets.images[2]
  global.map.EnemiesLayer = global.map:FindLayer('Enemies')
  global.map.EnemiesTiles = global.map.tilesets.images[3]

  --
  -- Set background for map
  love.graphics.setBackgroundColor(unpack(global.map.background:split(',')))

  if global.items then
    global.items:empty()
  else
    global.items = collection.Collection(global)
  end

  --
  -- Get Items from Collects Layer
  global.items:addFromLayer(global.map.CollectsTiles, global.map.CollectsLayer, function(baseTile, x, y)
    local tempItem = item[item.types[baseTile]](global, x, y)
    global.collider:register(tempItem, {tempItem.rect}, {
      player = function(self, other) self:startRemoval() end
    })
    return tempItem
  end)


  if global.enemies then
    global.enemies:empty()
  else
    global.enemies = collection.Collection(global)
  end

  --
  -- Get Enemies from Enemies Layer
  global.enemies:addFromLayer(global.map.EnemiesTiles, global.map.EnemiesLayer, function(baseTile, x, y)
    local tempItem = enemy[enemy.types[baseTile]](global, x, y)
    global.collider:register(tempItem, {tempItem.rect}, tempItem.collisionFuncs)
    return tempItem
  end)
  
  global.camera.maxx, global.camera.maxy = love.graphics.getWidth() - global.map.width, love.graphics.getHeight() - global.map.height
end

------------------------------------------------------------
-- Load function
function love.load()
  global = {
    center = {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2},
    map = nil,
    keyhandle = keyhandler.KeyHandler('keys.lua'),
    logger = logger.Logger(),
    gravity = vector.Vector:new(0, 0.2),

    debug = {
      slowmo = false
    },

    camera = camera.Camera(0, 0),
    player = nil,
    collider = collider.Collider(1),
    items = nil,
    enemies = nil,

    hud = hud.HUD(global, 'top', 30),

    loadMap = loadMap
  }

  screens = screenhandler.ScreenHandler()
  screens:addScreen({
    name = 'game',
    global = global,
    enter = function(self) end,
    update = function(self, dt)
      if self.global.debug.slowmo then
        love.timer.sleep(0.1)
      end

      self.global.player:update(dt)
      self.global.player:collide(global.map)

      self.global.keyhandle:updateTimes(dt)
      
      self.global.collider:update(dt)

      self.global.items:update(dt)
      self.global.enemies:update(dt)

      self.global.camera:update(
        math.floor(-self.global.player.pos.x + self.global.center.x),
        math.floor(-self.global.player.pos.y + self.global.center.y)
      )
    end,
    draw = function(self)
      self.global.player:draw(self.global.camera:drawPlayer(self.global.player.pos.x, self.global.player.pos.y))

      self.global.items:draw()
      self.global.enemies:draw()

      for tile, x, y in loader.tileIter(self.global.camera, self.global.map.DisplayLayer, self.global.map.tilesets.images[1]) do
        local usetile = self.global.map.tilesets.tiles[tonumber(tile)]
        if usetile then
          usetile.image.image:draw(x, y, tonumber(tile))
        end
      end

      self.global.hud:draw()
    end
  })

  screens:switchScreen('main')
    
  global.loadMap(global, 'level1.tmx')

  global.player = player.Player(global, global.map.start.x, global.map.start.y)

  global.collider:register(global.player, {global.player.rect}, global.player.collisionFuncs)
end

function love.update(dt)
  screens:update(dt)
end

function love.draw()
  screens:draw()
end

function love.keypressed(key)
  if key == 'escape' or key == 'q' then
    love.event.push('quit')
  elseif key == 's' then
    if type(global.debug.slowmo) == 'boolean' then
      global.debug.slowmo = true
    end
  end
  global.player:handleKeyPress(global.keyhandle.keys, key)
  global.keyhandle:update(key, true)
end

function love.keyreleased(key)
  global.keyhandle:update(key, false)
  if key == 's' then
    if type(global.debug.slowmo) == 'boolean' then
      global.debug.slowmo = false
    end
  end
end

