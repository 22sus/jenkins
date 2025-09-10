<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>2D Platformer Game</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            background-color: #34495e;
            color: white;
            font-family: Arial, sans-serif;
            margin: 0;
            height: 100vh;
        }
        canvas {
            background-color: #7f8c8d;
            border: 5px solid #bdc3c7;
            box-shadow: 0 0 25px rgba(0, 0, 0, 0.5);
        }
        .info {
            margin-top: 10px;
            font-size: 1.2em;
        }
    </style>
</head>
<body>

    <div class="info">
        Coins: <span id="coinCount">0</span> / 3 | Lives: <span id="lives">3</span>
    </div>
    <canvas id="gameCanvas" width="800" height="400"></canvas>
    
    <script>
        const canvas = document.getElementById('gameCanvas');
        const ctx = canvas.getContext('2d');

        // Game State
        let lives = 3;
        let coinsCollected = 0;
        const totalCoins = 3;

        // Player
        const player = {
            x: 50,
            y: 350,
            width: 30,
            height: 30,
            color: '#2ecc71',
            dx: 0,
            dy: 0,
            gravity: 0.5,
            jumpStrength: -10,
            isJumping: false,
            onGround: false
        };

        // Keyboard Input
        const keys = {
            left: false,
            right: false,
            up: false
        };

        // Map and Tiles
        const TILE_SIZE = 40;
        const MAP_ROWS = canvas.height / TILE_SIZE;
        const MAP_COLS = canvas.width / TILE_SIZE;

        // 0: empty, 1: block, 2: coin
        const map = [
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
            [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
            [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
            [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
            [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
            [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
            [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
        ];

        // Add some platforms and coins
        map[12][2] = 1;
        map[12][3] = 1;
        map[11][5] = 1;
        map[11][6] = 1;
        map[10][8] = 2; // Coin
        map[9][10] = 1;
        map[9][11] = 1;
        map[8][13] = 2; // Coin
        map[7][15] = 1;
        map[6][17] = 2; // Coin

        // Game Logic
        function drawPlayer() {
            ctx.fillStyle = player.color;
            ctx.fillRect(player.x, player.y, player.width, player.height);
        }

        function drawMap() {
            for (let r = 0; r < MAP_ROWS; r++) {
                for (let c = 0; c < MAP_COLS; c++) {
                    const tile = map[r][c];
                    const x = c * TILE_SIZE;
                    const y = r * TILE_SIZE;
                    
                    if (tile === 1) {
                        ctx.fillStyle = '#95a5a6';
                        ctx.fillRect(x, y, TILE_SIZE, TILE_SIZE);
                    } else if (tile === 2) {
                        ctx.fillStyle = '#f1c40f';
                        ctx.beginPath();
                        ctx.arc(x + TILE_SIZE / 2, y + TILE_SIZE / 2, TILE_SIZE / 3, 0, Math.PI * 2);
                        ctx.fill();
                        ctx.closePath();
                    }
                }
            }
        }

        function updatePlayer() {
            // Apply gravity
            player.dy += player.gravity;

            // Horizontal movement
            if (keys.left) {
                player.dx = -4;
            } else if (keys.right) {
                player.dx = 4;
            } else {
                player.dx = 0;
            }

            // Jump
            if (keys.up && player.onGround) {
                player.dy = player.jumpStrength;
                player.isJumping = true;
                player.onGround = false;
            }

            // Update position
            player.x += player.dx;
            player.y += player.dy;

            // Check for ground collision
            player.onGround = false;
            // Check below player
            const playerBottomRow = Math.floor((player.y + player.height) / TILE_SIZE);
            const playerLeftCol = Math.floor(player.x / TILE_SIZE);
            const playerRightCol = Math.floor((player.x + player.width) / TILE_SIZE);

            if (playerBottomRow < MAP_ROWS) {
                if (map[playerBottomRow][playerLeftCol] === 1 || map[playerBottomRow][playerRightCol] === 1) {
                    player.y = playerBottomRow * TILE_SIZE - player.height;
                    player.dy = 0;
                    player.onGround = true;
                }
            }

            // Coin collision
            const coinRow = Math.floor((player.y + player.height / 2) / TILE_SIZE);
            const coinCol = Math.floor((player.x + player.width / 2) / TILE_SIZE);
            if (coinRow >= 0 && coinRow < MAP_ROWS && coinCol >= 0 && coinCol < MAP_COLS) {
                if (map[coinRow][coinCol] === 2) {
                    map[coinRow][coinCol] = 0;
                    coinsCollected++;
                    document.getElementById('coinCount').textContent = coinsCollected;
                    if (coinsCollected === totalCoins) {
                        alert("You won! 🎉");
                        document.location.reload();
                    }
                }
            }

            // Fall off screen
            if (player.y > canvas.height) {
                lives--;
                document.getElementById('lives').textContent = lives;
                if (lives === 0) {
                    alert("Game Over! 💀");
                    document.location.reload();
                } else {
                    player.x = 50;
                    player.y = 350;
                    player.dx = 0;
                    player.dy = 0;
                    player.onGround = true;
                }
            }
        }

        // Game Loop
        function gameLoop() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            drawMap();
            drawPlayer();
            updatePlayer();
            
            requestAnimationFrame(gameLoop);
        }

        // Event Listeners
        document.addEventListener('keydown', (e) => {
            if (e.key === 'ArrowLeft' || e.key === 'Left') {
                keys.left = true;
            }
            if (e.key === 'ArrowRight' || e.key === 'Right') {
                keys.right = true;
            }
            if (e.key === 'ArrowUp' || e.key === 'Up') {
                keys.up = true;
            }
        });

        document.addEventListener('keyup', (e) => {
            if (e.key === 'ArrowLeft' || e.key === 'Left') {
                keys.left = false;
            }
            if (e.key === 'ArrowRight' || e.key === 'Right') {
                keys.right = false;
            }
            if (e.key === 'ArrowUp' || e.key === 'Up') {
                keys.up = false;
            }
        });

        // Start the game
        gameLoop();
    </script>
</body>
</html>