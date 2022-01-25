module.exports = {
  // globals: {
  //   "ts-jest": {
  //     tsConfigFile: "tsconfig.json",
  //     babelConfig: true,
  //   },
  // },
  //automock: true,
  rootDir: "frontend",
  moduleFileExtensions: ["ts", "tsx", "js"],
  testMatch: ["**/*.test.+(ts|tsx|js)"],
  transform: {
    "\\.[jt]sx?$": "babel-jest",
  },
  testEnvironment: "jsdom",
  //setupFilesAfterEnv: ["@testing-library/jest-dom/extend-expect"],
  transformIgnorePatterns: ["(?!d3|d3-array)"],
};
