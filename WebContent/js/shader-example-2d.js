var renderer, scene, camera, clock, stats, uniforms;

init();
animate();

/*
 * Initializes the sketch
 */
function init() {
	// Initialize the WebGL renderer
	renderer = new THREE.WebGLRenderer();
	renderer.setPixelRatio(window.devicePixelRatio);
	renderer.setSize(window.innerWidth, window.innerHeight);

	// Add the renderer to the sketch container
	var container = document.getElementById("container");
	container.appendChild(renderer.domElement);

	// Initialize the scene
	scene = new THREE.Scene();

	// Initialize the camera
	camera = new THREE.Camera();
	camera.position.z = 1;

	// Initialize the clock
	clock = new THREE.Clock(true);

	// Initialize the statistics monitor and add it to the sketch container
	stats = new Stats();
	container.appendChild(stats.dom);

	// Create the plane geometry
	var geometry = new THREE.PlaneBufferGeometry(2, 2);

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
	var material = new THREE.ShaderMaterial({
		uniforms : uniforms,
		vertexShader : document.getElementById("vertexShader").textContent,
		fragmentShader : document.getElementById("fragmentShader").textContent
	});

	// Create the mesh and add it to the scene
	var mesh = new THREE.Mesh(geometry, material);
	scene.add(mesh);

	// Add the event listeners
	window.addEventListener("resize", onWindowResize, false);
	document.addEventListener("mousemove", onMouseMove, false);
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
 * Updates the renderer size and the uniforms when the window is resized
 */
function onWindowResize(event) {
	// Update the renderer
	renderer.setSize(window.innerWidth, window.innerHeight);

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
