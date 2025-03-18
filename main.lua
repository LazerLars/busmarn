if arg[2] == "debug" then
    require("lldebugger").start()
end
local maid64 = require "src/libs/maid64"
local anim8 = require 'src/libs/anim8'
local tween = require 'src/libs/tween'

-- recommended screen sizes
---+--------------+-------------+------+-----+-----+-----+-----+-----+-----+-----+
-- | scale factor | desktop res | 1    | 2   | 3   | 4   | 5   | 6   | 8   | 10  |
-- +--------------+-------------+------+-----+-----+-----+-----+-----+-----+-----+
-- | width        | 1920        | 1920 | 960 | 640 | 480 | 384 | 320 | 240 | 192 |
-- | height       | 1080        | 1080 | 540 | 360 | 270 | 216 | 180 | 135 | 108 |
-- +--------------+-------------+------+-----+-----+-----+-----+-----+-----+-----+
local settings = {
    fullscreen = false,
    scaleMuliplier = 2,
    sceenWidth = 640,
    screenHeight = 360
}

developerMode = true

local imagePath = {}

local images = {}

local animations = {}

local bus = {
    x = 0,
    y = 0
}

local mouse = {
    x_start = 0,
    y_start = 0,
    x_current = 0,
    y_current = 0,
    width = 0,
    height = 0
}

local mouse_last_selection = mouse


function love.load()
    
    math.randomseed( os.time() )
    love.mouse.setVisible(false)
    
    love.graphics.setBackgroundColor( 0/255, 135/255, 81/255)
    love.window.setTitle( 'BUSMARN' )
    --optional settings for window
    love.window.setMode(settings.sceenWidth*settings.scaleMuliplier, settings.screenHeight*settings.scaleMuliplier, {resizable=true, vsync=false, minwidth=200, minheight=200})
    love.graphics.setDefaultFilter("nearest", "nearest")
    --initilizing maid64 for use and set to 64x64 mode 
    --can take 2 parameters x and y if needed for example maid64.setup(64,32)
    maid64.setup(settings.sceenWidth, settings.screenHeight)

    font = love.graphics.newFont('src/fonts/pico-8-mono.ttf', 8)
    -- font = love.graphics.newFont('src/fonts/PressStart2P-Regular.ttf', 8)
    --font:setFilter('nearest', 'nearest')

    love.graphics.setFont(font)

    -- path to images
    imagePath.watermelon_cursor = "src/sprites/cursor_watermelon.png"
    imagePath.bus_idle_sheet = "src/sprites/bus_idle_sheet.png"
    
    -- create the images
    images.watermelon_cursor = love.graphics.newImage(imagePath.watermelon_cursor)
    images.bus_idle_sheet = love.graphics.newImage(imagePath.bus_idle_sheet)
    
    local bus_idle_grid = anim8.newGrid(24, 12, images.bus_idle_sheet:getWidth(), images.bus_idle_sheet:getHeight())

    animations.bus_idle_animation = anim8.newAnimation(bus_idle_grid('1-3',1), 0.1)

    t1 = tween.new(2, bus, {x=300,y=300}, tween.easing.inOutSine)


    
end

function love.update(dt)
    animations.bus_idle_animation:update(dt)
    if love.mouse.isDown(1) then
		mouse.x_current = maid64.mouse.getX()
		mouse.y_current = maid64.mouse.getY()
        mouse.width = mouse.x_current - mouse.x_start
        mouse.height = mouse.y_current - mouse.y_start
	end	

    t1:update(dt)
end



function love.draw()
    
    maid64.start()--starts the maid64 process
   
    love.graphics.setLineStyle('rough')
   
    if developerMode == true then
    
        love.graphics.print(maid64.mouse.getX() ..  "," ..  maid64.mouse.getY(), 1,1)
        -- love.graphics.print(math.floor(player.x-player.originX) ..  "," .. math.floor(player.y-player.originY), 1,58)
         --can also draw shapes and get mouse position
        -- love.graphics.rectangle("fill", maid64.mouse.getX(),  maid64.mouse.getY(), 1,1)
    end
    
    love.graphics.draw(images.watermelon_cursor,maid64.mouse.getX(), 
    maid64.mouse.getY())
    
    love.graphics.rectangle("line", mouse.x_start, mouse.y_start, mouse.width, mouse.height)

    -- draw right facing bus
    animations.bus_idle_animation:draw(images.bus_idle_sheet, bus.x, bus.y, 0, 2, 2)
    -- animations.bus_idle_animation:draw(images.bus_idle_sheet, maid64.mouse.getX(),maid64.mouse.getY(), 0, 2, 2)
    -- draw left facing bus, offset with the width of the original bus image
    -- animations.bus_idle_animation:draw(images.bus_idle_sheet, maid64.mouse.getX(),maid64.mouse.getY(), 0, -2, 2, 24, 0)

    
    maid64.finish()--finishes the maid64 process
end

function love.resize(w, h)
    -- this is used to resize the screen correctly
    maid64.resize(w, h)
end


function love.keypressed(key)
    if key == 'e' then
        print("e")
    end

    if key == "escape" then
      print("escape")

    end

    -- toggle fullscreen
    if key == 'f11' then
        if settings.fullscreen == false then
            love.window.setFullscreen(true, "desktop")
            settings.fullscreen = true
        else
            love.window.setMode(settings.sceenWidth*settings.scaleMuliplier, settings.screenHeight*settings.scaleMuliplier, {resizable=true, vsync=false, minwidth=200, minheight=200})
            maid64.setup(settings.sceenWidth, settings.screenHeight)
            settings.fullscreen = false
        end 
    end
end

function love.mousepressed(x, y, button, istouch)
    -- when the leftm mouse  is pressed, we want to save the initial click x,y position
    if button == 1 then -- Versions prior to 0.10.0 use the MouseConstant 'l'
        mouse.x_start = maid64.mouse.getX()
        mouse.y_start = maid64.mouse.getY()
    end
 end

 function love.mousereleased(x, y, button)
    -- when the left mouse is released we want to reset the mouse selection so we can stop drawing the square on the screen
    if button == 1 then
        copy_last_mouse_selection()
        reset_mouse_selection()
    end
 end

function copy_last_mouse_selection()

    mouse_last_selection = copy_table(mouse)

end

function reset_mouse_selection()

    mouse.x_start = 0
    mouse.y_start = 0
    mouse.x_current = 0
    mouse. y_current = 0
    mouse.width = 0
    mouse.height = 0
    
end

-- make a copy of a table
function copy_table(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v  -- Copy each value
    end
    return copy
end

-- make a copy of nested tables
function deep_copy(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = deep_copy(v)
        else
            copy[k] = v
        end
    end
    return copy
end
