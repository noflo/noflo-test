var Mocha = require('mocha');

module.exports = function (grunt) {
  grunt.registerMultiTask('noflo_test', 'Run NoFlo component tests', function () {
    var options = this.options({
      reporter: 'spec',
      bail: false
    });

    // NoFlo tests are always async
    var done = this.async();

    // Set up Mocha
    var mocha = new Mocha();
    mocha.ui('exports');
    mocha.reporter(options.reporter);
    mocha.suite.bail(options.bail);

    // Register tests
    this.files.forEach(function (f) {
      f.src.filter(function (file) {
        mocha.addFile(file);
      });
    });

    mocha.run(function (failures) {
      if (failures) {
        grunt.fail.warn('Mocha tests failed.');
      }
      done();
    });
  });
};
