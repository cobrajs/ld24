module(..., package.seeall)

require 'utils'
require 'vector'
require 'shapes'
require 'animated'

function Item(global, startx, starty)
  local self = {
    type = 'item',
    subtype = '',
    image = nil,
    rect = nil,
    vel = vector.Vector:new(0, 0),
    global = global
  }

  return self
end

function Food(global, startx, starty)
  local self = Item(global, startx, starty)

  self.type = 'food'

  self.attribs = {
    fat = 5,
    protein = 5,
    fiber = 5,
    spicy = 5
  }


  self.anim = animated.Animated('gfx/food.lua')
  self.width = self.anim.image.tilewidth
  self.height = self.anim.image.tileheight

  self.rect = shapes.Rect(startx, starty, self.width, self.height)

  self.update = function(self, dt)
    self.anim:update(dt)
  end

  self.draw = function(self, x, y)
    self.anim:draw(x or self.rect.x, y or self.rect.y)
  end

  return self
end

function Cake(global, startx, starty)
  local self = Food(global, startx, starty)

  self.subtype = 'cake'
  self.attribs.fat = 10
  self.attribs.protien = 0
  self.attribs.fiber = 0
  self.attribs.spicy = 0

  self.anim:changeAnim('cake', 'normal')

  return self
end

function Carrot(global, startx, starty)
  local self = Food(global, startx, starty)

  self.subtype = 'carrot'
  self.attribs.fat = 0
  self.attribs.protien = 0
  self.attribs.fiber = 10
  self.attribs.spicy = 0

  self.anim:changeAnim('carrot', 'normal')

  return self
end

function Chicken(global, startx, starty)
  local self = Food(global, startx, starty)

  self.subtype = 'chicken'
  self.attribs.fat = 0
  self.attribs.protien = 10
  self.attribs.fiber = 0
  self.attribs.spicy = 0

  self.anim:changeAnim('chicken', 'normal')

  return self
end
