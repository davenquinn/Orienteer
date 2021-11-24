const merge = require("webpack-merge");

const modifyConfig = (cfg) => {
  return merge(cfg, {});
};

module.exports = modifyConfig;
