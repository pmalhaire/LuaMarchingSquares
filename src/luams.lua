local LEFT, RIGHT, TOP, BOTTOM, NONE = "LEFT", "RIGHT", "TOP", "BOTTOM", "NONE"
local ts, hts = 1, 0.5
local verbose= false

local function log(...) if verbose then print(...) end end

local function clearTile(tile) if tile.cval ~= 5 and tile.cval ~= 10 and tile.cval ~= 15 then tile.cval = 15 end end

local function getXY(r, c, side) --lua collections start at 1, x y start at 0    
  if     side == TOP    then return (c -1) + hts, (r -1)
  elseif side == LEFT   then return (c -1)      , (r -1) + hts
  elseif side == RIGHT  then return (c -1) + ts , (r -1) + hts
  elseif side == BOTTOM then return (c -1) + hts, (r -1) + ts end
end

local function buildBitMask(data, levels)
  local rows= #data - 1
  local cols= #data[1] - 1
  local length = #levels    
  local layers = {}
  for i=1, length do --Create layer    
    layers[i] = {}
    for r=1, rows do --layer, row      
      layers[i][r] = {}
      for c=1, cols do --buffering                      
        local tl = data[r  ][c  ]
        local tr = data[r  ][c+1]
        local br = data[r+1][c+1]
        local bl = data[r+1][c  ]
        
        local tile_id = 0
        local threshold = levels[i]
        if tl < threshold then tile_id = tile_id + 8 end
        if tr < threshold then tile_id = tile_id + 4 end      
        if br < threshold then tile_id = tile_id + 2 end
        if bl < threshold then tile_id = tile_id + 1 end
                        
        if tile_id ~= 0 and tile_id ~= 15 then --store no Trivial  
          local flipped = nil 
          if tile_id == 5 or tile_id == 10 then --
            local avg = (tl + tr + br + bl) / 4
            if avg > threshold then flipped = true end
          end                    
          layers[i][r][c] = {id= tile_id, cval= tile_id, flipped= flipped} --layer, row, cell
        end 
      end
    end
  end  
  return {levels= levels, length= length, layers= layers, rows= rows, cols= cols}
end

local function firstSide( tile, prev )
  local id = tile.cval
  if      id == 1 or id == 3  or id == 7              then return LEFT
  elseif  id == 2 or id == 6  or id == 14             then return BOTTOM
  elseif  id == 4 or id == 11 or id == 12 or id == 13 then return RIGHT
  elseif  id == 8 or id == 9                          then return TOP
  elseif  id == 5 then
    if prev == LEFT then return RIGHT elseif prev == RIGHT then return LEFT end
  elseif  id == 10 then
    if prev == BOTTOM then return TOP elseif prev == TOP then return BOTTOM end
  end
end

local function secondSide( tile, prev )
  local id = tile.cval
  if      id == 8 or id == 12 or id == 14 then return LEFT
  elseif  id == 1 or id == 9  or id == 13 then return BOTTOM
  elseif  id == 2 or id == 3  or id == 11 then return RIGHT
  elseif  id == 4 or id == 6  or id == 7  then return TOP
  elseif  id == 5 then
    if prev == LEFT then
      if tile.flipped then return BOTTOM else return TOP end
    elseif prev == RIGHT then 
      if tile.flipped then return TOP else return BOTTOM end
    end
  elseif id == 10 then
    if prev == BOTTOM then
      if tile.flipped then return RIGHT else return LEFT end
    elseif prev == TOP then 
      if tile.flipped then return LEFT else return RIGHT end
    end
  end
end

local function tracePath(bitMaskLayers, l, r1, c1)
  local layer = bitMaskLayers.layers[l]
  local currentCell = layer[r1][c1]
  local rows = bitMaskLayers.rows
  local path = {}
  local ndx = 1
  
  -- push initial segment
  local edge = firstSide(currentCell, NONE)
  path[ndx], path[ndx+1]= getXY(r1, c1, edge)            
  ndx = ndx + 2
  
  edge = secondSide(currentCell, edge)
  path[ndx], path[ndx+1]= getXY(r1, c1, edge)
  ndx = ndx + 2
  log("Start " .. firstSide(currentCell, NONE) .. " to " .. secondSide(currentCell, edge), " id: " .. currentCell.id .. " row: " ..  r1 .. " col: " .. c1)
  
  clearTile(currentCell)
  
  local r2, c2 = r1, c1
  -- now walk arround the enclosed area in clockwise-direction                            
  if     edge == LEFT   then c2 = c2 - 1
  elseif edge == RIGHT  then c2 = c2 + 1
  elseif edge == BOTTOM then r2 = r2 + 1
  elseif edge == TOP    then r2 = r2 - 1 
  end
  local closed = true
  while r2 >= 1 and c2 >= 1 --and r2 < rows 
  and (r1 ~= r2 or c1 ~= c2) do
    currentCell = layer[r2] and layer[r2][c2]
    if not currentCell then 
      print(r2 .. " " .. c2 .. " is undefined, stopping path!")
      break
    end
    if currentCell.cval == 15 or currentCell.cval == 0 then
      return { path= path, info= "mergeable" }
    end
    edge = secondSide(currentCell, edge)
    path[ndx], path[ndx+1]= getXY(r2, c2, edge)              
    ndx = ndx + 2            
    log("  path to " .. edge  , " id: " .. currentCell.id .. " row: " ..  r2 .. " col: " .. c2)
    
    clearTile(currentCell)            
    if     edge == LEFT   then c2 = c2 - 1
    elseif edge == RIGHT  then c2 = c2 + 1
    elseif edge == BOTTOM then r2 = r2 + 1
    elseif edge == TOP    then r2 = r2 - 1 
    end     
  end          
  return { path= path, info= "closed" }
end

local function lineTracer(bitMaskLayers)
  local rows= bitMaskLayers.rows
  local cols= bitMaskLayers.cols
  local length= bitMaskLayers.length
  local layers= bitMaskLayers.layers
  local paths = {}
  local epsilon = 1e-7
  
  for l=1, length do
    paths[l] = {}
    local path_idx = 1
    for r1=1, rows do      
      for c1=1, cols do        
        local currentCell = layers[l][r1] and layers[l][r1][c1]
        if  currentCell and
            currentCell.cval ~= 15 and currentCell.cval ~= 0 and  --not isTrivial
            currentCell.cval ~= 5 and currentCell.cval ~= 10 then --not isSaddle
          local p= tracePath(bitMaskLayers, l, r1, c1)
          local merged = false
          if p.info == "mergeable" then 
            log("mergeable")
            local x, y = p.path[#p.path-1], p.path[#p.path]
            for k= path_idx - 1, 1, -1 do              
              if math.abs(paths[l][k][1] - x) <= epsilon and math.abs(paths[l][k][2] - y) <= epsilon then                
                for m=#p.path -2, 1, -2 do                  
                  log("insert path " , k, m)	
                  table.insert(paths[l][k], 1, p.path[m])
                  table.insert(paths[l][k], 1, p.path[m-1])
                end                
                merged = true
                break
              end
            end
          end
          if not merged then
            paths[l][path_idx] = p.path
            path_idx = path_idx + 1
          end          
        end
      end      
    end
  end
  return paths
end

local MarchingSquares = {
  buildBitMask= buildBitMask,
  lineTracer= lineTracer,
  getContour= function(data, levels) return lineTracer(buildBitMask(data, levels)) end,
  setVerbose = function(value) verbose = value end,  
}

return MarchingSquares