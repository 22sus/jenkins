<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RPG 던전 탐험</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: #2c3e50; /* 어두운 배경 */
            color: #ecf0f1;
            font-family: 'Courier New', Courier, monospace;
            flex-direction: column;
        }
        canvas {
            background: #34495e;
            border: 5px solid #bdc3c7;
            box-shadow: 0 0 25px rgba(0, 0, 0, 0.5);
        }
        .game-status {
            display: flex;
            justify-content: space-between;
            width: 500px;
            margin-top: 20px;
            padding: 10px;
            border: 2px solid #3498db;
            background: #2980b9;
        }
        .game-status div {
            flex-basis: 30%;
        }
        .log-container {
            width: 500px;
            height: 100px;
            background: #2c3e50;
            border: 2px solid #7f8c8d;
            margin-top: 10px;
            padding: 10px;
            overflow-y: scroll;
            color: #ecf0f1;
        }
        .log {
            margin: 0;
        }
    </style>
</head>
<body>

    <h2>던전 탐험 게임</h2>
    <canvas id="gameCanvas" width="500" height="500"></canvas>
    
    <div class="game-status">
        <div>플레이어 HP: <span id="playerHp">100</span></div>
        <div>플레이어 ATK: <span id="playerAtk">10</span></div>
        <div>아이템: <span id="itemsFound">0</span></div>
    </div>

    <div class="log-container">
        <p class="log" id="gameLog">게임 시작! 던전을 탐험하세요...</p>
    </div>

    <script>
        const canvas = document.getElementById("gameCanvas");
        const ctx = canvas.getContext("2d");

        // 게임 변수
        const tileSize = 50;
        const mapSize = 10;
        
        const player = {
            x: 1,
            y: 1,
            hp: 100,
            attack: 10,
            items: 0
        };

        const enemies = [
            { x: 5, y: 5, hp: 30, attack: 5 },
            { x: 8, y: 2, hp: 40, attack: 7 },
            { x: 2, y: 8, hp: 20, attack: 3 }
        ];

        const items = [
            { x: 3, y: 7, type: 'sword', value: 5 },
            { x: 6, y: 1, type: 'potion', value: 20 }
        ];

        // 지도 (0: 벽, 1: 길, 2: 아이템, 3: 적)
        const map = [
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 1, 1, 1, 0, 1, 1, 1, 1, 0],
            [0, 1, 0, 1, 0, 1, 0, 0, 1, 0],
            [0, 1, 0, 1, 1, 1, 0, 1, 1, 0],
            [0, 1, 0, 0, 0, 0, 0, 1, 0, 0],
            [0, 1, 1, 1, 1, 1, 1, 1, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
            [0, 1, 1, 1, 1, 1, 1, 1, 0, 0],
            [0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        ];

        // UI 업데이트
        function updateUI() {
            document.getElementById("playerHp").textContent = player.hp;
            document.getElementById("playerAtk").textContent = player.attack;
            document.getElementById("itemsFound").textContent = player.items;
        }

        // 로그 기록
        function logMessage(message) {
            const logElement = document.getElementById("gameLog");
            const newLog = document.createElement("p");
            newLog.classList.add("log");
            newLog.textContent = `> ${message}`;
            logElement.prepend(newLog); // 최신 로그가 위에 오도록
        }

        // 게임 맵 그리기
        function drawMap() {
            for (let y = 0; y < mapSize; y++) {
                for (let x = 0; x < mapSize; x++) {
                    ctx.beginPath();
                    ctx.rect(x * tileSize, y * tileSize, tileSize, tileSize);
                    if (map[y][x] === 0) {
                        ctx.fillStyle = "#2c3e50"; // 벽
                    } else {
                        ctx.fillStyle = "#34495e"; // 길
                    }
                    ctx.fill();
                    ctx.closePath();
                }
            }
        }

        // 게임 요소(플레이어, 적, 아이템) 그리기
        function drawEntities() {
            // 적 그리기
            enemies.forEach(enemy => {
                ctx.beginPath();
                ctx.arc(enemy.x * tileSize + tileSize / 2, enemy.y * tileSize + tileSize / 2, tileSize / 3, 0, Math.PI * 2);
                ctx.fillStyle = "#e74c3c"; // 빨간색
                ctx.fill();
                ctx.closePath();
            });

            // 아이템 그리기
            items.forEach(item => {
                ctx.beginPath();
                ctx.rect(item.x * tileSize + tileSize/4, item.y * tileSize + tileSize/4, tileSize/2, tileSize/2);
                if (item.type === 'sword') {
                    ctx.fillStyle = "#f1c40f"; // 노란색
                } else {
                    ctx.fillStyle = "#3498db"; // 파란색
                }
                ctx.fill();
                ctx.closePath();
            });

            // 플레이어 그리기
            ctx.beginPath();
            ctx.arc(player.x * tileSize + tileSize / 2, player.y * tileSize + tileSize / 2, tileSize / 2.5, 0, Math.PI * 2);
            ctx.fillStyle = "#2ecc71"; // 초록색
            ctx.fill();
            ctx.closePath();
        }

        // 충돌 감지 및 상호작용
        function checkCollisions() {
            // 아이템 획득
            items.forEach((item, index) => {
                if (player.x === item.x && player.y === item.y) {
                    if (item.type === 'sword') {
                        player.attack += item.value;
                        logMessage(`공격력이 ${item.value} 증가했습니다!`);
                    } else if (item.type === 'potion') {
                        player.hp += item.value;
                        logMessage(`체력이 ${item.value} 회복되었습니다!`);
                    }
                    player.items++;
                    items.splice(index, 1); // 아이템 제거
                }
            });

            // 적과의 전투
            enemies.forEach(enemy => {
                if (player.x === enemy.x && player.y === enemy.y) {
                    logMessage("적이 길을 막고 있습니다. 스페이스바를 눌러 공격하세요!");
                }
            });
        }

        // 공격
        function attackEnemy() {
            const enemyIndex = enemies.findIndex(enemy => player.x === enemy.x && player.y === enemy.y);
            if (enemyIndex !== -1) {
                const enemy = enemies[enemyIndex];
                
                logMessage(`플레이어가 적을 공격하여 ${player.attack}의 피해를 입혔습니다!`);
                enemy.hp -= player.attack;

                if (enemy.hp <= 0) {
                    logMessage("적을 물리쳤습니다! 🎉");
                    enemies.splice(enemyIndex, 1);
                    if (enemies.length === 0) {
                        alert("모든 적을 물리치고 던전을 클리어했습니다!");
                        document.location.reload();
                    }
                } else {
                    player.hp -= enemy.attack;
                    logMessage(`적이 반격하여 ${enemy.attack}의 피해를 입었습니다! (남은 HP: ${player.hp})`);
                    if (player.hp <= 0) {
                        alert("게임 오버! 💀");
                        document.location.reload();
                    }
                }
            } else {
                logMessage("주변에 공격할 적이 없습니다.");
            }
            updateUI();
        }

        // 키보드 입력
        document.addEventListener('keydown', (e) => {
            let newX = player.x;
            let newY = player.y;

            if (e.key === "ArrowUp") newY--;
            if (e.key === "ArrowDown") newY++;
            if (e.key === "ArrowLeft") newX--;
            if (e.key === "ArrowRight") newX++;

            // 벽 충돌 체크
            if (newX >= 0 && newX < mapSize && newY >= 0 && newY < mapSize && map[newY][newX] === 1) {
                player.x = newX;
                player.y = newY;
                checkCollisions();
            } else if (e.key === " ") {
                e.preventDefault(); // 스페이스바 스크롤 방지
                attackEnemy();
            }

            draw();
            updateUI();
        });

        // 게임 시작
        function draw() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            drawMap();
            drawEntities();
            updateUI();
        }

        draw();
        updateUI();

    </script>
</body>
</html>