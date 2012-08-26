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

  self.currentAnim = {anim = '', dir = ''}
  self.current = nil

  self.anims = self.image.anims
  for k, v in pairs(self.anims) do
    if self.currentAnim.anim == '' then 
      self.currentAnim.anim = k
    end

    for d, anim in pairs(v) do 
      if self.currentAnim.dir == '' then 
        self.currentAnim.dir = d
        self.current = self.anims[self.currentAnim.anim][self.currentAnim.dir]
      end
      anim.pos = anim.start
      anim.state = 0
      anim.delay = 0
      anim.origDelay = anim.delayLen
    end
  end

  self.changeAnim = function(self, state, dir, reset) 
    self.currentAnim.anim, self.currentAnim.dir = utils.coalesce(state, self.currentAnim.anim), utils.coalesce(dir, self.currentAnim.dir)
    self.current = self.anims[self.currentAnim.anim][self.currentAnim.dir]
    if reset then
      self.current.pos, self.current.state, self.current.delay = self.current.start, 0, 0
    end
  end

  self.modifyDelay = function(self, factor)
    self.current.delayLen = self.current.origDelay * factor
  end

  self.update = function(self, dt)
    self.current.delay = self.current.delay + dt
    if self.current.delay > self.current.delayLen then
      self.current.delay = 0
      self.current.pos = animWrap(self.current.pos + 1, self.current.start, self.current.fin)
    end
  end

  self.draw = function(self, x, y)
    self.image:draw(x, y, self.current.pos)
  end

  self.drawSpecial = function(self, x, y, scaleX, scaleY, fade)
    love.graphics.setColor(255,255,255,fade)
    self.image:draw(x - math.floor((self.width * scaleX - self.width) / 2), y - math.floor((self.height * scaleY - self.height) / 2), self.current.pos, 0, scaleX, scaleY)
    love.graphics.setColor(255,255,255,255)
  end

  return self
end

function animWrap(number, min, max)
  if number > max then return min
  elseif number < min then return max
  end
  return number
end
