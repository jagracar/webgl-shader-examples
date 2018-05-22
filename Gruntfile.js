module.exports = function(grunt) {
    // Project configuration.
    grunt.initConfig({
	pkg : grunt.file.readJSON('package.json'),
	exec : {
	    clean_shaders : {
		exitCode: [0, 1],
		cwd : 'WebContent/shaders',
		cmd : 'rm *.glsl'
	    },
	    build_shaders : {
		cwd : 'shaders',
		cmd : 'for filename in *.glsl; do glslify "${filename}" -o ../WebContent/shaders/"${filename}"; done'
	    }
	},
	watch : {
	    files : [ 'shaders/*.glsl' ],
	    tasks : [ 'exec:clean_shaders', 'exec:clean_build_shaders' ]
	}
    });

    // Load the grunt tasks.
    grunt.loadNpmTasks('grunt-exec');
    grunt.loadNpmTasks('grunt-contrib-watch');

    // Default task(s).
    grunt.registerTask('default', [ 'exec' ]);
};