module(..., package.seeall)

require 'utils'
require 'vector'

function Collider()
  local self = {}

  self.elems = {}

  self.functions = {}

  local id = 1

  self.rectrect = function(self, rect1, rect2) 
    local leftA, rightA, topA, bottomA = rect1.x, rect1.x + rect1.width, rect1.y, rect1.y + rect1.height
    local leftB, rightB, topB, bottomB = rect2.x, rect2.x + rect2.width, rect2.y, rect2.y + rect2.height

    if leftA > rightB then return false end
    if rightA < leftB then return false end
    if topA > bottomB then return false end
    if bottomA < topB then return false end

    return true
  end

  self.register = function(self, object, shapes, functions)
    assert(type(object) == 'table' and type(shapes) == 'table' and #shapes > 0 and type(functions) == 'table', 'Invalid types passed to register')

    print(object, object.type, object.subtype)

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
          if self[elem.shapes[1].type .. collideElem.shapes[1].type](self, elem.shapes[1], collideElem.shapes[1]) then
            if elemToCollideElemTypeFunc then elemToCollideElemTypeFunc(elem.object, collideElem.object) end
            if elemToCollideElemSubTypeFunc then elemToCollideElemSubTypeFunc(elem.object, collideElem.object) end
            if collideElemToElemTypeFunc then collideElemToElemTypeFunc(collideElem.object, elem.object) end
            if collideElemToElemSubTypeFunc then collideElemToElemSubTypeFunc(collideElem.object, elem.object) end
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

