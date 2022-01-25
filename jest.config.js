const esModules = [
  "d3-array",
  "leaflet",
  "attitude/src",
  "d3-jetpack",
  "d3-selection-multi",
  "kld-intersections",
].join("|");

module.exports = {
  // globals: {
  //   "ts-jest": {
  //     tsConfigFile: "tsconfig.json",
  //     babelConfig: true,
  //   },
  // },
  //automock: true,
  //rootDir: "frontend",
  moduleFileExtensions: ["ts", "tsx", "js"],
  testMatch: ["**/*.test.+(ts|tsx|js)"],
  testEnvironment: "jest-environment-jsdom",
  setupFilesAfterEnv: ["<rootDir>/frontend/tests/mocks.ts"],
  //setupFilesAfterEnv: ["@testing-library/jest-dom/extend-expect"],
  //transformIgnorePatterns: [],
  testPathIgnorePatterns: [
    "<rootDir>/node_modules/",
    "<rootDir>/core/",
    "<rootDir>/__archive",
  ],
  //testEnvironment: "jsdom",
  transform: {
    /* Use babel-jest to transpile tests with the next/babel preset
        https://jestjs.io/docs/configuration#transform-objectstring-pathtotransformer--pathtotransformer-object */
    "^.+\\.(js|jsx|ts|tsx)$": require.resolve("babel-jest"),
  },
  moduleNameMapper: {
    "\\.(css|less|styl)$": "identity-obj-proxy",
    "^app(.*)$": "<rootDir>/frontend/src/$1",
    "@macrostrat/map-components": "@macrostrat/map-components/src",
  },

  transformIgnorePatterns: [
    `node_modules/(?!(${esModules})/)`,
    "^.+\\.module\\.(css|sass|scss|styl)$",
  ],
};
