var CoffeeScript = require('coffeescript');

const { compile } = CoffeeScript;
CoffeeScript.compile = function (file, options) {
  compile(file, Object.assign(options, {
    transpile: {
      presets: ["@babel/preset-env"]
    },
  }))
};
CoffeeScript.register();

require('./app-container');
