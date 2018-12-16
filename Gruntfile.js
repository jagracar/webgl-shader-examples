module.exports = function(grunt) {

	/*
	 * Defines the grunt-replace parameters that will fill the html template file for a shader example
	 */
	function replaceParametersForExample(name, htmlFile, jsFile, vertexShader, fragmentShader) {
		var parameters = {
			files : [ {
				src : 'html/' + htmlFile,
				dest : 'WebContent/' + name + '-example.html'
			} ],
			options : {
				patterns : [ {
					match : 'name',
					replacement : name
				}, {
					match : 'jsFile',
					replacement : '/js/' + jsFile
				}, {
					match : 'vertexShaderFile',
					replacement : '/shaders/' + vertexShader
				}, {
					match : 'fragmentShaderFile',
					replacement : '/shaders/' + fragmentShader
				}, {
					match : 'vertexShaderContent',
					replacement : '<%= grunt.file.read("WebContent/shaders/' + vertexShader + '") %>'
				}, {
					match : 'fragmentShaderContent',
					replacement : '<%= grunt.file.read("WebContent/shaders/' + fragmentShader + '") %>'
				} ]
			}
		};

		return parameters;
	}

	/*
	 * Defines the grunt-replace parameters that will fill the html template file for a simulation shader example
	 */
	function replaceParametersForSimExample(name, htmlFile, jsFile, positionShader, velocityShader, vertexShader, fragmentShader) {
		var parameters = {
			files : [ {
				src : 'html/' + htmlFile,
				dest : 'WebContent/' + name + '-example.html'
			} ],
			options : {
				patterns : [ {
					match : 'name',
					replacement : name
				}, {
					match : 'jsFile',
					replacement : '/js/' + jsFile
				}, {
					match : 'positionShaderFile',
					replacement : '/shaders/' + positionShader
				}, {
					match : 'velocityShaderFile',
					replacement : '/shaders/' + velocityShader
				}, {
					match : 'vertexShaderFile',
					replacement : '/shaders/' + vertexShader
				}, {
					match : 'fragmentShaderFile',
					replacement : '/shaders/' + fragmentShader
				}, {
					match : 'positionShaderContent',
					replacement : '<%= grunt.file.read("WebContent/shaders/' + positionShader + '") %>'
				}, {
					match : 'velocityShaderContent',
					replacement : '<%= grunt.file.read("WebContent/shaders/' + velocityShader + '") %>'
				}, {
					match : 'vertexShaderContent',
					replacement : '<%= grunt.file.read("WebContent/shaders/' + vertexShader + '") %>'
				}, {
					match : 'fragmentShaderContent',
					replacement : '<%= grunt.file.read("WebContent/shaders/' + fragmentShader + '") %>'
				} ]
			}
		};

		return parameters;
	}

	// Project configuration.
	grunt.initConfig({
		pkg : grunt.file.readJSON('package.json'),

		// grunt-contrib-clean
		clean : {
			build : {
				src : [ 'WebContent/*.html', 'WebContent/shaders/*.glsl' ]
				//src : [ 'WebContent/*.html', 'WebContent/shaders/frag-flare.glsl' ]
			}
		},

		// grunt-contrib-copy
		copy : {
			index : {
				src : 'html/index.html',
				dest : 'WebContent/index.html'
			},
			about : {
				src : 'html/about.html',
				dest : 'WebContent/about.html'
			}
		},

		// grunt-exec
		exec : {
			build_shaders : {
				cwd : 'shaders',
				cmd : 'for filename in *.glsl; do glslify "${filename}" -o ../WebContent/shaders/"${filename}"; done'
				//cmd : 'glslify frag-flare.glsl -o ../WebContent/shaders/frag-flare.glsl'
			}
		},

		// grunt-replace
		replace : {
			random : replaceParametersForExample('random', 'template-example-2d.html', 'shader-example-2d.js', 'vert-2d.glsl', 'frag-random.glsl'),
			noise : replaceParametersForExample('noise', 'template-example-2d.html', 'shader-example-2d.js', 'vert-2d.glsl', 'frag-noise.glsl'),
			rain : replaceParametersForExample('rain', 'template-example-2d.html', 'shader-example-2d.js', 'vert-2d.glsl', 'frag-rain.glsl'),
			tile : replaceParametersForExample('tile', 'template-example-2d.html', 'shader-example-2d.js', 'vert-2d.glsl', 'frag-tile.glsl'),
			wave : replaceParametersForExample('wave', 'template-example-3d.html', 'shader-example-3d.js', 'vert-3d.glsl', 'frag-wave.glsl'),
			pencil : replaceParametersForExample('pencil', 'template-example-3d.html', 'shader-example-3d.js', 'vert-3d.glsl', 'frag-pencil.glsl'),
			dots : replaceParametersForExample('dots', 'template-example-3d.html', 'shader-example-3d.js', 'vert-3d.glsl', 'frag-dots.glsl'),
			toon : replaceParametersForExample('toon', 'template-example-3d.html', 'shader-example-3d.js', 'vert-3d.glsl', 'frag-toon.glsl'),
			edge : replaceParametersForExample('edge', 'template-example-2d.html', 'shader-example-filters.js', 'vert-filters.glsl', 'frag-edge.glsl'),
			blur : replaceParametersForExample('blur', 'template-example-2d.html', 'shader-example-filters.js', 'vert-filters.glsl', 'frag-blur.glsl'),
			pixels : replaceParametersForExample('pixels', 'template-example-2d.html', 'shader-example-filters.js', 'vert-filters.glsl', 'frag-pixelated.glsl'),
			lens : replaceParametersForExample('lens', 'template-example-2d.html', 'shader-example-filters.js', 'vert-filters.glsl', 'frag-lens.glsl'),
			gravity : replaceParametersForSimExample('gravity', 'template-example-sim.html', 'shader-example-gravity.js', 'frag-grav-pos.glsl', 'frag-grav-vel.glsl', 'vert-sim.glsl', 'frag-sim.glsl'),
			galaxies : replaceParametersForSimExample('galaxies', 'template-example-sim.html', 'shader-example-galaxies.js', 'frag-galaxies-pos.glsl', 'frag-galaxies-vel.glsl', 'vert-sim.glsl', 'frag-sim.glsl'),
			debug : replaceParametersForSimExample('debug', 'template-example-sim.html', 'shader-example-debug.js', 'frag-debug-pos.glsl', 'frag-debug-vel.glsl', 'vert-debug.glsl', 'frag-debug.glsl'),
			repulsion : replaceParametersForSimExample('repulsion', 'template-example-sim.html', 'shader-example-repulsion.js', 'frag-repulsion-pos.glsl', 'frag-repulsion-vel.glsl', 'vert-repulsion.glsl', 'frag-repulsion.glsl'),
			stippling : replaceParametersForSimExample('stippling', 'template-example-sim.html', 'shader-example-stippling.js', 'frag-stippling-pos.glsl', 'frag-stippling-vel.glsl', 'vert-stippling.glsl', 'frag-stippling.glsl'),
			badtv : replaceParametersForExample('badtv', 'template-example-post.html', 'shader-example-postprocessing.js', 'vert-filters.glsl', 'frag-badtv.glsl'),
			pixelated : replaceParametersForExample('pixelated', 'template-example-post.html', 'shader-example-postprocessing.js', 'vert-filters.glsl', 'frag-pixelated.glsl'),
			flare : replaceParametersForExample('flare', 'template-example-2d.html', 'shader-example-evolve.js', 'vert-filters.glsl', 'frag-flare.glsl'),
			fire : replaceParametersForExample('fire', 'template-example-2d.html', 'shader-example-evolve.js', 'vert-filters.glsl', 'frag-fire.glsl'),
			cursor : replaceParametersForExample('cursor', 'template-example-2d.html', 'shader-example-evolve.js', 'vert-filters.glsl', 'frag-cursor.glsl'),
			sort : replaceParametersForExample('sort', 'template-example-2d.html', 'shader-example-evolveImage.js', 'vert-filters.glsl', 'frag-sort.glsl'),
			deform : replaceParametersForExample('deform', 'template-example-3d.html', 'shader-example-3d.js', 'vert-deform.glsl', 'frag-normals.glsl')
		},

		// grunt-jshint
		jshint : {
			files : [ 'Gruntfile.js', 'package.json', 'WebContent/js/*.js' ]
		},

		// grunt-contrib-sass
		sass : {
			options : {
				sourcemap : 'none',
				style : 'expanded'
			},
			build : {
				src : 'sass/styles.scss',
				dest : 'WebContent/css/styles.css'
			}
		},

		// grunt-autoprefixer
		autoprefixer : {
			build : {
				src : 'WebContent/css/styles.css',
				dest : 'WebContent/css/styles.css'
			}
		},

		// grunt-contrib-watch
		watch : {
			files : [ 'html/*.html', 'shaders/**/*.glsl', 'WebContent/js/*.js' ],
			tasks : [ 'default' ]
		}
	});

	// Load the grunt tasks
	grunt.loadNpmTasks('grunt-contrib-clean');
	grunt.loadNpmTasks('grunt-contrib-copy');
	grunt.loadNpmTasks('grunt-exec');
	grunt.loadNpmTasks('grunt-replace');
	grunt.loadNpmTasks('grunt-contrib-jshint');
	grunt.loadNpmTasks('grunt-contrib-sass');
	grunt.loadNpmTasks('grunt-autoprefixer');
	grunt.loadNpmTasks('grunt-contrib-watch');

	// Default task
	grunt.registerTask('default', [ 'clean', 'copy', 'exec', 'replace', 'jshint', 'sass', 'autoprefixer' ]);
};
