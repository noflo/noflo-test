var coffeeScript = require('coffeescript');
if (typeof coffeeScript.register !== 'undefined') {
  coffeeScript.register();
}
var tester = require('./lib/test.coffee');
exports.component = tester.component;
