window.onload = function() {
	runSketch();
};

function runSketch() {
	var renderer, scene, camera, clock, stats, controlParameters, mesh, uniforms, composer;

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
		camera.position.z = 30;

		// Initialize the camera controls
		var controls = new THREE.OrbitControls(camera, renderer.domElement);
		controls.enablePan = false;

		// Initialize the clock
		clock = new THREE.Clock(true);

		// Initialize the statistics monitor and add it to the sketch container
		stats = new Stats();
		stats.dom.style.cssText = "";
		document.getElementById("sketch-stats").appendChild(stats.dom);

		// Initialize the control parameters
		controlParameters = {
			"Geometry" : "Torus knot"
		};

		// Add the control panel to the sketch
		addControlPanel();

		// Create the mesh and add it to the scene
		addMeshToScene();

		// Add some lights to the scene
		scene.add(new THREE.AmbientLight(0x222222));
		var light = new THREE.DirectionalLight(0xffffff);
		light.position.set(1, 1, 1);
		scene.add(light);

		// Define the shader uniforms
		uniforms = {
			u_time : {
				type : "f",
				value : 0.0
			},
			u_frame : {
				type : "f",
				value : 0.0
			},
			u_resolution : {
				type : "v2",
				value : new THREE.Vector2(window.innerWidth, window.innerHeight)
						.multiplyScalar(window.devicePixelRatio)
			},
			u_mouse : {
				type : "v2",
				value : new THREE.Vector2(0.5 * window.innerWidth, window.innerHeight)
						.multiplyScalar(window.devicePixelRatio)
			},
			u_texture : {
				type : "t",
				value : null
			}
		};

		// Create the shader material
		var material = new THREE.ShaderMaterial({
			uniforms : uniforms,
			vertexShader : document.getElementById("vertexShader").textContent,
			fragmentShader : document.getElementById("fragmentShader").textContent
		});

		// Initialize the effect composer
		composer = new THREE.EffectComposer(renderer);
		composer.addPass(new THREE.RenderPass(scene, camera));

		// Add the post-processing effect
		var effect = new THREE.ShaderPass(material, "u_texture");
		effect.renderToScreen = true;
		composer.addPass(effect);

		// Add the event listeners
		window.addEventListener("resize", onWindowResize, false);
		renderer.domElement.addEventListener("mousemove", onMouseMove, false);
		renderer.domElement.addEventListener("touchstart", onTouchMove, false);
		renderer.domElement.addEventListener("touchmove", onTouchMove, false);
	}

	/*
	 * Adds the control panel to the sketch
	 */
	function addControlPanel() {
		// Create the control panel
		var controlPanel = new dat.GUI({
			autoPlace : false
		});

		// Add the controllers
		controlPanel.add(controlParameters, "Geometry", [ "Torus knot", "Sphere", "Icosahedron", "Suzanne" ])
				.onFinishChange(addMeshToScene);

		// Add the GUI to the correct DOM element
		document.getElementById("sketch-gui").appendChild(controlPanel.domElement);
	}

	/*
	 * Adds the mesh to the scene
	 */
	function addMeshToScene() {
		// Remove any previous mesh from the scene
		if (mesh) {
			scene.remove(mesh);
		}

		// Create the mesh material
		var material = new THREE.MeshPhongMaterial({
			color : 0xffffff,
			precision: "mediump"
		});

		// Handle all the different options
		if (controlParameters.Geometry == "Suzanne") {
			// Load the json file that contains the geometry
			var loader = new THREE.BufferGeometryLoader();
			loader.load("/objects/suzanne_buffergeometry.json", function(geometry) {
				// Scale the geometry
				geometry.scale(10, 10, 10);

				// Calculate the vertex normals
				geometry.computeVertexNormals();

				// Create the mesh and add it to the scene
				mesh = new THREE.Mesh(geometry, material);
				scene.add(mesh);
			});
		} else {
			// Create the desired geometry
			var geometry;

			if (controlParameters.Geometry == "Torus knot") {
				geometry = new THREE.TorusKnotGeometry(6.5, 2.3, 256, 32);
			} else if (controlParameters.Geometry == "Sphere") {
				geometry = new THREE.SphereGeometry(10, 64, 64);
			} else if (controlParameters.Geometry == "Icosahedron") {
				geometry = new THREE.IcosahedronGeometry(10, 0);
			}

			// Create the mesh and add it to the scene
			mesh = new THREE.Mesh(geometry, material);
			scene.add(mesh);
		}
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
		uniforms.u_time.value = clock.getElapsedTime();
		uniforms.u_frame.value += 1.0;
		composer.render();
	}

	/*
	 * Updates the renderer size, the camera aspect ratio and the uniforms when the window is resized
	 */
	function onWindowResize(event) {
		// Update the renderer and the effect composer
		renderer.setSize(window.innerWidth, window.innerHeight);
		composer.setSize(window.innerWidth, window.innerHeight);

		// Update the camera
		camera.aspect = window.innerWidth / window.innerHeight;
		camera.updateProjectionMatrix();

		// Update the resolution uniform
		uniforms.u_resolution.value.set(window.innerWidth, window.innerHeight).multiplyScalar(window.devicePixelRatio);
	}

	/*
	 * Updates the uniforms when the mouse moves
	 */
	function onMouseMove(event) {
		// Update the mouse uniform
		uniforms.u_mouse.value.set(event.pageX, window.innerHeight - event.pageY).multiplyScalar(
				window.devicePixelRatio);
	}

	/*
	 * Updates the uniforms when the touch moves
	 */
	function onTouchMove(event) {
		// Update the mouse uniform
		uniforms.u_mouse.value.set(event.touches[0].pageX, window.innerHeight - event.touches[0].pageY).multiplyScalar(
				window.devicePixelRatio);
	}
}
