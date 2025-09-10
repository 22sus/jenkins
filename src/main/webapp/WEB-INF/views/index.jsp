<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>✨ 마법 거울 ✨</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #a8c0ff, #3f2b96); /* 그라데이션 배경 */
            color: #fff;
            overflow: hidden; /* 반짝이 효과를 위한 오버플로우 숨김 */
        }

        .container {
            background-color: rgba(255, 255, 255, 0.1); /* 반투명 배경 */
            padding: 30px 50px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            text-align: center;
            max-width: 90%;
            backdrop-filter: blur(10px); /* 유리 효과 */
            border: 1px solid rgba(255, 255, 255, 0.3); /* 테두리 */
            position: relative;
            overflow: hidden;
        }

        h1 {
            font-size: 2.5em;
            margin-bottom: 20px;
            text-shadow: 2px 2px 5px rgba(0, 0, 0, 0.5);
            color: #ffeb3b; /* 황금색 */
            position: relative;
            z-index: 2;
        }

        h1::before {
            content: "🌟 ";
            color: #ffd700;
        }

        h1::after {
            content: " 🌟";
            color: #ffd700;
        }

        input[type="text"] {
            width: calc(100% - 40px);
            padding: 15px 20px;
            margin-bottom: 20px;
            border: none;
            border-radius: 10px;
            font-size: 1.2em;
            background-color: rgba(255, 255, 255, 0.9);
            color: #333;
            box-shadow: inset 0 2px 5px rgba(0, 0, 0, 0.2);
            transition: all 0.3s ease;
        }

        input[type="text"]:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.5);
        }

        .mirror-output {
            min-height: 80px;
            background-color: rgba(255, 255, 255, 0.2);
            border-radius: 10px;
            padding: 20px;
            font-size: 1.8em;
            font-weight: bold;
            color: #fff;
            text-shadow: 0 0 10px #ffffff, 0 0 20px #ffffff; /* 반짝이는 효과 */
            word-wrap: break-word; /* 긴 텍스트 줄바꿈 */
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }

        /* 반짝이는 효과 (별똥별처럼) */
        .sparkle {
            position: absolute;
            background-color: #ffffff;
            border-radius: 50%;
            animation: twinkle 1.5s infinite ease-out;
            opacity: 0;
            filter: blur(2px);
            z-index: 1;
        }

        @keyframes twinkle {
            0% {
                transform: scale(0) translate(-50%, -50%);
                opacity: 0;
            }
            50% {
                transform: scale(1) translate(-50%, -50%);
                opacity: 0.8;
            }
            100% {
                transform: scale(0) translate(-50%, -50%);
                opacity: 0;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>✨ 마법 거울에 속마음을 비춰보세요 ✨</h1>
        <input type="text" id="magicInput" placeholder="여기에 뭔가 입력해 보세요...">
        <div class="mirror-output" id="mirrorOutput">
            거울이 당신을 기다립니다...
        </div>
    </div>

    <script>
        const magicInput = document.getElementById('magicInput');
        const mirrorOutput = document.getElementById('mirrorOutput');
        const container = document.querySelector('.container');

        magicInput.addEventListener('input', function() {
            mirrorOutput.textContent = this.value || '거울이 당신을 기다립니다...';
            createSparkle(); // 텍스트 입력 시 반짝이 효과 생성
        });

        // 반짝이 효과 생성 함수
        function createSparkle() {
            for (let i = 0; i < 5; i++) { // 여러 개의 반짝이를 생성
                const sparkle = document.createElement('div');
                sparkle.classList.add('sparkle');
                const size = Math.random() * 20 + 5; // 5px ~ 25px
                sparkle.style.width = `${size}px`;
                sparkle.style.height = `${size}px`;
                sparkle.style.left = `${Math.random() * 100}%`;
                sparkle.style.top = `${Math.random() * 100}%`;
                sparkle.style.animationDelay = `${Math.random() * 0.5}s`; // 딜레이를 줘서 비동기적으로 반짝임
                mirrorOutput.appendChild(sparkle);

                // 애니메이션이 끝나면 요소 제거
                sparkle.addEventListener('animationend', () => {
                    sparkle.remove();
                });
            }
        }

        // 초기 로드 시에도 한 번 반짝이 생성
        createSparkle();

        // 텍스트 입력이 없을 때도 주기적으로 반짝이 생성 (옵션)
        setInterval(() => {
            if (!magicInput.value) {
                createSparkle();
            }
        }, 3000); // 3초마다 반짝이 생성
    </script>
</body>
</html>