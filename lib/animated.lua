module(..., package.seeall)

require 'utils'
require 'tileset'

function Animated(tilesetFile)
  local self = {}
  -- Position vars
  self.pos = vector.Vector:new(startx, starty)
  self.vel = vector.Vector:new(0, 0)

  -- Animation vars
  self.image = tileset.LuaTileset(tilesetFile)
  self.width = self.image.tilewidth
  self.height = self.image.tileheight

  self.animPos = 1
  self.animState = 0
  self.animDelay = 0
  self.anim = self.image.anims.stand

  self.changeAnim = function(state, dir, reset) 

  end

  self.update = function(self, dt)
    if self.vel.x ~= 0 then
      if love.timer.getTime() - self.animDelay > 1 / math.abs(self.vel.x) then
        self.animState = self.animState > 0 and 0 or self.animState + 1
        self.animDelay = love.timer.getTime()
      end
      self.animPos = self.vel.x > 0 and self.anim.right.start or self.anim.left.start
    end
    self.pos:add(self.vel)
  end

  self.draw = function(self, x, y)
    self.image:draw(x or self.pos.x, y or self.pos.y, self.animPos + self.animState)
  end

  return self
end

local function AnimState()
  return {pos = 1, state = 0, delay = 0}
end
