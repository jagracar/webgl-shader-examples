window.onload = function() {
	runSketch();
};

function runSketch() {
	var renderer, scene, camera, gpuSimulator, positionVariable, velocityVariable, uniforms;

	init();
	animate();

	function init() {
		// Initialize the WebGL renderer
		renderer = new THREE.WebGLRenderer({
			antialias : true
		});
		renderer.setPixelRatio(window.devicePixelRatio);
		renderer.setSize(window.innerWidth, window.innerHeight);
		renderer.setClearColor(new THREE.Color(0, 0, 0));

		// Add the renderer to the sketch container
		var container = document.getElementById("sketch-container");
		container.appendChild(renderer.domElement);

		// Initialize the scene
		scene = new THREE.Scene();

		// Initialize the camera
		camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 5000);
		camera.position.z = 20;

		// Initialize the simulator
		var simSizeX = 64;
		var simSizeY = 64;
		var nParticles = simSizeX * simSizeY;
		gpuSimulator = new GPUComputationRenderer(simSizeX, simSizeY, renderer);

		// Create the position and the velocity textures
		var positionTexture = gpuSimulator.createTexture();
		var velocityTexture = gpuSimulator.createTexture();

		// Fill the texture data arrays with the simulation initial conditions
		var position = positionTexture.image.data;
		var velocity = velocityTexture.image.data;

		for (var i = 0; i < nParticles; i++) {
			var particleIndex = 4 * i;
			var distance = 3 * Math.sqrt(Math.random());
			var ang = 2 * Math.PI * Math.random();
			position[particleIndex] = distance * Math.cos(ang);
			position[particleIndex + 1] = distance * Math.sin(ang);
			position[particleIndex + 2] = 0;
			position[particleIndex + 3] = 1;
			velocity[particleIndex] = -0.01 * Math.sin(ang);
			velocity[particleIndex + 1] = 0.01 * Math.cos(ang);
			velocity[particleIndex + 2] = 0;
			velocity[particleIndex + 3] = 1;
		}

		// Add the position and velocity variables to the simulator
		positionVariable = gpuSimulator.addVariable("u_positionTexture",
				document.getElementById("positionShader").textContent, positionTexture);
		velocityVariable = gpuSimulator.addVariable("u_velocityTexture",
				document.getElementById("velocityShader").textContent, velocityTexture);

		// Specify the variable dependencies
		gpuSimulator.setVariableDependencies(positionVariable, [ positionVariable, velocityVariable ]);
		gpuSimulator.setVariableDependencies(velocityVariable, [ positionVariable, velocityVariable ]);

		// Initialize the GPU simulator
		var error = gpuSimulator.init();

		if (error !== null) {
			console.error(error);
		}

		// Create the particles geometry
		var geometry = new THREE.BufferGeometry();

		// Add the particle attributes to the geometry
		var indices = new Float32Array(nParticles);
		var positions = new Float32Array(3 * nParticles);
		geometry.addAttribute("a_index", new THREE.BufferAttribute(indices, 1));
		geometry.addAttribute("position", new THREE.BufferAttribute(positions, 3));

		for (i = 0; i < nParticles; i++) {
			indices[i] = i;
			positions[3 * i] = 0;
			positions[3 * i + 1] = 0;
			positions[3 * i + 2] = 0;
		}

		// Define the particle shader uniforms
		uniforms = {
			u_width : {
				type : "f",
				value : simSizeX
			},
			u_height : {
				type : "f",
				value : simSizeY
			},
			u_positionTexture : {
				type : "t",
				value : null
			}
		};

		// Create the particles shader material
		var material = new THREE.ShaderMaterial({
			uniforms : uniforms,
			vertexShader : document.getElementById("vertexShader").textContent,
			fragmentShader : document.getElementById("fragmentShader").textContent
		});

		// Create the particles and add them to the scene
		var particles = new THREE.Points(geometry, material);
		scene.add(particles);
	}

	function animate() {
		requestAnimationFrame(animate);
		render();
	}

	function render() {
		gpuSimulator.compute();
		uniforms.u_positionTexture.value = gpuSimulator.getCurrentRenderTarget(positionVariable).texture;
		renderer.render(scene, camera);
	}
}
