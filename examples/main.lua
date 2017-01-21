local canvas = nil
local tileSize = 64

local function drawGrid()
  love.graphics.setColor(0, 63,0, 255)
  
  local w = math.ceil( love.graphics.getWidth() / tileSize )
  local h = math.ceil( love.graphics.getHeight() / tileSize )
  local width, height = love.graphics.getDimensions()  
  for r=0, w do love.graphics.line(r * tileSize, 0, r * tileSize, height) end  
  for c=0, h do love.graphics.line(0, c * tileSize, width, c * tileSize) end
end

local function drawIsolines(layers)
  love.graphics.setColor(0, 127,0, 255)
  
  for l=1, #layers do
    for p=1, #layers[l] do love.graphics.line(layers[l][p]) end
  end
end

function love.draw()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(canvas)
end

function love.load()
  package.path = package.path .. ";../src/?.lua"
  --package.path = package.path .. ";src/?.lua"
  local luams = require("luams")
  --luams.setVerbose(true)
  --luams.setInterpolate(false)
  
  local data = {
    {1, 1, 1, 1, 1},
    {1, 2, 3, 2, 1},
    {1, 3, 3, 3, 1},
    {1, 2, 3, 2, 1},
    {1, 1, 1, 1, 1},
  }
  local levels = {1, 1.4, 1.8, 2.2, 2.6}    
  
  layers = luams.getContour(data, levels)
    
  for l=1, #layers do
    for p=1, #layers[l] do
      for n=1, #layers[l][p], 2 do
        local p = layers[l][p]        
        p[n], p[n+1] = p[n] * tileSize, p[n+1] * tileSize        
      end
    end
  end
  
  canvas = love.graphics.newCanvas()
  love.graphics.setCanvas(canvas)
  drawGrid()
  drawIsolines(layers)
  love.graphics.setCanvas()
end

--function love.update(dt) end