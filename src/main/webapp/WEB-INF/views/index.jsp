<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Galaxy Defender - 우주선 슈팅 게임</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            background: linear-gradient(135deg, #0c0c0c 0%, #1a1a2e 50%, #16213e 100%);
            font-family: 'Courier New', monospace;
            overflow: hidden;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .game-container {
            position: relative;
            border: 3px solid #00ffff;
            border-radius: 10px;
            box-shadow: 0 0 30px #00ffff;
        }

        #gameCanvas {
            background: radial-gradient(circle at center, #001122 0%, #000511 100%);
            display: block;
        }

        .game-ui {
            position: absolute;
            top: 10px;
            left: 10px;
            color: #00ffff;
            font-size: 18px;
            text-shadow: 0 0 10px #00ffff;
            z-index: 10;
        }

        .game-over {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: rgba(0, 0, 0, 0.9);
            padding: 40px;
            border-radius: 15px;
            text-align: center;
            color: #00ffff;
            border: 2px solid #00ffff;
            display: none;
            z-index: 20;
        }

        .game-over h2 {
            font-size: 32px;
            margin-bottom: 20px;
            text-shadow: 0 0 15px #00ffff;
        }

        .game-over button {
            background: linear-gradient(45deg, #00ffff, #0099cc);
            border: none;
            padding: 15px 30px;
            font-size: 18px;
            border-radius: 8px;
            cursor: pointer;
            color: #000;
            font-weight: bold;
            margin: 10px;
            transition: all 0.3s;
        }

        .game-over button:hover {
            transform: scale(1.1);
            box-shadow: 0 0 20px #00ffff;
        }

        .instructions {
            position: absolute;
            bottom: 10px;
            right: 10px;
            color: #00ffff;
            font-size: 12px;
            text-align: right;
            opacity: 0.7;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        .pulse {
            animation: pulse 1s infinite;
        }
    </style>
</head>
<body>
    <div class="game-container">
        <canvas id="gameCanvas" width="800" height="600"></canvas>
        
        <div class="game-ui">
            <div>점수: <span id="score">0</span></div>
            <div>레벨: <span id="level">1</span></div>
            <div>생명: <span id="lives">3</span></div>
            <div>적 처치: <span id="enemiesKilled">0</span></div>
        </div>

        <div class="game-over" id="gameOver">
            <h2>게임 오버!</h2>
            <p>최종 점수: <span id="finalScore">0</span></p>
            <p>적 처치 수: <span id="finalEnemiesKilled">0</span></p>
            <button onclick="restartGame()">다시 시작</button>
        </div>

        <div class="instructions">
            <div>WASD 또는 화살표키: 이동</div>
            <div>스페이스바: 발사</div>
            <div>P: 일시정지</div>
        </div>
    </div>

    <script>
        class Game {
            constructor() {
                this.canvas = document.getElementById('gameCanvas');
                this.ctx = this.canvas.getContext('2d');
                this.width = this.canvas.width;
                this.height = this.canvas.height;
                
                this.player = new Player(this.width / 2, this.height - 50);
                this.bullets = [];
                this.enemies = [];
                this.explosions = [];
                this.powerUps = [];
                this.stars = [];
                
                this.score = 0;
                this.level = 1;
                this.lives = 3;
                this.enemiesKilled = 0;
                this.gameRunning = true;
                this.paused = false;
                
                this.enemySpawnRate = 120;
                this.enemySpawnCounter = 0;
                
                this.keys = {};
                this.lastTime = 0;
                
                this.initStars();
                this.bindEvents();
                this.gameLoop();
            }

            initStars() {
                for (let i = 0; i < 100; i++) {
                    this.stars.push({
                        x: Math.random() * this.width,
                        y: Math.random() * this.height,
                        size: Math.random() * 2,
                        speed: Math.random() * 2 + 1,
                        brightness: Math.random() * 0.8 + 0.2
                    });
                }
            }

            bindEvents() {
                document.addEventListener('keydown', (e) => {
                    this.keys[e.code] = true;
                    
                    if (e.code === 'KeyP') {
                        this.paused = !this.paused;
                    }
                });

                document.addEventListener('keyup', (e) => {
                    this.keys[e.code] = false;
                });
            }

            update(deltaTime) {
                if (this.paused || !this.gameRunning) return;

                this.updateStars();
                this.updatePlayer();
                this.updateBullets();
                this.updateEnemies();
                this.updateExplosions();
                this.updatePowerUps();
                this.checkCollisions();
                this.spawnEnemies();
                this.updateLevel();
                this.updateUI();
            }

            updateStars() {
                this.stars.forEach(star => {
                    star.y += star.speed;
                    if (star.y > this.height) {
                        star.y = 0;
                        star.x = Math.random() * this.width;
                    }
                });
            }

            updatePlayer() {
                // 플레이어 이동
                if (this.keys['KeyA'] || this.keys['ArrowLeft']) {
                    this.player.x = Math.max(this.player.width / 2, this.player.x - this.player.speed);
                }
                if (this.keys['KeyD'] || this.keys['ArrowRight']) {
                    this.player.x = Math.min(this.width - this.player.width / 2, this.player.x + this.player.speed);
                }
                if (this.keys['KeyW'] || this.keys['ArrowUp']) {
                    this.player.y = Math.max(this.player.height / 2, this.player.y - this.player.speed);
                }
                if (this.keys['KeyS'] || this.keys['ArrowDown']) {
                    this.player.y = Math.min(this.height - this.player.height / 2, this.player.y + this.player.speed);
                }

                // 발사
                if (this.keys['Space']) {
                    this.player.shoot(this.bullets);
                }

                this.player.update();
            }

            updateBullets() {
                this.bullets = this.bullets.filter(bullet => {
                    bullet.update();
                    return bullet.y > -10;
                });
            }

            updateEnemies() {
                this.enemies = this.enemies.filter(enemy => {
                    enemy.update();
                    return enemy.y < this.height + 50 && enemy.health > 0;
                });
            }

            updateExplosions() {
                this.explosions = this.explosions.filter(explosion => {
                    explosion.update();
                    return !explosion.finished;
                });
            }

            updatePowerUps() {
                this.powerUps = this.powerUps.filter(powerUp => {
                    powerUp.update();
                    return powerUp.y < this.height + 50;
                });
            }

            spawnEnemies() {
                this.enemySpawnCounter++;
                if (this.enemySpawnCounter >= this.enemySpawnRate) {
                    this.enemies.push(new Enemy(Math.random() * (this.width - 60) + 30, -30, this.level));
                    this.enemySpawnCounter = 0;
                    
                    // 레벨에 따라 스폰 빈도 증가
                    this.enemySpawnRate = Math.max(30, 120 - this.level * 10);
                }
            }

            checkCollisions() {
                // 총알과 적 충돌
                this.bullets.forEach((bullet, bulletIndex) => {
                    this.enemies.forEach((enemy, enemyIndex) => {
                        if (this.isColliding(bullet, enemy)) {
                            enemy.takeDamage(bullet.damage);
                            this.bullets.splice(bulletIndex, 1);
                            
                            if (enemy.health <= 0) {
                                this.createExplosion(enemy.x, enemy.y);
                                this.score += enemy.points;
                                this.enemiesKilled++;
                                
                                // 파워업 드롭 확률
                                if (Math.random() < 0.15) {
                                    this.powerUps.push(new PowerUp(enemy.x, enemy.y));
                                }
                                
                                this.enemies.splice(enemyIndex, 1);
                            }
                        }
                    });
                });

                // 플레이어와 적 충돌
                this.enemies.forEach((enemy, enemyIndex) => {
                    if (this.isColliding(this.player, enemy)) {
                        this.createExplosion(enemy.x, enemy.y);
                        this.enemies.splice(enemyIndex, 1);
                        this.lives--;
                        
                        if (this.lives <= 0) {
                            this.gameOver();
                        }
                    }
                });

                // 플레이어와 파워업 충돌
                this.powerUps.forEach((powerUp, powerUpIndex) => {
                    if (this.isColliding(this.player, powerUp)) {
                        this.player.applyPowerUp(powerUp.type);
                        this.powerUps.splice(powerUpIndex, 1);
                    }
                });
            }

            isColliding(obj1, obj2) {
                return obj1.x < obj2.x + obj2.width &&
                       obj1.x + obj1.width > obj2.x &&
                       obj1.y < obj2.y + obj2.height &&
                       obj1.y + obj1.height > obj2.y;
            }

            createExplosion(x, y) {
                this.explosions.push(new Explosion(x, y));
            }

            updateLevel() {
                const newLevel = Math.floor(this.enemiesKilled / 10) + 1;
                if (newLevel > this.level) {
                    this.level = newLevel;
                }
            }

            updateUI() {
                document.getElementById('score').textContent = this.score;
                document.getElementById('level').textContent = this.level;
                document.getElementById('lives').textContent = this.lives;
                document.getElementById('enemiesKilled').textContent = this.enemiesKilled;
            }

            gameOver() {
                this.gameRunning = false;
                document.getElementById('finalScore').textContent = this.score;
                document.getElementById('finalEnemiesKilled').textContent = this.enemiesKilled;
                document.getElementById('gameOver').style.display = 'block';
            }

            render() {
                // 배경 클리어
                this.ctx.fillStyle = 'rgba(0, 5, 17, 0.1)';
                this.ctx.fillRect(0, 0, this.width, this.height);

                // 별 그리기
                this.ctx.fillStyle = '#ffffff';
                this.stars.forEach(star => {
                    this.ctx.globalAlpha = star.brightness;
                    this.ctx.fillRect(star.x, star.y, star.size, star.size);
                });
                this.ctx.globalAlpha = 1;

                // 게임 오브젝트 그리기
                this.player.render(this.ctx);
                this.bullets.forEach(bullet => bullet.render(this.ctx));
                this.enemies.forEach(enemy => enemy.render(this.ctx));
                this.explosions.forEach(explosion => explosion.render(this.ctx));
                this.powerUps.forEach(powerUp => powerUp.render(this.ctx));

                // 일시정지 표시
                if (this.paused) {
                    this.ctx.fillStyle = 'rgba(0, 255, 255, 0.8)';
                    this.ctx.font = '48px Courier New';
                    this.ctx.textAlign = 'center';
                    this.ctx.fillText('PAUSED', this.width / 2, this.height / 2);
                    this.ctx.textAlign = 'left';
                }
            }

            gameLoop(currentTime = 0) {
                const deltaTime = currentTime - this.lastTime;
                this.lastTime = currentTime;

                this.update(deltaTime);
                this.render();

                requestAnimationFrame((time) => this.gameLoop(time));
            }
        }

        class Player {
            constructor(x, y) {
                this.x = x;
                this.y = y;
                this.width = 40;
                this.height = 40;
                this.speed = 5;
                this.shootCooldown = 0;
                this.maxCooldown = 15;
                this.bulletDamage = 1;
                this.powerUpTime = 0;
            }

            update() {
                if (this.shootCooldown > 0) this.shootCooldown--;
                if (this.powerUpTime > 0) this.powerUpTime--;
            }

            shoot(bullets) {
                if (this.shootCooldown <= 0) {
                    bullets.push(new Bullet(this.x, this.y - 20, -8, this.bulletDamage));
                    this.shootCooldown = this.maxCooldown;
                    
                    // 파워업 상태일 때 추가 총알
                    if (this.powerUpTime > 0) {
                        bullets.push(new Bullet(this.x - 15, this.y - 20, -8, this.bulletDamage));
                        bullets.push(new Bullet(this.x + 15, this.y - 20, -8, this.bulletDamage));
                    }
                }
            }

            applyPowerUp(type) {
                if (type === 'multiShot') {
                    this.powerUpTime = 300; // 5초
                } else if (type === 'damage') {
                    this.bulletDamage = 2;
                    setTimeout(() => this.bulletDamage = 1, 5000);
                }
            }

            render(ctx) {
                // 플레이어 우주선 그리기
                ctx.fillStyle = this.powerUpTime > 0 ? '#ff00ff' : '#00ffff';
                ctx.beginPath();
                ctx.moveTo(this.x, this.y - 20);
                ctx.lineTo(this.x - 20, this.y + 20);
                ctx.lineTo(this.x + 20, this.y + 20);
                ctx.closePath();
                ctx.fill();

                // 엔진 불꽃
                ctx.fillStyle = '#ffff00';
                ctx.fillRect(this.x - 5, this.y + 15, 3, 10);
                ctx.fillRect(this.x + 2, this.y + 15, 3, 10);
            }
        }

        class Bullet {
            constructor(x, y, velocityY, damage = 1) {
                this.x = x;
                this.y = y;
                this.width = 4;
                this.height = 10;
                this.velocityY = velocityY;
                this.damage = damage;
            }

            update() {
                this.y += this.velocityY;
            }

            render(ctx) {
                ctx.fillStyle = '#ffff00';
                ctx.fillRect(this.x - 2, this.y, this.width, this.height);
                
                // 발광 효과
                ctx.shadowColor = '#ffff00';
                ctx.shadowBlur = 10;
                ctx.fillRect(this.x - 1, this.y, 2, this.height);
                ctx.shadowBlur = 0;
            }
        }

        class Enemy {
            constructor(x, y, level) {
                this.x = x;
                this.y = y;
                this.width = 30;
                this.height = 30;
                this.speed = 2 + level * 0.5;
                this.health = level;
                this.maxHealth = level;
                this.points = level * 10;
                this.color = this.getColorByLevel(level);
            }

            getColorByLevel(level) {
                const colors = ['#ff0000', '#ff8800', '#ffff00', '#00ff00', '#0088ff', '#8800ff'];
                return colors[Math.min(level - 1, colors.length - 1)];
            }

            update() {
                this.y += this.speed;
            }

            takeDamage(damage) {
                this.health -= damage;
            }

            render(ctx) {
                // 적 우주선
                ctx.fillStyle = this.color;
                ctx.fillRect(this.x - 15, this.y - 15, this.width, this.height);
                
                // 체력 바
                if (this.health < this.maxHealth) {
                    ctx.fillStyle = '#ff0000';
                    ctx.fillRect(this.x - 15, this.y - 25, 30, 3);
                    ctx.fillStyle = '#00ff00';
                    ctx.fillRect(this.x - 15, this.y - 25, 30 * (this.health / this.maxHealth), 3);
                }
            }
        }

        class Explosion {
            constructor(x, y) {
                this.x = x;
                this.y = y;
                this.particles = [];
                this.finished = false;
                this.timer = 0;
                this.maxTime = 30;

                // 파티클 생성
                for (let i = 0; i < 10; i++) {
                    this.particles.push({
                        x: x,
                        y: y,
                        vx: (Math.random() - 0.5) * 8,
                        vy: (Math.random() - 0.5) * 8,
                        life: 1,
                        decay: Math.random() * 0.05 + 0.02
                    });
                }
            }

            update() {
                this.timer++;
                if (this.timer >= this.maxTime) {
                    this.finished = true;
                }

                this.particles.forEach(particle => {
                    particle.x += particle.vx;
                    particle.y += particle.vy;
                    particle.life -= particle.decay;
                });

                this.particles = this.particles.filter(particle => particle.life > 0);
            }

            render(ctx) {
                this.particles.forEach(particle => {
                    ctx.globalAlpha = particle.life;
                    ctx.fillStyle = `hsl(${60 - particle.life * 60}, 100%, 50%)`;
                    ctx.fillRect(particle.x - 2, particle.y - 2, 4, 4);
                });
                ctx.globalAlpha = 1;
            }
        }

        class PowerUp {
            constructor(x, y) {
                this.x = x;
                this.y = y;
                this.width = 20;
                this.height = 20;
                this.speed = 2;
                this.type = Math.random() < 0.5 ? 'multiShot' : 'damage';
                this.rotation = 0;
            }

            update() {
                this.y += this.speed;
                this.rotation += 0.1;
            }

            render(ctx) {
                ctx.save();
                ctx.translate(this.x, this.y);
                ctx.rotate(this.rotation);
                
                if (this.type === 'multiShot') {
                    ctx.fillStyle = '#00ff00';
                    ctx.fillRect(-10, -10, 20, 20);
                    ctx.fillStyle = '#ffffff';
                    ctx.font = '12px Arial';
                    ctx.textAlign = 'center';
                    ctx.fillText('M', 0, 4);
                } else {
                    ctx.fillStyle = '#ff8800';
                    ctx.fillRect(-10, -10, 20, 20);
                    ctx.fillStyle = '#ffffff';
                    ctx.font = '12px Arial';
                    ctx.textAlign = 'center';
                    ctx.fillText('D', 0, 4);
                }
                
                ctx.restore();
            }
        }

        // 게임 시작
        let game;

        function startGame() {
            game = new Game();
        }

        function restartGame() {
            document.getElementById('gameOver').style.display = 'none';
            startGame();
        }

        // 페이지 로드 시 게임 시작
        window.addEventListener('load', startGame);
    </script>
</body>
</html>
