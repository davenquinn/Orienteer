var fs = require('fs');
var coffee = require('coffeescript');
var babel = require('babel-core');
var preset_react = require('babel-preset-react');
var transformed = false;

function transform() {
  if (transformed) {
    return;
  }

  require.extensions['.coffee'] = require.extensions['.cjsx'] = function(module, filename) {
    var src = fs.readFileSync(filename, {encoding: 'utf8'});
    try {
      src = coffee.compile(src, { 'bare': true });
    } catch (e) {
      throw new Error('Error transforming ' + filename + ' to JSX: ' + e.toString());
    }
    try {
      var opts = {};
      src = babel.transform(src, {filename: filename, ast: false, presets: [preset_react]}).code;
    } catch (e) {
      throw new Error('Error transforming ' + filename + ' to JS: ' + e.toString());
    }

    module._compile(src, filename);
  };

  transformed = true;
}

module.exports = {
  transform: transform
};
