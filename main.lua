require("level")
require("camera")
require("helper")

nowLev = 1
textLine = 1
function restart()
  level = Level.create(nowLev)
end

function love.load()

	-- sounds
	gameMusic = love.audio.newSource("sfx/nostalg2.mod")
	gameMusic:setLooping(true)
	
	saveSound = love.audio.newSource("sfx/save_pixel.wav")
	hitSound = love.audio.newSource("sfx/hit.wav")
	deathSound = love.audio.newSource("sfx/death.wav")
  	winSound = love.audio.newSource("sfx/win.wav")
  	continueSound = love.audio.newSource("sfx/continue.wav")

	-- fonts
	font = love.graphics.newFont('fnts/8-BIT_WONDER.TTF', 12)
	font2 = love.graphics.newFont('fnts/Greyscale Basic Bold.ttf', 30)

	-- start game
	restart()

	-- play music
	gameMusic:stop()
	gameMusic:play()

	effect = love.graphics.newPixelEffect [[
        extern number time;
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            return vec4((1.0+sin(time))/2.0, abs(cos(time/4000)), abs(sin(time)), 90);
        }
    ]]
end


local t = 0

local shearedX = 0
local shearedY = 0
reversedX = false
reversedY = false
shearStep = 0.0008
function love.update(dt)
  level:update(dt)
  t = t + dt
  effect:send("time", t)
  
  
  if not reversedX then
	  if shearedX >= -0.2 then
	  	shearedX = shearedX + shearStep
	  	if shearedX > 0.2 then
	  		reversedX = true
	  	end
	  end
  end

  if reversedX then
  	shearedX = shearedX - shearStep
  	if shearedX <= -0.198 then
  		reversedX = false
  	end
  end


  if not reversedY then
	  if shearedY >= 0 then
	  	shearedY = shearedY + shearStep
	  	if shearedY > 0.2 then
	  		reversedY = true
	  	end
	  end
  end

  if reversedY then

  	shearedY = shearedY - shearStep
  	if shearedY < 0.002 then
  		reversedY = false
  	end
  end

  
  camera:shear(shearedX, shearedY)

end

function love.keyreleased(key, unicode)
   -- if key == 'x' then
   -- 	objects.pixel:addChild(10, 10, 10, false)
   -- end


   if key == 'p' then
   	x, y = objects.pixel.body:getPosition()
   	
   end

   if key == ' ' then
   	if textLine <= #help_text then
	   	continueSound:stop()
		continueSound:play()
	end
   	textLine = textLine + 1
   end

   
end

function love.draw()
	
	level:draw()
end