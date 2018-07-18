var scene, renderer, camera, controls, clock, stats, controlParameters, uniforms, material, mesh;

init();
animate();

/*
 * Initializes the sketch
 */
function init() {
	// Scene setup
	scene = new THREE.Scene();

	// Get the WebGL renderer
	renderer = new THREE.WebGLRenderer({
		antialias : true
	});
	renderer.setPixelRatio(window.devicePixelRatio);
	renderer.setClearColor(new THREE.Color(0, 0, 0));

	// Add the renderer to the sketch container
	var container = document.getElementById("container");
	container.appendChild(renderer.domElement);

	// Camera setup
	camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 50);
	camera.position.z = 30;

	// Initialize the camera controls
	controls = new THREE.OrbitControls(camera, renderer.domElement);
	controls.enablePan = false;

	// Initialize the clock
	clock = new THREE.Clock(true);

	// Initialize the statistics monitor and add it to the sketch container
	stats = new Stats();
	container.appendChild(stats.dom);

	// Initialize the control parameters
	controlParameters = {
		"Geometry" : "sphere"
	};

	// Add the control panel
	addControlPanel();

	// Define the shader uniforms
	uniforms = {
		u_time : {
			type : "f",
			value : 1.0
		},
		u_resolution : {
			type : "v2",
			value : new THREE.Vector2()
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

	// Add the mesh to the scene
	addMeshToScene();

	// Update the uniforms
	onWindowResize();

	// Add the event listeners
	window.addEventListener("resize", onWindowResize, false);
	document.addEventListener("mousemove", onMouseMove, false);
}

/*
 * Adds the sketch control panel
 */
function addControlPanel() {
	// Create the control panel
	var controlPanel = new dat.GUI();

	// Add the controllers
	controlPanel.add(controlParameters, "Geometry", [ "sphere", "torus" ]).onFinishChange(addMeshToScene);
}

/*
 * Adds the mesh to the scence
 */
function addMeshToScene() {
	// If the mesh exists, remove it from the scene
	if (mesh) {
		scene.remove(mesh);
	}

	// Create the desired geometry
	var geometry;

	if (controlParameters.Geometry == "sphere") {
		geometry = new THREE.SphereGeometry(10, 64, 64);
	} else if (controlParameters.Geometry == "torus") {
		geometry = new THREE.TorusKnotGeometry(8, 2.5, 256, 32);
	}

	// Create the mesh
	mesh = new THREE.Mesh(geometry, material);

	// Add the mesh to the scene
	scene.add(mesh);
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
 * Updates the renderer size, the camera aspect ratio and the uniform values when the window is resized
 */
function onWindowResize(event) {
	// Update the camera
	camera.aspect = window.innerWidth / window.innerHeight;
	camera.updateProjectionMatrix();

	// Update the renderer
	renderer.setSize(window.innerWidth, window.innerHeight);

	// Update the resolution uniform
	uniforms.u_resolution.value.x = window.innerWidth;
	uniforms.u_resolution.value.y = window.innerHeight;
}

/*
 * Updates the uniform values when the mouse moves
 */
function onMouseMove(event) {
	uniforms.u_mouse.value.x = event.pageX;
	uniforms.u_mouse.value.y = window.innerHeight - event.pageY;
}
