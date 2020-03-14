--package.path = package.path .. ";./glue/?.lua;./giflib//?.lua;./"
package.path = package.path .. ";./png-lua/?.lua"

-- Free font by Johan Holmdahl 1999.
local atwfont = love.graphics.newFont("/assets/atwriter.ttf",24)

local pngImage = require("png")

--[[ package.path = package.path .. ";./glue/?.lua;./libpng/?.lua;./libpng/bin/mingw64/?.dll;./?.dll"
os.env['PATH'] = "${os.env.PATH};${'./'};"
local libpng = require'libpng' ]]--

love.window.setTitle("Through the Woods")
local windowsizex = 800
local windowsizey = 600

local abs = math.abs

local worldsize = 256

-- Initialize log
local logsize = 16
local logbuffer = {}
for i=1, logsize do
	logbuffer[i]="-"
end

-- Log a string
local function log(s)
	for i=logsize, 2, -1 do
		logbuffer[i]=logbuffer[i-1]
	end
	logbuffer[1] = s
end

-- Render log text
local function drawLog()
	love.graphics.setColor(1,1,1,1)
	for i, s in ipairs(logbuffer) do
		love.graphics.print(s, 4, windowsizey-(i*12)-4)
	end
end

--[[ for k, v in pairs(pngImage) do
	log(tostring(k)..": "..tostring(v))
end ]]--

--log(package.path)

-- Load world image
--local worldimg = libpng.load({["path"]="../assets/world.png"})
local worldImg = pngImage("./src/assets/world.png")
local pixels = worldImg.pixels

local start_tile = 1
local water_hazard = 2
local cliff_hazard = 3
local path_tile = 4
local bush_tile = 5
local flower_field = 6
local log_over_water = 7
local bridge_over_water = 8
local finish_tile = 9


local tile_ids = {}
tile_ids["start_tile"] = start_tile
tile_ids["water_hazard"] = water_hazard
tile_ids["cliff_hazard"] = cliff_hazard
tile_ids["path_tile"] = path_tile
tile_ids["bush_tile"] = bush_tile
tile_ids["flower_field"] = flower_field
tile_ids["log_over_water"] = log_over_water
tile_ids["bridge_over_water"] = bridge_over_water
tile_ids["finish_tile"] = finish_tile

-- Register color keycodes for tile types
local tile_colors = {}
for name, id in pairs(tile_ids) do
	local pixel = worldImg.pixels[id][1]
	local pixel_str = tostring(pixel.R)..","..tostring(pixel.G)..","..tostring(pixel.B)
	tile_colors[pixel_str] = name
	log(name..":"..pixel_str)
end


-- Load world tile names by pixel color string
-- but only from one chunk of pixels
local worldtiles ={}
for y=1, 32 do
	local row = {}
	for x=33, 64 do
		local pixel = pixels[y][x]
		local pixel_str = tostring(pixel.R)..","..tostring(pixel.G)..","..tostring(pixel.B)
		local tiletype = tile_colors[pixel_str]
		row[x-33] = tiletype
	end
	worldtiles[y] = row
end

-- Starting point is first path_tile going from top-bottom left-right
local start = nil
for y=1, 32 do
	local row = worldtiles[y]
	for x=1, 32 do
		local tile = row[x]
		if tile =="path_tile" then
			start={["x"]=x,["y"]=y}
			break
		end
	end
	if start then break end
end

log("Starting at ["..tostring(start.x)..","..tostring(start.y).."]")

local mousedown_l = {}; mousedown_l.x = -1; mousedown_l.y = -1

function love.mousepressed(x,y,button)
	if button == "l" then
		mousedown_l.x = x; mousedown.y = y
	end
end

function love.mouserleased(x,y,button)
	if button == "l" then
		if abs(mousedown_l.x-x) < 4 and abs(mousedown_l.y-y) < 4 then
			mouseclicked(x,y)
		end
	end
end

-- Player heading, NSEW
-- 1  | 3  | 5
-- 7  | x  | 11
-- 13 | 17 | 19
local heading = 17

-- Options for this turn
local options = {}

-- Initial options
options[1] = {
	["text"] = "Stroll, carefully observe your surroundings",
	["bias"] = {1,1,2,1},
	["weight"] = 4,
	["preference"] = "path_tile" }

options[2] = {
	["text"] = "Walk down the path",
	["bias"] = {2,4,2,2},
	["weight"] = 2,
	["preference"] = "path_tile" }

options[3] = {
	["text"] = "Go for an impromptu jog",
	["bias"] = {5,5,5,5},
	["weight"] = 1,
	["preference"] = "path_tile" }

local texts = {}

texts[1] = love.graphics.newText(atwfont)
texts[2] = love.graphics.newText(atwfont)
texts[3] = love.graphics.newText(atwfont)

-- Process mouseclicks
local function mouseclicked(x,y)

	if cinematic == 1 then return end

	-- See which option we clicked on

end

-- A simple cooldown for cinematics (text, animation etc)
local cinematic = -1
local panic = false

-- Background image
local bgimg = nil

function love.load()
	bgimg = love.graphics.newImage("/assets/path2blur.png")
end

local function drawOptions()
	love.graphics.setColor(1,1,1)

	-- Draw each option text
	for i, option in ipairs(options) do
		local textobj = texts[i]
		textobj:set(option.text)
		love.graphics.draw(textobj,windowsizex/2-textobj:getWidth()/2,
			windowsizey/2-(i-#options/2)*80)
	end
end

local selectionline = -100

function love.mousemoved(x, y, dx, dy)

	selectionline = -100

	-- See which text option we are hovering over
	for i, option in ipairs(options) do
		local liney = windowsizey/2-(i-#options/2)*80
		if abs(liney-y+20) < 20 then
			selectionline = liney
		end
	end
end

function love.draw()

	-- Backgrounds
	love.graphics.draw(bgimg,0,0,0,8/9,6/7)

	if cinematic == -1 then

		-- Draw the text selection line
		love.graphics.setColor(0,0,0,0.5)
		love.graphics.rectangle("fill",0,selectionline,windowsizex,40)

		-- Draw all options
		drawOptions()
	end

	drawLog()
end