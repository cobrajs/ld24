module(..., package.seeall)

--
-- Loads Tiled maps
--
require 'utils' require 'xml'

function LoadMapLove(mapname)
  assert(type(love) ~= nil, 'Love2D is required for this function')
  local parsedXML = xml.LoadXML(love.filesystem.read(mapname))
  return ParseMap(parsedXML)
end

function LoadMapLua(mapname)
  local f = io.open(mapname)
  local parsedXML = xml.LoadXML(f:read('*a'))
  f:close()
  return ParseMap(parsedXML)
end

function ParseMap(parsedXML)
  local map = {}
  local tilesets = xml.FindAllInXML(parsedXML, 'tileset')
  map.tilesets = ParseTilesets(tilesets)
  local layers = xml.FindAllInXML(parsedXML, 'layer')
  map.layers = {}
  for i, v in pairs(layers) do
    table.insert(map.layers, ParseLayer(v))
  end
  local objectgroups = xml.FindAllInXML(parsedXML, 'objectgroup')
  map.objectgroups = {}
  for i, v in pairs(objectgroups) do
    table.insert(map.objectgroups, ParseObjectGroup(v))
  end
  map.tileWidth = map.tilesets.images[1].tilewidth
  map.tileHeight = map.tilesets.images[1].tileheight
  map.width = map.layers[1].width * map.tilesets.images[1].tilewidth
  map.height = map.layers[1].height * map.tilesets.images[1].tileheight
  map.FindLayer = FindLayer
  map.FindObject = FindObject

  local getFrom = function(side, rect, x, y, width, height)
    if side == 'up' then
      return -rect.y + y * height + height
    elseif side == 'down' then
      return rect.y + rect.height - y * height
    elseif side == 'left' then
      return -rect.x + x * width + width
    elseif side == 'right' then
      return rect.x + rect.width - x * width
    end
  end

  map.collides = function(self, rect, dir)
    local blank = '1'
    local collideLayer = self.CollideLayer
    local ignoreCorners = rect.width >= self.tileWidth * 2
    local minx = math.floor((rect.x) / self.tileWidth)
    local miny = math.floor((rect.y) / self.tileHeight)
    local maxx = math.floor((rect.x + rect.width) / self.tileWidth)
    local maxy = math.floor((rect.y + rect.height) / self.tileHeight)
    local ret = {up = 0, down = 0, left = 0, right = 0}
    local count = {up = 0, down = 0, left = 0, right = 0}
    for y = miny, maxy do
      for x = minx, maxx do
        if collideLayer.grid[y + 1][x + 1] ~= blank and (not ignoreCorners or not ((x == minx and y == miny) or (x == minx and y == maxy) or (x == maxx and y == miny) or (x == maxx and y == maxy))) then 
          --local isCorner = (x == minx and y == miny) or (x == minx and y == maxy) or (x == maxx and y == miny) or (x == maxx and y == maxy)
          --if ignoreCorners or not isCorner then
          if maxx - minx <= 1 and maxy - miny <= 1 then
            if x == minx and y == miny then
              ret.up = getFrom('up', rect, x, y, self.tileWidth, self.tileHeight)
              count.up = count.up + 1
              ret.left = getFrom('left', rect, x, y, self.tileWidth, self.tileHeight)
              count.left = count.left + 1
            elseif x == minx and y == maxy then
              ret.down = getFrom('down', rect, x, y, self.tileWidth, self.tileHeight)
              count.down = count.down + 1
              ret.left = getFrom('left', rect, x, y, self.tileWidth, self.tileHeight)
              count.left = count.left + 1
            elseif x == maxx and y == miny then
              ret.up = getFrom('up', rect, x, y, self.tileWidth, self.tileHeight)
              count.up = count.up + 1
              ret.right = getFrom('right', rect, x, y, self.tileWidth, self.tileHeight)
              count.right = count.right + 1
            elseif x == maxx and y == maxy then
              ret.down = getFrom('down', rect, x, y, self.tileWidth, self.tileHeight)
              count.down = count.down + 1
              ret.right = getFrom('right', rect, x, y, self.tileWidth, self.tileHeight)
              count.right = count.right + 1
            end
          else
            local side = 
              y == miny and 'up' or
              y == maxy and 'down' or
              x == minx and 'left' or
              x == maxx and 'right' or nil

            if side then
              ret[side] = getFrom(side, rect, x, y, self.tileWidth, self.tileHeight)
              count[side] = count[side] + 1
              --print(side, x, y)
            end
          end
            --[[
          else
            if x == minx and y == miny then
              ret.up = getFrom('up', rect, x, y, self.tileWidth, self.tileHeight)
              count.up = count.up + 1
              ret.left = getFrom('left', rect, x, y, self.tileWidth, self.tileHeight)
              count.left = count.left + 1
            elseif x == minx and y == maxy then
              ret.down = getFrom('down', rect, x, y, self.tileWidth, self.tileHeight)
              count.down = count.down + 1
              ret.left = getFrom('left', rect, x, y, self.tileWidth, self.tileHeight)
              count.left = count.left + 1
            elseif x == maxx and y == miny then
              ret.up = getFrom('up', rect, x, y, self.tileWidth, self.tileHeight)
              count.up = count.up + 1
              ret.right = getFrom('right', rect, x, y, self.tileWidth, self.tileHeight)
              count.right = count.right + 1
            elseif x == maxx and y == maxy then
              ret.down = getFrom('down', rect, x, y, self.tileWidth, self.tileHeight)
              count.down = count.down + 1
              ret.right = getFrom('right', rect, x, y, self.tileWidth, self.tileHeight)
              count.right = count.right + 1
            end
          end
          --]]
        end
      end
    end

    if ignoreCorners then
      -- Top Left Block
      local x, y = minx, miny
      if collideLayer.grid[y + 1][x + 1] ~= blank then
        if count.left > count.up then 
          ret.left = getFrom('left', rect, x, y, self.tileWidth, self.tileHeight)
        elseif count.left < count.up then
          ret.up = getFrom('up', rect, x, y, self.tileWidth, self.tileHeight)
        else
          ret.left = getFrom('left', rect, x, y, self.tileWidth, self.tileHeight)
          ret.up = getFrom('up', rect, x, y, self.tileWidth, self.tileHeight)
        end
      end
      -- Bottom Left Block
      x, y = minx, maxy
      if collideLayer.grid[y + 1][x + 1] ~= blank then
        if count.left > count.down then 
          ret.left = getFrom('left', rect, x, y, self.tileWidth, self.tileHeight)
        elseif count.left < count.down then
          ret.down = getFrom('down', rect, x, y, self.tileWidth, self.tileHeight)
        else
          ret.left = getFrom('left', rect, x, y, self.tileWidth, self.tileHeight)
          ret.down = getFrom('down', rect, x, y, self.tileWidth, self.tileHeight)
        end
      end
      -- Top Right Block
      x, y = maxx, miny
      if collideLayer.grid[y + 1][x + 1] ~= blank then
        if count.right > count.up then 
          ret.right = getFrom('right', rect, x, y, self.tileWidth, self.tileHeight)
        elseif count.right < count.up then
          ret.up = getFrom('up', rect, x, y, self.tileWidth, self.tileHeight)
        else
          ret.right = getFrom('right', rect, x, y, self.tileWidth, self.tileHeight)
          ret.up = getFrom('up', rect, x, y, self.tileWidth, self.tileHeight)
        end
      end
      -- Bottom Right Block
      x, y = maxx, maxy
      if collideLayer.grid[y + 1][x + 1] ~= blank then
        if count.right > count.down then 
          ret.right = getFrom('right', rect, x, y, self.tileWidth, self.tileHeight)
        elseif count.right < count.down then
          ret.down = getFrom('down', rect, x, y, self.tileWidth, self.tileHeight)
        else
          ret.right = getFrom('right', rect, x, y, self.tileWidth, self.tileHeight)
          ret.down = getFrom('down', rect, x, y, self.tileWidth, self.tileHeight)
        end
      end
    else
      local hori = count.left + count.right
      local vert = count.up + count.down
      if hori == 1 and count.up == 1 and count.down == 1 then ret.up, ret.down = 0, 0 end
      if count.down == 2 and count.left == 1 and count.right == 1 then ret.left, ret.right = 0, 0 end
      if count.down > count.up then ret.up = 0 end
      if count.up > count.down then ret.down = 0 end
      if count.left > count.right then ret.right = 0 end
      if count.right > count.left then ret.left = 0 end
    end

    if ret.left > 0 and dir.x >= 0 then ret.left = 0 end
    if ret.right > 0 and dir.x <= 0 then ret.right = 0 end
    if ret.up > 0 and dir.y >= 0 then ret.up = 0 end
    if ret.down > 0 and dir.y <= 0 then ret.down = 0 end

    return ret, count
  end

  return map
end

function gt(n) return n < 0 and 0 or n end

function ParseObjectGroup(objgrp)
  assert(type(objgrp) == 'table' and objgrp.label == 'objectgroup', "Passed something that is not an objectgroup")
  local a = {}
  utils.CopyXargs(a, objgrp.xarg)
  local objects = xml.FindAllInXML(objgrp, 'object')
  a.objects = {}
  for i,v in ipairs(objects) do
    a.objects[i] = v.xarg
  end
  return a
end

function ParseTilesets(tilesets)
  local a = {}
  a.images = {}
  a.tiles = {}
  for i,v in pairs(tilesets) do
    local gid = tonumber(v.xarg.firstgid)
    local image = xml.FindInXML(v, 'image')
    assert(type(image) == 'table', "Problem with tileset image")
    local img = {}
    utils.CopyXargs(img, image.xarg)
    utils.CopyXargs(img, v.xarg)
    img.firstgid = gid
    img.trans = utils.RGBToTable(img.trans)
    img.tileX, img.tileY = img.width/img.tilewidth, img.height/img.tileheight
    for y=1,img.tileY do
      for x=1,img.tileX do
        local tmp = {}
        tmp.image = img
        tmp.x = x
        tmp.y = y
        a.tiles[gid] = tmp
        gid = gid + 1
      end
    end
    table.insert(a.images, img)
  end
  return a
end

function ParseLayer(layer)
  assert(type(layer) == 'table' and layer.label == 'layer', "Passed something that is not a layer")
  local a = {}
  utils.CopyXargs(a, layer.xarg)
  a.grid = {}
  for y,yd in ipairs(string.split(layer[1][1], '\n')) do
    if utils.hasNum(yd) then
      local temp = {}
      for x, xd in ipairs(string.split(yd, ',')) do
        if utils.isNum(xd) then
          table.insert(temp, xd)
        end
      end
      table.insert(a.grid, temp)
    end
  end
  assert(#a.grid == a.height, "Invalid map height (Expected: "..a.height.."; Got: "..#a.grid..")")
  assert(#a.grid[1] == a.width, "Invalid map width (Expected: "..a.width.."; Got: "..#a.grid[1]..")")
  return a
end

function pt(t,o) 
  for i,j in pairs(t) do print(i,o and j[o] or j) end 
end

function FindLayer(map, layerName)
  for _,layer in ipairs(map.layers) do
    if layer.name and layer.name:lower() == layerName:lower() then
      return layer
    end
  end
  return nil
end

function FindObject(map, objType, objName)
  for i,objgroup in ipairs(map.objectgroups) do
    for _,obj in ipairs(objgroup.objects) do
      if obj.name and obj.type and obj.name:lower() == objName:lower() and obj.type:lower() == objType:lower() then
        return obj
      end
    end
  end
  return nil
end


--
-- Iterates over tiles visible in the current camera view
--
function tileIter(camera, layer, image)
  local minx = math.floor(-camera.x / image.tilewidth)
  local miny = math.floor(-camera.y / image.tileheight)
  local maxx = math.floor(minx + camera.width / image.tilewidth) + 1
  local maxy = math.floor(miny + camera.height / image.tileheight) + 1
  local x = minx - 1
  local y = miny
  return function()
    x = x + 1
    if x > maxx then
      y = y + 1
      x = minx
      if y > maxy then
        return nil
      end
    end
    if y < 0 or x < 0 or x >= layer.width or y >= layer.height then
      return 0, camera.x + x * image.tilewidth, camera.y + y * image.tileheight
    else 
      return layer.grid[y+1][x+1], camera.x + x * image.tilewidth, camera.y + y * image.tileheight
    end
  end
end
