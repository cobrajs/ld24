module(..., package.seeall)

require 'utils'
require 'vector'
require 'tileset'
require 'shapes'
require 'animated'

function Player(global, startx, starty)
  local self = {
    global = global,
    type = 'player',

    -- Position vars
    pos = vector.Vector:new(startx, starty),
    vel = vector.Vector:new(0, 0),

    -- Animation vars
    anim = animated.Animated('gfx/player_tiles.lua'),
    width = nil,
    height = nil,

    rect = nil,

    grounded = false,
    jumping = false,

    -- Key Handler

    xMove = vector.Vector:new(0.1, 0),
    keyhandle = {
      jump = vector.Vector:new(0,-4)
    },

    maxVel = vector.Vector:new(2, 8),

    collisionFuncs = {
      blue = function(self, other, collideDepth, collideSide) 
        if collideSide ~= 'top' then 
          self.global:loadMap()
        end
      end,
      food = function(self, other)
        if not other.taken then
          self:updateAttribs(other.attribs)
          other.taken = true
        end
      end
    },

    attribs = {
      weight = 1,
      jump = 1,
      speed = 1
    },
    minAttribs = {
      weight = 0.5, 
      jump = 0,
      speed = 0.2
    },
    maxAttribs = {
      weight = 2,
      jump = 2,
      speed = 2
    }
  }

  self.width = self.anim.image.tilewidth
  self.height = self.anim.image.tileheight

  local offset = self.width / 4

  self.rect = shapes.Rect(self.pos.x + offset, self.pos.y, self.width - offset * 2, self.height)
  self.updateRect = function(self)
    self.rect.x, self.rect.y = self.pos.x + offset, self.pos.y
  end

  self.anim:changeAnim('stand', 'right')

  self.vel:add(self.global.gravity)

  local updateMap = {
    weight = 'fat',
    jump = 'fiber',
    speed = 'protein'
  }
  self.updateAttribs = function(self, attribs)
    for k,v in pairs(updateMap) do
      self.attribs[k] = self.attribs[k] + attribs[v]
    end
  end

  self.reset = function(self, newstartx, newstarty)
    self.pos.x, self.pos.y = newstartx or startx, newstarty or starty
    self.vel.x, self.vel.y = 0, 0
    self.grounded, self.jumping = false, false
    self.attribs.weight, self.attribs.jump, self.attribs.speed = 1, 1, 1
    self:updateRect()
  end

  self.update = function(self, dt)
    self.anim:update(dt)

    self.grounded = not (math.abs(self.vel.y) > self.global.gravity.y) and not self.jumping

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
      if self.vel.x > 0 then
        self.vel.x = self.vel.x < -0.25 and self.vel.x * 0.5 or 0
      else
        self.vel:sub(self.xMove)
      end
    elseif self.global.keyhandle:check('right') then
      if self.vel.x < 0 then
        self.vel.x = self.vel.x > 0.25 and self.vel.x * 0.5 or 0
      else
        self.vel:add(self.xMove)
      end
    else
      if self.grounded then
        self.vel.x = math.abs(self.vel.x) > 0.25 and self.vel.x * 0.9 or 0
      end
    end

    self.vel.x = utils.clamp(-self.maxVel.x * self.attribs.speed, self.vel.x, self.maxVel.x * self.attribs.speed)
    self.vel.y = utils.clamp(-self.maxVel.y, self.vel.y, self.maxVel.y)

    self.pos:add(self.vel)

    self:updateRect()
  end

  self.collide = function(self, map)
    local collideMap, countMap = map:collides(self.rect, self.vel, true)
    if collideMap == 'death' then
      self.global:loadMap()
    else
      if collideMap.down > 0 then
        self.pos.y = self.pos.y - collideMap.down
        self.vel.y = 0
        self.jumping = false
      else
        self.vel:add(self.global.gravity)
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
    end

    self:updateRect()
  end

  self.draw = function(self, x, y)
    self.anim:draw(math.floor(x or self.pos.x), math.floor(y or self.pos.y))
    --self.rect:draw('line', x + offset, y)
  end

  self.handleKeyPress = function(self, keys, key)
    local action = ''
    for k,v in pairs(keys) do
      if key == k then action = v end
    end
    if action == 'jump' and self.grounded then
      self.vel.y = self.vel.y + self.keyhandle[action].y * self.attribs.jump
      self.jumping = true
    end
  end

  return self
end

