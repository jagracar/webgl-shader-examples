module.exports = function(grunt) {

	/*
	 * Defines the grunt-replace parameters that will fill the html and js template files of a 2d shader example
	 */
	function replaceParameters2dExample(name, vertexShader, fragmentShader) {
		var parameters = {
			files : [ {
				src : 'html/template-example.html',
				dest : 'WebContent/' + name + '-example.html'
			}, {
				src : 'js/template-2d-example.js',
				dest : 'WebContent/tmp/' + name + '.js'
			} ],
			options : {
				patterns : [ {
					match : 'name',
					replacement : name
				}, {
					match : 'jsfile',
					replacement : 'js/' + name + '.js'
				}, {
					match : 'vertexShader',
					replacement : '../shaders/' + vertexShader
				}, {
					match : 'fragmentShader',
					replacement : '../shaders/' + fragmentShader
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
			},
			tmp : {
				src : [ 'WebContent/tmp' ]
			}
		},

		// grunt-contrib-copy
		copy : {
			index : {
				src : 'html/index.html',
				dest : 'WebContent/index.html'
			},
			three : {
				src : 'js/three.js',
				dest : 'WebContent/js/three.js'
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
			random : replaceParameters2dExample('random', 'vert2d.glsl', 'fragRandom.glsl'),
			noise : replaceParameters2dExample('noise', 'vert2d.glsl', 'fragNoise.glsl')
		},

		// grunt-browserify
		browserify : {
			build : {
				files : {
					'WebContent/js/random.js' : [ 'WebContent/tmp/random.js' ],
					'WebContent/js/noise.js' : [ 'WebContent/tmp/noise.js' ]
				},
				options : {
					transform : [ 'glslify' ]
				}
			}
		},

		// grunt-contrib-watch
		watch : {
			files : [ 'html/*.html', 'shaders/*.glsl', 'js/*.js' ],
			tasks : [ 'default' ]
		}
	});

	// Load the grunt tasks
	grunt.loadNpmTasks('grunt-contrib-clean');
	grunt.loadNpmTasks('grunt-contrib-copy');
	grunt.loadNpmTasks('grunt-exec');
	grunt.loadNpmTasks('grunt-replace');
	grunt.loadNpmTasks('grunt-browserify');
	grunt.loadNpmTasks('grunt-contrib-watch');

	// Default task
	grunt.registerTask('default', [ 'clean', 'copy', 'exec', 'replace', 'browserify', 'clean:tmp' ]);
};
