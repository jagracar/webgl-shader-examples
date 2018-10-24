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
		camera.position.x = 8;
		camera.position.y = 5;
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
		var simSizeX = isDesktop ? 128 : 64;
		var simSizeY = isDesktop ? 128 : 64;
		simulator = getSimulator(simSizeX, simSizeY, renderer);
		positionVariable = getSimulationVariable("u_positionTexture", simulator);

		// Create the particles geometry
		var geometry = new THREE.BufferGeometry();

		// Add the particle attributes to the geometry
		var nParticles = simSizeX * simSizeY;
		var references = new Float32Array(2 * nParticles);
		var positions = new Float32Array(3 * nParticles);
		geometry.addAttribute("reference", new THREE.BufferAttribute(references, 2));
		geometry.addAttribute("position", new THREE.BufferAttribute(positions, 3));

		// Fill the references attribute. It's not necessary to fill the positions
		// attribute because it's not used in the shaders (the position texture is
		// used instead)
		for (var i = 0; i < nParticles; i++) {
			references[2 * i] = (i % simSizeX) / simSizeX;
			references[2 * i + 1] = Math.floor(i / simSizeX)/ simSizeY;
		}

		// Define the particle shader uniforms
		uniforms = {
			u_positionTexture : {
				type : "t",
				value : null
			},
			u_texture : {
				type : "t",
				value : new THREE.TextureLoader().load("img/particle2.png")
			},
			u_size : {
				type : "f",
				value : 50 * window.devicePixelRatio
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
		var galaxyMass = 0.00015;
		var galaxyHaloSize = 6;
		setInitialConditions(positionTexture, velocityTexture, galaxyMass, galaxyHaloSize);

		// Add the position and velocity variables to the simulator
		var positionVariable = gpuSimulator.addVariable("u_positionTexture",
				document.getElementById("positionShader").textContent, positionTexture);
		var velocityVariable = gpuSimulator.addVariable("u_velocityTexture",
				document.getElementById("velocityShader").textContent, velocityTexture);

		// Specify the variable dependencies
		gpuSimulator.setVariableDependencies(positionVariable, [ positionVariable, velocityVariable ]);
		gpuSimulator.setVariableDependencies(velocityVariable, [ positionVariable, velocityVariable ]);

		// Add the velocity defines
		velocityVariable.material.defines.nGalaxies = "2.0";

		// Add the position uniforms
		positionUniforms = positionVariable.material.uniforms;
		positionUniforms.u_dt = {
			type : "f",
			value : 0.2
		};

		// Add the velocity uniforms
		velocityUniforms = velocityVariable.material.uniforms;
		velocityUniforms.u_dt = {
			type : "f",
			value : positionUniforms.u_dt.value
		};
		velocityUniforms.u_mass = {
			type : "f",
			value : galaxyMass
		};
		velocityUniforms.u_haloSize = {
			type : "f",
			value : galaxyHaloSize
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
	function setInitialConditions(positionTexture, velocityTexture, galaxyMass, galaxyHaloSize) {
		// Get the position and velocity arrays
		var position = positionTexture.image.data;
		var velocity = velocityTexture.image.data;

		// Set the galaxy properties
		var nGalaxies = 2;
		var nParticles = (position.length / 4) - nGalaxies;
		var galaxyParticles = [ Math.round(nParticles / 2), nParticles - Math.round(nParticles / 2) ];
		var galaxySizes = [ 0.7 * galaxyHaloSize, 0.7 * galaxyHaloSize ];
		var galaxyInclinations = [ 0.35 * Math.PI, Math.PI * Math.random() ];
		var galaxyPositions = [ new THREE.Vector3(-galaxyHaloSize, 0, 0), new THREE.Vector3(galaxyHaloSize, 0, 0) ];
		var galaxyVelocities = [ new THREE.Vector3(0.0005, 0.0001, 0.001), new THREE.Vector3(-0.0005, -0.0001, -0.001) ];

		// Fill the position and velocity arrays
		var startIndex = nGalaxies;

		for (var i = 0; i < nGalaxies; i++) {
			// Use the first indices for the galaxy centers
			var galaxyIndex = 4 * i;
			position[galaxyIndex] = galaxyPositions[i].x;
			position[galaxyIndex + 1] = galaxyPositions[i].y;
			position[galaxyIndex + 2] = galaxyPositions[i].z;
			position[galaxyIndex + 3] = 1;
			velocity[galaxyIndex] = galaxyVelocities[i].x;
			velocity[galaxyIndex + 1] = galaxyVelocities[i].y;
			velocity[galaxyIndex + 2] = galaxyVelocities[i].z;
			velocity[galaxyIndex + 3] = 1;

			// Loop over the galaxy particles
			var sin = Math.sin(galaxyInclinations[i]);
			var cos = Math.cos(galaxyInclinations[i]);

			for (var j = startIndex; j < startIndex + galaxyParticles[i]; j++) {
				// Get a random point inside the galaxy disk
				var distance = galaxySizes[i] * Math.sqrt(Math.random());
				var ang = 2 * Math.PI * Math.random();

				// Get the expected velocity at the point distance
				var massAtPosition = galaxyMass * Math.min(distance, galaxyHaloSize) / galaxyHaloSize;
				var vel = Math.sqrt(massAtPosition / distance);

				// Calculate the particle position and velocity before applying the galaxy inclination
				var x = distance * Math.cos(ang);
				var y = distance * Math.sin(ang);
				var velx = -vel * Math.sin(ang);
				var vely = vel * Math.cos(ang);

				// Calculate the particle position and velocity
				var particleIndex = 4 * j;
				position[particleIndex] = x + galaxyPositions[i].x;
				position[particleIndex + 1] = cos * y + galaxyPositions[i].y;
				position[particleIndex + 2] = -sin * y + galaxyPositions[i].z;
				position[particleIndex + 3] = 1;
				velocity[particleIndex] = velx + galaxyVelocities[i].x;
				velocity[particleIndex + 1] = cos * vely + galaxyVelocities[i].y;
				velocity[particleIndex + 2] = -sin * vely + galaxyVelocities[i].z;
				velocity[particleIndex + 3] = 1;
			}

			// Increase the starting index
			startIndex += galaxyParticles[i];
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
		for (var i = 0; i < 20; i++) {
			simulator.compute();
		}

		// Render the particles on the screen
		uniforms.u_positionTexture.value = simulator.getCurrentRenderTarget(positionVariable).texture;
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
