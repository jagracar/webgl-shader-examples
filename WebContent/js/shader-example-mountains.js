window.onload = function() {
	runSketch();
};

function runSketch() {
	var renderer, scene, camera, clock, stats, skyColor, uniforms;

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

		// Set the sky color
		skyColor = new THREE.Color(0.1, 0.8, 0.9);
		renderer.setClearColor(skyColor);

		// Create the plane geometry
		var planeSize = 320;
		var planeSegments = 32;
		var geometry = new THREE.PlaneGeometry(planeSize, planeSize, planeSegments, planeSegments);
		geometry.rotateX(-Math.PI / 2);

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
				value : new THREE.Vector2(0.7 * window.innerWidth, window.innerHeight)
						.multiplyScalar(window.devicePixelRatio)
			},
			u_tileSize : {
				type : "f",
				value : planeSize / planeSegments
			},
			u_speed : {
				type : "f",
				value : 30.0
			},
			u_maxHeight : {
				type : "f",
				value : 20.0
			},
			u_skyColor : {
				type : "v3",
				value : skyColor
			}
		};

		// Create the shader material
		var material = new THREE.ShaderMaterial({
			uniforms : uniforms,
			vertexShader : document.getElementById("vertexShader").textContent,
			fragmentShader : document.getElementById("fragmentShader").textContent,
			side : THREE.FrontSide,
			transparent : true,
			extensions : {
				derivatives : true
			}
		});

		// Create the mesh and add it to the scene
		var mesh = new THREE.Mesh(geometry, material);
		mesh.rotateX(Math.PI / 9);
		scene.add(mesh);

		// Add the event listeners
		window.addEventListener("resize", onWindowResize, false);
		renderer.domElement.addEventListener("mousemove", onMouseMove, false);
		renderer.domElement.addEventListener("touchstart", onTouchMove, false);
		renderer.domElement.addEventListener("touchmove", onTouchMove, false);
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
		uniforms.u_resolution.value.set(window.innerWidth, window.innerHeight).multiplyScalar(window.devicePixelRatio);
	}

	/*
	 * Updates the uniforms when the mouse moves
	 */
	function onMouseMove(event) {
		// Calculate the new sky color and update the renderer
		var sunset = event.pageY / window.innerHeight;
		var newSkyColor = new THREE.Color(skyColor.r + sunset, skyColor.g - 0.2 * sunset, skyColor.b - 0.2 * sunset);
		renderer.setClearColor(newSkyColor);

		// Update the uniforms
		uniforms.u_mouse.value.set(event.pageX, window.innerHeight - event.pageY).multiplyScalar(
				window.devicePixelRatio);
		uniforms.u_skyColor.value = newSkyColor;
	}

	/*
	 * Updates the uniforms when the touch moves
	 */
	function onTouchMove(event) {
		// Calculate the new sky color and update the renderer
		var sunset = event.touches[0].pageY / window.innerHeight;
		var newSkyColor = new THREE.Color(skyColor.r + sunset, skyColor.g - 0.2 * sunset, skyColor.b - 0.2 * sunset);
		renderer.setClearColor(newSkyColor);

		// Update the uniforms
		uniforms.u_mouse.value.set(event.touches[0].pageX, window.innerHeight - event.touches[0].pageY).multiplyScalar(
				window.devicePixelRatio);
		uniforms.u_skyColor.value = newSkyColor;
	}
}