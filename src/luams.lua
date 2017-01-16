-- LuaMarchingSquares
local luams = { }

local meta = {
  __call = function(self, key, vars)
    print key
  end
}


return setmetatable(luams, meta)