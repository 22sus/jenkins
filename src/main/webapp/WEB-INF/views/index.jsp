<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebGL 3D 큐브</title>
    <style>
        body {
            margin: 0;
            overflow: hidden;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background-color: #000;
        }
        canvas {
            border: 2px solid #fff;
        }
    </style>
</head>
<body>
    <canvas id="glcanvas" width="640" height="480"></canvas>
    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gl-matrix/2.8.1/gl-matrix-min.js"></script>

    <script>
        // WebGL 컨텍스트 가져오기
        const canvas = document.getElementById("glcanvas");
        const gl = canvas.getContext("webgl");

        if (!gl) {
            alert("WebGL을 지원하지 않는 브라우저입니다. 다른 브라우저를 사용해 보세요.");
        }

        // 셰이더 소스 (3D 객체를 그리는 프로그램)
        const vsSource = `
            attribute vec4 aVertexPosition;
            attribute vec4 aVertexColor;

            uniform mat4 uModelViewMatrix;
            uniform mat4 uProjectionMatrix;

            varying lowp vec4 vColor;

            void main(void) {
                gl_Position = uProjectionMatrix * uModelViewMatrix * aVertexPosition;
                vColor = aVertexColor;
            }
        `;

        const fsSource = `
            varying lowp vec4 vColor;

            void main(void) {
                gl_FragColor = vColor;
            }
        `;

        // 셰이더 프로그램 초기화
        function initShaderProgram(gl, vsSource, fsSource) {
            const vertexShader = loadShader(gl, gl.VERTEX_SHADER, vsSource);
            const fragmentShader = loadShader(gl, gl.FRAGMENT_SHADER, fsSource);

            const shaderProgram = gl.createProgram();
            gl.attachShader(shaderProgram, vertexShader);
            gl.attachShader(shaderProgram, fragmentShader);
            gl.linkProgram(shaderProgram);

            if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
                alert('셰이더 프로그램 초기화 실패: ' + gl.getProgramInfoLog(shaderProgram));
                return null;
            }

            return shaderProgram;
        }

        function loadShader(gl, type, source) {
            const shader = gl.createShader(type);
            gl.shaderSource(shader, source);
            gl.compileShader(shader);
            return shader;
        }

        const shaderProgram = initShaderProgram(gl, vsSource, fsSource);
        const programInfo = {
            program: shaderProgram,
            attribLocations: {
                vertexPosition: gl.getAttribLocation(shaderProgram, 'aVertexPosition'),
                vertexColor: gl.getAttribLocation(shaderProgram, 'aVertexColor'),
            },
            uniformLocations: {
                projectionMatrix: gl.getUniformLocation(shaderProgram, 'uProjectionMatrix'),
                modelViewMatrix: gl.getUniformLocation(shaderProgram, 'uModelViewMatrix'),
            },
        };

        // 큐브 버퍼 생성
        function initBuffers(gl) {
            const positionBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

            const positions = [
                // 앞면
                -1.0, -1.0,  1.0,
                 1.0, -1.0,  1.0,
                 1.0,  1.0,  1.0,
                -1.0,  1.0,  1.0,

                // 뒷면
                -1.0, -1.0, -1.0,
                -1.0,  1.0, -1.0,
                 1.0,  1.0, -1.0,
                 1.0, -1.0, -1.0,

                // 윗면
                -1.0,  1.0, -1.0,
                -1.0,  1.0,  1.0,
                 1.0,  1.0,  1.0,
                 1.0,  1.0, -1.0,

                // 아랫면
                -1.0, -1.0, -1.0,
                 1.0, -1.0, -1.0,
                 1.0, -1.0,  1.0,
                -1.0, -1.0,  1.0,

                // 오른쪽
                 1.0, -1.0, -1.0,
                 1.0,  1.0, -1.0,
                 1.0,  1.0,  1.0,
                 1.0, -1.0,  1.0,

                // 왼쪽
                -1.0, -1.0, -1.0,
                -1.0, -1.0,  1.0,
                -1.0,  1.0,  1.0,
                -1.0,  1.0, -1.0,
            ];

            gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

            const faceColors = [
                [1.0,  1.0,  1.0,  1.0],    // 앞면 (흰색)
                [1.0,  0.0,  0.0,  1.0],    // 뒷면 (빨간색)
                [0.0,  1.0,  0.0,  1.0],    // 윗면 (녹색)
                [0.0,  0.0,  1.0,  1.0],    // 아랫면 (파란색)
                [1.0,  1.0,  0.0,  1.0],    // 오른쪽 (노란색)
                [1.0,  0.0,  1.0,  1.0],    // 왼쪽 (자홍색)
            ];

            let colors = [];
            for (let j = 0; j < 6; j++) {
                const c = faceColors[j];
                colors = colors.concat(c, c, c, c);
            }

            const colorBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ARRAY_BUFFER, colorBuffer);
            gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(colors), gl.STATIC_DRAW);

            const indexBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
            const indices = [
                0,  1,  2,      0,  2,  3,    // 앞면
                4,  5,  6,      4,  6,  7,    // 뒷면
                8,  9,  10,     8,  10, 11,   // 윗면
                12, 13, 14,     12, 14, 15,   // 아랫면
                16, 17, 18,     16, 18, 19,   // 오른쪽
                20, 21, 22,     20, 22, 23,   // 왼쪽
            ];
            gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(indices), gl.STATIC_DRAW);

            return {
                position: positionBuffer,
                color: colorBuffer,
                indices: indexBuffer,
            };
        }

        const buffers = initBuffers(gl);
        const mat4 = glMatrix.mat4;
        const projectionMatrix = mat4.create();
        const modelViewMatrix = mat4.create();
        let cubeRotation = 0.0;
        let then = 0;

        // 렌더링 루프
        function render(now) {
            now *= 0.001;
            const deltaTime = now - then;
            then = now;
            
            // 그리기 전 화면 초기화
            gl.clearColor(0.0, 0.0, 0.0, 1.0);
            gl.clearDepth(1.0);
            gl.enable(gl.DEPTH_TEST);
            gl.depthFunc(gl.LEQUAL);
            gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

            // 뷰포트 설정
            const fieldOfView = 45 * Math.PI / 180;
            const aspect = gl.canvas.clientWidth / gl.canvas.clientHeight;
            const zNear = 0.1;
            const zFar = 100.0;
            mat4.perspective(projectionMatrix, fieldOfView, aspect, zNear, zFar);
            mat4.translate(modelViewMatrix, modelViewMatrix, [-0.0, 0.0, -6.0]);
            mat4.rotate(modelViewMatrix, modelViewMatrix, cubeRotation, [0, 0, 1]);
            mat4.rotate(modelViewMatrix, modelViewMatrix, cubeRotation * 0.7, [0, 1, 0]);

            // 버퍼 연결
            gl.bindBuffer(gl.ARRAY_BUFFER, buffers.position);
            gl.vertexAttribPointer(programInfo.attribLocations.vertexPosition, 3, gl.FLOAT, false, 0, 0);
            gl.enableVertexAttribArray(programInfo.attribLocations.vertexPosition);
            
            gl.bindBuffer(gl.ARRAY_BUFFER, buffers.color);
            gl.vertexAttribPointer(programInfo.attribLocations.vertexColor, 4, gl.FLOAT, false, 0, 0);
            gl.enableVertexAttribArray(programInfo.attribLocations.vertexColor);
            gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, buffers.indices);
            gl.useProgram(programInfo.program);
            gl.uniformMatrix4fv(programInfo.uniformLocations.projectionMatrix, false, projectionMatrix);
            gl.uniformMatrix4fv(programInfo.uniformLocations.modelViewMatrix, false, modelViewMatrix);
            
            // 그리기
            gl.drawElements(gl.TRIANGLES, 36, gl.UNSIGNED_SHORT, 0);

            cubeRotation += deltaTime;
            
            requestAnimationFrame(render);
        }
        
        requestAnimationFrame(render);
    </script>
</body>
</html>