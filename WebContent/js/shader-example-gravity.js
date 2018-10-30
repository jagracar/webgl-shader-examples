window.onload = function() {
	runSketch();
};

function runSketch() {
	var renderer, scene, camera, stats, simulator, positionVariable, uniforms;

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
		controls.enablePan = false;

		// Initialize the statistics monitor and add it to the sketch container
		stats = new Stats();
		stats.dom.style.cssText = "";
		document.getElementById("sketch-stats").appendChild(stats.dom);

		// Initialize the simulator
		var isDesktop = Math.min(window.innerWidth, window.innerHeight) > 450;
		var simSizeX = isDesktop ? 64 : 32;
		var simSizeY = isDesktop ? 64 : 32;
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
				value : 50 * window.devicePixelRatio
			},
			u_positionTexture : {
				type : "t",
				value : null
			},
			u_texture : {
				type : "t",
				value : new THREE.TextureLoader().load("img/particle.png")
			}
		};

		// Create the particles shader material
		var material = new THREE.ShaderMaterial({
			uniforms : uniforms,
			vertexShader : document.getElementById("vertexShader").textContent,
			fragmentShader : document.getElementById("fragmentShader").textContent,
			depthTest : false,
			lights : false,
			transparent : true,
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

		// Create the position and the velocity textures
		var positionTexture = gpuSimulator.createTexture();
		var velocityTexture = gpuSimulator.createTexture();

		// Fill the texture data arrays with the simulation initial conditions
		setInitialConditions(positionTexture, velocityTexture);

		// Add the position and velocity variables to the simulator
		var positionVariable = gpuSimulator.addVariable("u_positionTexture",
				document.getElementById("positionShader").textContent, positionTexture);
		var velocityVariable = gpuSimulator.addVariable("u_velocityTexture",
				document.getElementById("velocityShader").textContent, velocityTexture);

		// Specify the variable dependencies
		gpuSimulator.setVariableDependencies(positionVariable, [ positionVariable, velocityVariable ]);
		gpuSimulator.setVariableDependencies(velocityVariable, [ positionVariable, velocityVariable ]);

		// Add the position uniforms
		var positionUniforms = positionVariable.material.uniforms;
		positionUniforms.u_dt = {
			type : "f",
			value : 1.0
		};

		// Add the velocity uniforms
		var velocityUniforms = velocityVariable.material.uniforms;
		velocityUniforms.u_dt = {
			type : "f",
			value : positionUniforms.u_dt.value
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
	function setInitialConditions(positionTexture, velocityTexture) {
		// Get the position and velocity arrays
		var position = positionTexture.image.data;
		var velocity = velocityTexture.image.data;

		// Fill the position and velocity arrays
		var nParticles = position.length / 4;

		for (var i = 0; i < nParticles; i++) {
			// Get a random point inside a sphere
			var distance = 10 * Math.pow(Math.random(), 1 / 3);
			var cos = 2 * Math.random() - 1;
			var sin = Math.sqrt(1 - cos * cos);
			var ang = 2 * Math.PI * Math.random();

			// Calculate the point x,y,z coordinates
			var particleIndex = 4 * i;
			position[particleIndex] = distance * sin * Math.cos(ang);
			position[particleIndex + 1] = distance * sin * Math.sin(ang);
			position[particleIndex + 2] = distance * cos;
			position[particleIndex + 3] = 1;

			// Start with zero initial velocity
			velocity[particleIndex] = 0;
			velocity[particleIndex + 1] = 0;
			velocity[particleIndex + 2] = 0;
			velocity[particleIndex + 3] = 1;
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
