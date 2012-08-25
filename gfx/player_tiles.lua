local function addState(start, fin, len, delayLen)
  return {start = start, fin = fin, len = len, delayLen = delayLen}
end

return {
  tilesx = 4, tilesy = 4,
  image = {source = "gfx/man.png", width = 128, height = 128},
  anims = {
    stand = {
      right = addState(1, 1, 0, 0.01),
      left = addState(5, 5, 0, 0.01)
    },
    walk = {
      right = addState(2, 4, 1, 0.1),
      left = addState(6, 8, 1, 0.1)
    },
    fall = {
      right = addState(9, 9, 0, 5),
      left = addState(13, 13, 0, 5)
    },
    jump = {
      right = addState(9, 9, 0, 5),
      left = addState(13, 13, 0, 5)
    }
  }
}
