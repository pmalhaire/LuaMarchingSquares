--https://en.wikipedia.org/wiki/Marching_squares
describe("wikipedia isoline example", function()
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
  
  local output1 = {
    {{cval= 13, flipped= nil}, {cval= 12, flipped= nil}, {cval= 12, flipped= nil}, {cval= 14, flipped= nil}},
    {{cval=  9, flipped= nil},                      nil,                      nil, {cval=  6, flipped= nil}},
    {{cval=  9, flipped= nil},                      nil,                      nil, {cval=  6, flipped= nil}},
    {{cval= 11, flipped= nil}, {cval=  3, flipped= nil}, {cval=  3, flipped= nil}, {cval=  7, flipped= nil}},
  }
  
  local output2 = {
    {nil, {cval= 13}, {cval= 14}, nil},
    {{cval=  13}, {cval=  8}, {cval=  4}, {cval=  14}},
    {{cval=  11}, {cval=  1}, {cval=  2}, {cval=  7}},
    {nil, {cval= 13}, {cval= 14}, nil},
  }
  
  it("output", function()
    local bitMaskLayers = luams.buildBitMask(data, levels)
    assert.same(bitMaskLayers.rows, #data - 1)
    assert.same(bitMaskLayers.cols, #data[1] - 1)
    assert.same(bitMaskLayers.length, #levels)
    
    assert.same(bitMaskLayers.layers[1], output1)
    assert.same(bitMaskLayers.layers[2], output2)
  end)
end)
