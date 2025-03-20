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
draw_hit_boxes = true

local imagePath = {}

local images = {}

local grids = {}

local animations = {}

local sfx = {}

local bus_states = {
    driving = 'driving',
    braking = 'braking',
    idleing = 'idleing'
}

local bus = {
    x = 0,
    y = 0,
    x_target = 0,
    y_target = 0,
    width = 24,
    height = 12,
    scaling = 2,
    facing_left = true,
    bus_state = bus_states.idleing,
    distance_to_target = 0
}


local mouse = {
    x_start = 0,
    y_start = 0,
    x_current = 0,
    y_current = 0,
    width = 0, -- used to store the value of the width of the current ongoing selection
    height = 0 -- used to store the value of the height of the current on going selection
}

local passengers = {}

local mouse_last_selection = mouse

local mouse_x = 0
local mouse_y = 0


function love.load()
    
    math.randomseed( os.time() )
    love.mouse.setVisible(false)
    
    -- love.graphics.setBackgroundColor( 0/255, 135/255, 81/255) -- green
    love.graphics.setBackgroundColor( 227/255, 160/255, 102/255)
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
    imagePath.bus_driving_sheet = "src/sprites/bus_driving_sheet.png"
    imagePath.bus_braking = "src/sprites/bus_breaking.png"
    imagePath.chicken = "src/sprites/figures/ckn_little_marn_sheet.png"
    imagePath.frog = "src/sprites/figures/frog_girl_marn_sheet.png"
    imagePath.rabbit = "src/sprites/figures/roger_rabbit_marn_sheet.png"
    imagePath.smiley = "src/sprites/figures/smiley_marn_sheet.png"
    
    -- create the images
    images.watermelon_cursor = love.graphics.newImage(imagePath.watermelon_cursor)
    images.bus_idle_sheet = love.graphics.newImage(imagePath.bus_idle_sheet)
    images.bus_driving_sheet = love.graphics.newImage(imagePath.bus_driving_sheet)
    images.bus_breaking = love.graphics.newImage(imagePath.bus_braking)
    images.chicken = love.graphics.newImage(imagePath.chicken)
    images.frog = love.graphics.newImage(imagePath.frog)
    images.rabbit = love.graphics.newImage(imagePath.rabbit)
    images.smiley = love.graphics.newImage(imagePath.smiley)
    
    grids.bus_idle_grid = anim8.newGrid(24, 12, images.bus_idle_sheet:getWidth(), images.bus_idle_sheet:getHeight())
    grids.bus_drinving_grid = anim8.newGrid(24, 12, images.bus_driving_sheet:getWidth(), images.bus_driving_sheet:getHeight())
    grids.chicken_grid = anim8.newGrid(16, 16, images.chicken:getWidth(), images.chicken:getHeight())
    grids.frog_grid = anim8.newGrid(16, 16, images.frog:getWidth(), images.frog:getHeight())
    grids.rabbit_grid = anim8.newGrid(16, 16, images.rabbit:getWidth(), images.rabbit:getHeight())
    grids.smiley_grid = anim8.newGrid(16, 16, images.smiley:getWidth(), images.smiley:getHeight())

    animations.bus_idle_animation = anim8.newAnimation(grids.bus_idle_grid('1-3',1), 0.1)
    animations.bus_driving_animation = anim8.newAnimation(grids.bus_drinving_grid('1-2', 1), 0.1)
    animations.chicken_animation = anim8.newAnimation(grids.chicken_grid('1-3', 1), 0.15)
    animations.frog_animation = anim8.newAnimation(grids.frog_grid('1-2', 1), 0.1)
    animations.rabbit_animation = anim8.newAnimation(grids.rabbit_grid('1-2', 1), 0.1)
    animations.smiley_animation = anim8.newAnimation(grids.smiley_grid('1-3', 1), 0.1)

    move_bus = tween.new(2, bus, {x=bus.x_target,y=bus.y_target}, tween.easing.linear) -- how do i check that this is finished?
    

    -- LOAD SOUNDS
    sfx.driving = love.audio.newSource("src/sfx/sfx_drive_short.wav", 'static')
    sfx.driving:setLooping(true)
    sfx.idle = love.audio.newSource("src/sfx/sfx_bus_idle.wav", 'static')
    sfx.idle:setLooping(true)
    sfx.brake = love.audio.newSource("src/sfx/sfx_braking_car_short.wav", 'static')

    sfx.idle:play()
    
end

function love.update(dt)

    for key, passenger in pairs(passengers) do
        passenger.animation:update(dt)
        local move_completed = passenger.move:update(dt)
        if move_completed then
            local x_target = passenger.x + math.random(-50,50)
            local y_target = passenger.y + math.random(-50,50)
            if x_target > settings.screenHeight or x_target < 5 then
                x_target = passenger.x + math.random(-50,50)
            end
            if y_target > settings.sceenWidth or y_target < 5 then
                y_target = passenger.x + math.random(-50,50)
            end
            local time_to_target = math.random(2,10)
            -- create tween to move passenger
            passenger.move = tween.new(time_to_target, passenger, {x=x_target, y=y_target}, tween.easing.inOutSine)
        end
    end
    mouse_x = maid64.mouse.getX()
    mouse_y = maid64.mouse.getY()
    animations.bus_idle_animation:update(dt)
    animations.bus_driving_animation:update(dt)
    if love.mouse.isDown(1) then
		mouse.x_current = maid64.mouse.getX()
		mouse.y_current = maid64.mouse.getY()
        mouse.width = mouse.x_current - mouse.x_start
        mouse.height = mouse.y_current - mouse.y_start
	end	


    bus.distance_to_target = calculate_distance_between_two_targets(bus.x, bus.y, bus.x_target, bus.y_target)

    local move_bus_complete = move_bus:update(dt)
    
    if bus.distance_to_target < 20 and bus.distance_to_target > 1 then
        if sfx.driving:isPlaying() then
            sfx.driving:stop()
        end
        sfx.brake:play()
        bus.bus_state = bus_states.braking
        print(bus.distance_to_target)
        print("we are breaking")
    end
    if move_bus_complete then
        bus.bus_state = bus_states.idleing
        if sfx.driving:isPlaying() then
            sfx.driving:stop()
        end
        sfx.idle:play()
    end

end



function love.draw()
    
    maid64.start()--starts the maid64 process
   
    love.graphics.setLineStyle('rough')
    for key, value in pairs(passengers) do
        value.animation:draw(value.image, value.x, value.y)
        if draw_hit_boxes then
            love.graphics.rectangle('line', value.x, value.y, value.width, value.height)
        end
    end
    if developerMode == true then
    
        love.graphics.print(maid64.mouse.getX() ..  "," ..  maid64.mouse.getY(), 1,1)
        -- love.graphics.print(math.floor(player.x-player.originX) ..  "," .. math.floor(player.y-player.originY), 1,58)
         --can also draw shapes and get mouse position
        -- love.graphics.rectangle("fill", maid64.mouse.getX(),  maid64.mouse.getY(), 1,1)
    end
    
    
    love.graphics.rectangle("line", mouse.x_start, mouse.y_start, mouse.width, mouse.height)
    
    -- draw right facing bus
    if bus.facing_left then
        if bus.bus_state == bus_states.idleing then
            animations.bus_idle_animation:draw(images.bus_idle_sheet, bus.x, bus.y, 0, -bus.scaling, bus.scaling, bus.width, 0)
        elseif bus.bus_state == bus_states.driving then
            animations.bus_driving_animation:draw(images.bus_driving_sheet, bus.x, bus.y, 0, -bus.scaling, bus.scaling, bus.width, 0)
        elseif bus.bus_state == bus_states.braking then
            love.graphics.draw(images.bus_breaking, bus.x, bus.y, 0, -bus.scaling, bus.scaling, bus.width, 0)
            
        end
        if draw_hit_boxes then
            love.graphics.rectangle('line', bus.x, bus.y, bus.width*bus.scaling, bus.height*bus.scaling, 0, -bus.scaling)
        end
    else
        
        if bus.bus_state == bus_states.idleing then
            animations.bus_idle_animation:draw(images.bus_idle_sheet, bus.x, bus.y, 0, bus.scaling, bus.scaling)
        elseif bus.bus_state == bus_states.driving then
            animations.bus_driving_animation:draw(images.bus_driving_sheet, bus.x, bus.y, 0, bus.scaling, bus.scaling)
        elseif bus.bus_state == bus_states.braking then
            love.graphics.draw(images.bus_breaking, bus.x, bus.y, 0, bus.scaling, bus.scaling)
            
        end
        -- animations.bus_driving_animation:draw(images.bus_driving_sheet, bus.x, bus.y, 0, 2, 2)
        if draw_hit_boxes then
            love.graphics.rectangle('line', bus.x, bus.y, bus.width*bus.scaling, bus.height*bus.scaling, 0, bus.scaling)
        end
    end
    -- animations.bus_idle_animation:draw(images.bus_idle_sheet, maid64.mouse.getX(),maid64.mouse.getY(), 0, 2, 2)
    -- draw left facing bus, offset with the width of the original bus image
    -- animations.bus_idle_animation:draw(images.bus_idle_sheet, maid64.mouse.getX(),maid64.mouse.getY(), 0, -2, 2, 24, 0)
    
    love.graphics.draw(images.watermelon_cursor,maid64.mouse.getX(), maid64.mouse.getY())
    maid64.finish()--finishes the maid64 process
end

function love.resize(w, h)
    -- this is used to resize the screen correctly
    maid64.resize(w, h)
end


function love.keypressed(key)
    if key == 'e' then
        print("adding passenger")
        add_pasenger()
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

    if button == 2 then
        if sfx.idle:isPlaying() then
            sfx.idle:stop()
        end
        sfx.driving:play()
        bus.x_target = mouse_x
        bus.y_target = mouse_y
        move_bus = tween.new(2, bus, {x=bus.x_target, y=bus.y_target}, tween.easing.inOutSine)
        bus.bus_state = bus_states.driving

        if mouse_x < bus.x then
            bus.facing_left = true
        else
            bus.facing_left = false
        end
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


-- Function to calculate the distance to the target
function calculate_distance_between_two_targets(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function add_pasenger()
    
    local animation_picker = math.random(1,4);
    local time_to_target = math.random(2,10)
    
    local animation
    local image
    if animation_picker == 1 then
        animation = anim8.newAnimation(grids.chicken_grid('1-3', 1), 0.15)
        image = images.chicken
    elseif animation_picker == 2 then
        animation = anim8.newAnimation(grids.frog_grid('1-2', 1), 0.1)
        image = images.frog
    elseif  animation_picker == 3 then
        animation = anim8.newAnimation(grids.rabbit_grid('1-2', 1), 0.1)
        image = images.rabbit
    elseif animation_picker == 4 then
        animation = anim8.newAnimation(grids.smiley_grid('1-3', 1), 0.1)
        image = images.smiley
    end
    local passenger = {
        x = math.random(5,620); math.random(5,620); math.random(5,620),
        y = math.random(5,350); math.random(5,350); math.random(5,350),
        animation = animation,
        image = image,
        width = 16,
        height = 16
        
    }
    local x_target = passenger.x + math.random(-50,50)
    local y_target = passenger.y + math.random(-50,50)

    -- create tween to move passenger
    passenger.move = tween.new(time_to_target, passenger, {x=x_target, y=y_target}, tween.easing.inOutSine)

    table.insert(passengers, passenger)
end
