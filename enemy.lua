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

types = {[1]='BlueEnemy'}

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
  self.vel:add(self.global.gravity)
  
  self.collisionFuncs = {
    player = function(self, player, collideDepth, collideSide) 
      if collideSide == 'top' then 
        if player.attribs.weight > 1 then
          self.remove = true
        end
        player.jumping = true
        player.vel.y = -4
      end
    end,
    blue = function(self, blue) 
      self.vel.x = self.vel.x * -1
    end
  }

  self.update = function(self, dt)
    self.anim:update(dt)

    self.anim:changeAnim(nil, self.vel.x > 0 and 'right' or 'left')

    self.rect:add(self.vel)
  end

  self.collide = function(self, map)
    local collideMap, countMap = map:collides(self.rect, self.vel)

    if collideMap.down > 0 then
      collideMap.left = 0
      collideMap.right = 0
      self.rect.y = self.rect.y - collideMap.down
      self.vel.y = 0
    else
      self.vel:add(self.global.gravity)
    end
    if collideMap.left > 0 then 
      self.rect.x = self.rect.x - collideMap.left
      self.vel.x = self.vel.x * -1
    elseif collideMap.right > 0 then
      self.rect.x = self.rect.x - collideMap.right
      self.vel.x = self.vel.x * -1
    end
  end

  self.draw = function(self, x, y)
    self.anim:draw(x or self.rect.x, y or self.rect.y)
    --self.rect:draw('line', x, y)
  end

  return self
end
