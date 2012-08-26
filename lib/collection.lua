module(..., package.seeall)

require 'utils'
require 'vector'

function Collection(global)
  local self = {
    global = global,
    elems = {}
  }

  self.addFromLayer = function(self, tileset, layer, callback)
    assert(type(callback) == 'function', 'Callback must be a function')
    local firstgid = tileset.firstgid
    local tileWidth = tileset.tilewidth
    local tileHeight = tileset.tileheight
    for y, yL in ipairs(layer.grid) do
      for x, tileNum in ipairs(yL) do
        tileNum = tonumber(tileNum)
        local baseTile = tonumber(1 + tileNum - firstgid)
        if tileNum > 0 then
          self:add(callback(baseTile, (x-1) * tileWidth, (y-1) * tileHeight))
        end
      end
    end
  end

  self.add = function(self, item)
    table.insert(self.elems, item)
    return item
  end

  self.update = function(self, dt)
    for i=#self.elems, 1, -1 do
      local v = self.elems[i]
      v:update(dt)
      if v.collide then
        v:collide(self.global.map)
      end
      if v.remove then
        self.global.collider:deregister(v)
        table.remove(self.elems, i)
      end
    end
  end

  self.draw = function(self)
    for _, v in ipairs(self.elems) do
      v:draw(self.global.camera:drawOther(v.rect.x, v.rect.y))
    end
  end

  self.empty = function(self)
    for i=#self.elems, 1, -1 do
      self.global.collider:deregister(self.elems[i])
      table.remove(self.elems, i)
    end
  end

  return self
end
