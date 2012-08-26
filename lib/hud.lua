module(..., package.seeall)

require 'utils'

function HUD(global, position, depth)
  local self = {
    global = global, position = position, depth = depth,
    canvas = nil, x = 0, y = 0, width = 0, height = 0
  }
  
  local width, height = love.graphics.getWidth(), love.graphics.getHeight()

  if position == 'top' then
    self.x, self.y = 0, 0
    self.width, self.height = width, self.depth
  elseif position == 'bottom' then
    self.x, self.y = 0, height - self.depth
    self.width, self.height = width, self.depth
  elseif position == 'left' then
    self.x, self.y = 0, 0
    self.width, self.height = depth, height
  elseif position == 'right' then
    self.x, self.y = width - depth, 0
    self.width, self.height = depth, height
  end

  self.canvas = love.graphics.newCanvas(self.width, self.height)

  self.background = {100, 100, 100, 255}
  love.graphics.setCanvas(self.canvas)
  love.graphics.setColor(unpack(self.background))
  love.graphics.rectangle('fill', 0, 0, self.width, self.height)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setCanvas()

  self.draw = function(self)
    if not self.cleared then
      love.graphics.draw(self.canvas, self.x, self.y)
    end
  end

  self.setText = function(self, text)
    if self.currentText ~= text then 
      self.currentText = text
      love.graphics.setCanvas(self.canvas)
      love.graphics.printf(text, 0, 0, self.width, 'left')
      love.graphics.setCanvas()
      self.cleared = false
    end
  end

  self.clear = function(self)
    if not self.cleared then
      self.currentText = ''
      love.graphics.setCanvas(self.canvas)
      love.graphics.setColor(unpack(self.background))
      love.graphics.rectangle('fill', 0, 0, self.width, self.height)
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.setCanvas()
      self.cleared = true
    end
  end

  return self
end
