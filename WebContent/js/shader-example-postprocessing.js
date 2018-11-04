window.onload = function() {
	runSketch();
};

function runSketch() {
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
		var container = document.getElementById("sketch-container");
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
		stats.dom.style.cssText = "";
		document.getElementById("sketch-stats").appendChild(stats.dom);

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
						.multiplyScalar(window.devicePixelRatio)
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
			transparent : true,
			extensions : {
				derivatives : true
			}
		});

		// Create the mesh and add it to the scene
		addMeshToScene();

		// Start the user webcam
		startWebcam();

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

		// Handle all the different options
		if (controlParameters.Geometry == "Suzanne") {
			// Load the json file that contains the geometry
			var loader = new THREE.JSONLoader();
			loader.load("/objects/suzanne_geometry.json", function(geometry) {
				// Scale and rotate the geometry
				geometry.scale(10, 10, 10);
				geometry.rotateX(Math.PI / 2);

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
	 * Starts the user's webcam
	 */
	function startWebcam() {
		// Browser compatibility check
		navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia
				|| navigator.msGetUserMedia;

		// Try to access the user's webcam
		if (!navigator.getUserMedia) {
			displayErrorMessage("navigator.getUserMedia() is not supported in your browser");
		} else {
			navigator.getUserMedia({
				video : true
			}, webcamSuccessCallback, webcamErrorCallback);
		}
	}

	/*
	 * Handles the webcam media stream
	 */
	function webcamSuccessCallback(mediaStream) {
		// Create the video element, but don't add it to the document
		videoElement = document.createElement("video");
		videoElement.autoplay = true;

		// Read the media stream with the video element
		try {
			videoElement.srcObject = mediaStream;
		} catch (error) {
			window.URL = window.URL || window.webkitURL;
			videoElement.src = window.URL ? window.URL.createObjectURL(mediaStream) : mediaStream;
		}

		// Run this when the video element metadata information has finished loading (only once)
		videoElement.onloadedmetadata = function() {
			if (this.videoWidth > 0) {
				// Update the webcam pass size uniform
				// webcamPass.uniforms.size.value.set(renderer.domElement.width, renderer.domElement.height);
			}

			// Create the webcam plane and add it to the scene
			createWebcamPlane();
		};
	}

	/*
	 * Alerts the user that the webcam video cannot be displayed
	 */
	function webcamErrorCallback(e) {
		if (e.name == "PermissionDeniedError" || e.code == 1) {
			console.error("User denied access to the camera");
		} else {
			console.error("No camera available");
		}
	}

	/*
	 * Creates the plane that will show the webcam video output
	 */
	function createWebcamPlane() {
		var geometry, texture, material;

		// Create the webcam plane geometry
		geometry = new THREE.PlaneGeometry(2, 2, 1, 1);

		// Create the texture that will contain the webcam video output
		texture = new THREE.Texture(videoElement);
		texture.format = THREE.RGBFormat;
		texture.generateMipmaps = false;
		texture.minFilter = THREE.LinearFilter;
		texture.magFilter = THREE.LinearFilter;

		// Create the webcam plane material
		material = new THREE.MeshBasicMaterial();
		material.depthTest = false;
		material.depthWrite = false;
		material.map = texture;

		// Create the webcam plane mesh
		webcamPlane = new THREE.Mesh(geometry, material);

		// Add it to the scene
		scene.add(webcamPlane);
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
