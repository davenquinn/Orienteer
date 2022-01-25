// We currently have to jump through hoops to make sure we can work
// with esModules that should not be transpiled.
const esModules = [
  "d3-array",
  "leaflet",
  "attitude/src",
  "d3-jetpack",
  "d3-selection-multi",
  "kld-intersections",
  "@macrostrat/ui-components/node_modules/d3-array",
  "internmap",
].join("|");

module.exports = {
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
