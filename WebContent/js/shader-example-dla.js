window.onload = function() {
	runSketch();
};

function runSketch() {
	var renderer, scene, camera, clock, stats, simulator, positionVariable, uniforms;

	init();
	animate();

	/*
	 * Initializes the sketch
	 */
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
		camera.position.z = 10;

		// Initialize the camera controls
		var controls = new THREE.OrbitControls(camera, renderer.domElement);
		controls.enableRotate = false;
		controls.enablePan = false;

		// Initialize the clock
		clock = new THREE.Clock(true);

		// Initialize the statistics monitor and add it to the sketch container
		stats = new Stats();
		stats.dom.style.cssText = "";
		document.getElementById("sketch-stats").appendChild(stats.dom);

		// Initialize the simulator
		var isDesktop = Math.min(window.innerWidth, window.innerHeight) > 450;
		var simSizeX = isDesktop ? 2 * 64 : 64;
		var simSizeY = isDesktop ? 64 : 64;
		simulator = getSimulator(simSizeX, simSizeY, renderer);
		positionVariable = getSimulationVariable("u_positionTexture", simulator);

		// Create the particles geometry
		var geometry = new THREE.BufferGeometry();

		// Add the particle attributes to the geometry
		var nParticles = simSizeX * simSizeY;
		var indices = new Float32Array(nParticles);
		var positions = new Float32Array(3 * nParticles);
		geometry.addAttribute("a_index", new THREE.BufferAttribute(indices, 1));
		geometry.addAttribute("position", new THREE.BufferAttribute(positions, 3));

		// Fill the indices attribute. It's not necessary to fill the positions
		// attribute because it's not used in the shaders (the position texture is
		// used instead)
		for (var i = 0; i < nParticles; i++) {
			indices[i] = i;
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
			u_particleSize : {
				type : "f",
				value : 40 * Math.min(window.devicePixelRatio, 2)
			},
			u_positionTexture : {
				type : "t",
				value : null
			},
			u_texture : {
				type : "t",
				value : new THREE.TextureLoader().load("img/particle2.png")
			}
		};

		// Create the particles shader material
		var material = new THREE.ShaderMaterial({
			uniforms : uniforms,
			vertexShader : document.getElementById("vertexShader").textContent,
			fragmentShader : document.getElementById("fragmentShader").textContent,
			depthTest : false,
			lights : false,
			transparent : false,
			blending : THREE.AdditiveBlending
		});

		// Create the particles and add them to the scene
		var particles = new THREE.Points(geometry, material);
		scene.add(particles);

		// Add the event listeners
		window.addEventListener("resize", onWindowResize, false);
	}

	/*
	 * Initializes and returns the GPU simulator
	 */
	function getSimulator(simSizeX, simSizeY, renderer) {
		// Create a new GPU simulator instance
		var gpuSimulator = new GPUComputationRenderer(simSizeX, simSizeY, renderer);

		// Create the position texture
		var positionTexture = gpuSimulator.createTexture();

		// Fill the texture data array with the simulation initial conditions
		var maxDistance = 6;
		setInitialConditions(positionTexture, maxDistance);

		// Add the position variable to the simulator
		var positionVariable = gpuSimulator.addVariable("u_positionTexture",
				document.getElementById("positionShader").textContent, positionTexture);

		// Specify the variable dependencies
		gpuSimulator.setVariableDependencies(positionVariable, [ positionVariable ]);

		// Add the position uniforms
		var positionUniforms = positionVariable.material.uniforms;
		positionUniforms.u_minDistance = {
			type : "f",
			value : 0.07
		};
		positionUniforms.u_maxDistance = {
			type : "f",
			value : maxDistance
		};
		positionUniforms.u_time = {
			type : "f",
			value : 0
		};

		// Initialize the GPU simulator
		var error = gpuSimulator.init();

		if (error !== null) {
			console.error(error);
		}

		return gpuSimulator;
	}

	/*
	 * Sets the simulation initial conditions
	 */
	function setInitialConditions(positionTexture, maxDistance) {
		// Get the position array
		var position = positionTexture.image.data;

		// The first particle will be the aggregation seed
		position[0] = 0;
		position[1] = 0;
		position[2] = 0;
		position[3] = -1;

		// Fill the rest of the position array
		var nParticles = position.length / 4;

		for (var i = 1; i < nParticles; i++) {
			// Get a random position inside a disk
			var distance = maxDistance * Math.sqrt(Math.random());
			var ang = 2 * Math.PI * Math.random();

			// Calculate the particle x,y,z coordinates
			var particleIndex = 4 * i;
			position[particleIndex] = distance * Math.cos(ang);
			position[particleIndex + 1] = distance * Math.sin(ang);
			position[particleIndex + 2] = 0;
			position[particleIndex + 3] = 1;
		}
	}

	/*
	 * Returns the requested simulation variable
	 */
	function getSimulationVariable(variableName, gpuSimulator) {
		for (var i = 0; i < gpuSimulator.variables.length; i++) {
			if (gpuSimulator.variables[i].name === variableName) {
				return gpuSimulator.variables[i];
			}
		}

		return null;
	}

	/*
	 * Animates the sketch
	 */
	function animate() {
		requestAnimationFrame(animate);
		render();
		stats.update();
	}

	/*
	 * Renders the sketch
	 */
	function render() {
		// Run several iterations per frame
		for (var i = 0; i < 1; i++) {
			// Update the position variable uniforms
			positionVariable.material.uniforms.u_time.value = clock.getElapsedTime();

			// Compute the next simulation step
			simulator.compute();
		}

		// Update the uniforms
		uniforms.u_positionTexture.value = simulator.getCurrentRenderTarget(positionVariable).texture;

		// Render the particles on the screen
		renderer.render(scene, camera);
	}

	/*
	 * Updates the renderer size and the camera aspect ratio when the window is resized
	 */
	function onWindowResize(event) {
		// Update the renderer
		renderer.setSize(window.innerWidth, window.innerHeight);

		// Update the camera
		camera.aspect = window.innerWidth / window.innerHeight;
		camera.updateProjectionMatrix();
	}
}
