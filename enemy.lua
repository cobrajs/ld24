module(..., package.seeall)

require 'utils'
require 'vector'
require 'tileset'
require 'shapes'
require 'animated'

function Enemy(global, startx, starty)
  local self = {
    type = 'enemy',
    subtype = '',
    image = nil,
    rect = nil,
    vel = vector.Vector:new(0, 0),
    global = global
  }

  return self
end

function BlueEnemy(global, startx, starty)
  local self = Enemy(global, startx, starty)

  self.subtype = 'blue'

  self.anim = animated.Animated('gfx/blue_enemy.lua')
  self.width = self.anim.image.tilewidth
  self.height = self.anim.image.tileheight

  self.rect = shapes.Rect(startx, starty, self.width, self.height)

  self.anim:changeAnim('walk', 'left')

  self.xMove = vector.Vector:new(1, 0)
  self.vel:add(self.xMove)

  self.update = function(self, dt)
    self.anim:update(dt)

    self.rect:add(self.vel)
  end

  self.collide = function(self, map)
    local collideMap = map:collides(self.rect, self.vel, true)
    if collideMap.left > 0 then 
      self.pos.x = self.pos.x - collideMap.left
      self.vel.x = self.vel.x * -1
    elseif collideMap.right > 0 then
      self.pos.x = self.pos.x - collideMap.right
      self.vel.x = self.vel.x * -1
    end
  end

  self.draw = function(self, x, y)
    self.anim:draw(x or self.rect.x, y or self.rect.y)
  end

  return self
end
