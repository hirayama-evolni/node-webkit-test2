module.exports = function(grunt) {
    var _path = require('path');

    grunt.initConfig({
        coffee: {
            all: {
                options: {
//                    bare: true
                },
                files: {
                    'app/main.js': 'app/main.coffee'
                }
            },
        },
        less: {
            all: {
                files: {
                    "app/main.css": "app/main.less"
                }
            }
        },
        watch: {
            files: ['app/main.coffee', 'app/main.less'],
            tasks: ['less', 'coffee']
        },
        compress: {
            app: {
                options: {
                    mode: 'zip',
                    archive: 'app.nw'
                },
                files: [
                    {src: ['package.json',
                           'app/assets/**',
                           'app/index.html',
                           'app/main.js',
                           'app/main.css',
                           'node_modules/clean-css/**',
                           'node_modules/coffee-script/**',
                           'node_modules/csslint/**',
                           'node_modules/jshint/**',
                           'node_modules/uglify-js/**',
                           'node_modules/underscore/**']}
                ]
            }
        },
        dist: {
            all: {
                dest_dir: "dist",
                nw_dir: "node-webkit-v0.5.1-win-ia32",
                exe_name: "nw-test.exe"
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-less');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-compress');

    grunt.registerMultiTask('dist', 'make distribution.', function(){
        var copy = function(src, dest){
            var content = grunt.file.read(src, {encoding: null});
            grunt.file.write(dest, content);
        };

        var dest_dir = this.data.dest_dir;
        var nw_dir = this.data.nw_dir;
        var exe_name = this.data.exe_name;

        // check
        if(!grunt.file.exists(nw_dir)){
            grunt.fail.fatal("nw_dir not exists: "+nw_dir);
        }
        if(!grunt.file.isDir(nw_dir)){
            grunt.fail.fatal("nw_dir is not directory: "+nw_dir);
        }
        if(!grunt.file.exists(nw_dir, 'nw.exe')){
            grunt.fail.fatal("nw_dir not contains nw.exe: "+nw_dir);
        }

        if(!grunt.file.exists(dest_dir)){
            grunt.file.mkdir(dest_dir);
        }

        var files = grunt.file.expand(nw_dir+"/*.dll");
        files.push(nw_dir+"/nw.pak");

        grunt.util._.each(files, function(path){
            var dest_file = _path.join(dest_dir, _path.basename(path));
            copy(path, dest_file);
        });

        var fs = require('fs');
        var src = [_path.join(nw_dir, 'nw.exe'), 'app.nw'];
        var dest = _path.join(dest_dir, exe_name);

        if(fs.existsSync(dest)){
            fs.unlinkSync(dest);
        }
        src.forEach(function(value, index, ary){
            grunt.log.writeln("reading "+value);
            var buf = fs.readFileSync(value);
            grunt.log.writeln("writing to "+dest);
            fs.appendFileSync(dest, buf, {
                encoding: null,
                mode: 0755
            });
        });
    });
    grunt.registerTask('default', ['less', 'coffee', 'compress', 'dist']);
};
