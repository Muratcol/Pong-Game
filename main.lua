-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'
-- https://github.com/Ulydev/push
push = require 'push'


require 'Ball'
require 'Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()

    love.window.setTitle("Murat's Pong Game")
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed((os.time()))
    smallFont = love.graphics.newFont('Daydream.ttf', 8)
    scoreFont = love.graphics.newFont('Daydream.ttf', 25)

    player1Score = 0
    player2Score = 0

    -- Initializing paddles
    paddle1 = Paddle(5, 20, 5, 20)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)
    gameState = 'start'

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = false
    }) 
end

function love.update(dt)
    if gameState == 'play' then
        ball:update(dt)
        -- Collide effect
        if ball:collides(paddle1) then
            -- deflect ball to the right
            ball.dx = -ball.dx
        end

        if ball:collides(paddle2) then
            -- deflect ball to the left
            ball.dx = -ball.dx
        end

        if ball.y <= 0 then
            ball.dy = -ball.dy
            ball.y = 0
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - 4
        end

        if ball.x <= 0 or ball.x >= VIRTUAL_WIDTH - 4 then
            score()
        end  
    end

    paddle1:update(dt)
    paddle2:update(dt)
    if love.keyboard.isDown('w') then
        -- move paddles only verticaly
        paddle1.dy = -PADDLE_SPEED

    elseif love.keyboard.isDown('s') then
        paddle1.dy = PADDLE_SPEED
    else
        paddle1.dy = 0
    end
    if love.keyboard.isDown('up') then
        paddle2.dy = - PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        paddle2.dy = PADDLE_SPEED
    else
        paddle2.dy = 0
    end   

end

function score()
    if ball.x <= 0 then
        player2Score = player2Score + 1
        ball:reset()
    end
    if ball.x >= VIRTUAL_WIDTH -4 then
        player1Score = player1Score + 1
        ball:reset()
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        elseif gameState == 'play' then
            ball:reset()
            player1Score = 0
            player2Score = 0
            gameState = 'start'           
        end
    end
    if key == 'space' then
        if gameState == 'start' then
            gameState = 'play'
        elseif gameState == 'play' then
            gameState = 'start'
        end
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
    ball:render()
    paddle1:render()
    paddle2:render()  

    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.printf('Welcome to Pong!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Start', 0, 40, VIRTUAL_WIDTH + 20, 'center')
    end
    if gameState == 'play' then
        love.graphics.printf('', 0, 20, VIRTUAL_WIDTH, 'center')
    end
    love.graphics.setFont(scoreFont)
    love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
    push:apply('end')

    -- Displaying FPS
    displayFPS()
    end

    function displayFPS()
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.setFont(smallFont)
        love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
        love.graphics.setColor(1, 1, 1, 1)
    end