require("helper")
require("pixel")

Level = {}
Level.__index = Level






function Level.create(level)
  require("levels/level"..level)
  -- physics stuff
  local self = {}
  setmetatable(self, Level)
  self:load()
  return self
end

function Level:load()
  
  -- physics objects
  objects = {} 

  textLine = 1


  -- pixels to save
  pixels_to_save_objects = {}


  createChildFlag = false
  resetFlag = false
  levelWon = false

  love.physics.setMeter(64)
  self.world = love.physics.newWorld(0, 0, true) 
  self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)

  -- level: physics
  levelBlocks = {}
  levelBlocksGray = {}
  for y=1, #map_code do
    for x=1, #map_code[y] do
        if map_code[y][x] == 1 then
            block = {}
            block.body = love.physics.newBody(self.world, x*84+42, y*84+42)
            block.shape = love.physics.newRectangleShape(84, 84)
            block.fixture = love.physics.newFixture(block.body, block.shape, 1)
            block.fixture:setUserData("Wall")
            table.insert(levelBlocks, block)
        end

        if map_code[y][x] == 2 then
            block = {}
            block.body = love.physics.newBody(self.world, x*84+42, y*84+42)
            block.shape = love.physics.newRectangleShape(84, 84)
            block.fixture = love.physics.newFixture(block.body, block.shape, 1)
            block.fixture:setUserData("Wall")
            table.insert(levelBlocksGray, block)
        end 
    end
  end

  -- level: pixels to save
  for pts=1, #pixels_to_save do
    block = {}
    block.body = love.physics.newBody(self.world, pixels_to_save[pts][1], pixels_to_save[pts][2])
    block.shape = love.physics.newRectangleShape(10, 10)
    block.fixture = love.physics.newFixture(block.body, block.shape, 1)
    block.fixture:setUserData("PTS_"..pts)
    pixels_to_save_objects["PTS_"..pts] = block
  end

  -- level: winning location

  objects.winning = {}
  objects.winning.body = love.physics.newBody(self.world, winning_location[1][1], winning_location[1][2])
  objects.winning.shape = love.physics.newRectangleShape(30, 30)
  objects.winning.fixture = love.physics.newFixture(objects.winning.body, objects.winning.shape, 1)
  objects.winning.fixture:setUserData("WIN")

  -- set env
  --love.graphics.setMode(640,480,false)


  love.graphics.setBackgroundColor(244,249,244) -- background color
  love.graphics.setColor(0,0,0)


  -- player
  objects.pixel = Pixel.create(self.world, spawn_location[1][1], spawn_location[1][2], 20, 20, 20, true, false, 100) -- x, y, width, height, mass, canMove, isChild, life points  


  -- particles
  particle = love.graphics.newImage("part1.png")
  wineffect = love.graphics.newParticleSystem(particle, 1000)
  
  wineffectW = 0.5
  wineffectH = 0.2
  wineffect:setEmissionRate(100)
  wineffect:setSpeed(300, 400)
  wineffect:setGravity(0)
  wineffect:setSizes(wineffectW, wineffectH)
  wineffect:setColors(255, 255, 255, 255, 58, 128, 255, 0)
  wineffect:setPosition(winning_location[1][1], winning_location[1][2])
  wineffect:setLifetime(1)
  wineffect:setParticleLife(1)
  wineffect:setDirection(0)
  wineffect:setSpread(360)
  wineffect:setRadialAcceleration(-2000)
  wineffect:setTangentialAcceleration(1000)
  wineffect:start()
end



function beginContact(a, b, coll)

  if splitter(a:getUserData(), '_')[1] == "PTS" and b:getUserData() == "Pixel" then
    if #splitter(a:getUserData(), '_') > 1 then
      --id = tonumber(splitter(b:getUserData(), '_')[2])
      x = pixels_to_save_objects[a:getUserData()]

      if pixels_to_save_objects[a:getUserData()] then
        table.removekey(pixels_to_save_objects,a:getUserData())

        
        x.body:destroy()
        saveSound:stop()
        saveSound:play()
        createChildFlag=true
        objects.pixel.life = objects.pixel.life + 5

        if table.countkeys(pixels_to_save_objects) == 0 then
          for i in ipairs(levelBlocksGray) do
            levelBlocksGray[i].body:destroy()
          end
          levelBlocksGray = {}
        end
      end

    end
  end

  if a:getUserData() == "Pixel" and splitter(b:getUserData(), '_')[1] == "PTS" then
    if #splitter(b:getUserData(), '_') > 1 then
      --id = tonumber(splitter(b:getUserData(), '_')[2])
      x = pixels_to_save_objects[b:getUserData()]
      if pixels_to_save_objects[b:getUserData()] then
        table.removekey(pixels_to_save_objects,b:getUserData())
        
        x.body:destroy()
        saveSound:stop()
        saveSound:play()
        createChildFlag = true
        objects.pixel.life = objects.pixel.life + 5

        if table.countkeys(pixels_to_save_objects) == 0 then
          for i in ipairs(levelBlocksGray) do
            levelBlocksGray[i].body:destroy()
          end
          levelBlocksGray = {}
        end
      end

    end
  end

  if a:getUserData() == "Pixel" and b:getUserData() == "WIN"  or a:getUserData() == "WIN" and b:getUserData() == "Pixel" then
    if table.countkeys(pixels_to_save_objects) == 0 then
      objects.winning.body:destroy()
      levelWon = true
      winSound:stop()
      winSound:play()
      objects.pixel.frozen = true
      
    end
  end
end


function preSolve(a, b, coll)
    if a:getUserData() == "Wall" and b:getUserData() == "Pixel" or a:getUserData() == "Pixel" and b:getUserData() == "Wall"  then
      if not objects.pixel.frozen then
        objects.pixel.life = objects.pixel.life - 3
        
        if objects.pixel.life < 0 then
          deathSound:stop()
          deathSound:play()
          resetFlag = true
        end

        objects.pixel.hurting = true

        hitSound:stop()
        hitSound:play()
      end
  end
end

function postSolve(a, b, coll)

end

function Level:update(dt)
  
  wineffect:update(dt)
  wineffect:start()
  
  if levelWon then
    wineffectW = wineffectW +0.1
    wineffectH = wineffectH +0.1
    
    wineffect:setSizes(wineffectW,wineffectH)
    
    if wineffectW > 15.7 then
      nowLev = nowLev + 1
      if nowLev == 8 then nowLev = 1 end
      level = Level.create(nowLev)
    end

  end

  -- update level 
  self.world:update(dt) -- activate physics 

  --
  objects.pixel:update(dt) -- update pixel

  if createChildFlag then
    createChildFlag=false
    objects.pixel:addChild(self.world, 10, 10, 10, false)
  end

  if resetFlag then
    resetFlag=false
    restart()
  end


  if #objects.pixel.children > 0 then
    for i in ipairs(objects.pixel.children) do
      objects.pixel.children[i]:update()
    end
  end


  if love.keyboard.isDown("c") then
    if camera.scaleX < 1.6 then
      camera.scaleX = camera.scaleX +0.01
    camera.scaleY  = camera.scaleY +0.01
    end
    --camera:scale(scaleX,scaleY)
  elseif love.keyboard.isDown("z") then
    if camera.scaleX > 0.7 then
      camera.scaleX = camera.scaleX -0.01
      camera.scaleY = camera.scaleY -0.01
    end
  --
  end

  pixel_x, pixel_y  = objects.pixel.body:getPosition()
  camera:setPosition(pixel_x-(love.graphics.getWidth()/2)*camera.scaleX, pixel_y-(love.graphics.getHeight()/2)*camera.scaleY)
end


function Level:draw(dt)
  --love.graphics.setPixelEffect(effect)
  --love.graphics.setColor(10,10,10)
  --love.graphics.rectangle('fill', 0, 0, 800, 600)
  --love.graphics.setPixelEffect()

  camera:set()

  -- draw pixel
  objects.pixel:draw(objects.pixel)


  -- draw level
  love.graphics.setColor(0,0,0)

  for i in ipairs(levelBlocks) do
    love.graphics.polygon("fill", levelBlocks[i].body:getWorldPoints(levelBlocks[i].shape:getPoints()))
  end

  love.graphics.setColor(55,55,55)
  for i in ipairs(levelBlocksGray) do
    love.graphics.polygon("fill", levelBlocksGray[i].body:getWorldPoints(levelBlocksGray[i].shape:getPoints()))
  end

  

  -- draw pixles to save
  for k,v in pairs(pixels_to_save_objects) do 
    love.graphics.setColor(194,217,80)
    love.graphics.polygon("fill", v.body:getWorldPoints(v.shape:getPoints()))
  end

  -- draw winning location
  if levelWon == false then
    objects.winning.body:setAngle(objects.winning.body:getAngle() + 0.1)
    love.graphics.setColor(220,220,220)
    love.graphics.polygon("fill", objects.winning.body:getWorldPoints(objects.winning.shape:getPoints()))
  end

  love.graphics.draw(wineffect,0,0)
  
  camera:unset()

  -- draw life points
  love.graphics.setFont(font)
  if objects.pixel.life < 50 then
    love.graphics.setColor(255,0,0)
  else
    love.graphics.setColor(194,217,80)
  end

  love.graphics.setColor(194,217,80)

  if textLine <= #help_text then
    love.graphics.setFont(font2)
    love.graphics.printf(help_text[textLine], 0, 20, love.graphics.getWidth(), "center")
    love.graphics.setFont(font)
    love.graphics.printf("Press Space to Continue", 0, 85, love.graphics.getWidth(), "center")
  end

end