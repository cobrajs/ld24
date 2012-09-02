local function addState(start, fin, len, delayLen)
  return {start = start, fin = fin, len = len, delayLen = delayLen}
end

return {
  tilesx = 8, tilesy = 8,
  image = "gfx/man.png",
  anims = {
    stand = {
      right = addState(1, 1, 0, 5),
      left = addState(9, 9, 0, 5)
    },
    walk = {
      right = addState(2, 4, 1, 0.1),
      left = addState(10, 12, 1, 0.1)
    },
    fall = {
      right = addState(17, 17, 0, 5),
      left = addState(25, 25, 0, 5)
    },
    jump = {
      right = addState(17, 17, 0, 5),
      left = addState(25, 25, 0, 5)
    }
  }
}
