(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
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
		vertexShader : glslify(["#define GLSLIFY 1\n#define GLSLIFY 1\nvoid main() {\n\tgl_Position = vec4(position, 1.0);\n}\n"]),
		fragmentShader : glslify(["#define GLSLIFY 1\n#define GLSLIFY 1\nuniform vec2 u_resolution;\nuniform vec2 u_mouse;\nuniform float u_time;\n\n// Import the 2d noise function\n//\n// GLSL textureless classic 2D noise \"cnoise\",\n// with an RSL-style periodic variant \"pnoise\".\n// Author:  Stefan Gustavson (stefan.gustavson@liu.se)\n// Version: 2011-08-22\n//\n// Many thanks to Ian McEwan of Ashima Arts for the\n// ideas for permutation and gradient selection.\n//\n// Copyright (c) 2011 Stefan Gustavson. All rights reserved.\n// Distributed under the MIT license. See LICENSE file.\n// https://github.com/ashima/webgl-noise\n//\n\nvec4 mod289(vec4 x)\n{\n  return x - floor(x * (1.0 / 289.0)) * 289.0;\n}\n\nvec4 permute(vec4 x)\n{\n  return mod289(((x*34.0)+1.0)*x);\n}\n\nvec4 taylorInvSqrt(vec4 r)\n{\n  return 1.79284291400159 - 0.85373472095314 * r;\n}\n\nvec2 fade(vec2 t) {\n  return t*t*t*(t*(t*6.0-15.0)+10.0);\n}\n\n// Classic Perlin noise\nfloat cnoise(vec2 P)\n{\n  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);\n  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);\n  Pi = mod289(Pi); // To avoid truncation effects in permutation\n  vec4 ix = Pi.xzxz;\n  vec4 iy = Pi.yyww;\n  vec4 fx = Pf.xzxz;\n  vec4 fy = Pf.yyww;\n\n  vec4 i = permute(permute(ix) + iy);\n\n  vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;\n  vec4 gy = abs(gx) - 0.5 ;\n  vec4 tx = floor(gx + 0.5);\n  gx = gx - tx;\n\n  vec2 g00 = vec2(gx.x,gy.x);\n  vec2 g10 = vec2(gx.y,gy.y);\n  vec2 g01 = vec2(gx.z,gy.z);\n  vec2 g11 = vec2(gx.w,gy.w);\n\n  vec4 norm = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));\n  g00 *= norm.x;\n  g01 *= norm.y;\n  g10 *= norm.z;\n  g11 *= norm.w;\n\n  float n00 = dot(g00, vec2(fx.x, fy.x));\n  float n10 = dot(g10, vec2(fx.y, fy.y));\n  float n01 = dot(g01, vec2(fx.z, fy.z));\n  float n11 = dot(g11, vec2(fx.w, fy.w));\n\n  vec2 fade_xy = fade(Pf.xy);\n  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);\n  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);\n  return 2.3 * n_xy;\n}\n\nvoid main() {\n\tfloat n = cnoise(5.0 * (gl_FragCoord.xy - u_mouse) / u_resolution.xy);\n\tgl_FragColor = vec4(vec3(n), 1.0);\n}\n"])
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

},{"glslify":2}],2:[function(require,module,exports){
module.exports = function(strings) {
  if (typeof strings === 'string') strings = [strings]
  var exprs = [].slice.call(arguments,1)
  var parts = []
  for (var i = 0; i < strings.length-1; i++) {
    parts.push(strings[i], exprs[i] || '')
  }
  parts.push(strings[i])
  return parts.join('')
}

},{}]},{},[1]);
