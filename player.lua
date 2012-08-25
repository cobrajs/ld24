module(..., package.seeall)

require 'utils'
require 'vector'
require 'tileset'
require 'shapes'
require 'animated'

function Player(global, startx, starty)
  local self = {global = global}
  -- Position vars
  self.pos = vector.Vector:new(startx, starty)
  self.vel = vector.Vector:new(0, 0)

  -- Animation vars
  self.anim = animated.Animated('gfx/player_tiles.lua')
  self.width = self.anim.image.tilewidth
  self.height = self.anim.image.tileheight

  local offset = self.width / 4

  self.rect = shapes.Rect(self.pos.x + offset, self.pos.y, self.width - offset * 2, self.height)
  self.updateRect = function(self)
    self.rect.x, self.rect.y = self.pos.x + offset, self.pos.y
  end

  self.anim:changeAnim('stand', 'left')

  self.grounded = false
  self.jumping = false

  -- Key Handler
  self.xMove = vector.Vector:new(0.1, 0)
  self.keyhandle = {
    --left = vector.Vector:new(-0.5,0),
    --right = vector.Vector:new(0.5,0),
    --up = vector.Vector:new(0,-0.5),
    --down = vector.Vector:new(0,0.5),
    jump = vector.Vector:new(0,-4)
  }

  self.gravity = vector.Vector:new(0, 0.2)

  self.maxVel = vector.Vector:new(2, 8)

  self.vel:add(self.gravity)

  self.update = function(self, dt)
    self.anim:update(dt)

    self.grounded = not (math.abs(self.vel.y) > self.gravity.y) and not self.jumping

    if self.grounded then
      if self.vel.x ~= 0 then 
        self.anim:changeAnim('walk', self.vel.x > 0 and 'right' or 'left')
        self.anim:modifyDelay(math.abs(1 / self.vel.x))
      else
        self.anim:changeAnim('stand', nil)
      end
    else
      if self.vel.y < 0 then 
        self.anim:changeAnim('jump', self.vel.x > 0 and 'right' or 'left')
      else
        self.anim:changeAnim('fall', self.vel.x > 0 and 'right' or 'left')
      end
    end

    if self.global.keyhandle:check('left') then
      self.vel:sub(self.xMove)
    elseif self.global.keyhandle:check('right') then
      self.vel:add(self.xMove)
    else
      if self.grounded then
        self.vel.x = 0
      end
    end

    self.vel.x = utils.clamp(-self.maxVel.x, self.vel.x, self.maxVel.x)
    self.vel.y = utils.clamp(-self.maxVel.y, self.vel.y, self.maxVel.y)

    self.pos:add(self.vel)

    self:updateRect()
  end

  self.collide = function(self, map)
    local collideMap, countMap = map:collides(self.rect, self.vel)
    if collideMap.down > 0 then
      self.pos.y = self.pos.y - collideMap.down
      self.vel.y = 0
      self.jumping = false
    else
      self.vel:add(self.gravity)
    end

    if collideMap.up > 0 then
      self.pos.y = self.pos.y + collideMap.up
      self.vel.y = 0
    end
    if collideMap.left > 0 then
      self.pos.x = self.pos.x + collideMap.left
      self.vel.x = 0
    elseif collideMap.right > 0 then
      self.pos.x = self.pos.x - collideMap.right
      self.vel.x = 0
    end

    self:updateRect()
  end

  self.draw = function(self, x, y)
    self.anim:draw(x or self.pos.x, y or self.pos.y)
    --self.rect:draw('line', x + offset, y)
  end

  self.handleKeyPress = function(self, keys, key)
    local action = ''
    for k,v in pairs(keys) do
      if key == k then action = v end
    end
    if action == 'jump' and self.grounded then
      self.vel:add(self.keyhandle[action])
      self.jumping = true
    end
  end

  return self
end

