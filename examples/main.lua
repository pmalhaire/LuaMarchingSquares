local layers = nil

function love.load()
  package.path = package.path .. ";../src/?.lua"
  --package.path = package.path .. ";src/?.lua"
  local luams = require("luams")
  luams.setVerbose(false)  
  
  local data = {
    {1, 1, 1, 1, 1},
    {1, 2, 3, 2, 1},
    {1, 3, 3, 3, 1},
    {1, 2, 3, 2, 1},
    {1, 1, 1, 1, 1},
  }
  local levels = {2, 2.5, 3, 4}  
  
  layers = luams.getContour(data, levels)
  
  for l=1, #layers do
    for p=1, #layers[l] do
      for n=1, #layers[l][p], 2 do
        --print(layers[l][p][n], layers[l][p][n+1])
        layers[l][p][n] = layers[l][p][n] * 32
        layers[l][p][n+1] = layers[l][p][n+1] * 32
      end
    end
  end
  
end

function love.update(dt)
end

function love.draw()
  for l=1, #layers do
    for p=1, #layers[l] do
      love.graphics.line(layers[l][p])
    end
  end    
end
