module(..., package.seeall)

require 'lib.utils';utils = lib.utils
require 'lib.vector';vector = lib.vector

function Collider(offset)
  local self = {
    elems = {},
    offset = offset or 0
  }

  self.elems = {}

  self.rectrect = function(self, rect1, rect2, offset) 
    local leftA, rightA, topA, bottomA = rect1.x + offset, rect1.x + rect1.width - offset * 2, rect1.y + offset, rect1.y + rect1.height - offset * 2
    local leftB, rightB, topB, bottomB = rect2.x + offset, rect2.x + rect2.width - offset * 2, rect2.y + offset, rect2.y + rect2.height - offset * 2
    local centerXA, centerYA, centerXB, centerYB = rect1.x + rect1.width/2, rect1.y + rect1.height/2, rect2.x + rect2.width/2, rect2.y + rect2.height/2

    if leftA > rightB then return nil end
    if rightA < leftB then return nil end
    if topA > bottomB then return nil end
    if bottomA < topB then return nil end

    local side = ''
    local depth = nil
    if math.abs(centerXA - centerXB) > math.abs(centerYA - centerYB) then
      if centerXA < centerXB then side = 'left'
      else side = 'right' end
      if math.abs(rightA - leftB) < math.abs(leftA - rightB) then
        depth = rightA - leftB
      else
        depth = leftA - rightB
      end
    else
      if centerYA < centerYB then side = 'top'
      else side = 'bottom' end
      if math.abs(topA - bottomB) < math.abs(bottomA - topB) then
        depth = topA - bottomB
      else
        depth = bottomA - topB
      end
    end

    --[[
    local hori = nil
    if math.abs(rightA - leftB) < math.abs(leftA - rightB) then
      hori = rightA - leftB
    else
      hori = leftA - rightB
    end

    local vert = nil
    if math.abs(topA - bottomB) < math.abs(bottomA - topB) then
      vert = topA - bottomB
    else
      vert = bottomA - topB
    end
    --]]

    return depth, side
  end

  self.register = function(self, object, shapes, functions)
    assert(type(object) == 'table' and type(shapes) == 'table' and #shapes > 0 and type(functions) == 'table', 'Invalid types passed to register')

    --print(object, object.type, object.subtype)

    table.insert(self.elems, ColliderElement(object, shapes, functions))
  end

  self.deregister = function(self, object)
    for i = #self.elems, 1, -1 do
      if self.elems[i].object == object then
        table.remove(self.elems, i)
        return
      end
    end
  end

  self.update = function(self, dt)
    for i = 1, #self.elems do
      local elem = self.elems[i]
      for j = i, #self.elems do
        local collideElem = self.elems[j]
        local elemToCollideElemSubTypeFunc = elem.collidesWith[collideElem.subtype]
        local elemToCollideElemTypeFunc = elem.collidesWith[collideElem.type]
        local collideElemToElemSubTypeFunc = collideElem.collidesWith[elem.subtype]
        local collideElemToElemTypeFunc = collideElem.collidesWith[elem.type]
        if elem ~= collideElem and (elemToCollideElemTypeFunc or collideElemToElemTypeFunc or elemToCollideElemSubTypeFunc or collideElemToElemSubTypeFunc) then
          local collideDepth, collideSide = self[elem.shapes[1].type .. collideElem.shapes[1].type](self, elem.shapes[1], collideElem.shapes[1], self.offset)
          if collideDepth and collideSide then
            if elemToCollideElemTypeFunc then elemToCollideElemTypeFunc(elem.object, collideElem.object, collideDepth, collideSide) end
            if elemToCollideElemSubTypeFunc then elemToCollideElemSubTypeFunc(elem.object, collideElem.object, collideDepth, collideSide) end
            if collideElemToElemTypeFunc then collideElemToElemTypeFunc(collideElem.object, elem.object, collideDepth, collideSide) end
            if collideElemToElemSubTypeFunc then collideElemToElemSubTypeFunc(collideElem.object, elem.object, collideDepth, collideSide) end
          end
        end
      end
    end
  end

  return self
end

local types = {}
local function nextId(objType)
  types[objType] = (types[objType] or 0) + 1
  return types[objType]
end

function ColliderElement(object, shapes, functions)
  local self = {
    object = object,
    shapes = shapes,
    collidesWith = functions, 
    type = object.type,
    subtype = object.subtype,
    id = (object.subtype or object.type) .. nextId(object.subtype or object.type)
  }

  return self
end

