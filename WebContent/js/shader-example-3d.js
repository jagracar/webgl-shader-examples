var renderer, scene, camera, clock, stats, controlParameters, uniforms, material, mesh;

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
	var container = document.getElementById("container");
	container.appendChild(renderer.domElement);

	// Initialize the scene
	scene = new THREE.Scene();

	// Initialize the camera
	camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 50);
	camera.position.z = 30;

	// Initialize the camera controls
	var controls = new THREE.OrbitControls(camera, renderer.domElement);
	controls.enablePan = false;

	// Initialize the clock
	clock = new THREE.Clock(true);

	// Initialize the statistics monitor and add it to the sketch container
	stats = new Stats();
	container.appendChild(stats.dom);

	// Initialize the control parameters
	controlParameters = {
		"Geometry" : "Torus knot"
	};

	// Add the control panel to the sketch
	addControlPanel();

	// Define the shader uniforms
	uniforms = {
		u_time : {
			type : "f",
			value : 0.0
		},
		u_resolution : {
			type : "v2",
			value : new THREE.Vector2(window.innerWidth, window.innerHeight)
		},
		u_mouse : {
			type : "v2",
			value : new THREE.Vector2()
		}
	};

	// Create the shader material
	material = new THREE.ShaderMaterial({
		uniforms : uniforms,
		vertexShader : document.getElementById("vertexShader").textContent,
		fragmentShader : document.getElementById("fragmentShader").textContent,
		transparent : true
	});

	// Create the mesh and add it to the scene
	addMeshToScene();

	// Add the event listeners
	window.addEventListener("resize", onWindowResize, false);
	document.addEventListener("mousemove", onMouseMove, false);
}

/*
 * Adds the control panel to the sketch
 */
function addControlPanel() {
	// Create the control panel
	var controlPanel = new dat.GUI();

	// Add the controllers
	controlPanel.add(controlParameters, "Geometry", [ "Torus knot", "Sphere", "Icosahedron", "Suzanne" ])
			.onFinishChange(addMeshToScene);
}

/*
 * Adds the mesh to the scene
 */
function addMeshToScene() {
	// Remove any previous mesh from the scene
	if (mesh) {
		scene.remove(mesh);
	}

	// Handle all the different options
	if (controlParameters.Geometry == "Suzanne") {
		// Load the json file that contains the geometry
		var loader = new THREE.JSONLoader();
		loader.load("objects/suzanne_geometry.json", function(geometry) {
			// Scale and rotate the geometry
			geometry.scale(12, 12, 12);
			geometry.rotateX(Math.PI / 2);

			// Create the mesh and add it to the scene
			mesh = new THREE.Mesh(geometry, material);
			scene.add(mesh);
		});
	} else {
		// Create the desired geometry
		var geometry;

		if (controlParameters.Geometry == "Torus knot") {
			geometry = new THREE.TorusKnotGeometry(8, 2.5, 256, 32);
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
	renderer.render(scene, camera);
}

/*
 * Updates the renderer size, the camera aspect ratio and the uniforms when the window is resized
 */
function onWindowResize(event) {
	// Update the renderer
	renderer.setSize(window.innerWidth, window.innerHeight);

	// Update the camera
	camera.aspect = window.innerWidth / window.innerHeight;
	camera.updateProjectionMatrix();

	// Update the resolution uniform
	uniforms.u_resolution.value.x = window.innerWidth;
	uniforms.u_resolution.value.y = window.innerHeight;
}

/*
 * Updates the uniforms when the mouse moves
 */
function onMouseMove(event) {
	uniforms.u_mouse.value.x = event.pageX;
	uniforms.u_mouse.value.y = window.innerHeight - event.pageY;
}
