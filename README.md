# LuaMarchingSquares

>Marching squares is a computer graphics algorithm that generates contours for a two-dimensional scalar field (rectangular array of individual numerical values).
[Wikipedia](https://en.wikipedia.org/wiki/Marching_squares)

##Example
local data = {
  {1, 1, 1, 1, 1},
  {1, 2, 3, 2, 1},
  {1, 3, 3, 3, 1},
  {1, 2, 3, 2, 1},
  {1, 1, 1, 1, 1},
}
local levels = {1, 1.4, 1.8, 2.2, 2.6}    
luams.getContour(data, levels)
![screenshot](https://raw.githubusercontent.com/phobus/LuaMarchingSquares/master/examples/screenshot001.png)
  
##Based on:

- http://udel.edu/~mm/code/marchingSquares/
- https://github.com/RaumZeit/MarchingSquares.js
