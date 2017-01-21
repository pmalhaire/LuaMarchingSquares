--https://en.wikipedia.org/wiki/Marching_squares
describe("Marching squares", function()
  package.path = package.path .. ";../src/?.lua"
  local luams = require("luams")
  
  local data = {
    {1, 1, 1, 1, 1},
    {1, 2, 3, 2, 1},
    {1, 3, 3, 3, 1},
    {1, 2, 3, 2, 1},
    {1, 1, 1, 1, 1},
  }
  local levels = {2, 3}
  local bitMaskLayers = luams.buildBitMask(data, levels)
  local paths = luams.tracePaths(bitMaskLayers)
  local rows = bitMaskLayers.rows
  local cols = bitMaskLayers.cols
  local length = bitMaskLayers.length  
  
  it("Length", function()
    assert.same(rows, #data - 1)
    assert.same(cols, #data[1] - 1)
    assert.same(length, #levels)
  end)

  it("Bit mask", function()
    local output1 = {
      {13, 12, 12, 14},
      {9, nil,nil,  6},
      {9, nil,nil,  6},
      {11,  3,  3,  7},
    }
    
    local output2 = {
      {nil, 13, 14, nil},
      { 13,  8,  4,  14},
      { 11,  1,  2,   7},
      {nil, 11,  7, nil},
    }
    
    local ids = {}
    for i=1, length do
      ids[i] = {}
      for r=1, rows do
        ids[i][r] = {}
        for c=1, cols do
          if bitMaskLayers.layers[i][r][c] then
            ids[i][r][c] = bitMaskLayers.layers[i][r][c]._id
          end
        end
      end
    end
    
    assert.same(ids[1], output1)
    assert.same(ids[2], output2)
  end)
  
  it("Points", function()
    local points1 = {
        1, 1,
      0.5, 2,
        1, 3,
        2, 3.5,
        3, 3,
      3.5, 2,
        3, 1,
        2, 0.5,
        1, 1,
    }
    
    local points2 = {
      2, 1,
      1, 2,
      2, 3,
      3, 2,
      2, 1,
    }
    
    assert.same(paths[1][1], points1)
    assert.same(paths[2][1], points2)
    
  end)  
end)
