local function addState(start, fin, len, delayLen)
  return {start = start, fin = fin, len = len, delayLen = delayLen}
end

return {
  tilesx = 8, tilesy = 8,
  image = {source = "gfx/small_enemies.png", width = 128, height = 128},
  anims = {
    blue = {
      right = addState(1,2,1,0.5),
      left = addState(9,10,1,0.5)
    }
  }
}
