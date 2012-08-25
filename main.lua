--
-- Ludum Dare 24 Entry
--

-- Make it so I can store libraries in the lib folder
package.path = package.path .. ';./lib/?.lua'

function love.load()

end

function love.update(dt)

end

function love.draw()

end

function love.keypressed(key)
  if key == 'escape' or key == 'q' then
    love.event.push('quit')
  end
end
