module(..., package.seeall)

require 'lib.loader';loader = lib.loader
require 'lib.tileset';tileset = lib.tileset
require 'lib.collection';collection = lib.collection
require 'lib.collider';collider = lib.collider

mapsTable = {
  Tutorial = 'tutorial.tmx', 
  First = 'level1.tmx'
}

levelOrder = {'Tutorial', 'First'}

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

  if global.finishes then
    global.finishes:empty()
  else
    global.finishes = collection.Collection(global)
  end

  local finishes = global.map:FindObjects('Finish')
  if finishes then
    utils.printTable(finishes[1])
    for i,v in ipairs(finishes) do
      v.rect = {type = 'rect', x = tonumber(v.x), y = tonumber(v.y), width = tonumber(v.width), height = tonumber(v.height)}
      v.type = 'finish'
      global.finishes:add(v)
      global.collider:register(v, {v.rect}, {player = function(self, other)
        if v.next then
          global.currentLevel = mapsTable[v.next]
          global:loadMap()
        else
          screens:switchScreen('end')
        end
      end})
    end
  end

  if global.player then
    global.player:reset(global.map.start.x, global.map.start.y)
  end

  --
  -- Preload some map stuff
  global.map.DisplayFrontLayer = global.map:FindLayer('DisplayFront')
  global.map.DisplayBackLayer = global.map:FindLayer('DisplayBack')
  global.map.CollideLayer = global.map:FindLayer('Collides')
  global.map.CollectsLayer = global.map:FindLayer('Collects')
  global.map.CollectsTiles = global.map.tilesets.images[2]
  global.map.EnemiesLayer = global.map:FindLayer('Enemies')
  global.map.EnemiesTiles = global.map.tilesets.images[3]

  if global.helpBoxes then
    global.helpBoxes:empty()
  else
    global.helpBoxes = collection.Collection(global)
  end

  local helpBoxes = global.map:FindObjects('help')
  if helpBoxes then
    for i,v in ipairs(helpBoxes) do
      v.rect = {type = 'rect', x = tonumber(v.x), y = tonumber(v.y), width = tonumber(v.width), height = tonumber(v.height)}
      v.type = 'help'
      global.helpBoxes:add(v)
      global.collider:register(v, {v.rect}, {player = function(self, other)
        if self.text == 'clear' then
          global.hud:clear()
        else
          global.hud:clear()
          global.hud:setText(self.text)
        end
      end})
    end
  end

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
