--
-- Ludum Dare 24 Entry
--

------------------------------------------------------------
-- Libraries
--
-- Make it so I can store libraries in the lib folder
require 'lib.animated';animated = lib.animated
require 'lib.loader';loader = lib.loader
require 'lib.camera';camera = lib.camera
require 'lib.utils';utils = lib.utils
require 'lib.keyhandler';keyhandler = lib.keyhandler
require 'lib.logger';logger = lib.logger
require 'lib.collider';collider = lib.collider
require 'lib.collection';collection = lib.collection
require 'lib.screenhandler';screenhandler = lib.screenhandler
require 'lib.menuhandler';menuhandler = lib.menuhandler
require 'lib.hud';hud = lib.hud
require 'lib.vector';vector = lib.vector
require 'lib.tileset';tileset = lib.tileset

------------------------------------------------------------
-- Game objects
--
require 'player'
require 'enemy'
require 'item'
require 'maps'

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

    loadMap = maps.loadMap
  }

  screens = screenhandler.ScreenHandler()
  screens:addScreen({
    name = 'title',
    global = global,
    timeout = 2,
    titleImage = utils.loadImage('title.png'),
    enter = function(self) 
      love.graphics.setBackgroundColor(0, 0, 0, 255)
    end,
    update = function(self, dt)
      if self.timeout > 0 then
        self.timeout = self.timeout - dt
      else
        screens:switchScreen('game')
      end
    end,
    draw = function(self)
      love.graphics.draw(self.titleImage, 0, 0)
      love.graphics.setColor(150, 150, 150, 255)
      love.graphics.print('Press any key', 230, 220)
      love.graphics.setColor(255, 255, 255, 255)
    end
  })
  screens:addScreen({
    name = 'end',
    global = global,
    endImage = utils.loadImage('credits.png'),
    enter = function(self) 
      love.graphics.setBackgroundColor(0, 0, 0, 255)
    end,
    update = function(self, dt) end,
    draw = function(self)
      love.graphics.draw(self.endImage, 0, 0)
    end
  })
  screens:addScreen({
    name = 'game',
    global = global,
    enter = function(self) 
      self.global.loadMap(self.global, self.global.currentLevel)
    end,
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
      for tile, x, y in loader.tileIter(self.global.camera, self.global.map.DisplayBackLayer, self.global.map.tilesets.images[1]) do
        tile = tonumber(tile)
        local usetile = self.global.map.tilesets.tiles[tonumber(tile)]
        if usetile and tile > 1 then
          usetile.image.image:draw(x, y, tonumber(tile))
        end
      end

      self.global.player:draw(self.global.camera:drawPlayer(self.global.player.pos.x, self.global.player.pos.y))

      self.global.items:draw()
      self.global.enemies:draw()

      for tile, x, y in loader.tileIter(self.global.camera, self.global.map.DisplayFrontLayer, self.global.map.tilesets.images[1]) do
        tile = tonumber(tile)
        local usetile = self.global.map.tilesets.tiles[tonumber(tile)]
        if usetile and tile > 1 then
          usetile.image.image:draw(x, y, tonumber(tile))
        end
      end

      self.global.hud:draw()
    end
  })

  screens:switchScreen('title')
    
  global.currentLevel = maps.mapsTable[maps.levelOrder[1]]
  --global.loadMap(global, 'tutorial.tmx')

  global.player = player.Player(global, 0, 0)

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
  if screens:onScreen('title') then
    screens:switchScreen('game')
  end
  if screens:onScreen('end') then
    love.event.push('quit')
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

