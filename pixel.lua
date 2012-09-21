Pixel = {}
Pixel.__index = Pixel

function Pixel.create(world, x, y, w, h, mass, canMove, isChild, life)
  local self = {}
  setmetatable(self, Pixel)

  self:reset(world, x,y, w, h, mass, canMove, isChild, life)
  return self
end

function Pixel:reset(world, x, y, w, h, mass, canMove, isChild, life)
  
  self.life = life or 100
  self.x = x
  self.y = y
  self.isChild = isChild
  self.children = {}
  self.width = w or 20
  self.height = h or 20
  self.canMove = canMove
  self.mass = mass or 20


  -- physics
  self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
  self.body:setMass(self.mass) 
  self.shape = love.physics.newRectangleShape(self.width, self.height)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setRestitution(0.3)
  self.fixture:setUserData("Pixel")

  -- movement force
  self.moveUpForce = -25 
  self.moveDownForce = 15
  self.moveLeftForce = -15
  self.moveRightForce = 15

  -- particles
  particle = love.graphics.newImage("part1.png")
  p = love.graphics.newParticleSystem(particle, 1000)
  p:setEmissionRate(50)
  p:setSpeed(200, 250)
  --p:setGravity(100, 200)
  p:setSizes(0.3, 0.3)
  p:setColors(80, 183, 217, 150, 24, 240, 3, 0)
  --p:setPosition(400, 300)
  p:setLifetime(0.04)
  p:setParticleLife(1)
  p:setSpread(1)
  p:setSpin(300, 800)
  p:stop()
  --table.insert(systems, p)  

end


function Pixel:update(dt)
  if self.canMove and self.isChild == false then
    p:update(dt) --update particles
    if not self.frozen then
      if love.keyboard.isDown('l') then
        self.body:applyForce(self.moveRightForce, 0)
      

        x,y = self.body:getPosition()
        p:setPosition(x, y)
        p:setDirection(210)
        p:start()

        
      elseif love.keyboard.isDown('j') then
        self.body:applyForce(self.moveLeftForce, 0)

        x,y = self.body:getPosition()
        p:setPosition(x, y)
        p:setDirection(0)
        p:start()

      end


      if love.keyboard.isDown('i') then
        self.body:applyForce(0, self.moveUpForce)

        x,y = self.body:getPosition()
        p:setPosition(x, y)
        p:setDirection(90)
        p:start()

      elseif love.keyboard.isDown('k') then
        self.body:applyForce(0, self.moveDownForce)

        x,y = self.body:getPosition()
        

        p:setPosition(x, y)
        p:setDirection(180)
        p:start()
      end
    end

    -- if love.keyboard.isDown('p') then
    --   self.body:applyTorque(15)
    -- elseif love.keyboard.isDown('i') then
    --   self.body:applyTorque(-15)
    -- end

  elseif self.canMove and self.isChild == true then
    if not self.frozen then
      if love.keyboard.isDown('d') then
        self.body:applyForce(self.moveRightForce, 0)
        --self.body:applyTorque(5)
      elseif love.keyboard.isDown('a') then
        self.body:applyForce(self.moveLeftForce, 0)
        --self.body:applyTorque(-5)
      end


      if love.keyboard.isDown('w') then
        self.body:applyForce(0, self.moveUpForce)
      elseif love.keyboard.isDown('s') then
        self.body:applyForce(0, self.moveDownForce)
      end
    end
  end



  if love.keyboard.isDown('q') then
    if self.isChild and self.canMove then
      self.body:setType('')
    end
  end

  if love.keyboard.isDown('u') then
    if self.isChild == false then
      self.body:setType('')
    end
  else
    
    self.body:setType('dynamic')
  end
end



function Pixel:draw(pixel)
  love.graphics.draw(p, 0, 0) -- draw particles

  love.graphics.setColor(80,165,217)

  if self.hurting then
    love.graphics.setColor(255,0,0)
    self.hurting = false
  end

  -- draw pixel
  love.graphics.polygon("fill", pixel.body:getWorldPoints(pixel.shape:getPoints()))

  

  
  -- draw children
  for i in ipairs(self.children) do
    if self.children[i].canMove then 
      love.graphics.setColor(80,165,217)
    else
      love.graphics.setColor(194,217,80)
    end
    love.graphics.polygon("fill", self.children[i].body:getWorldPoints(self.children[i].shape:getPoints()))
  end
  
end


function Pixel:addChild(world, w, h, mass, canMove, isChild)
  last_child = #self.children
  if last_child == 0 then
    x, y = self.body:getPosition()
  else
    x, y = self.children[last_child].body:getPosition()
  end

  if #self.children == 0 then
    height = 15
  else
    height = 9
  end

  --dad_x, dad_y  = self.body:getPosition()
  if #self.children == 0 then
    
    xLV, yLV = self.body:getLinearVelocity()
    if xLV > 0 then
      x = x - height
    elseif xLV < 0 then
      x = x + height
    end

    if yLV > 0 then
      y = y - height
    elseif yLV < 0 then
      y = y + height
    end
    
  else
    xLV, yLV = self.children[last_child].body:getLinearVelocity()
    if xLV > 0 then
      x = x + height
    elseif xLV < 0 then
      x = x - height
    end

    if yLV > 0 then
      y = y + height
    elseif yLV < 0 then
      y = y - height
    end
  end

  

  new_child = Pixel.create(world, x, y, w, h, mass, canMove, true) -- x, y, width, height, mass, canMove, isChild
  table.insert(self.children, new_child)

  -- create joint
  -- if first element then joint should be between element 1 and the pixel
  new_last_child = #self.children
  if new_last_child == 1 then
    pixel_x, pixel_y = self.body:getPosition()
    child_x, child_y = self.children[new_last_child].body:getPosition()
    love.physics.newDistanceJoint( self.body, self.children[new_last_child].body, pixel_x, pixel_y, child_x, child_y)
    
    love.physics.newRevoluteJoint( self.body, self.children[new_last_child].body, child_x, child_y, collideConnected )
  else
    -- else between the last two elements
    child1_x, child1_y = self.children[last_child].body:getPosition()
    child2_x, child2_y = self.children[new_last_child].body:getPosition()
    love.physics.newDistanceJoint( self.children[last_child].body, self.children[new_last_child].body, child1_x, child1_y, child2_x, child2_y)

    love.physics.newRevoluteJoint( self.children[last_child].body, self.children[new_last_child].body, child2_x, child2_y, collideConnected )
  end

  if #self.children > 1 then
    for i in ipairs(self.children) do
      self.children[i].canMove=false
    end


    self.children[#self.children].canMove = true
  end

  -- every time we create a new child we need to increase forces

  self.moveUpForce = self.moveUpForce - 5
  self.moveLeftForce = self.moveLeftForce - 5

  self.moveRightForce = self.moveRightForce + 5
  self.moveDownForce = self.moveDownForce + 5

end