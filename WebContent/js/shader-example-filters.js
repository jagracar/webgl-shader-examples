window.onload = function() {
	runSketch();
};

function runSketch() {
	var renderer, scene, camera, clock, stats, controlParameters, uniforms, videoElement;

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

		// Initialize the scene
		scene = new THREE.Scene();

		// Initialize the camera
		camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);

		// Initialize the clock
		clock = new THREE.Clock(true);

		// Initialize the statistics monitor and add it to the sketch container
		stats = new Stats();
		stats.dom.style.cssText = "";
		document.getElementById("sketch-stats").appendChild(stats.dom);

		// Initialize the control parameters
		controlParameters = {
			"Input" : "Webcam"
		};

		// Add the control panel to the sketch
		addControlPanel();

		// Create the plane geometry
		var geometry = new THREE.PlaneBufferGeometry(2, 2);

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

		// Create the mesh and add it to the scene
		var mesh = new THREE.Mesh(geometry, material);
		scene.add(mesh);

		// Set the input texture
		setInputTexture();

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
		controlPanel.add(controlParameters, "Input", [ "Webcam", "Image" ]).onFinishChange(setInputTexture);

		// Add the GUI to the correct DOM element
		document.getElementById("sketch-gui").appendChild(controlPanel.domElement);
	}

	/*
	 * Sets the input texture
	 */
	function setInputTexture() {
		// Handle all the different options
		if (controlParameters.Input == "Webcam") {
			// Create the video element if it was not done before
			if (!videoElement) {
				videoElement = document.createElement("video");
				videoElement.autoplay = true;
			}

			// Start the user's webcam
			startWebcam();
		} else if (controlParameters.Input == "Image") {
			// Stop the webcam if it's active
			if (videoElement && videoElement.srcObject) {
				videoElement.srcObject.getVideoTracks()[0].stop();
			}

			// Load the image texture
			loadTextrure("img/portrait.jpg");
		}
	}

	/*
	 * Starts the user's webcam and updates the texture uniform
	 */
	function startWebcam() {
		// Try to access the webcam stream using the MediadDevices interface
		if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
			// Set the video constraints
			var constraints = {
				video : {
					width : {
						ideal : window.innerWidth * window.devicePixelRatio
					},
					height : {
						ideal : window.innerHeight * window.devicePixelRatio
					},
					facingMode : "user"
				}
			};

			// Request the user media
			var promise = navigator.mediaDevices.getUserMedia(constraints);

			// Add the handlers
			promise.then(function(stream) {
				// Add the stream to the video element
				videoElement.srcObject = stream;

				// Create the texture that will contain the webcam video output
				var texture = new THREE.VideoTexture(videoElement);
				texture.format = THREE.RGBFormat;
				texture.generateMipmaps = false;
				texture.minFilter = THREE.LinearFilter;
				texture.magFilter = THREE.LinearFilter;
				uniforms.u_texture.value = texture;
			});

			promise.catch(function(error) {
				console.error("Unable to access the camera/webcam.", error);
			});
		} else {
			console.error("MediaDevices interface not available.");
		}
	}

	/*
	 * Loads a texture and updates the texture uniform
	 */
	function loadTextrure(imageFileName) {
		var loader = new THREE.TextureLoader();

		loader.load(imageFileName, function(texture) {
			texture.minFilter = THREE.LinearFilter;
			texture.magFilter = THREE.LinearFilter;
			uniforms.u_texture.value = texture;
		});
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
	 * Updates the renderer size and the uniforms when the window is resized
	 */
	function onWindowResize(event) {
		// Update the renderer
		renderer.setSize(window.innerWidth, window.innerHeight);

		// Restart the user's webcam if necessary
		if (controlParameters.Input == "Webcam") {
			startWebcam();
		}

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