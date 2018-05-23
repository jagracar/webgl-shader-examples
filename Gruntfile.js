module.exports = function(grunt) {
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

	// grunt-exec
	exec : {
	    build_shaders : {
		cwd : 'shaders',
		cmd : 'for filename in *.glsl; do glslify "${filename}" -o ../WebContent/shaders/"${filename}"; done'
	    }
	},

	// grunt-replace
	replace : {
	    random : {
		options : {
		    patterns : [ {
			match : 'vert2d.glsl',
			replacement : '../shaders/vert2d.glsl'
		    }, {
			match : 'frag2d.glsl',
			replacement : '../shaders/fragRandom.glsl'
		    }, {
			match : 'sketch.js',
			replacement : 'js/random.js'
		    } ]
		},
		files : [ {
		    src : 'js/sketch2d.js',
		    dest : 'WebContent/tmp/random.js'
		}, {
		    src : 'html/template-example.html',
		    dest : 'WebContent/random-example.html'
		} ]
	    },
	    noise : {
		options : {
		    patterns : [ {
			match : 'vert2d.glsl',
			replacement : '../shaders/vert2d.glsl'
		    }, {
			match : 'frag2d.glsl',
			replacement : '../shaders/fragNoise.glsl'
		    }, {
			match : 'sketch.js',
			replacement : 'js/noise.js'
		    } ]
		},
		files : [ {
		    src : 'js/sketch2d.js',
		    dest : 'WebContent/tmp/noise.js'
		}, {
		    src : 'html/template-example.html',
		    dest : 'WebContent/noise-example.html'
		} ]
	    }
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
	
	// grunt-contrib-copy
	copy : {
	    main : {
		src : 'html/index.html',
		dest : 'WebContent/index.html'
	    }
	},
	
	// grunt-contrib-watch
	watch : {
	    files : [ 'html/*.html', 'shaders/*.glsl', 'js/*.js' ],
	    tasks : [ 'default' ]
	}
    });

    // Load the grunt tasks.
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-exec');
    grunt.loadNpmTasks('grunt-replace');
    grunt.loadNpmTasks('grunt-browserify');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-copy');

    // Default task(s).
    grunt.registerTask('default', [ 'clean', 'exec', 'replace', 'browserify', 'copy', 'clean:tmp' ]);
};