<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>3D 레이저 슈터 게임</title>
  <style>
    body { margin: 0; overflow: hidden; }
    #info {
      position: absolute;
      top: 10px; left: 10px;
      color: #fff;
      font-family: sans-serif;
      z-index: 1;
    }
    #startBtn {
      padding: 10px 20px;
      font-size: 18px;
      cursor: pointer;
    }
  </style>
</head>
<body>
  <div id="info">
    <div id="score">점수: 0</div>
    <button id="startBtn">게임 시작</button>
  </div>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r152/three.min.js"></script>
  <audio id="laserSound" src="https://freesound.org/data/previews/66/66717_931655-lq.mp3"></audio>

  <script>
    let scene, camera, renderer;
    let raycaster = new THREE.Raycaster();
    let mouse = new THREE.Vector2();
    let targets = [];
    let score = 0;
    const scoreEl = document.getElementById('score');
    const laserSound = document.getElementById('laserSound');
    const startBtn = document.getElementById('startBtn');

    function init() {
      scene = new THREE.Scene();
      scene.fog = new THREE.Fog(0x000000, 10, 60);

      camera = new THREE.PerspectiveCamera(75, window.innerWidth/window.innerHeight, 0.1, 1000);
      camera.position.z = 10;

      renderer = new THREE.WebGLRenderer({ antialias: true });
      renderer.setSize(window.innerWidth, window.innerHeight);
      document.body.appendChild(renderer.domElement);

      // 조명
      const ambientLight = new THREE.AmbientLight(0xcccccc, 0.4);
      scene.add(ambientLight);
      const pointLight = new THREE.PointLight(0xffffff, 0.8);
      camera.add(pointLight);
      scene.add(camera);

      window.addEventListener('resize', onWindowResize, false);
      document.addEventListener('click', handleClick, false);

      animate();
    }

    function onWindowResize() {
      camera.aspect = window.innerWidth/window.innerHeight;
      camera.updateProjectionMatrix();
      renderer.setSize(window.innerWidth, window.innerHeight);
    }

    function spawnTarget() {
      const geometry = new THREE.SphereGeometry(0.5, 16, 16);
      const material = new THREE.MeshPhongMaterial({
        color: Math.random() * 0xffffff,
        shininess: 100
      });
      const target = new THREE.Mesh(geometry, material);
      target.position.x = (Math.random() - 0.5) * 20;
      target.position.y = (Math.random() - 0.5) * 10;
      target.position.z = -20;
      scene.add(target);
      targets.push(target);

      // 이동 애니메이션
      const speed = 0.03 + Math.random() * 0.05;
      target.userData.speed = speed;
      setTimeout(spawnTarget, 1000);
    }

    function handleClick(event) {
      mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
      mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;

      raycaster.setFromCamera(mouse, camera);
      const intersects = raycaster.intersectObjects(targets);

      if (intersects.length > 0) {
        const obj = intersects[0].object;
        scene.remove(obj);
        targets = targets.filter(item => item !== obj);
        score += 1;
        scoreEl.textContent = `점수: ${score}`;
        laserSound.currentTime = 0;
        laserSound.play();
      }
    }

    function animate() {
      requestAnimationFrame(animate);
      targets.forEach(t => {
        t.position.z += t.userData.speed;
        if (t.position.z > camera.position.z) {
          scene.remove(t);
          targets = targets.filter(item => item !== t);
        }
      });
      renderer.render(scene, camera);
    }

    startBtn.addEventListener('click', () => {
      score = 0;
      scoreEl.textContent = '점수: 0';
      startBtn.disabled = true;
      spawnTarget();
    });

    init();
  </script>
</body>
</html>
