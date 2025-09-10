<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MapleStory Style RPG - 한국 온라인게임 스타일</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            background: linear-gradient(180deg, #87CEEB 0%, #98FB98 50%, #90EE90 100%);
            font-family: 'Arial', sans-serif;
            overflow: hidden;
            position: relative;
        }

        .game-container {
            position: relative;
            width: 100vw;
            height: 100vh;
        }

        #gameCanvas {
            display: block;
            background: linear-gradient(180deg, #87CEEB 0%, #98FB98 100%);
            image-rendering: pixelated;
        }

        .ui-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            z-index: 10;
        }

        .hp-mp-bar {
            position: absolute;
            top: 20px;
            left: 20px;
            display: flex;
            flex-direction: column;
            gap: 5px;
            pointer-events: auto;
        }

        .bar-container {
            width: 200px;
            height: 20px;
            background: rgba(0, 0, 0, 0.7);
            border: 2px solid #fff;
            border-radius: 10px;
            overflow: hidden;
            position: relative;
        }

        .hp-bar {
            height: 100%;
            background: linear-gradient(90deg, #ff4444, #ff6666);
            transition: width 0.3s ease;
        }

        .mp-bar {
            height: 100%;
            background: linear-gradient(90deg, #4444ff, #6666ff);
            transition: width 0.3s ease;
        }

        .exp-bar {
            height: 100%;
            background: linear-gradient(90deg, #ffaa00, #ffcc44);
            transition: width 0.3s ease;
        }

        .bar-text {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-weight: bold;
            font-size: 12px;
            text-shadow: 1px 1px 2px #000;
        }

        .character-info {
            position: absolute;
            top: 20px;
            right: 20px;
            background: rgba(0, 0, 0, 0.8);
            color: #fff;
            padding: 15px;
            border-radius: 10px;
            border: 2px solid #ffd700;
            font-size: 14px;
            pointer-events: auto;
        }

        .inventory {
            position: absolute;
            bottom: 20px;
            right: 20px;
            background: rgba(0, 0, 0, 0.9);
            color: #fff;
            padding: 15px;
            border-radius: 10px;
            border: 2px solid #4169e1;
            max-width: 300px;
            pointer-events: auto;
        }

        .inventory h3 {
            color: #ffd700;
            margin-bottom: 10px;
        }

        .item-list {
            display: flex;
            flex-wrap: wrap;
            gap: 5px;
        }

        .item {
            width: 40px;
            height: 40px;
            background: rgba(255, 255, 255, 0.2);
            border: 1px solid #fff;
            border-radius: 5px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            position: relative;
        }

        .item.potion { background: #ff69b4; }
        .item.coin { background: #ffd700; }
        .item.equipment { background: #4169e1; }

        .damage-text {
            position: absolute;
            color: #fff;
            font-weight: bold;
            font-size: 18px;
            text-shadow: 2px 2px 4px #000;
            pointer-events: none;
            z-index: 20;
        }

        .level-up-effect {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: #ffd700;
            font-size: 48px;
            font-weight: bold;
            text-shadow: 3px 3px 6px #000;
            animation: levelUpAnimation 2s ease-out forwards;
            pointer-events: none;
            z-index: 30;
        }

        @keyframes levelUpAnimation {
            0% {
                opacity: 0;
                transform: translate(-50%, -50%) scale(0.5);
            }
            50% {
                opacity: 1;
                transform: translate(-50%, -50%) scale(1.2);
            }
            100% {
                opacity: 0;
                transform: translate(-50%, -50%) scale(1);
            }
        }

        .controls {
            position: absolute;
            bottom: 20px;
            left: 20px;
            background: rgba(0, 0, 0, 0.8);
            color: #fff;
            padding: 10px;
            border-radius: 8px;
            font-size: 12px;
            pointer-events: auto;
        }

        .skill-bar {
            position: absolute;
            bottom: 80px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            gap: 10px;
            pointer-events: auto;
        }

        .skill-slot {
            width: 50px;
            height: 50px;
            background: rgba(0, 0, 0, 0.8);
            border: 2px solid #ffd700;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.2s;
        }

        .skill-slot:hover {
            background: rgba(255, 215, 0, 0.3);
            transform: scale(1.1);
        }

        .skill-slot.cooldown {
            opacity: 0.5;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <div class="game-container">
        <canvas id="gameCanvas" width="1200" height="800"></canvas>
        
        <div class="ui-overlay">
            <!-- HP/MP/EXP 바 -->
            <div class="hp-mp-bar">
                <div class="bar-container">
                    <div class="hp-bar" id="hpBar" style="width: 100%"></div>
                    <div class="bar-text" id="hpText">HP: 100/100</div>
                </div>
                <div class="bar-container">
                    <div class="mp-bar" id="mpBar" style="width: 100%"></div>
                    <div class="bar-text" id="mpText">MP: 50/50</div>
                </div>
                <div class="bar-container">
                    <div class="exp-bar" id="expBar" style="width: 0%"></div>
                    <div class="bar-text" id="expText">EXP: 0/100</div>
                </div>
            </div>

            <!-- 캐릭터 정보 -->
            <div class="character-info">
                <div><strong>용사</strong></div>
                <div>레벨: <span id="playerLevel">1</span></div>
                <div>공격력: <span id="playerAttack">10</span></div>
                <div>방어력: <span id="playerDefense">5</span></div>
                <div>골드: <span id="playerGold">0</span></div>
            </div>

            <!-- 인벤토리 -->
            <div class="inventory">
                <h3>인벤토리</h3>
                <div class="item-list" id="itemList">
                    <!-- 동적으로 아이템 추가됨 -->
                </div>
            </div>

            <!-- 스킬 바 -->
            <div class="skill-bar">
                <div class="skill-slot" onclick="useSkill(1)" id="skill1">
                    <div>파이어볼</div>
                </div>
                <div class="skill-slot" onclick="useSkill(2)" id="skill2">
                    <div>힐링</div>
                </div>
                <div class="skill-slot" onclick="useSkill(3)" id="skill3">
                    <div>스피드</div>
                </div>
            </div>

            <!-- 조작법 -->
            <div class="controls">
                <div>← → : 이동</div>
                <div>스페이스 : 점프</div>
                <div>Z : 공격</div>
                <div>X : 스킬1</div>
                <div>C : 스킬2</div>
                <div>V : 스킬3</div>
            </div>
        </div>
    </div>

    <script>
        class MapleRPG {
            constructor() {
                this.canvas = document.getElementById('gameCanvas');
                this.ctx = this.canvas.getContext('2d');
                this.width = this.canvas.width;
                this.height = this.canvas.height;

                // 게임 상태
                this.keys = {};
                this.camera = { x: 0, y: 0 };
                this.lastTime = 0;

                // 플레이어
                this.player = {
                    x: 200,
                    y: 400,
                    width: 40,
                    height: 60,
                    velocityX: 0,
                    velocityY: 0,
                    speed: 5,
                    jumpPower: 15,
                    onGround: false,
                    facing: 1, // 1: 오른쪽, -1: 왼쪽
                    hp: 100,
                    maxHp: 100,
                    mp: 50,
                    maxMp: 50,
                    level: 1,
                    exp: 0,
                    expToNext: 100,
                    attack: 10,
                    defense: 5,
                    gold: 0,
                    attackCooldown: 0,
                    isAttacking: false
                };

                // 게임 오브젝트들
                this.monsters = [];
                this.platforms = [];
                this.items = [];
                this.projectiles = [];
                this.effects = [];
                this.damageTexts = [];
                this.inventory = [];

                // 스킬 쿨다운
                this.skillCooldowns = {
                    1: 0, // 파이어볼
                    2: 0, // 힐링
                    3: 0  // 스피드
                };

                this.initWorld();
                this.bindEvents();
                this.gameLoop();
            }

            initWorld() {
                // 플랫폼 생성
                this.platforms = [
                    { x: 0, y: 700, width: 400, height: 100 },
                    { x: 500, y: 600, width: 200, height: 20 },
                    { x: 800, y: 500, width: 200, height: 20 },
                    { x: 1100, y: 400, width: 200, height: 20 },
                    { x: 1400, y: 650, width: 300, height: 150 },
                    { x: 1800, y: 550, width: 150, height: 20 },
                    { x: 2000, y: 700, width: 400, height: 100 }
                ];

                // 몬스터 생성
                this.spawnMonster(600, 580);
                this.spawnMonster(900, 480);
                this.spawnMonster(1200, 380);
                this.spawnMonster(1500, 630);
                this.spawnMonster(1900, 530);
            }

            spawnMonster(x, y) {
                const monsterTypes = [
                    { name: '슬라임', hp: 30, attack: 5, exp: 15, color: '#00ff00', speed: 1 },
                    { name: '고블린', hp: 50, attack: 8, exp: 25, color: '#8b4513', speed: 1.5 },
                    { name: '오크', hp: 80, attack: 12, exp: 40, color: '#ff4444', speed: 0.8 }
                ];

                const type = monsterTypes[Math.floor(Math.random() * monsterTypes.length)];
                
                this.monsters.push({
                    ...type,
                    x: x,
                    y: y,
                    width: 40,
                    height: 40,
                    maxHp: type.hp,
                    velocityX: 0,
                    velocityY: 0,
                    onGround: false,
                    direction: Math.random() > 0.5 ? 1 : -1,
                    lastDirectionChange: 0,
                    attackCooldown: 0,
                    isDead: false
                });
            }

            bindEvents() {
                document.addEventListener('keydown', (e) => {
                    this.keys[e.code] = true;
                    
                    // 스킬 단축키
                    if (e.code === 'KeyX') this.useSkill(1);
                    if (e.code === 'KeyC') this.useSkill(2);
                    if (e.code === 'KeyV') this.useSkill(3);
                });

                document.addEventListener('keyup', (e) => {
                    this.keys[e.code] = false;
                });
            }

            useSkill(skillNum) {
                if (this.skillCooldowns[skillNum] > 0) return;

                switch(skillNum) {
                    case 1: // 파이어볼
                        if (this.player.mp >= 10) {
                            this.castFireball();
                            this.player.mp -= 10;
                            this.skillCooldowns[1] = 180; // 3초
                        }
                        break;
                    case 2: // 힐링
                        if (this.player.mp >= 15 && this.player.hp < this.player.maxHp) {
                            this.castHealing();
                            this.player.mp -= 15;
                            this.skillCooldowns[2] = 300; // 5초
                        }
                        break;
                    case 3: // 스피드 부스트
                        if (this.player.mp >= 8) {
                            this.castSpeedBoost();
                            this.player.mp -= 8;
                            this.skillCooldowns[3] = 600; // 10초
                        }
                        break;
                }
                this.updateUI();
            }

            castFireball() {
                this.projectiles.push({
                    x: this.player.x + (this.player.facing > 0 ? this.player.width : 0),
                    y: this.player.y + 20,
                    width: 20,
                    height: 20,
                    velocityX: this.player.facing * 8,
                    velocityY: 0,
                    damage: this.player.attack * 1.5,
                    type: 'fireball',
                    life: 120
                });

                this.addEffect(this.player.x, this.player.y, 'cast', 30);
            }

            castHealing() {
                this.player.hp = Math.min(this.player.maxHp, this.player.hp + 30);
                this.addEffect(this.player.x, this.player.y, 'heal', 60);
                this.showDamageText(this.player.x, this.player.y - 20, '+30', '#00ff00');
            }

            castSpeedBoost() {
                // 임시 스피드 증가 효과 (실제로는 더 복잡한 버프 시스템 필요)
                this.player.speed = 8;
                setTimeout(() => {
                    this.player.speed = 5;
                }, 5000);
                this.addEffect(this.player.x, this.player.y, 'speed', 40);
            }

            update(deltaTime) {
                this.updatePlayer(deltaTime);
                this.updateMonsters(deltaTime);
                this.updateProjectiles();
                this.updateEffects();
                this.updateDamageTexts();
                this.updateCamera();
                this.checkCollisions();
                this.updateCooldowns();
                
                // MP 자동 회복
                if (this.player.mp < this.player.maxMp) {
                    this.player.mp = Math.min(this.player.maxMp, this.player.mp + 0.1);
                }
            }

            updatePlayer(deltaTime) {
                // 공격 쿨다운
                if (this.player.attackCooldown > 0) {
                    this.player.attackCooldown--;
                }

                // 좌우 이동
                this.player.velocityX = 0;
                if (this.keys['ArrowLeft'] || this.keys['KeyA']) {
                    this.player.velocityX = -this.player.speed;
                    this.player.facing = -1;
                }
                if (this.keys['ArrowRight'] || this.keys['KeyD']) {
                    this.player.velocityX = this.player.speed;
                    this.player.facing = 1;
                }

                // 점프
                if ((this.keys['Space'] || this.keys['ArrowUp'] || this.keys['KeyW']) && this.player.onGround) {
                    this.player.velocityY = -this.player.jumpPower;
                    this.player.onGround = false;
                }

                // 공격
                if (this.keys['KeyZ'] && this.player.attackCooldown <= 0) {
                    this.playerAttack();
                    this.player.attackCooldown = 30;
                    this.player.isAttacking = true;
                    setTimeout(() => this.player.isAttacking = false, 200);
                }

                // 중력
                this.player.velocityY += 0.8;

                // 위치 업데이트
                this.player.x += this.player.velocityX;
                this.player.y += this.player.velocityY;

                // 플랫폼 충돌 체크
                this.player.onGround = false;
                for (let platform of this.platforms) {
                    if (this.isColliding(this.player, platform)) {
                        if (this.player.velocityY > 0 && 
                            this.player.y < platform.y) {
                            this.player.y = platform.y - this.player.height;
                            this.player.velocityY = 0;
                            this.player.onGround = true;
                        }
                    }
                }

                // 화면 경계
                if (this.player.x < 0) this.player.x = 0;
                if (this.player.y > this.height) {
                    this.player.y = 400;
                    this.player.hp -= 10;
                    if (this.player.hp <= 0) this.gameOver();
                }
            }

            updateMonsters(deltaTime) {
                this.monsters = this.monsters.filter(monster => {
                    if (monster.isDead) return false;

                    // AI 행동
                    monster.lastDirectionChange++;
                    if (monster.lastDirectionChange > 180) { // 3초마다 방향 변경
                        monster.direction *= -1;
                        monster.lastDirectionChange = 0;
                    }

                    // 플레이어와 거리 체크 (추적)
                    const distToPlayer = Math.abs(this.player.x - monster.x);
                    if (distToPlayer < 200) {
                        monster.direction = this.player.x > monster.x ? 1 : -1;
                    }

                    monster.velocityX = monster.direction * monster.speed;
                    monster.velocityY += 0.8; // 중력

                    monster.x += monster.velocityX;
                    monster.y += monster.velocityY;

                    // 플랫폼 충돌
                    monster.onGround = false;
                    for (let platform of this.platforms) {
                        if (this.isColliding(monster, platform)) {
                            if (monster.velocityY > 0 && monster.y < platform.y) {
                                monster.y = platform.y - monster.height;
                                monster.velocityY = 0;
                                monster.onGround = true;
                            }
                        }
                    }

                    // 플레이어 공격
                    monster.attackCooldown--;
                    if (distToPlayer < 50 && monster.attackCooldown <= 0) {
                        this.monsterAttack(monster);
                        monster.attackCooldown = 90; // 1.5초
                    }

                    return true;
                });
            }

            updateProjectiles() {
                this.projectiles = this.projectiles.filter(projectile => {
                    projectile.x += projectile.velocityX;
                    projectile.y += projectile.velocityY;
                    projectile.life--;

                    // 몬스터와 충돌 체크
                    for (let i = 0; i < this.monsters.length; i++) {
                        const monster = this.monsters[i];
                        if (this.isColliding(projectile, monster)) {
                            this.damageMonster(monster, projectile.damage);
                            return false; // 투사체 제거
                        }
                    }

                    return projectile.life > 0 && 
                           projectile.x > -50 && projectile.x < this.width + 50;
                });
            }

            updateEffects() {
                this.effects = this.effects.filter(effect => {
                    effect.life--;
                    effect.scale += 0.02;
                    effect.alpha = effect.life / effect.maxLife;
                    return effect.life > 0;
                });
            }

            updateDamageTexts() {
                this.damageTexts = this.damageTexts.filter(text => {
                    text.y -= 2;
                    text.life--;
                    text.alpha = text.life / 60;
                    return text.life > 0;
                });
            }

            updateCamera() {
                const targetX = this.player.x - this.width / 2;
                this.camera.x += (targetX - this.camera.x) * 0.1;
                
                if (this.camera.x < 0) this.camera.x = 0;
            }

            updateCooldowns() {
                for (let skill in this.skillCooldowns) {
                    if (this.skillCooldowns[skill] > 0) {
                        this.skillCooldowns[skill]--;
                    }
                }

                // 스킬 UI 업데이트
                for (let i = 1; i <= 3; i++) {
                    const skillElement = document.getElementById(`skill${i}`);
                    if (this.skillCooldowns[i] > 0) {
                        skillElement.classList.add('cooldown');
                    } else {
                        skillElement.classList.remove('cooldown');
                    }
                }
            }

            playerAttack() {
                // 근접 공격 범위 내 몬스터 찾기
                const attackRange = {
                    x: this.player.x + (this.player.facing > 0 ? this.player.width : -60),
                    y: this.player.y,
                    width: 60,
                    height: this.player.height
                };

                for (let monster of this.monsters) {
                    if (this.isColliding(attackRange, monster)) {
                        this.damageMonster(monster, this.player.attack);
                    }
                }

                this.addEffect(
                    this.player.x + this.player.facing * 30, 
                    this.player.y + 20, 
                    'slash', 
                    20
                );
            }

            monsterAttack(monster) {
                const damage = Math.max(1, monster.attack - this.player.defense);
                this.player.hp -= damage;
                
                this.showDamageText(this.player.x, this.player.y - 20, `-${damage}`, '#ff4444');
                this.addEffect(this.player.x, this.player.y, 'hit', 20);

                if (this.player.hp <= 0) {
                    this.gameOver();
                }
                this.updateUI();
            }

            damageMonster(monster, damage) {
                monster.hp -= damage;
                this.showDamageText(monster.x, monster.y - 20, `-${damage}`, '#ffff00');

                if (monster.hp <= 0) {
                    this.killMonster(monster);
                }
            }

            killMonster(monster) {
                monster.isDead = true;
                
                // 경험치 획득
                this.player.exp += monster.exp;
                this.showDamageText(monster.x, monster.y - 40, `+${monster.exp} EXP`, '#00ffff');
                
                // 레벨업 체크
                if (this.player.exp >= this.player.expToNext) {
                    this.levelUp();
                }

                // 골드 획득
                const goldGain = Math.floor(Math.random() * 10) + 5;
                this.player.gold += goldGain;
                this.showDamageText(monster.x, monster.y - 60, `+${goldGain} G`, '#ffd700');

                // 아이템 드롭
                if (Math.random() < 0.3) { // 30% 확률
                    this.dropItem(monster.x, monster.y);
                }

                // 폭발 효과
                this.addEffect(monster.x, monster.y, 'explosion', 40);

                // 새 몬스터 스폰 (일정 확률로)
                if (Math.random() < 0.5) {
                    setTimeout(() => {
                        const spawnX = Math.random() * 2000 + 500;
                        const spawnY = 300;
                        this.spawnMonster(spawnX, spawnY);
                    }, 3000);
                }

                this.updateUI();
            }

            levelUp() {
                this.player.level++;
                this.player.exp = 0;
                this.player.expToNext = Math.floor(this.player.expToNext * 1.5);
                
                // 스탯 증가
                this.player.maxHp += 10;
                this.player.hp = this.player.maxHp; // 풀 회복
                this.player.maxMp += 5;
                this.player.mp = this.player.maxMp;
                this.player.attack += 2;
                this.player.defense += 1;

                // 레벨업 이펙트
                const levelUpDiv = document.createElement('div');
                levelUpDiv.className = 'level-up-effect';
                levelUpDiv.textContent = 'LEVEL UP!';
                document.body.appendChild(levelUpDiv);

                setTimeout(() => {
                    levelUpDiv.remove();
                }, 2000);

                this.updateUI();
            }

            dropItem(x, y) {
                const itemTypes = [
                    { type: 'potion', name: '포션', effect: 'heal', value: 25 },
                    { type: 'coin', name: '골드', effect: 'gold', value: 20 },
                    { type: 'equipment', name: '장비', effect: 'stat', value: 1 }
                ];

                const item = itemTypes[Math.floor(Math.random() * itemTypes.length)];
                
                this.items.push({
                    ...item,
                    x: x,
                    y: y,
                    width: 20,
                    height: 20,
                    velocityY: -5
                });
            }

            checkCollisions() {
                // 아이템 습득
                this.items = this.items.filter(item => {
                    if (this.isColliding(this.player, item)) {
                        this.collectItem(item);
                        return false;
                    }
                    
                    // 아이템 물리
                    item.velocityY += 0.5;
                    item.y += item.velocityY;
                    
                    // 플랫폼과 충돌
                    for (let platform of this.platforms) {
                        if (this.isColliding(item, platform) && item.velocityY > 0) {
                            item.y = platform.y - item.height;
                            item.velocityY = 0;
                        }
                    }
                    
                    return item.y < this.height;
                });
            }

            collectItem(item) {
                switch(item.effect) {
                    case 'heal':
                        this.player.hp = Math.min(this.player.maxHp, this.player.hp + item.value);
                        this.showDamageText(this.player.x, this.player.y - 20, `+${item.value} HP`, '#00ff00');
                        break;
                    case 'gold':
                        this.player.gold += item.value;
                        this.showDamageText(this.player.x, this.player.y - 20, `+${item.value} G`, '#ffd700');
                        break;
                    case 'stat':
                        this.player.attack += item.value;
                        this.showDamageText(this.player.x, this.player.y - 20, '+1 공격력', '#ff69b4');
                        break;
                }

                // 인벤토리에 추가
                this.inventory.push(item);
                this.updateInventoryUI();
                this.updateUI();
            }

            isColliding(obj1, obj2) {
                return obj1.x < obj2.x + obj2.width &&
                       obj1.x + obj1.width > obj2.x &&
                       obj1.y < obj2.y + obj2.height &&
                       obj1.y + obj1.height > obj2.y;
            }

            addEffect(x, y, type, life) {
                this.effects.push({
                    x: x,
                    y: y,
                    type: type,
                    life: life,
                    maxLife: life,
                    scale: 1,
                    alpha: 1
                });
            }

            showDamageText(x, y, text, color) {
                this.damageTexts.push({
                    x: x,
                    y: y,
                    text: text,
                    color: color,
                    life: 60,
                    alpha: 1
                });
            }

            updateUI() {
                const hpPercent = (this.player.hp / this.player.maxHp) * 100;
                const mpPercent = (this.player.mp / this.player.maxMp) * 100;
                const expPercent = (this.player.exp / this.player.expToNext) * 100;

                document.getElementById('hpBar').style.width = hpPercent + '%';
                document.getElementById('mpBar').style.width = mpPercent + '%';
                document.getElementById('expBar').style.width = expPercent + '%';

                document.getElementById('hpText').textContent = `HP: ${Math.floor(this.player.hp)}/${this.player.maxHp}`;
                document.getElementById('mpText').textContent = `MP: ${Math.floor(this.player.mp)}/${this.player.maxMp}`;
                document.getElementById('expText').textContent = `EXP: ${this.player.exp}/${this.player.expToNext}`;

                document.getElementById('playerLevel').textContent = this.player.level;
                document.getElementById('playerAttack').textContent = this.player.attack;
                document.getElementById('playerDefense').textContent = this.player.defense;
                document.getElementById('playerGold').textContent = this.player.gold;
            }

            updateInventoryUI() {
                const itemList = document.getElementById('itemList');
                itemList.innerHTML = '';

                for (let item of this.inventory.slice(-12)) { // 최대 12개만 표시
                    const itemDiv = document.createElement('div');
                    itemDiv.className = `item ${item.type}`;
                    itemDiv.textContent = item.name.charAt(0);
                    itemDiv.title = item.name;
                    itemList.appendChild(itemDiv);
                }
            }

            render() {
                // 화면 클리어
                this.ctx.fillStyle = 'rgba(135, 206, 235, 0.1)';
                this.ctx.fillRect(0, 0, this.width, this.height);

                this.ctx.save();
                this.ctx.translate(-this.camera.x, 0);

                // 플랫폼 그리기
                this.ctx.fillStyle = '#8B4513';
                for (let platform of this.platforms) {
                    this.ctx.fillRect(platform.x, platform.y, platform.width, platform.height);
                    
                    // 플랫폼 테두리
                    this.ctx.strokeStyle = '#654321';
                    this.ctx.lineWidth = 2;
                    this.ctx.strokeRect(platform.x, platform.y, platform.width, platform.height);
                }

                // 플레이어 그리기
                this.renderPlayer();

                // 몬스터 그리기
                for (let monster of this.monsters) {
                    this.renderMonster(monster);
                }

                // 투사체 그리기
                for (let projectile of this.projectiles) {
                    this.renderProjectile(projectile);
                }

                // 아이템 그리기
                for (let item of this.items) {
                    this.renderItem(item);
                }

                // 이펙트 그리기
                for (let effect of this.effects) {
                    this.renderEffect(effect);
                }

                this.ctx.restore();

                // 데미지 텍스트 (카메라 영향 받지 않음)
                for (let text of this.damageTexts) {
                    this.ctx.save();
                    this.ctx.globalAlpha = text.alpha;
                    this.ctx.fillStyle = text.color;
                    this.ctx.font = 'bold 16px Arial';
                    this.ctx.textAlign = 'center';
                    this.ctx.strokeStyle = '#000';
                    this.ctx.lineWidth = 3;
                    this.ctx.strokeText(text.text, text.x - this.camera.x, text.y);
                    this.ctx.fillText(text.text, text.x - this.camera.x, text.y);
                    this.ctx.restore();
                }
            }

            renderPlayer() {
                this.ctx.fillStyle = this.player.isAttacking ? '#ffaaaa' : '#4169e1';
                
                // 몸체
                this.ctx.fillRect(this.player.x, this.player.y, this.player.width, this.player.height);
                
                // 얼굴
                this.ctx.fillStyle = '#ffdbac';
                this.ctx.fillRect(this.player.x + 5, this.player.y + 5, 30, 25);
                
                // 눈
                this.ctx.fillStyle = '#000';
                this.ctx.fillRect(this.player.x + 10, this.player.y + 10, 3, 3);
                this.ctx.fillRect(this.player.x + 20, this.player.y + 10, 3, 3);
                
                // 방향 표시 (코)
                this.ctx.fillStyle = '#ffaaaa';
                if (this.player.facing > 0) {
                    this.ctx.fillRect(this.player.x + 25, this.player.y + 15, 2, 2);
                } else {
                    this.ctx.fillRect(this.player.x + 13, this.player.y + 15, 2, 2);
                }
            }

            renderMonster(monster) {
                // 체력바
                if (monster.hp < monster.maxHp) {
                    const barWidth = 40;
                    const barHeight = 4;
                    
                    this.ctx.fillStyle = '#ff0000';
                    this.ctx.fillRect(monster.x - 5, monster.y - 15, barWidth, barHeight);
                    
                    this.ctx.fillStyle = '#00ff00';
                    const hpWidth = (monster.hp / monster.maxHp) * barWidth;
                    this.ctx.fillRect(monster.x - 5, monster.y - 15, hpWidth, barHeight);
                }

                // 몬스터 몸체
                this.ctx.fillStyle = monster.color;
                this.ctx.fillRect(monster.x, monster.y, monster.width, monster.height);
                
                // 눈
                this.ctx.fillStyle = '#fff';
                this.ctx.fillRect(monster.x + 8, monster.y + 8, 6, 6);
                this.ctx.fillRect(monster.x + 20, monster.y + 8, 6, 6);
                
                this.ctx.fillStyle = '#000';
                this.ctx.fillRect(monster.x + 10, monster.y + 10, 2, 2);
                this.ctx.fillRect(monster.x + 22, monster.y + 10, 2, 2);

                // 이름표
                this.ctx.fillStyle = '#fff';
                this.ctx.font = '12px Arial';
                this.ctx.textAlign = 'center';
                this.ctx.strokeStyle = '#000';
                this.ctx.lineWidth = 2;
                this.ctx.strokeText(monster.name, monster.x + 20, monster.y - 20);
                this.ctx.fillText(monster.name, monster.x + 20, monster.y - 20);
            }

            renderProjectile(projectile) {
                if (projectile.type === 'fireball') {
                    this.ctx.fillStyle = '#ff4500';
                    this.ctx.beginPath();
                    this.ctx.arc(projectile.x + 10, projectile.y + 10, 8, 0, Math.PI * 2);
                    this.ctx.fill();
                    
                    // 불꽃 효과
                    this.ctx.fillStyle = '#ffff00';
                    this.ctx.beginPath();
                    this.ctx.arc(projectile.x + 10, projectile.y + 10, 4, 0, Math.PI * 2);
                    this.ctx.fill();
                }
            }

            renderItem(item) {
                this.ctx.fillStyle = item.type === 'potion' ? '#ff69b4' : 
                                   item.type === 'coin' ? '#ffd700' : '#4169e1';
                
                this.ctx.fillRect(item.x, item.y, item.width, item.height);
                
                // 아이템 글로우 효과
                this.ctx.shadowColor = this.ctx.fillStyle;
                this.ctx.shadowBlur = 10;
                this.ctx.fillRect(item.x + 5, item.y + 5, 10, 10);
                this.ctx.shadowBlur = 0;
            }

            renderEffect(effect) {
                this.ctx.save();
                this.ctx.globalAlpha = effect.alpha;
                this.ctx.translate(effect.x, effect.y);
                this.ctx.scale(effect.scale, effect.scale);

                switch(effect.type) {
                    case 'explosion':
                        this.ctx.fillStyle = '#ff4500';
                        this.ctx.beginPath();
                        this.ctx.arc(0, 0, 20, 0, Math.PI * 2);
                        this.ctx.fill();
                        break;
                    case 'heal':
                        this.ctx.fillStyle = '#00ff00';
                        this.ctx.font = '20px Arial';
                        this.ctx.textAlign = 'center';
                        this.ctx.fillText('+', 0, 0);
                        break;
                    case 'cast':
                        this.ctx.strokeStyle = '#4169e1';
                        this.ctx.lineWidth = 3;
                        this.ctx.beginPath();
                        this.ctx.arc(0, 0, 25, 0, Math.PI * 2);
                        this.ctx.stroke();
                        break;
                }

                this.ctx.restore();
            }

            gameOver() {
                alert('게임 오버!\n레벨: ' + this.player.level + '\n골드: ' + this.player.gold);
                location.reload();
            }

            gameLoop(currentTime = 0) {
                const deltaTime = currentTime - this.lastTime;
                this.lastTime = currentTime;

                this.update(deltaTime);
                this.render();

                requestAnimationFrame((time) => this.gameLoop(time));
            }
        }

        // 전역 스킬 함수
        function useSkill(skillNum) {
            if (window.game) {
                window.game.useSkill(skillNum);
            }
        }

        // 게임 시작
        window.addEventListener('load', () => {
            window.game = new MapleRPG();
        });
    </script>
</body>
</html>
