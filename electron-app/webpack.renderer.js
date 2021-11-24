const { merge } = require("webpack-merge");
const { version } = require("electron/package.json");

const modifyConfig = (cfg) => {
  // Modify javascript rule for typescript
  jsRule = cfg.module.rules[0];
  jsRule.test = /\.(js|jsx|ts|tsx)$/;
  jsRule.use.options.presets = [
    ["@babel/preset-env", { modules: false, targets: { electron: version } }],
    "@babel/preset-react",
    "@babel/preset-typescript",
  ];

  return merge(cfg, {});
};

module.exports = modifyConfig;
