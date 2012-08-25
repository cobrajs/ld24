return {
  tilesx = 8, tilesy = 8,
  image = {source = "gfx/small_enemies.png", width = 128, height = 128},
  anims = {
    walk = {
      right = addState(1,2,1,0.5),
      left = addState(9,10,1,0.5)
    }
  }
}
