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
  self.rect = shapes.Rect(self.pos.x, self.pos.y, self.width, self.height)
  self.anim:changeAnim('stand', 'left')

  self.grounded = false

  -- Key Handler
  self.keyhandle = {
    left = vector.Vector:new(-0.5,0),
    right = vector.Vector:new(0.5,0),
    up = vector.Vector:new(0,-0.5),
    down = vector.Vector:new(0,0.5)
  }

  self.gravity = vector.Vector:new(0, 0.1)

  self.maxVel = vector.Vector:new(8, 8)

  self.vel:add(self.gravity)

  self.update = function(self, dt)
    self.anim:update(dt)
    if self.vel.x ~= 0 then 
      self.anim:changeAnim('walk', self.vel.x > 0 and 'right' or 'left')
      self.anim:modifyDelay(math.abs(1 / self.vel.x))
    else
      self.anim:changeAnim('stand', nil)
    end

    self.vel.x = utils.clamp(-self.maxVel.x, self.vel.x, self.maxVel.x)
    self.vel.y = utils.clamp(-self.maxVel.y, self.vel.y, self.maxVel.y)

    self.pos:add(self.vel)

    self:updateRect()
  end

  self.updateRect = function(self)
    self.rect.x, self.rect.y = self.pos.x, self.pos.y
  end

  self.global.logger:add('Left', '0')
  self.global.logger:add('Right', '0')
  self.global.logger:add('Up', '0')
  self.global.logger:add('Down', '0')

  self.collide = function(self, map)
    local collideMap, countMap = map:collides(self.rect, self.vel)
    self.global.logger:update('Left', collideMap.left .. ' ' .. countMap.left)
    self.global.logger:update('Right', collideMap.right .. ' ' .. countMap.right)
    self.global.logger:update('Up', collideMap.up .. ' ' .. countMap.up)
    self.global.logger:update('Down', collideMap.down .. ' ' .. countMap.down)
    if collideMap.down > 1 then
      self.pos.y = self.pos.y - collideMap.down
      --self.vel.y = 0
      self.grounded = true
    else
      --self.vel:add(self.gravity)
      self.grounded = false
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
    --utils.printTable(collideMap)
  end

  self.draw = function(self, x, y)
    self.anim:draw(x or self.pos.x, y or self.pos.y)
    self.rect:draw('line', x, y)
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

