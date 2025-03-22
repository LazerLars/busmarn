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
draw_hit_boxes = false

local pause_game = false

local image_path = {}

local images = {}

local grids = {}

local animations = {}

local sfx = {}

local passengers = {}

local effects = {}

local buttons = {}


local spawn_Settings = {
    timer = 0,
    spawn_now = false,
    spawn_interval = 1,
    spawn_counter = 0,
}

local spawn_meter_pin = {
    x = nil,
    y = nil,
    width = nil,
    height = nil,
    bar_x = nil,
    bar_y = nil,
    bar_width = nil,
    bar_height = nil
}

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
    distance_to_target = 0,
    collision = false
}

local stats = {
    passenger_count = 0
}


local mouse = {
    x_start = 0,
    y_start = 0,
    x_current = 0,
    y_current = 0,
    width = 0, -- used to store the value of the width of the current ongoing selection
    height = 0 -- used to store the value of the height of the current on going selection
}

local timer = 0

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
    image_path.watermelon_cursor = "src/sprites/cursor_watermelon.png"
    image_path.bus_idle_sheet = "src/sprites/bus_idle_sheet.png"
    image_path.bus_driving_sheet = "src/sprites/bus_driving_sheet.png"
    image_path.bus_braking = "src/sprites/bus_breaking.png"
    image_path.chicken = "src/sprites/figures/ckn_little_marn_sheet.png"
    image_path.frog = "src/sprites/figures/frog_girl_marn_sheet.png"
    image_path.rabbit = "src/sprites/figures/roger_rabbit_marn_sheet.png"
    image_path.smiley = "src/sprites/figures/smiley_marn_sheet.png"
    image_path.blood_00 = "src/sprites/effects/blood_00.png"
    image_path.blood_01 = "src/sprites/effects/blood_01.png"
    image_path.blood_02 = "src/sprites/effects/blood_02.png"
    image_path.blood_03 = "src/sprites/effects/blood_03.png"
    image_path.blood_04 = "src/sprites/effects/blood_04.png"
    image_path.button_green_up = "src/sprites/effects/button_green_up.png"
    image_path.button_green_down = "src/sprites/effects/button_green_down.png"
    image_path.button_red_up = "src/sprites/effects/button_red_up.png"
    image_path.button_red_down = "src/sprites/effects/button_red_down.png"
    
    -- create the images
    images.watermelon_cursor = love.graphics.newImage(image_path.watermelon_cursor)
    images.bus_idle_sheet = love.graphics.newImage(image_path.bus_idle_sheet)
    images.bus_driving_sheet = love.graphics.newImage(image_path.bus_driving_sheet)
    images.bus_breaking = love.graphics.newImage(image_path.bus_braking)
    images.chicken = love.graphics.newImage(image_path.chicken)
    images.frog = love.graphics.newImage(image_path.frog)
    images.rabbit = love.graphics.newImage(image_path.rabbit)
    images.smiley = love.graphics.newImage(image_path.smiley)
    images.blood_00 = love.graphics.newImage(image_path.blood_00)
    images.blood_01 = love.graphics.newImage(image_path.blood_01)
    images.blood_02 = love.graphics.newImage(image_path.blood_02)
    images.blood_03 = love.graphics.newImage(image_path.blood_03)
    images.blood_04 = love.graphics.newImage(image_path.blood_04)
    images.button_green_up = love.graphics.newImage(image_path.button_green_up)
    images.button_green_down = love.graphics.newImage(image_path.button_green_down)
    images.button_red_up = love.graphics.newImage(image_path.button_red_up)
    images.button_red_down = love.graphics.newImage(image_path.button_red_down)

    
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
    sfx.blood_00 = love.audio.newSource("src/sfx/splatter/sfx_splat_00.wav", "static")
    sfx.blood_01 = love.audio.newSource("src/sfx/splatter/sfx_splat_01.wav", "static")
    sfx.blood_02 = love.audio.newSource("src/sfx/splatter/sfx_splat_02.wav", "static")
    sfx.blood_03 = love.audio.newSource("src/sfx/splatter/sfx_splat_03.wav", "static")

    sfx.idle:play()
    -- set initial position of the buttons
    timer_buttons_init()
    timer_buttons_change_position()

    spawn_meter_init()
    
end

function love.update(dt)
    if pause_game == false then

        timer = timer + dt
        spawn_Settings.timer = spawn_Settings.timer  + dt
        if spawn_Settings.timer >= spawn_Settings.spawn_interval then
            add_pasenger()
            spawn_Settings.timer = 0
            spawn_Settings.spawn_counter = spawn_Settings.spawn_counter + 1
        end
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

        -- check collision
        for key, passenger in pairs(passengers) do
            local collision = collision_check(passenger, bus)
            if collision then
                print("-collision detected")
                stats.passenger_count = stats.passenger_count + 1
                passenger.collision = true
                bus.collision = true
                add_blood_splat(passenger)
                table.remove(passengers, key)
            else 
                passenger.collision = false
                bus.collision = false
            end
        end

        for key, button in pairs(buttons) do
            local collision = collision_check(button, bus)
            if collision then
                button.collision = true
                if button.increase_button then
                    spawn_meter_pin.x = spawn_meter_pin.x + dt * 10
                    spawn_Settings.spawn_interval = spawn_Settings.spawn_interval - 0.0003
                else
                    spawn_meter_pin.x = spawn_meter_pin.x - dt * 10
                    spawn_Settings.spawn_interval = spawn_Settings.spawn_interval + 0.0003
                end
            else
                button.collision = false
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
        
        if bus.distance_to_target < 50 and bus.distance_to_target > 1 then
            if sfx.driving:isPlaying() then
                sfx.driving:stop()
            end
            sfx.brake:play()
            bus.bus_state = bus_states.braking
        end
        if move_bus_complete then
            bus.bus_state = bus_states.idleing
            if sfx.driving:isPlaying() then
                sfx.driving:stop()
            end
            sfx.idle:play()
        end
    end
end



function love.draw()
    
    maid64.start()--starts the maid64 process
    
    love.graphics.setLineStyle('rough')

    for key, button in pairs(buttons) do
        if button.collision == false then
            love.graphics.draw(button.up_image, button.x, button.y, 0, button.scaling, button.scaling)
        else
            love.graphics.draw(button.down_image, button.x, button.y, 0, button.scaling, button.scaling)
        end
    end
    
    for key, blood_effect in pairs(effects) do
        love.graphics.draw(blood_effect.image, blood_effect.x, blood_effect.y, 0, 2, 2)
    end
    
    for key, passenger in pairs(passengers) do
        passenger.animation:draw(passenger.image, passenger.x, passenger.y)
        if draw_hit_boxes then
            if passenger.collision then
                love.graphics.setColor(172/255, 50/255, 50/255) 
            end
            love.graphics.rectangle('line', passenger.x, passenger.y, passenger.width, passenger.height)
            love.graphics.setColor(1,1,1) 
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
    local spawn_rate_width = 150
    love.graphics.rectangle('fill', spawn_meter_pin.bar_x, spawn_meter_pin.bar_y, spawn_meter_pin.bar_width, spawn_meter_pin.bar_height)
    love.graphics.setColor(63/255, 63/255, 116/255)
    love.graphics.rectangle('fill', spawn_meter_pin.x , spawn_meter_pin.y, spawn_meter_pin.width, spawn_meter_pin.height)
    love.graphics.setColor(1,1,1)
    
    if pause_game then
        love.graphics.setColor(50/255,50/255,57/255) 
        love.graphics.rectangle("fill", 175, 40, settings.sceenWidth/2, 200)
        love.graphics.setColor(1,1,1)
    end
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

    if key == "." then
        if draw_hit_boxes then
            draw_hit_boxes = false
        else
            draw_hit_boxes = true
        end
    end

    if key == "escape" then
        if pause_game == false then
            print("pause game")
            pause_game = true
        else
            print("resume game")
            pause_game = false
        end
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
        height = 16,
        collision = false,
        scaling = 1,
        
    }
    local x_target = passenger.x + math.random(-50,50)
    local y_target = passenger.y + math.random(-50,50)

    -- create tween to move passenger
    passenger.move = tween.new(time_to_target, passenger, {x=x_target, y=y_target}, tween.easing.inOutSine)

    table.insert(passengers, passenger)
end

function add_blood_splat(passenger)
    local blood_splat_chooser = math.random(1,5)

    local blood_sfx = {}
    blood_sfx.x = passenger.x
    blood_sfx.y = passenger.y
    if blood_splat_chooser == 1 then
        blood_sfx.image = images.blood_00
    elseif blood_splat_chooser == 2  then
        blood_sfx.image = images.blood_01
    elseif blood_splat_chooser == 3  then
        blood_sfx.image = images.blood_02
    elseif blood_splat_chooser == 4  then
        blood_sfx.image = images.blood_03
    elseif blood_splat_chooser == 5  then
        blood_sfx.image = images.blood_04
    end

    table.insert(effects, blood_sfx)
    play_splatter_sound()
end

function collision_check(object_a, object_b)

    -- Adjusted edges of object a
    local a_left = object_a.x
    local a_right = object_a.x + object_a.width * object_a.scaling
    local a_top = object_a.y
    local a_bottom = object_a.y + object_a.height * object_a.scaling

    -- Adjusted edges of object b
    local b_left = object_b.x
    local b_right = object_b.x + object_b.width * object_b.scaling
    local b_top = object_b.y
    local b_bottom = object_b.y + object_b.height * object_b.scaling

    -- Check if the rectangles overlap
    local isColliding = a_right > b_left and
                        a_left < b_right and
                        a_bottom > b_top and
                        a_top < b_bottom

    return isColliding
end

function play_splatter_sound()
    local choose_splat_sfx = math.random(1,4)

    if choose_splat_sfx == 0 then
        sfx.blood_00:play()
    elseif choose_splat_sfx == 1 then
        sfx.blood_01:play()
    elseif choose_splat_sfx == 2 then
        sfx.blood_02:play()
    elseif choose_splat_sfx == 3 then
        sfx.blood_03:play()
    end
    
end

function add_wheel_marks()

end

function timer_buttons_init()
    local button = {}
    button = {
            up_image = images.button_green_up,
            down_image = images.button_green_down,
            x = 0,
            y = 0,
            width = 20,
            height = 12,
            scaling = 2,
            collision = false,
            increase_button = true
        }
           
    table.insert(buttons, button)
    button = {
        up_image = images.button_red_up,
        down_image = images.button_red_down,
        x = 0,
        y = 0,
        width = 20,
        height = 12,
        scaling = 2,
        collision = false,
        increase_button = false
    }
    table.insert(buttons, button)
end

function timer_buttons_change_position()
    for key, button in pairs(buttons) do
        local x = math.random(0, 600)
        local y = math.random(0, 340)
        button.x = x
        button.y = y
    end
end

function spawn_meter_init()
    local spawn_bar_width = 150
  
    spawn_meter_pin = {
        x = 0,
        y = 5,
        width = 5,
        height = 12,
        bar_x = 0,
        bar_y = 10,
        bar_width = spawn_bar_width,
        bar_height = 2,
        

    }
    spawn_meter_pin.x = (settings.sceenWidth / 2)
    spawn_meter_pin.bar_x = (settings.sceenWidth / 2) - (spawn_bar_width / 2)

end


