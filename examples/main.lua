local canvas
local tileSize = 16
local layers
--used to select what is or net an object
local rgbThreshold = 200
local dtotal = 0
local dtrate = 1
local layer_index = 1


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
    for p=1, #layer do
      if #(layer[p]) >= 4 then
        love.graphics.line(layer[p])
      end
    end
end

function love.draw()
  love.graphics.setColor(255, 255, 255, 255)
  --draw the canvas if ready
  if canvas then love.graphics.draw(canvas) end
end



function love.load()
  --debug
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  package.path = package.path .. ";../src/?.lua"
  --package.path = package.path .. ";src/?.lua"
  local luams = require("luams")
  --luams.setVerbose(true)
  --luams.setInterpolate(false)
  
  --local data used to run the algorithm
  local data = {}

  local image_data = love.image.newImageData("test.jpg")
  -- the value used to tell that there is something
  -- here we assume the objects are black and the background is white
  local threshold = rgbThreshold * tileSize * tileSize

  --here we adapt the image size to be a multiple of the tileSize
  --it is a bit messy since we crop possibly a part of the image
  local w = math.floor((image_data:getWidth()-1)/tileSize)*tileSize - tileSize
  local h = math.floor((image_data:getHeight()-1)/tileSize)*tileSize - tileSize

  --we give each point of the grid a value
  for i=tileSize,h,tileSize do
    local iGrid = i/tileSize
    data[iGrid] = {}
    for j=tileSize,w,tileSize  do
        local jGrid = j/tileSize
        local r, g, b = 0, 0 ,0
        for l=i,i+tileSize-1 do
          for k=j,j+tileSize-1 do
            local rl, gl, bl = image_data:getPixel( k , l )
            r = r + rl
            g = g + gl
            b = b + bl
          end
        end
        local result
        if (r+g+b) < threshold then
          result = 3
        elseif (r+g+b) < 2*threshold then
          result=2
        elseif (r+g+b) < 3*threshold then
          result = 1
        else
          result = 0
        end
        data[iGrid][jGrid] = result
    end
  end
  
  --just a trick to get all levels for 1 to 3
  local levels = {}
  for i=.1,3,.1 do
    levels[#levels+1] = i
  end
  
  layers = luams.getContour(data, levels)
  
  -- reshape layers to the size of the window
  for l=1, #layers do
    for p=1, #layers[l] do
      for n=1, #layers[l][p], 2 do
        local p = layers[l][p]
        p[n], p[n+1] = p[n] * tileSize, p[n+1] * tileSize
      end
    end
  end
  --use this to debug after processing is made
  --if arg[#arg] == "-debug" then require("mobdebug").start() end
  
end

function love.update(dt)
  dtotal = dtotal + dt
  if dtotal > dtrate then
    local layer = layers[layer_index]
    
    if layer then
        canvas = love.graphics.newCanvas()
        love.graphics.setCanvas(canvas)
        drawGrid()
        drawIsoline(layer)
        love.graphics.setCanvas()
        layer_index = layer_index + 1
    else
      layer_index = 1
    end
    dtotal = 0
  end
end