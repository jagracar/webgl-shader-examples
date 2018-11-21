window.onload = function() {
	runSketch();
};

function runSketch() {
	var renderer, renderTarget1, renderTarget2, sceneShader, sceneScreen, camera, clock, stats, uniforms, materialScreen;

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
		var container = document.getElementById("sketch-container");
		container.appendChild(renderer.domElement);

		// Initialize the render targets
		renderTarget1 = new THREE.WebGLRenderTarget(window.innerWidth, window.innerHeight);
		renderTarget2 = new THREE.WebGLRenderTarget(window.innerWidth, window.innerHeight);

		// Initialize the scenes
		sceneShader = new THREE.Scene();
		sceneScreen = new THREE.Scene();

		// Initialize the camera
		camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);

		// Initialize the clock
		clock = new THREE.Clock(true);

		// Initialize the statistics monitor and add it to the sketch container
		stats = new Stats();
		stats.dom.style.cssText = "";
		document.getElementById("sketch-stats").appendChild(stats.dom);

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
						.multiplyScalar(window.devicePixelRatio)
			},
			u_mouse : {
				type : "v2",
				value : new THREE.Vector2()
			},
			u_texture : {
				type : "t",
				value : null
			}
		};

		// Create the shader material
		var materialShader = new THREE.ShaderMaterial({
			uniforms : uniforms,
			vertexShader : document.getElementById("vertexShader").textContent,
			fragmentShader : document.getElementById("fragmentShader").textContent
		});

		// Create the screen material
		materialScreen = new THREE.MeshBasicMaterial();

		// Create the meshes and add them to the scene
		var meshShader = new THREE.Mesh(geometry, materialShader);
		var meshScreen = new THREE.Mesh(geometry, materialScreen);
		sceneShader.add(meshShader);
		sceneScreen.add(meshScreen);

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
		// Update the uniforms
		uniforms.u_time.value = clock.getElapsedTime();
		uniforms.u_texture.value = renderTarget1.texture;

		// Render the shader scene
		renderer.render(sceneShader, camera, renderTarget2);

		// Update the screen material texture
		materialScreen.map = renderTarget2.texture;

		// Render the screen scene
		renderer.render(sceneScreen, camera);

		// Swap the render targets
		var tmp = renderTarget1;
		renderTarget1 = renderTarget2;
		renderTarget2 = tmp;
	}

	/*
	 * Updates the renderer size and the uniforms when the window is resized
	 */
	function onWindowResize(event) {
		// Update the renderer and the render targets
		renderer.setSize(window.innerWidth, window.innerHeight);
		renderTarget1.setSize(window.innerWidth, window.innerHeight);
		renderTarget2.setSize(window.innerWidth, window.innerHeight);

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
		event.preventDefault();

		// Update the mouse uniform
		uniforms.u_mouse.value.set(event.touches[0].pageX, window.innerHeight - event.touches[0].pageY).multiplyScalar(
				window.devicePixelRatio);
	}
}