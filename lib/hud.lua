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

  love.graphics.setCanvas(self.canvas)
  love.graphics.setColor(100, 255, 100, 255)
  love.graphics.rectangle('fill', 0, 0, self.width, self.height)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setCanvas()

  self.draw = function(self)
    love.graphics.draw(self.canvas, self.x, self.y)
  end

  return self
end
