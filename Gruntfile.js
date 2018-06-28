module.exports = function(grunt) {

	/*
	 * Defines the grunt-replace parameters that will fill the html template file for a 2d shader example
	 */
	function replaceParametersFor2dExample(name, vertexShader, fragmentShader) {
		var parameters = {
			files : [ {
				src : 'html/template-example-2d.html',
				dest : 'WebContent/' + name + '-example.html'
			} ],
			options : {
				patterns : [ {
					match : 'name',
					replacement : name
				}, {
					match : 'jsfile',
					replacement : 'js/shader-example-2d.js'
				}, {
					match : 'vertexShader',
					replacement : '<%= grunt.file.read("WebContent/shaders/' + vertexShader + '") %>'
				}, {
					match : 'fragmentShader',
					replacement : '<%= grunt.file.read("WebContent/shaders/' + fragmentShader + '") %>'
				} ]
			}
		};

		return parameters;
	}

	/*
	 * Defines the grunt-replace parameters that will fill the html template file for a 3d shader example
	 */
	function replaceParametersFor3dExample(name, vertexShader, fragmentShader) {
		var parameters = {
			files : [ {
				src : 'html/template-example-3d.html',
				dest : 'WebContent/' + name + '-example.html'
			} ],
			options : {
				patterns : [ {
					match : 'name',
					replacement : name
				}, {
					match : 'jsfile',
					replacement : 'js/shader-example-3d.js'
				}, {
					match : 'vertexShader',
					replacement : '<%= grunt.file.read("WebContent/shaders/' + vertexShader + '") %>'
				}, {
					match : 'fragmentShader',
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
				src : [ 'WebContent/*.html', 'WebContent/shaders/*.glsl', 'WebContent/js/*.js' ]
			}
		},

		// grunt-contrib-copy
		copy : {
			index : {
				src : 'html/index.html',
				dest : 'WebContent/index.html'
			},
			jsfiles : {
				expand : true,
				flatten : true,
				src : 'js/*.js',
				dest : 'WebContent/js/'
			}
		},

		// grunt-exec
		exec : {
			build_shaders : {
				cwd : 'shaders',
				cmd : 'for filename in *.glsl; do glslify "${filename}" -o ../WebContent/shaders/"${filename}"; done'
			}
		},

		// grunt-replace
		replace : {
			random : replaceParametersFor2dExample('random', 'vert-2d.glsl', 'frag-random.glsl'),
			noise : replaceParametersFor2dExample('noise', 'vert-2d.glsl', 'frag-noise.glsl'),
			rain : replaceParametersFor2dExample('rain', 'vert-2d.glsl', 'frag-rain.glsl'),
			tile : replaceParametersFor2dExample('tile', 'vert-2d.glsl', 'frag-tile.glsl'),
			sphere : replaceParametersFor3dExample('sphere', 'vert-3d.glsl', 'frag-sphere.glsl'),
			pencil : replaceParametersFor3dExample('pencil', 'vert-3d.glsl', 'frag-pencil.glsl')
		},

		// grunt-jshint
		jshint : {
			files : [ 'Gruntfile.js', 'package.json', 'WebContent/js/*example*.js' ]
		},

		// grunt-contrib-watch
		watch : {
			files : [ 'html/*.html', 'shaders/**/*.glsl', 'js/*.js' ],
			tasks : [ 'default' ]
		}
	});

	// Load the grunt tasks
	grunt.loadNpmTasks('grunt-contrib-clean');
	grunt.loadNpmTasks('grunt-contrib-copy');
	grunt.loadNpmTasks('grunt-exec');
	grunt.loadNpmTasks('grunt-replace');
	grunt.loadNpmTasks('grunt-contrib-jshint');
	grunt.loadNpmTasks('grunt-contrib-watch');

	// Default task
	grunt.registerTask('default', [ 'clean', 'copy', 'exec', 'replace', 'jshint' ]);
};
