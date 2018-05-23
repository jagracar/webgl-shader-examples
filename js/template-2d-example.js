var scene, renderer, camera, clock, uniforms;

var glslify = require("glslify")

init();
animate();

/*
 * Initializes the sketch
 */
function init() {
	// Scene setup
	scene = new THREE.Scene();

	// Get the WebGL renderer
	renderer = new THREE.WebGLRenderer();
	renderer.setPixelRatio(window.devicePixelRatio);

	// Add the renderer to the sketch container
	document.getElementById("container").appendChild(renderer.domElement);

	// Camera setup
	camera = new THREE.Camera();
	camera.position.z = 1;

	// Initialize the clock
	clock = new THREE.Clock(true);

	// Create the plane geometry
	var geometry = new THREE.PlaneBufferGeometry(2, 2);

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
	var material = new THREE.ShaderMaterial({
		uniforms : uniforms,
		vertexShader : glslify("@@vertexShader"),
		fragmentShader : glslify("@@fragmentShader")
	});

	// Create the mesh
	var mesh = new THREE.Mesh(geometry, material);

	// Add the mesh to the scene
	scene.add(mesh);

	// Update the uniforms
	onWindowResize();

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
}

/*
 * Renders the sketch
 */
function render() {
	uniforms.u_time.value = clock.getElapsedTime();
	renderer.render(scene, camera);
}

/*
 * Updates the renderer size and the uniform values when the window is resized
 */
function onWindowResize(event) {
	renderer.setSize(window.innerWidth, window.innerHeight);
	uniforms.u_resolution.value.x = renderer.domElement.width;
	uniforms.u_resolution.value.y = renderer.domElement.height;
}

/*
 * Updates the uniform values when the mouse moves
 */
function onMouseMove(event) {
	uniforms.u_mouse.value.x = event.pageX
	uniforms.u_mouse.value.y = event.pageY
}
