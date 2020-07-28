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
    -- Audio Object
    sounds = {
        ['paddleHitSound'] = love.audio.newSource('collisionSound.wav', 'static'),
        ['scoreSound'] = love.audio.newSource('scoreSound.wav', 'static'),
        ['wallHitSound'] = love.audio.newSource('wallCollideSound.wav', 'static')
    }  
    -- Variables
    player1Score = 0
    player2Score = 0
    servingPlayer = math.random(2) == 1 and 2
    victoryPlayer = ""
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
            sounds['paddleHitSound']:play()
        end

        if ball:collides(paddle2) then
            -- deflect ball to the left
            ball.dx = -ball.dx
            sounds['paddleHitSound']:play()
        end

        if ball.y <= 0 then
            ball.dy = -ball.dy
            ball.y = 0
            sounds['wallHitSound']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - 4
            sounds['wallHitSound']:play()
        end

        if ball.x <= 0 or ball.x >= VIRTUAL_WIDTH - 4 then
            score()
            sounds['scoreSound']:play()
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
        servingPlayer = 1
        ball.dx = 100       
    end
    if ball.x >= VIRTUAL_WIDTH -4 then
        player1Score = player1Score + 1
        ball:reset()    
        servingPlayer = 2
        ball.dx = -100  
    end
    if player1Score == 4 then
        victoryPlayer = 1
        gameState = 'victory'
    elseif player2Score == 4 then
        victoryPlayer = 2
        gameState = 'victory'
    else 
        gameState = 'serve'
    end  
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' or gameState == 'serve' then
            gameState = 'play'
        end
    end

    if key == 'r' then
        resetGame()               
    end
    -- Pause button
    if key == 'space' then
        pauseGame()
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
    ball:render()
    paddle1:render()
    paddle2:render()  

    displayGameState()
    displayScore()

    push:apply('end')

    -- Displaying FPS
    displayFPS()
    end

    function displayScore()
        love.graphics.setFont(scoreFont)
        love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
        love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
    end

    function displayGameState()
        love.graphics.setFont(smallFont)
        if gameState == 'start' then
            love.graphics.printf('Welcome to Pong!', 0, 20, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('Press Enter to start', 0, 40, VIRTUAL_WIDTH + 20, 'center')
        elseif gameState == 'pause' then
            love.graphics.printf('Game paused', 0, 20, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('Press Space to continue', 0, 40, VIRTUAL_WIDTH + 20, 'center')
        elseif gameState == 'serve' then
            love.graphics.printf('Serving player: ' .. tostring(servingPlayer == 1 and 'Player 2' or 'Player 1'), 0, 20, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('Press Enter to serve', 0, 40, VIRTUAL_WIDTH + 20, 'center')
        elseif gameState == 'victory' then
            love.graphics.printf('Player ' .. tostring(victoryPlayer)  .. ' Wins!', 0, 20, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('Press R to restart', 0, 40, VIRTUAL_WIDTH + 20, 'center')
        else
            love.graphics.printf('', 0, 20, VIRTUAL_WIDTH, 'center')
        end
    end

    function resetGame()
        ball:reset()
        player1Score = 0
        player2Score = 0
        gameState = 'start'  
    end

    function pauseGame()
        if gameState == 'play' then
            gameState = 'pause'
        elseif gameState == 'pause' then
            gameState = 'play'
        end
    end

    function displayFPS()
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.setFont(smallFont)
        love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
        love.graphics.setColor(1, 1, 1, 1)
    end