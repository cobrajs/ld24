module(..., package.seeall)

require 'utils'
require 'vector'
require 'tileset'
require 'shapes'
require 'animated'

function Player(startx, starty)
  local self = {}
  -- Position vars
  self.pos = vector.Vector:new(startx, starty)
  self.vel = vector.Vector:new(0, 0)

  -- Animation vars
  self.anim = animated.Animated('gfx/player_tiles.lua')
  self.width = self.anim.image.tilewidth
  self.height = self.anim.image.tileheight
  self.rect = shapes.Rect(self.pos.x, self.pos.y, self.width, self.height)
  self.anim:changeAnim('stand', 'left')

  -- Key Handler
  self.keyhandle = {
    left = vector.Vector:new(-0.5,0),
    right = vector.Vector:new(0.5,0),
    up = vector.Vector:new(0,-0.5),
    down = vector.Vector:new(0,0.5)
  }

  self.update = function(self, dt)
    self.anim:update(dt)
    if self.vel.x ~= 0 then 
      self.anim:changeAnim('walk', self.vel.x > 0 and 'right' or 'left')
      self.anim:modifyDelay(math.abs(1 / self.vel.x))
    else
      self.anim:changeAnim('stand', nil)
    end
    self.pos:add(self.vel)
  end

  self.collide = function(layer)

  end

  self.draw = function(self, x, y)
    self.anim:draw(x or self.pos.x, y or self.pos.y)
  end

  self.handleKeyPress = function(self, keys, key)
    local action = ''
    for k,v in pairs(keys) do
      if key == k then action = v end
    end
    if self.keyhandle[action] then
      self.vel:add(self.keyhandle[action])
    end
  end

  return self
end

