<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>벽돌 깨기 게임</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(to right, #4facfe, #00f2fe);
            font-family: Arial, sans-serif;
            flex-direction: column;
            color: white;
        }
        canvas {
            background: #000;
            border: 5px solid #fff;
            box-shadow: 0 0 20px rgba(255, 255, 255, 0.5);
        }
        .info {
            margin-top: 20px;
            font-size: 1.2em;
            text-shadow: 1px 1px 2px #000;
        }
    </style>
</head>
<body>

    <div class="info">점수: <span id="score">0</span> | 목숨: <span id="lives">3</span></div>
    <canvas id="gameCanvas" width="480" height="320"></canvas>

    <script>
        // Canvas 설정
        const canvas = document.getElementById("gameCanvas");
        const ctx = canvas.getContext("2d");

        // 게임 변수
        let score = 0;
        let lives = 3;

        // 공 (Ball)
        let ballRadius = 10;
        let x = canvas.width / 2;
        let y = canvas.height - 30;
        let dx = 2;
        let dy = -2;

        // 패들 (Paddle)
        let paddleHeight = 10;
        let paddleWidth = 75;
        let paddleX = (canvas.width - paddleWidth) / 2;
        let rightPressed = false;
        let leftPressed = false;

        // 벽돌 (Bricks)
        const brickRowCount = 3;
        const brickColumnCount = 5;
        const brickWidth = 75;
        const brickHeight = 20;
        const brickPadding = 10;
        const brickOffsetTop = 30;
        const brickOffsetLeft = 30;
        const bricks = [];
        for (let c = 0; c < brickColumnCount; c++) {
            bricks[c] = [];
            for (let r = 0; r < brickRowCount; r++) {
                bricks[c][r] = { x: 0, y: 0, status: 1 };
            }
        }

        // 이벤트 리스너
        document.addEventListener("keydown", keyDownHandler, false);
        document.addEventListener("keyup", keyUpHandler, false);
        document.addEventListener("mousemove", mouseMoveHandler, false);

        function keyDownHandler(e) {
            if (e.key === "Right" || e.key === "ArrowRight") {
                rightPressed = true;
            } else if (e.key === "Left" || e.key === "ArrowLeft") {
                leftPressed = true;
            }
        }

        function keyUpHandler(e) {
            if (e.key === "Right" || e.key === "ArrowRight") {
                rightPressed = false;
            } else if (e.key === "Left" || e.key === "ArrowLeft") {
                leftPressed = false;
            }
        }

        function mouseMoveHandler(e) {
            const relativeX = e.clientX - canvas.offsetLeft;
            if (relativeX > 0 && relativeX < canvas.width) {
                paddleX = relativeX - paddleWidth / 2;
            }
        }

        function collisionDetection() {
            for (let c = 0; c < brickColumnCount; c++) {
                for (let r = 0; r < brickRowCount; r++) {
                    const b = bricks[c][r];
                    if (b.status === 1) {
                        if (x > b.x && x < b.x + brickWidth && y > b.y && y < b.y + brickHeight) {
                            dy = -dy;
                            b.status = 0;
                            score++;
                            if (score === brickRowCount * brickColumnCount) {
                                alert("승리했습니다! 🎉🎉");
                                document.location.reload();
                            }
                        }
                    }
                }
            }
        }

        function drawBall() {
            ctx.beginPath();
            ctx.arc(x, y, ballRadius, 0, Math.PI * 2);
            ctx.fillStyle = "#fff";
            ctx.fill();
            ctx.closePath();
        }

        function drawPaddle() {
            ctx.beginPath();
            ctx.rect(paddleX, canvas.height - paddleHeight, paddleWidth, paddleHeight);
            ctx.fillStyle = "#fff";
            ctx.fill();
            ctx.closePath();
        }

        function drawBricks() {
            for (let c = 0; c < brickColumnCount; c++) {
                for (let r = 0; r < brickRowCount; r++) {
                    if (bricks[c][r].status === 1) {
                        const brickX = (c * (brickWidth + brickPadding)) + brickOffsetLeft;
                        const brickY = (r * (brickHeight + brickPadding)) + brickOffsetTop;
                        bricks[c][r].x = brickX;
                        bricks[c][r].y = brickY;
                        ctx.beginPath();
                        ctx.rect(brickX, brickY, brickWidth, brickHeight);
                        ctx.fillStyle = "#0095DD";
                        ctx.fill();
                        ctx.closePath();
                    }
                }
            }
        }

        function drawScoreAndLives() {
            document.getElementById("score").textContent = score;
            document.getElementById("lives").textContent = lives;
        }

        function draw() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            drawBricks();
            drawBall();
            drawPaddle();
            drawScoreAndLives();
            collisionDetection();

            // 공의 경계 충돌 처리
            if (x + dx > canvas.width - ballRadius || x + dx < ballRadius) {
                dx = -dx;
            }
            if (y + dy < ballRadius) {
                dy = -dy;
            } else if (y + dy > canvas.height - ballRadius) {
                if (x > paddleX && x < paddleX + paddleWidth) {
                    dy = -dy;
                } else {
                    lives--;
                    if (!lives) {
                        alert("게임 오버! 😢");
                        document.location.reload();
                    } else {
                        x = canvas.width / 2;
                        y = canvas.height - 30;
                        dx = 2;
                        dy = -2;
                        paddleX = (canvas.width - paddleWidth) / 2;
                    }
                }
            }

            // 패들 이동
            if (rightPressed && paddleX < canvas.width - paddleWidth) {
                paddleX += 7;
            } else if (leftPressed && paddleX > 0) {
                paddleX -= 7;
            }

            // 공 이동
            x += dx;
            y += dy;

            requestAnimationFrame(draw);
        }

        // 게임 시작
        draw();
    </script>
</body>
</html>