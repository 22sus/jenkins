<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>두더지 잡기 게임</title>
  <style>
    body {
      font-family: 'Arial';
      text-align: center;
      background-color: #e0f7fa;
      margin: 0;
      padding: 20px;
    }

    h1 {
      color: #00796b;
    }

    #game {
      display: grid;
      grid-template-columns: repeat(3, 100px);
      grid-gap: 15px;
      justify-content: center;
      margin: 20px auto;
    }

    .hole {
      width: 100px;
      height: 100px;
      background-color: #8d6e63;
      border-radius: 50%;
      position: relative;
      cursor: pointer;
      overflow: hidden;
    }

    .mole {
      width: 100px;
      height: 100px;
      background: url('https://i.imgur.com/5V3rYkG.png') center/contain no-repeat;
      position: absolute;
      top: 100%;
      left: 0;
      transition: top 0.3s;
    }

    .up {
      top: 0;
    }

    #score, #timer {
      font-size: 24px;
      margin: 10px;
    }

    button {
      padding: 10px 20px;
      background-color: #00796b;
      color: white;
      border: none;
      border-radius: 5px;
      cursor: pointer;
    }

    button:hover {
      background-color: #004d40;
    }
  </style>
</head>
<body>

  <h1>두더지 잡기 게임 🎯</h1>
  <div id="score">점수: 0</div>
  <div id="timer">남은 시간: 30</div>
  <button onclick="startGame()">게임 시작</button>

  <div id="game">
    <div class="hole"><div class="mole"></div></div>
    <div class="hole"><div class="mole"></div></div>
    <div class="hole"><div class="mole"></div></div>
    <div class="hole"><div class="mole"></div></div>
    <div class="hole"><div class="mole"></div></div>
    <div class="hole"><div class="mole"></div></div>
  </div>

  <script>
    const holes = document.querySelectorAll('.hole');
    const scoreBoard = document.getElementById('score');
    const timerDisplay = document.getElementById('timer');
    let score = 0;
    let timeUp = false;
    let timeLeft = 30;
    let countdown;

    function randomTime(min, max) {
      return Math.round(Math.random() * (max - min) + min);
    }

    function randomHole(holes) {
      const index = Math.floor(Math.random() * holes.length);
      return holes[index];
    }

    function showMole() {
      const time = randomTime(500, 1200);
      const hole = randomHole(holes);
      const mole = hole.querySelector('.mole');
      mole.classList.add('up');

      setTimeout(() => {
        mole.classList.remove('up');
        if (!timeUp) showMole();
      }, time);
    }

    function startGame() {
      sc
