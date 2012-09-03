module(..., package.seeall)

require 'lib.utils';utils = lib.utils
require 'lib.vector';vector = lib.vector
require 'lib.shapes';shapes = lib.shapes
require 'lib.animated';animated = lib.animated

local baseRemoveDelay = 0.5

types = {'Cake', 'Carrot', 'Chicken', 'Chile'}

function Item(global, startx, starty)
  local self = {
    type = 'item',
    subtype = '',
    image = nil,
    rect = nil,
    vel = vector.Vector:new(0, 0),
    global = global, 

    remove = false,
    removing = false,
    removePercent = 0,
    removeDelay = 0
  }

  return self
end

function Food(global, startx, starty)
  local self = Item(global, startx, starty)

  self.type = 'food'

  self.attribs = {
    fat = 0,
    protein = 0,
    fiber = 0,
    spicy = 0
  }


  self.anim = animated.Animated('gfx/food.lua')
  self.width = self.anim.image.tilewidth
  self.height = self.anim.image.tileheight

  self.rect = shapes.Rect(startx, starty, self.width, self.height)

  self.update = function(self, dt)
    if not self.removing then 
      self.anim:update(dt)
    else
      self.removeDelay = self.removeDelay - dt
      if self.removeDelay > 0 then
        self.removePercent = self.removePercent + 10
      else
        self.removePercent = 0
        self.removeDelay = 0
        self.removing = false
        self.remove = true
      end
    end
  end

  self.draw = function(self, x, y)
    if self.removing then
      self.anim:drawSpecial(x or self.rect.x, y or self.rect.y, 1 + self.removePercent / 100, 1 + self.removePercent / 100, 255 * (100 - utils.clamp(0, self.removePercent, 100)) / 100)
    else
      self.anim:draw(x or self.rect.x, y or self.rect.y)
    end
  end

  self.startRemoval = function(self)
    if not self.removing then
      self.removing = true
      self.removeDelay = baseRemoveDelay
    end
  end

  return self
end

function Cake(global, startx, starty)
  local self = Food(global, startx, starty)

  self.subtype = 'cake'
  self.attribs.fat = 0.4
  self.attribs.protein = -0.2
  self.attribs.fiber = -0.2
  self.attribs.spicy = 0

  self.anim:changeAnim(self.subtype, 'normal')

  return self
end

function Carrot(global, startx, starty)
  local self = Food(global, startx, starty)

  self.subtype = 'carrot'
  self.attribs.fat = -0.2
  self.attribs.protein = -0.1
  self.attribs.fiber = 0.2
  self.attribs.spicy = 0

  self.anim:changeAnim(self.subtype, 'normal')

  return self
end

function Chicken(global, startx, starty)
  local self = Food(global, startx, starty)

  self.subtype = 'chicken'
  self.attribs.fat = -0.2
  self.attribs.protein = 0.3
  self.attribs.fiber = -0.1
  self.attribs.spicy = 0

  self.anim:changeAnim(self.subtype, 'normal')

  return self
end

function Chile(global, startx, starty)
  local self = Food(global, startx, starty)

  self.subtype = 'chile'
  self.attribs.fat = -0.2
  self.attribs.protein = 0
  self.attribs.fiber = 0.1
  self.attribs.spicy = 1

  self.anim:changeAnim(self.subtype, 'normal')

  return self
end
