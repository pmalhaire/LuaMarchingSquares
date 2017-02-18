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

local function drawIsoline(layer)
  love.graphics.setColor(0, 127,0, 255)
    for p=1, #layer do love.graphics.line(layer[p]) end
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
  
  local data = {}
  local image_data = love.image.newImageData("test.jpg")
  local thresold = 200
  for i=1,image_data:getHeight()-1 do
    local w = image_data:getWidth()-1
    data[i] = {}
    for j=1,w do
        local r, g, b = image_data:getPixel( j , i )
        if (r+g+b) < thresold then
          data[i][j]=3
        elseif (r+g+b) < 2*thresold then
          data[i][j]=2
         elseif (r+g+b) < thresold then
          data[i][j]=1
        else
          data[i][j]=0
        end
    end
  end
  
  local levels = {}
  for i=.1,3,1 do
    levels[#levels+1] = i
  end
  
  layers = luams.getContour(data, levels)   
  --debug
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  canvas = love.graphics.newCanvas()
  love.graphics.setCanvas(canvas)
  love.graphics.setCanvas()
end

local dtotal = 0 
local dtrate = .2
local layer_index = 1

function love.update(dt)
  dtotal = dtotal + dt
  if dtotal > dtrate then
    local layer = layers[layer_index]
    
    if layer then
        canvas = love.graphics.newCanvas()
        love.graphics.setCanvas(canvas)
        drawIsoline(layer)
        love.graphics.setCanvas()
        layer_index = layer_index + 1
    else
      layer_index = 1
    end
    dtotal = 0
  end
end